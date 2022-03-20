# frozen_string_literal: true

module Bade
  module Runtime
    Location = Struct.new(:path, :lineno, :label, keyword_init: true) do
      def to_s
        "  #{path || TEMPLATE_FILE_NAME}:#{lineno}:in `#{label}'"
      end
    end

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
        bt = @template_backtrace

        # delete first location if is same as second (can happen when arguments are incorrect)
        last = bt.first
        bt.delete_at(0) if last && bt.length > 1 && last == bt[1]

        bt.map(&:to_s)
      end

      # @param [Array<Thread::Backtrace::Location>, nil] locations
      def self.process_locations(locations)
        return [] if locations.nil?

        index = locations&.find_index { |loc| loc.path == TEMPLATE_FILE_NAME || loc.path&.include?('.bade') }
        return [] if index.nil?

        new_locations = locations[0...index] || []

        new_locations.map do |loc|
          Location.new(path: loc.path, lineno: loc.lineno, label: loc.label)
        end
      end

      # @param [String] msg
      # @param [Exception] error
      # @param [Array<Location>] template_backtrace
      # @return [RuntimeError]
      def self.wrap_existing_error(msg, error, template_backtrace)
        locs = Bade::Runtime::RuntimeError.process_locations(error.backtrace_locations) + template_backtrace
        Bade::Runtime::RuntimeError.new(msg, locs, original: error)
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
