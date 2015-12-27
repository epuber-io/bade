# frozen_string_literal: true

module Bade
  module AST
    class TagNode < Node
      # @return [String]
      #
      attr_accessor :name

      # @return [Array<TagAttributeNode>]
      #
      def attributes
        children.select { |n| n.type == :tag_attribute }
      end
    end
  end
end
