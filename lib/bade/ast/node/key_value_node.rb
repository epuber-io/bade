# frozen_string_literal: true

module Bade
  module AST
    class KeyValueNode < Node
      # @return [String]
      #
      attr_accessor :name

      # @return [Any]
      #
      attr_accessor :value

      def to_s
        "#{name}:#{value}"
      end

      # @param other [KeyValueNode]
      #
      def ==(other)
        super && name == other.name && value == other.value
      end
    end
  end
end
