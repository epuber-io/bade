# frozen_string_literal: true

module Bade
  module AST
    class StaticTextNode < Node
      # @return [String]
      #
      attr_accessor :value

      # @return [Bool]
      #
      attr_accessor :escaped

      def initialize(*args)
        super

        @escaped = false
      end

      # @param [ValueNode] other
      #
      def ==(other)
        super && value == other.value && escaped == other.escaped
      end
    end
  end
end
