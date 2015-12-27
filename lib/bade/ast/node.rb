# frozen_string_literal: true


module Bade
  module AST
    class Node
      # --- MAIN INFO ---

      # @return [Symbol] type of this node
      #
      attr_reader :type

      # @return [Array<Bade::Node>]
      #
      attr_reader :children

      # --- METADATA ---

      # @return [Int] line number
      #
      attr_reader :lineno

      def initialize(type, lineno: nil)
        @type = type
        @children = []

        @lineno = lineno
      end

      def to_s
        require_relative 'string_serializer'
        StringSerializer.new(self).to_s
      end

      def inspect
        to_s
      end

      # @param other [Node]
      #
      # @return [Bool]
      #
      def ==(other)
        return false unless Node === other

        type == other.type && children == other.children
      end
    end
  end
end
