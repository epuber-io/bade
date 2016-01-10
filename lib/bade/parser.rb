# frozen_string_literal: true

require_relative 'ast/node'
require_relative 'ast/document'
require_relative 'ast/node_registrator'

require_relative 'ruby_extensions/string'
require_relative 'ruby_extensions/array'

module Bade
  class Parser
    class SyntaxError < StandardError
      attr_reader :error, :file, :line, :lineno, :column

      def initialize(error, file, line, lineno, column)
        @error = error
        @file = file || '(__TEMPLATE__)'
        @line = line.to_s
        @lineno = lineno
        @column = column
      end

      def to_s
        line = @line.lstrip
        column = @column + line.size - @line.size
        %{#{error}
  #{file}, Line #{lineno}, Column #{@column}
  #{line}
  #{' ' * column}^
}
      end
    end

    class ParserInternalError < StandardError; end

    require_relative 'parser/parser_constants'

    # @type @stacks [Array<Bade::Node>]

    # @return [Array<String>]
    #
    attr_reader :dependency_paths

    # @return [String]
    #
    attr_reader :file_path

    # @param [Fixnum] tabsize
    # @param [String] file_path
    #
    def initialize(tabsize: 4, file_path: nil)
      @line = ''

      @tabsize = tabsize
      @file_path = file_path

      @tab_re = /\G((?: {#{tabsize}})*) {0,#{tabsize-1}}\t/
      @tab = '\1' + ' ' * tabsize

      reset
    end

    # @param [String, Array<String>] str
    # @return [Bade::AST::Document] root node
    #
    def parse(str)
      @document = AST::Document.new(file_path: file_path)
      @root = @document.root

      @dependency_paths = []

      if str.kind_of? Array
        reset(str, [[@root]])
      else
        reset(str.split(/\r?\n/, -1), [[@root]]) # -1 is for not suppressing empty lines
      end

      parse_line while next_line

      reset

      @document
    end

    # Calculate indent for line
    #
    # @param [String] line
    #
    # @return [Int] indent size
    #
    def get_indent(line)
      line.get_indent(@tabsize)
    end

    # Append element to stacks and result tree
    #
    # @param [Symbol] type
    #
    def append_node(type, indent: @indents.length, add: false, value: nil)
      while indent >= @stacks.length
        @stacks << @stacks.last.dup
      end

      parent = @stacks[indent].last
      node = AST::NodeRegistrator.create(type, @lineno)
      parent.children << node

      node.value = value unless value.nil?

      if add
        @stacks[indent] << node
      end

      node
    end

    # @return [Array<AST::Node>]
    #
    def remove_last_newlines
      last_node = @stacks.last.last
      last_newlines_count = last_node.children.rcount_matching { |n| n.type == :newline }
      last_node.children.pop(last_newlines_count)
    end

    def parse_import
      path = eval(@line)
      append_node(:import, value: path)

      @dependency_paths << path unless @dependency_paths.include?(path)
    end

    # @param value [String]
    #
    def fixed_trailing_colon(value)
      if String === value && value.end_with?(':')
        value = value.remove_last
        @line.prepend(':')
      end

      value
    end

    # ----------- Errors ---------------

    # Raise specific error
    #
    # @param [String] message
    #
    def syntax_error(message)
      column = @orig_line && @line ? @orig_line.size - @line.size : 0
      raise SyntaxError.new(message, file_path, @orig_line, @lineno, column)
    end

    require_relative 'parser/parser_lines'
    require_relative 'parser/parser_tag'
    require_relative 'parser/parser_mixin'
    require_relative 'parser/parser_ruby_code'
    require_relative 'parser/parser_text'
  end
end
