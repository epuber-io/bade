# frozen_string_literal: true

require_relative 'block'

module Bade
  module Runtime
    class RenderBinding
      class KeyError < ::StandardError; end

      # @return [Array<Array<String>>]
      #
      attr_accessor :__buffs_stack

      # @return [Hash<String, Mixin>]
      #
      attr_accessor :__mixins

      # Holds
      # @return [String]
      #
      attr_accessor :__new_line, :__base_indent

      # @param vars [Hash]
      #
      def initialize(vars = {})
        __reset

        vars.each do |key, value|
          raise KeyError, "Already defined variable #{key.inspect} in this binding" if respond_to?(key.to_sym)

          define_singleton_method(key) do
            value
          end
        end
      end

      # Resets this binding to default state, this method should be envoked after running the template lambda
      #
      # @return [nil]
      #
      def __reset
        @__buffs_stack = [[]]
        @__mixins = Hash.new { |_hash, key| raise "Undefined mixin '#{key}'" }
      end

      # @return [Binding]
      #
      def __get_binding
        binding
      end

      # Shortcut for creating blocks
      #
      def __create_block(name, &block)
        Bade::Runtime::Block.new(name, self, &block)
      end

      def __create_mixin(name, &block)
        Bade::Runtime::Mixin.new(name, self, &block)
      end

      # --- Methods for dealing with pushing and poping buffers in stack

      def __buff
        __buffs_stack.last
      end

      def __buffs_push
        __buffs_stack.push([])
      end

      def __buffs_pop
        __buffs_stack.pop
      end

      # Escape input text with html escapes
      #
      # @param [String] text
      #
      # @return [String]
      #
      def __html_escaped(text)
        text.sub('&', '&amp;')
            .sub('<', '&lt;')
            .sub('>', '&gt;')
            .sub('"', '&quot;')
      end

      def __tag_render_attribute(name, *values)
        values = values.compact
        return if values.empty?

        %Q{ #{name}="#{values.join(' ')}"}
      end
    end
  end
end
