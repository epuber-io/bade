# frozen_string_literal: true

require_relative '../ruby2_keywords'

module Bade
  module Runtime
    class RuntimeError < ::StandardError; end

    class Block
      class MissingBlockDefinitionError < RuntimeError
        # @return [String]
        #
        attr_accessor :name

        # @return [Symbol] context of missing block, allowed values are :render and :call
        #
        attr_accessor :context

        def initialize(name, context, msg = nil)
          super()

          self.name = name
          self.context = context

          @message = msg
        end

        def message
          @message || "Block `#{name}` must have block definition to #{context}."
        end
      end

      # @return [Proc]
      #
      attr_reader :block

      # @return [String]
      #
      attr_reader :name

      # @return [RenderBinding]
      #
      attr_reader :render_binding

      # @param [String] name  name of the block
      # @param [RenderBinding] render_binding  reference to current binding instance
      # @param [Proc] block  reference to lambda
      #
      def initialize(name, render_binding, &block)
        @name = name
        @render_binding = render_binding
        @block = block
      end

      # --- Calling methods

      ruby2_keywords def call(*args)
        call!(*args) unless @block.nil?
      end

      ruby2_keywords def call!(*args)
        raise MissingBlockDefinitionError.new(name, :call) if @block.nil?

        render_binding.__buff.concat(@block.call(*args))
      end

      # --- Rendering methods

      def render(*args)
        if @block.nil?
          ''
        else
          render!(*args)
        end
      end

      def render!(*args)
        raise MissingBlockDefinitionError.new(name, :render) if @block.nil?

        @block.call(*args).join
      end
    end
  end
end
