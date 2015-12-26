# frozen_string_literal: true

require_relative 'parser'
require_relative 'ruby_extensions/object'


module Bade
  class Node
    # --- MAIN INFO ---

    # @return [Symbol] type of this node
    #
    attr_reader :type

    # @return [Array<Bade::Node>]
    #
    attr_reader :children

    # --- METADATA ---

    # @return [Int] line number
    #
    attr_reader :lineno

    def initialize(type, lineno: nil)
      @type = type
      @children = []

      @lineno = lineno
    end

    def to_s
      "#<#{self.class} #{type.inspect}>"
    end

    def inspect
      to_s
    end
  end

  class NodeRegistrator
    require_relative 'node/key_value_node'
    require_relative 'node/tag_node'
    require_relative 'node/text_node'
    require_relative 'node/mixin_node'
    require_relative 'node/doctype_node'

    class << self
      # @return [Hash<Symbol, Class>]
      def registered_types
        @registered_types ||= {}
      end

      # @param [Symbol] type
      # @param [Class] klass  registering class
      #
      def register_type(klass, type)
        raise StandardError, "Class #{klass} should be subclass of #{self}" unless klass <= Node

        registered_types[type] = klass
      end

      # @return [Node]
      #
      def create(type, lineno)
        klass = registered_types[type]

        if klass.nil?
          raise Parser::ParserInternalError, "undefined node type #{type.inspect}"
        end

        klass.new(type, lineno: lineno)
      end
    end

    register_type TextNode, :text
    register_type TextNode, :newline
    register_type TextNode, :ruby_code

    register_type Node, :comment
    register_type Node, :html_comment

    register_type TagNode, :tag
    register_type KeyValueNode, :tag_attribute

    register_type TextNode, :output

    register_type TextNode, :mixin_param
    register_type TextNode, :mixin_block_param
    register_type MixinBlockNode, :mixin_block

    register_type MixinCallNode, :mixin_call
    register_type MixinDeclarationNode, :mixin_declaration
    register_type KeyValueNode, :mixin_key_param

    register_type DoctypeNode, :doctype

    register_type TextNode, :import
  end
end
