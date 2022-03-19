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

      # @return [String, nil]
      #
      attr_accessor :default_value

      ruby2_keywords def initialize(*args)
        super(*args)

        @escaped = false
        @conditional = false
        @default_value = nil
      end

      # @param [ValueNode] other
      #
      def ==(other)
        super &&
          value == other.value &&
          escaped == other.escaped &&
          conditional == other.conditional &&
          default_value == other.default_value
      end
    end
  end
end
