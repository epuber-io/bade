# frozen_string_literal: true


module Bade
  require_relative '../parser'

  class Parser
    module ParseRubyCodeRegexps
      END_NEW_LINE = /\A\s*\n/.freeze
      END_PARAMS_ARG = /\A\s*[,)]/.freeze
    end

    # Parse ruby code, ended with outer delimiters
    #
    # @param [String, Regexp] outer_delimiters
    #
    # @return [Void] parsed ruby code
    #
    def parse_ruby_code(outer_delimiters, allow_multiline: false)
      code = String.new
      end_re = if outer_delimiters.is_a?(Regexp)
                 outer_delimiters
               else
                 /\A\s*[#{Regexp.escape outer_delimiters.to_s}]/
               end

      delimiters = []
      string_start_quote_char = nil

      loop do
        break if !allow_multiline && @line.empty?
        break if allow_multiline && @line.empty? && @lines&.empty?
        break if delimiters.empty? && @line =~ end_re

        if @line.empty? && allow_multiline && !@lines&.empty?
          next_line
          code << "\n"
        end

        char = @line[0]

        # backslash escaped delimiter
        if char == '\\' && RUBY_ALL_DELIMITERS.include?(@line[1])
          code << @line.slice!(0, 2)
          next
        end

        case char
        when RUBY_START_DELIMITERS_RE
          if RUBY_NOT_NESTABLE_DELIMITERS.include?(char) && delimiters.last == char
            # end char of not nestable delimiter
            delimiters.pop
            string_start_quote_char = nil
          else
            # diving into nestable delimiters
            delimiters << char if string_start_quote_char.nil?

            # mark start char of the not nestable delimiters, for example strings
            if RUBY_NOT_NESTABLE_DELIMITERS.include?(char) && string_start_quote_char.nil?
              string_start_quote_char = char
            end
          end

        when RUBY_END_DELIMITERS_RE
          # rising
          delimiters.pop if char == RUBY_DELIMITERS_REVERSE[delimiters.last]
        end

        code << @line.slice!(0)
      end

      syntax_error('Unexpected end of ruby code') unless delimiters.empty?

      code.strip
    end

    RUBY_DELIMITERS_REVERSE = {
      '(' => ')',
      '[' => ']',
      '{' => '}',
    }.freeze

    RUBY_QUOTES = %w[' "].freeze

    RUBY_NOT_NESTABLE_DELIMITERS = RUBY_QUOTES

    RUBY_START_DELIMITERS = (%w(\( [ {) + RUBY_NOT_NESTABLE_DELIMITERS).freeze
    RUBY_END_DELIMITERS = (%w(\) ] }) + RUBY_NOT_NESTABLE_DELIMITERS).freeze
    RUBY_ALL_DELIMITERS = (RUBY_START_DELIMITERS + RUBY_END_DELIMITERS).uniq.freeze

    RUBY_START_DELIMITERS_RE = /\A[#{Regexp.escape RUBY_START_DELIMITERS.join}]/.freeze
    RUBY_END_DELIMITERS_RE = /\A[#{Regexp.escape RUBY_END_DELIMITERS.join}]/.freeze
  end
end
