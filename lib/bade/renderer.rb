# frozen_string_literal: true

require_relative 'node'
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

    # @param file [String, File]
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
      @parsed ||= _parsed_document(source_text, file_path)
    end

    # @return [String]
    #
    def lambda_string(new_line: '\n', indent: '  ')
      RubyGenerator.document_to_lambda_string(root_document, new_line: new_line, indent: indent)
    end


    # ----------------------------------------------------------------------------- #
    # Render

    # @return [String]
    #
    def render(binding: nil, new_line: '\n', indent: '  ')
      lambda_str = lambda_string(new_line: new_line, indent: indent)
      scope = binding || Runtime::RenderBinding.new(locals || {}).get_binding

      lambda_instance = eval(lambda_str, scope, file_path || '(__template__)')
      lambda_instance.call
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
