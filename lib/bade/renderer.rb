# frozen_string_literal: true

require 'pathname'
require_relative 'parser'
require_relative 'generator'
require_relative 'runtime'
require_relative 'precompiled'


module Bade
  class Renderer
    class LoadError < Bade::Runtime::RuntimeError
      # @return [String]
      #
      attr_reader :loading_path

      # @return [String]
      #
      attr_reader :reference_path

      # @param [String] loading_path  currently loaded path
      # @param [String] reference_path  reference file from which is load performed
      # @param [String] msg  standard message
      #
      def initialize(loading_path, reference_path, msg, template_backtrace = [])
        super(msg, template_backtrace)
        @loading_path = loading_path
        @reference_path = reference_path
      end
    end

    class << self
      def _globals_tracker
        @globals_tracker ||= Bade::Runtime::GlobalsTracker.new
      end

      # When set to true it will remove all constants that template created. Off by default.
      #
      # @return [Boolean]
      attr_accessor :clear_constants
    end

    # @param clear_constants [Boolean] When set to true it will remove all constants that template created. Off by default.
    def initialize(clear_constants: Bade::Renderer.clear_constants)
      @optimize = false
      @clear_constants = clear_constants
    end

    # @return [String]
    #
    attr_accessor :source_text

    # @return [String]
    #
    attr_accessor :file_path

    # @return [Hash]
    #
    attr_accessor :locals

    # @return [Binding]
    #
    attr_accessor :lambda_binding

    # @return [RenderBinding]
    #
    attr_accessor :render_binding

    # @return [Bool]
    #
    attr_accessor :optimize

    # @return [Boolean] When set to true it will remove all constants that template created. Off by default.
    #
    attr_accessor :clear_constants


    # ----------------------------------------------------------------------------- #
    # Internal attributes

    # @return [Hash<String, Document>] absolute path => document
    #
    def parsed_documents
      @parsed_documents ||= {}
    end


    # ----------------------------------------------------------------------------- #
    # Factory methods

    # @param [String] source  source string that should be parsed
    #
    # @return [Renderer] preconfigured instance of this class
    #
    def self.from_source(source, file_path = nil, clear_constants: Bade::Renderer.clear_constants)
      inst = new(clear_constants: clear_constants)
      inst.source_text = source
      inst.file_path = file_path
      inst
    end

    # @param [String, File] file  file path or file instance, file that should be loaded and parsed
    #
    # @return [Renderer] preconfigured instance of this class
    #
    def self.from_file(file, clear_constants: Bade::Renderer.clear_constants)
      path = if file.is_a?(File)
               file.path
             else
               file
             end

      from_source(nil, path, clear_constants: clear_constants)
    end

    # Method to create Renderer from Precompiled object, for example when you want to reuse precompiled object from disk
    #
    # @param [Precompiled] precompiled
    #
    # @return [Renderer] preconfigured instance of this class
    #
    def self.from_precompiled(precompiled, clear_constants: Bade::Renderer.clear_constants)
      inst = new(clear_constants: clear_constants)
      inst.precompiled = precompiled
      inst
    end

    # ----------------------------------------------------------------------------- #
    # DSL methods


    # @param locals [Hash]
    #
    # @return [self]
    #
    def with_locals(locals = {})
      self.render_binding = nil

      self.locals = locals
      self
    end

    # @return [self]
    def with_binding(binding)
      self.lambda_binding = binding
      self
    end

    # @param [RenderBinding] binding
    # @return [self]
    def with_render_binding(binding)
      self.lambda_binding = nil
      self.render_binding = binding
      self
    end

    def optimized
      self.optimize = true
      self
    end


    # ----------------------------------------------------------------------------- #
    # Getters

    # @return [Bade::AST::Node]
    #
    def root_document
      @root_document ||= _parsed_document(source_text, file_path)
    end

    # @return [Precompiled]
    #
    attr_writer :precompiled

    # @return [Precompiled]
    #
    def precompiled
      @precompiled ||=
        Precompiled.new(Generator.document_to_lambda_string(root_document, optimize: @optimize), file_path)
    end

    # @return [String]
    #
    def lambda_string
      precompiled.code_string
    end

    # @return [RenderBinding]
    #
    # rubocop:disable Lint/DuplicateMethods
    def render_binding
      @render_binding ||= Runtime::RenderBinding.new(locals || {})
    end
    # rubocop:enable Lint/DuplicateMethods

    # @return [Proc]
    #
    def lambda_instance
      _catching_globals do
        if lambda_binding
          lambda_binding.eval(lambda_string, file_path || Bade::Runtime::TEMPLATE_FILE_NAME)
        else
          render_binding.instance_eval(lambda_string, file_path || Bade::Runtime::TEMPLATE_FILE_NAME)
        end
      end
    end

    # ----------------------------------------------------------------------------- #
    # Render

    # @param [Binding] binding  custom binding for evaluating the template, but it is not recommended to use,
    #                           use :locals and #with_locals instead
    # @param [String] new_line  newline string, default is \n
    # @param [String] indent  indent string, default is two spaces
    #
    # @return [String] rendered content of template
    #
    def render(binding: nil, new_line: nil, indent: nil)
      self.lambda_binding = binding unless binding.nil? # backward compatibility

      run_vars = {
        Generator::NEW_LINE_NAME.to_sym => new_line,
        Generator::BASE_INDENT_NAME.to_sym => indent,
      }
      run_vars.compact! # remove nil values

      begin
        return _catching_globals do
          lambda_instance.call(**run_vars)
        end
      rescue Bade::Runtime::RuntimeError => e
        raise e
      rescue StandardError => e
        msg = "Exception raised during execution of template: #{e}"
        raise Bade::Runtime::RuntimeError.new(msg, render_binding.__location_stack, original: e)
      ensure
        self.class._globals_tracker.clear_constants if @clear_constants
      end
    end

    private

    # @param [String] content  source code of the template
    # @param [String] file_path  reference path to template file
    #
    # @return [Bade::AST::Document]
    #
    def _parsed_document(content, file_path)
      if file_path.nil? && content.nil?
        raise LoadError.new(nil, file_path, "Don't know what to do with nil values for both content and path")
      end

      content = if !file_path.nil? && content.nil?
                  File.read(file_path)
                else
                  content
                end

      parsed_document = parsed_documents[file_path]
      return parsed_document unless parsed_document.nil?

      parser = Parser.new(file_path: file_path)
      document = parser.parse(content)

      parser.dependency_paths.each do |path|
        new_path = _find_file!(path, file_path)
        next if new_path.nil?

        document.sub_documents << _parsed_document(nil, new_path)
      end

      document
    end

    # Tries to find file with name, if no file could be found or there are multiple files matching the name error is
    # raised
    #
    # @param [String] name  name of the file that should be found
    # @param [String] reference_path  path to file from which is loading/finding
    #
    # @return [String, nil] returns nil when this file should be skipped otherwise absolute path to file
    #
    def _find_file!(name, reference_path)
      sub_path = File.expand_path(name, File.dirname(reference_path))

      if File.exist?(sub_path)
        return if sub_path.end_with?('.rb') # handled in Generator

        sub_path
      else
        bade_path = "#{sub_path}.bade"
        rb_path = "#{sub_path}.rb"

        bade_exist = File.exist?(bade_path)
        rb_exist = File.exist?(rb_path)
        relative = Pathname.new(reference_path).relative_path_from(Pathname.new(File.dirname(file_path))).to_s

        if bade_exist && rb_exist
          message = "Found both .bade and .rb files for `#{name}` in file #{relative}, "\
                    'change the import path so it references uniq file.'
          raise LoadError.new(name, reference_path, message)
        elsif bade_exist
          return bade_path
        elsif rb_exist
          return # handled in Generator
        else
          message = "Can't find file matching name `#{name}` referenced from file #{relative}"
          raise LoadError.new(name, reference_path, message)
        end
      end
    end

    def _catching_globals(&block)
      if @clear_constants
        self.class._globals_tracker.catch(&block)
      else
        block.call
      end
    end
  end
end

# Set default value to clear_constants
Bade::Renderer.clear_constants = false
