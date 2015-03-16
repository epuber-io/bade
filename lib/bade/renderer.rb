
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
      file_obj = if file.is_a?(String)
                   File.new(file, 'r')
                 else
                   file
                 end

      from_source(file_obj.read, file_obj.path)
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
      @parsed ||= (
        if file_path.nil?
          _parse_document_from_text(source_text)
        else
          _parse_document_from_file(file_path)
        end
      )
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
    def _parse_document_from_file(file_path)
      parser = Parser.new(file_path: file_path)

      new_path = if File.exists?(file_path)
               file_path
             elsif File.exists?("#{file_path}.bade")
               "#{file_path}.bade"
             end

      raise "Not existing file with path #{file_path}" if new_path.nil?

      parsed_document = @parsed_documents[new_path]
      return parsed_document unless parsed_document.nil?

      document = parser.parse(File.read(new_path))

      parser.dependency_paths.each do |path|
        sub_path = File.expand_path(path, File.dirname(new_path))
        document.sub_documents << _parse_document_from_file(sub_path)
      end

      document
    end

    # @param text [String]
    #
    # @return [Bade::Document]
    #
    def _parse_document_from_text(text)
      parser = Parser.new
      document = parser.parse(text)

      raise 'You cannot use import when it is loaded from source text' if parser.dependency_paths.length > 0

      document
    end
  end
end
