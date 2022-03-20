# frozen_string_literal: true

require_relative '../ruby2_keywords'

module Bade
  module Runtime
    class Block
      class MissingBlockDefinitionError < RuntimeError
        # @return [String]
        #
        attr_accessor :name

        # @return [Symbol] context of missing block, allowed values are :render and :call
        #
        attr_accessor :context

        def initialize(name, context, msg, template_backtrace)
          super(msg, template_backtrace)

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

      # @return [RenderBinding::Location, nil]
      #
      attr_reader :location

      # @return [RenderBinding]
      #
      attr_reader :render_binding

      # @param [String] name  name of the block
      # @param [RenderBinding::Location, nil] location
      # @param [RenderBinding] render_binding  reference to current binding instance
      # @param [Proc] block  reference to lambda
      #
      def initialize(name, location, render_binding, &block)
        @name = name
        @location = location
        @render_binding = render_binding
        @block = block
      end

      # --- Calling methods

      # Calls the block and adds rendered content into current buffer stack.
      #
      # @return [Void]
      ruby2_keywords def call(*args)
        call!(*args) unless @block.nil?
      end

      # Calls the block and adds rendered content into current buffer stack.
      #
      # @return [Void]
      ruby2_keywords def call!(*args)
        raise MissingBlockDefinitionError.new(name, :call, nil, render_binding.__location_stack) if @block.nil?

        __call(*args)
      end

      # --- Rendering methods

      # Calls the block and returns rendered content in string.
      #
      # Returns empty string when there is no block.
      #
      # @return [String]
      def render(*args)
        if @block.nil?
          ''
        else
          render!(*args)
        end
      end

      # Calls the block and returns rendered content in string.
      #
      # Throws error when there is no block.
      #
      # @return [String]
      def render!(*args)
        raise MissingBlockDefinitionError.new(name, :render, nil, render_binding.__location_stack) if @block.nil?

        loc = location.dup
        render_binding.__buffs_push(loc)

        @block.call(*args)

        render_binding.__buffs_pop&.join || ''
      end

      # Calls the block and adds rendered content into current buffer stack.
      #
      # @return [Void]
      ruby2_keywords def __call(*args)
        loc = location.dup
        render_binding.__buffs_push(loc)

        @block.call(*args)

        res = render_binding.__buffs_pop
        render_binding.__buff&.concat(res) if !res.nil? && !res.empty?
      end
    end
  end
end
