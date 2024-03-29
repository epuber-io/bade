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
          msg = "Root attribute passed into initializer must be subclass of #{Node} or #{Document}, is #{root.class}!"
          raise AttributeError, msg
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
          children_s = "\n#{node.children.map { |n| node_to_s(n, level + 1) }.join("\n")}\n#{indent}"
        end

        other = ''

        case node
        when TagNode, MixinCommonNode
          other = node.name
        when KeyValueNode
          other = "#{node.name}:#{node.value}"
        when ValueNode, StaticTextNode
          escaped_sign = if node.escaped
                           '& '
                         elsif node.escaped.nil?
                           '&(nil) '
                         else
                           ''
                         end
          other = "#{escaped_sign}#{node.value}"
        when Node
          # nothing
        else
          raise "Unknown node class #{node.class} of type #{node.type} for serializing"
        end

        other = " #{other}" if other && !other.empty?

        "#{indent}(#{type_s}#{other}#{children_s})"
      end
    end
  end
end
