# frozen_string_literal: true

require_relative 'parser'
require_relative 'generator'
require_relative 'runtime'


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

    # @param [String] precompiled
    # @param [File] file_path
    #
    # @return [self]
    #
    def self.from_precompiled(precompiled, file_path = nil)
      inst = new
      inst.lambda_string = precompiled
      inst.file_path = file_path
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
      self.locals = locals
      self
    end


    # ----------------------------------------------------------------------------- #
    # Getters

    # @return [Bade::Node]
    #
    def root_document
      @root_document ||= _parsed_document(source_text, file_path)
    end

    # @return [String]
    #
    def precompiled
      lambda_string
    end

    # @return [String]
    #
    attr_accessor :lambda_string

    # @return [String]
    #
    def lambda_string
      @lambda_string ||= Generator.document_to_lambda_string(root_document)
    end


    # ----------------------------------------------------------------------------- #
    # Render

    # @return [String]
    #
    def render(binding: nil, new_line: nil, indent: nil)
      lambda_str = lambda_string
      scope = binding || Runtime::RenderBinding.new(locals || {}).get_binding

      lambda_instance = eval(lambda_str, scope, file_path || '(__template__)')

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
