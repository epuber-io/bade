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
      class Constant < Struct.new(:obj, :name, :children)
        def initialize(obj, name, children = [])
          super(obj, name, children)
        end

        def to_s
          "#{obj.name}::#{name}"
        end

        # @return [Array<Constant>]
        def flatten
          [
            self,
            *children.flat_map(&:flatten),
          ]
        end
      end

      # @return [Array<Symbol>]
      attr_accessor :caught_variables

      # @return [Array<Constant>]
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
        before_global_constants = _get_global_constants
        before_binding_constants = _get_relative_constants

        res = nil
        begin
          res = yield
        ensure
          @caught_variables += global_variables - before_variables

          @caught_constants += (_get_global_constants - before_global_constants)

          @caught_constants += (_get_relative_constants - before_binding_constants)
        end

        res
      end

      def clear_all
        clear_global_variables
        clear_constants
      end

      def clear_constants
        _filtered_constants.each do |constant|
          _remove_constant(constant)
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
      # @return [Array<Constant>]
      def _filtered_constants
        @caught_constants.select do |constant|
          obj = constant.obj
          name = constant.name

          next unless obj.const_defined?(name)

          begin
            location = obj.const_source_location(name)
          rescue ::ArgumentError
            next
          end

          next true if location.nil?

          path = location.first
          next false if path == false
          if $LOADED_FEATURES.include?(path)
            # puts "Skipping #{name} because it is loaded in $LOADED_FEATURES from #{path}"
            next false
          end

          next true if constants_location_prefixes.nil?

          constants_location_prefixes&.any? { |prefix| path.start_with?(prefix) }
        end
      end

      # Removes constant from given object.
      #
      # @param [Constant] constant
      #
      def _remove_constant(constant)
        obj = constant.obj
        name = constant.name

        return unless obj.const_defined?(name)

        puts "removing const #{name} from #{obj}"
        obj.send(:remove_const, name)
      end

      # @return [Array<Constant>]
      #
      def _get_global_constants
        Object.constants.map { |name| Constant.new(Object, name) }
      end

      # Finds all constants defined in given object recursively.
      #
      # @param [Module, Class] obj
      # @return [Array<Constant>] Array of full paths to constants
      #
      def _get_relative_constants(obj = Bade::Runtime::BaseRenderBinding)
        return [] unless obj.is_a?(Module) || obj.is_a?(Class)

        obj
          .constants(false)
          .flat_map do |name|
            next [] unless obj.const_defined?(name)

            next [
              Constant.new(obj, name, _get_relative_constants(obj.const_get(name))),
            ]
          end
      end
    end
  end
end
