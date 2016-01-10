# frozen_string_literal: true


module Bade
  require_relative '../parser'

  class Parser
    module ParseRubyCodeRegexps
      END_NEW_LINE = /\A\s*\n/
      END_PARAMS_ARG = /\A\s*[,)]/
    end

    # Parse ruby code, ended with outer delimiters
    #
    # @param [String, Regexp] outer_delimiters
    #
    # @return [Void] parsed ruby code
    #
    def parse_ruby_code(outer_delimiters)
      code = String.new
      end_re = if Regexp === outer_delimiters
                 outer_delimiters
               else
                 /\A\s*[#{Regexp.escape outer_delimiters.to_s}]/
               end
      delimiters = []

      until @line.empty? or (delimiters.count == 0 and @line =~ end_re)
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
          else
            # diving
            delimiters << char
          end

        when RUBY_END_DELIMITERS_RE
          # rising
          if char == RUBY_DELIMITERS_REVERSE[delimiters.last]
            delimiters.pop
          end
        end

        code << @line.slice!(0)
      end

      unless delimiters.empty?
        syntax_error('Unexpected end of ruby code')
      end

      code.strip
    end

    RUBY_DELIMITERS_REVERSE = {
        '(' => ')',
        '[' => ']',
        '{' => '}'
    }.freeze

    RUBY_QUOTES = %w(' ").freeze

    RUBY_NOT_NESTABLE_DELIMITERS = RUBY_QUOTES

    RUBY_START_DELIMITERS = (%w(\( [ {) + RUBY_NOT_NESTABLE_DELIMITERS).freeze
    RUBY_END_DELIMITERS = (%w(\) ] }) + RUBY_NOT_NESTABLE_DELIMITERS).freeze
    RUBY_ALL_DELIMITERS = (RUBY_START_DELIMITERS + RUBY_END_DELIMITERS).uniq.freeze

    RUBY_START_DELIMITERS_RE = /\A[#{Regexp.escape RUBY_START_DELIMITERS.join}]/
    RUBY_END_DELIMITERS_RE = /\A[#{Regexp.escape RUBY_END_DELIMITERS.join}]/
  end
end
