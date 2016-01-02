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
        __call(*args) unless @block.nil?
      end

      def call!(*args)
        if @block.nil?
          raise RuntimeError, "Block `#{@name}` must have block definition"
        else
          __call(*args)
        end
      end

      def __call(*args)
        begin
          @block.call(*args)
        rescue ArgumentError => e
          if e.message =~ /wrong number of arguments \(given ([0-9]+), expected ([0-9]+)\)/
            given = $1.to_i - 1
            expected = $2.to_i - 1
            raise ArgumentError, "wrong number of arguments (given #{given}, expected #{expected}) for #{self.class.name.split('::').last.downcase} `#{name}`"
          else
            raise
          end
        end
      end
    end
  end
end
