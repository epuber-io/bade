

module Bade
  module Runtime
    class HashBinding
      class KeyError < ::StandardError; end

      # @param vars [Hash]
      #
      def initialize(vars = {})
        @vars = vars
      end

      def method_missing(name)
        raise KeyError, "Not found value for key `#{name}'" unless @vars.key?(name)
        @vars[name]
      end

      # @return [Binding]
      #
      def get_binding
        binding
      end
    end
  end
end
