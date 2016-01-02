# frozen_string_literal: true

require_relative 'block'

module Bade
  module Runtime
    class RenderBinding
      class KeyError < ::StandardError; end

      # @param vars [Hash]
      #
      def initialize(vars = {})
        vars.each do |key, value|
          define_singleton_method(key) do
            value
          end
        end
      end

      # @return [Binding]
      #
      def __get_binding
        binding
      end

      # Shortcut for creating blocks
      #
      def __create_block(*args, &block)
        Bade::Runtime::Block.new(*args, &block)
      end

      def __create_mixin(*args, &block)
        Bade::Runtime::Mixin.new(*args, &block)
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
