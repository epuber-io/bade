# frozen_string_literal: true

module Bade
  module Runtime
    Location = Struct.new(:path, :lineno, :label, keyword_init: true) do
      def template?
        path == TEMPLATE_FILE_NAME || path&.include?('.bade')
      end

      def to_s
        "#{path || TEMPLATE_FILE_NAME}:#{lineno}:in `#{label}'"
      end
    end

    class RuntimeError < ::StandardError
      # @return [Array<Location>]
      #
      attr_reader :template_backtrace

      # @return [Boolean]
      #
      attr_reader :print_locations_warning

      # @param [String] msg
      # @param [Array<Location>] template_backtrace
      # @param [Exception, nil] original
      def initialize(msg, template_backtrace = [], original: nil, print_locations_warning: false)
        super(msg)
        @template_backtrace = template_backtrace
        @original = original
        @print_locations_warning = print_locations_warning
      end

      def message
        if @template_backtrace.empty?
          super
        else
          warning = if print_locations_warning
                      <<~TEXT

                        !!! WARNING !!!, filenames and line numbers of functions can be misleading due to using Ruby
                        functions in different Bade file. Trust only functions names. Mixins are fine.

                        This will be fixed in https://github.com/epuber-io/bade/issues/32
                      TEXT
                    else
                      ''
                    end

          <<~MSG.rstrip
            #{super}
            template backtrace:
            #{__formatted_backtrace.join("\n")}
            #{warning}
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

        bt.map { |loc| "  #{loc}" }
      end

      # @param [Array<Thread::Backtrace::Location>, nil] locations
      def self.process_locations(locations)
        return [] if locations.nil?

        # map to Bade's Location
        new_locations = locations.map { |loc| Location.new(path: loc.path, lineno: loc.lineno, label: loc.label) }

        # find location to use or drop
        index = new_locations.rindex(&:template?)
        return [] if index.nil?

        # get only locations inside template
        new_locations = new_locations[0...index] || []

        # filter out not interested locations 
        new_locations
          .reject { |loc| loc.path.start_with?(__dir__) }
          .reject { |loc| loc.template? && loc.label.include?('lambda_instance') }
      end

      # @param [String] msg
      # @param [Exception] error
      # @param [Array<Location>] template_backtrace
      # @return [RuntimeError]
      def self.wrap_existing_error(msg, error, template_backtrace)
        ruby_locs = Bade::Runtime::RuntimeError.process_locations(error.backtrace_locations)
        locs = ruby_locs + template_backtrace
        Bade::Runtime::RuntimeError.new(msg, locs, original: error, print_locations_warning: !ruby_locs.empty?)
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
