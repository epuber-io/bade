# frozen_string_literal: true

unless Object.respond_to?(:const_source_location)
  class Object
    def Object.const_source_location(name)
      require_relative 'utils/where'

      konst = const_get(name)
      is_meta = konst.is_a?(Module) || konst.is_a?(Class)
      if is_meta
        Bade.where_is(konst)
      else
        nil
      end
    end
  end
end

module Bade
  module Runtime
    # Tracks created global variables and constants in block.
    class GlobalsTracker
      # @return [Array<Symbol>]
      attr_accessor :caught_variables

      # @return [Array<[Object, Symbol]>]
      attr_accessor :caught_constants

      # @return [Array<String>, nil]
      attr_accessor :constants_location_prefixes

      # @param [Array<String>, nil] constants_location_prefixes If given, only constants whose location starts with one
      #                                                         of the prefixes will be removed. If nil, all constants
      #                                                         will be removed.
      def initialize(constants_location_prefixes: nil)
        @caught_variables = []
        @caught_constants = []
        @constants_location_prefixes = constants_location_prefixes
      end

      # @yieldreturn [T]
      # @return [T]
      def catch
        before_variables = global_variables
        before_global_constants = Object.constants
        before_binding_constants = Bade::Runtime::RenderBinding.constants(false)

        res = nil
        begin
          res = yield
        ensure
          @caught_variables += global_variables - before_variables

          @caught_constants += (Object.constants - before_global_constants)
                               .map { |name| [Object, name] }
          @caught_constants += (Bade::Runtime::RenderBinding.constants(false) - before_binding_constants)
                               .map { |name| [Bade::Runtime::RenderBinding, name] }
        end

        res
      end

      def clear_all
        clear_global_variables
        clear_constants
      end

      def clear_constants
        _filtered_constants.each do |(obj, name)|
          obj.send(:remove_const, name)
        end
        @caught_constants = []
      end

      def clear_global_variables
        @caught_variables.each do |name|
          eval("#{name} = nil", binding, __FILE__, __LINE__)
        end
      end

      # Filteres caught constants by location prefixes and returns ones that should be removed.
      #
      # @return [Array<[Object, Symbol]>]
      def _filtered_constants
        @caught_constants.select do |(obj, name)|
          next unless obj.const_defined?(name)

          begin
            location = obj.const_source_location(name)
          rescue ::ArgumentError
            next
          end

          next true if location.nil?

          path = location.first
          next false if path == false
          next false if $LOADED_FEATURES.include?(path)

          next true if constants_location_prefixes.nil?

          constants_location_prefixes&.any? { |prefix| path.start_with?(prefix) }
        end
      end
    end
  end
end
