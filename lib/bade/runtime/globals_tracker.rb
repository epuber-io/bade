# frozen_string_literal: true

module Bade
  module Runtime
    # Tracks created global variables and constants in block.
    class GlobalsTracker
      # @return [Array<Symbol>]
      attr_accessor :caught_variables

      # @return [Array<[Object, :Symbol]>]
      attr_accessor :caught_constants

      def initialize
        @caught_variables = []
        @caught_constants = []
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
        @caught_constants.each do |(obj, name)|
          obj.send(:remove_const, name) if obj.const_defined?(name)
        end
        @caught_constants = []
      end

      def clear_global_variables
        @caught_variables.each do |name|
          eval("#{name} = nil", binding, __FILE__, __LINE__)
        end
      end
    end
  end
end
