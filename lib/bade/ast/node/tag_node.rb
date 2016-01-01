# frozen_string_literal: true

module Bade
  module AST
    class TagNode < Node
      # @return [String]
      #
      attr_accessor :name

      # @param [TagNode] other
      #
      def ==(other)
        super && name == other.name
      end

      # @return [Array<KeyValueNode>]
      #
      def attributes
        children.select { |n| n.type == :tag_attr }
      end
    end
  end
end
