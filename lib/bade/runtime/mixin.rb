# frozen_string_literal: true

require 'ruby2_keywords'

module Bade
  module Runtime
    require_relative 'block'

    class Mixin < Block
      ruby2_keywords def call!(blocks, *args)
        begin
          block.call(blocks, *args)
        rescue ArgumentError => e
          case e.message
          when /\Awrong number of arguments \(given ([0-9]+), expected ([0-9]+)\)\Z/,
               /\Awrong number of arguments \(([0-9]+) for ([0-9]+)\)\Z/
            # handle incorrect parameters count

            # minus one, because first argument is always hash of blocks
            given = $1.to_i - 1
            expected = $2.to_i - 1
            raise ArgumentError, "wrong number of arguments (given #{given}, expected #{expected}) for mixin `#{name}`"

          when /\Aunknown keyword: (.*)\Z/
            # handle unknown key-value parameter
            key_name = $1
            raise ArgumentError, "unknown key-value argument `#{key_name}` for mixin `#{name}`"

          else
            raise
          end
        rescue Block::MissingBlockDefinitionError => e
          msg = case e.context
                when :call
                  "Mixin `#{name}` requires block to get called of block `#{e.name}`"
                when :render
                  "Mixin `#{name}` requires block to get rendered content of block `#{e.name}`"
                else
                  raise ::ArgumentError, "Unknown context #{e.context} of error #{e}!"
                end

          raise Block::MissingBlockDefinitionError.new(e.name, e.context, msg)
        end
      end
    end
  end
end
