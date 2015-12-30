# frozen_string_literal: true

require_relative 'parser'
require_relative 'generator'
require_relative 'runtime'
require_relative 'precompiled'


module Bade
  class Renderer
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

    # @param source [String]
    #
    # @return [self]
    #
    def self.from_source(source, file_path = nil)
      inst = new
      inst.source_text = source
      inst.file_path = file_path
      inst
    end

    # @param [String, File] file
    #
    # @return [self]
    #
    def self.from_file(file)
      path = if file.is_a?(File)
               file.path
             else
               file
             end

      from_source(nil, path)
    end

    # @param [Precompiled] precompiled
    # @param [File] file_path
    #
    # @return [self]
    #
    def self.from_precompiled(precompiled)
      inst = new
      inst.precompiled = precompiled
      inst
    end


    def initialize
      # absolute path => document
      @parsed_documents = {}
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

    def with_binding(binding)
      self.lambda_binding = binding
      self
    end


    # ----------------------------------------------------------------------------- #
    # Getters

    # @return [Bade::Node]
    #
    def root_document
      @root_document ||= _parsed_document(source_text, file_path)
    end


    attr_writer :precompiled

    # @return [Precompiled]
    #
    def precompiled
      @precompiled ||= Precompiled.new(Generator.document_to_lambda_string(root_document), file_path)
    end

    # @return [String]
    #
    def lambda_string
      precompiled.code_string
    end

    # @return [RenderBinding]
    #
    def render_binding
      @render_binding ||= Runtime::RenderBinding.new(locals || {})
    end

    # @return [Binding]
    #
    def lambda_binding
      @lambda_binding || render_binding.get_binding
    end

    # @return [Proc]
    #
    def lambda_instance
      if @lambda_binding
        @lambda_binding.eval(lambda_string, file_path || '(__template__)')
      else
        render_binding.instance_eval(lambda_string, file_path || '(__template__)')
      end
    end

    # ----------------------------------------------------------------------------- #
    # Render

    # @return [String]
    #
    def render(binding: nil, new_line: nil, indent: nil)
      self.lambda_binding = binding unless binding.nil? # backward compatibility

      run_vars = {}
      run_vars[Generator::NEW_LINE_NAME.to_sym] = new_line unless new_line.nil?
      run_vars[Generator::BASE_INDENT_NAME.to_sym] = indent unless indent.nil?
      lambda_instance.call(**run_vars)
    end



    private

    # @param file_path [String]
    #
    # @return [Bade::Document]
    #
    def _parsed_document(content, file_path)
      content = if file_path.nil? && content.nil?
                  raise LoadError, "Don't know what to do with nil values for both content and path"
                elsif !file_path.nil? && content.nil?
                  File.read(file_path)
                else
                  content
                end

      parsed_document = @parsed_documents[file_path]
      return parsed_document unless parsed_document.nil?

      parser = Parser.new(file_path: file_path)

      document = parser.parse(content)

      parser.dependency_paths.each do |path|
        sub_path = File.expand_path(path, File.dirname(file_path))
        new_path = if File.exists?(sub_path)
                     sub_path
                   elsif File.exists?("#{sub_path}.bade")
                     "#{sub_path}.bade"
                   end

        document.sub_documents << _parsed_document(nil, new_path)
      end

      document
    end
  end
end
