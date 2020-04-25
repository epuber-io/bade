# frozen_string_literal: true

require 'ruby2_keywords'

module Bade
  module AST
    class StaticTextNode < Node
      # @return [String]
      #
      attr_accessor :value

      # @return [Bool]
      #
      attr_accessor :escaped

      ruby2_keywords def initialize(*args)
        super(*args)

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
