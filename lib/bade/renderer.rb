
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
    def self.from_source(source)
      inst = new
      inst.source_text = source
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

      inst = new
      inst.source_text = file_obj.read
      inst.file_path = file_obj.path
      inst
    end

    # @param locals [Hash]
    #
    # @return [self]
    #
    def with_locals(locals = {})
      self.locals = locals
      self
    end

    # @return [Bade::Node]
    #
    def root_node
      @parsed ||= Parser.new.parse(source_text)
    end

    # @return [String]
    #
    def lambda_string(new_line: '\n', indent: '  ')
      RubyGenerator.node_to_lambda_string(root_node, new_line: new_line, indent: indent)
    end

    # @return [String]
    #
    def render(binding: nil, new_line: '\n', indent: '  ')
      lambda_str = lambda_string(new_line: new_line, indent: indent)
      scope = binding || Runtime::RenderBinding.new(locals || {}).get_binding

      lambda_instance = eval(lambda_str, scope, file_path || '(__template__)')
      lambda_instance.call
    end
  end
end
