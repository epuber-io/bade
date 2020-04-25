# frozen_string_literal: true

require_relative '../../ruby2_keywords'

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

      ruby2_keywords def initialize(*args)
        super(*args)

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
