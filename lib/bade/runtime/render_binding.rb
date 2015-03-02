
require_relative 'block'
require_relative 'functions'

module Bade
  module Runtime
    class RenderBinding
      class KeyError < ::StandardError; end

      # @param vars [Hash]
      #
      def initialize(vars = {})
        @vars = vars
      end

      def method_missing(name, *args)
        raise KeyError, "Not found value for key `#{name}'" unless @vars.key?(name)
        @vars[name]
      end

      # @return [Binding]
      #
      def get_binding
        binding
      end

      # Shortcut for creating blocks
      #
      def __create_block(*args, &block)
        Bade::Runtime::Block.new(*args, &block)
      end
    end
  end
end
