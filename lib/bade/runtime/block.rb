# frozen_string_literal: true

module Bade
  module Runtime
    class RuntimeError < ::StandardError; end

    class Block

      # @return [Proc]
      #
      attr_reader :block

      # @return [String]
      #
      attr_reader :name

      # @param [String] name
      #
      def initialize(name, &block)
        @name = name
        @block = block
      end

      def call(*args)
        call!(*args) unless @block.nil?
      end

      def call!(*args)
        if @block.nil?
          raise RuntimeError, "Block `#{@name}` must have block definition"
        else
          @block.call(*args)
        end
      end
    end
  end
end
