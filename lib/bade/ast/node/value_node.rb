# frozen_string_literal: true

module Bade
  module AST
    class ValueNode < Node
      # @return [String]
      #
      attr_accessor :value

      # @return [Bool]
      #
      attr_accessor :escaped

      # @return [Bool]
      #
      attr_accessor :conditional

      def initialize(*args)
        super

        @escaped = false
        @conditional = false
      end

      # @param [ValueNode] other
      #
      def ==(other)
        super && value == other.value && escaped == other.escaped && conditional == other.conditional
      end
    end
  end
end
