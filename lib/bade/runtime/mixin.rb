# frozen_string_literal: true

module Bade
  module Runtime
    require_relative 'block'

    class Mixin < Block
      def call!(*args)
        block.call(*args)
      rescue ArgumentError => e
        if e.message =~ /\Awrong number of arguments \(given ([0-9]+), expected ([0-9]+)\)\Z/
          # handle incorrect parameters

          # minus one, because first argument is always hash of blocks
          given = $1.to_i - 1
          expected = $2.to_i - 1
          raise ArgumentError, "wrong number of arguments (given #{given}, expected #{expected}) for mixin `#{name}`"
        elsif e.message =~ /\Aunknown keyword: (.*)\Z/
          # handle unknown key-value parameter
          key_name = $1
          raise ArgumentError, "unknown key-value argument `#{key_name}` for mixin `#{name}`"
        else
          raise
        end
      end
    end
  end
end
