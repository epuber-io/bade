# frozen_string_literal: true


module Bade
  module AST
    class Node
      # --- MAIN INFO ---

      # @return [Symbol] type of this node
      #
      attr_reader :type

      # @return [Bade::AST::Node, nil]
      #
      attr_accessor :parent

      # @return [Array<Bade::AST::Node>]
      #
      attr_accessor :children

      # --- METADATA ---

      # @return [Int] line number
      #
      attr_reader :lineno

      # @return [String] filename
      #
      attr_reader :filename

      def initialize(type, parent = nil, lineno: nil, filename: nil)
        @type = type
        @parent = parent
        @children = []
        @lineno = lineno
        @filename = filename
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
        return false unless self.class == other.class

        type == other.type && children == other.children
      end
    end
  end
end
