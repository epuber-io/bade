# frozen_string_literal: true

module Bade
  module Runtime
    Location = Struct.new(:path, :lineno, :label, keyword_init: true)

    class RuntimeError < ::StandardError
      # @return [Array<Location>]
      #
      attr_reader :template_backtrace

      # @param [String] msg
      # @param [Array<Location>] template_backtrace
      # @param [Exception, nil] original
      def initialize(msg, template_backtrace = [], original: nil)
        super(msg)
        @template_backtrace = template_backtrace
        @original = original
      end

      def message
        if @template_backtrace.empty?
          super
        else
          <<~MSG.rstrip
            #{super}
            template backtrace:
            #{__formatted_backtrace.join("\n")}
          MSG
        end
      end

      def cause
        @original
      end

      # @return [Array<String>]
      def __formatted_backtrace
        bt = @template_backtrace.reverse

        last = bt.first
        bt.delete_at(0) if last && bt.length > 1 && last == bt[1]

        bt.map do |loc|
          "  #{loc.path || TEMPLATE_FILE_NAME}:#{loc.lineno}:in `#{loc.label}'"
        end
      end
    end

    class KeyError < RuntimeError; end

    class ArgumentError < RuntimeError; end

    TEMPLATE_FILE_NAME = '(__template__)'.freeze

    require_relative 'runtime/block'
    require_relative 'runtime/mixin'
    require_relative 'runtime/render_binding'
    require_relative 'runtime/globals_tracker'
  end
end
