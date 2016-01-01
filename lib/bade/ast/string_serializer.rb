# frozen_string_literal: true


module Bade
  module AST
    class StringSerializer
      # @return [AST::Node, AST::Document]
      #
      attr_reader :root

      # @param [AST::Node, AST::Document] root
      #
      def initialize(root)
        @root = root
      end

      def to_s
        case root
        when Node
          node_to_s(root, 0)
        when Document
          node_to_s(root.root, 0)
        else
          raise AttributeError, "Root attribute passed into initializer must be subclass of #{Node} or #{Document}, is #{root.class}!"
        end
      end

      # @param [Node] node
      # @param [Fixnum] level
      #
      # @return [String]
      #
      def node_to_s(node, level)
        type_s = node.type.inspect
        indent = '  ' * level

        children_s = ''
        if node.children.count > 0
          children_s = "\n" + node.children.map { |n| node_to_s(n, level + 1) }.join("\n")
        end

        other = ''

        case node
        when TagNode
          other = node.name
        when KeyValueNode
          other = "#{node.name}:#{node.value}"
        when ValueNode
          other = node.value || ''
        when MixinCommonNode
          other = node.name
        else
          # nothing
        end

        other = ' ' + other if other.length > 0

        "#{indent}(#{type_s}#{other}#{children_s})"
      end
    end
  end
end
