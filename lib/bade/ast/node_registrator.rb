# frozen_string_literal: true


module Bade
  module AST
    class NodeRegistrator
      require_relative 'node/key_value_node'
      require_relative 'node/tag_node'
      require_relative 'node/value_node'
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

      register_type ValueNode, :text
      register_type ValueNode, :newline
      register_type ValueNode, :ruby_code

      register_type Node, :comment
      register_type Node, :html_comment

      register_type TagNode, :tag
      register_type KeyValueNode, :tag_attribute

      register_type ValueNode, :output

      register_type ValueNode, :mixin_param
      register_type ValueNode, :mixin_block_param
      register_type MixinBlockNode, :mixin_block

      register_type MixinCallNode, :mixin_call
      register_type MixinDeclarationNode, :mixin_declaration
      register_type KeyValueNode, :mixin_key_param

      register_type DoctypeNode, :doctype

      register_type ValueNode, :import
    end
  end
end
