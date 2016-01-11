# frozen_string_literal: true


module Bade
  require_relative '../parser'

  class Parser
    module TextRegexps
      INTERPOLATION_START = /(\\)?(&|#)\{/
      INTERPOLATION_END = /\A\}/
    end

    def parse_text
      new_index = @line.index(TextRegexps::INTERPOLATION_START)

      # the interpolation sequence is not in text, mark whole text as static
      if new_index.nil?
        append_node(:static_text, value: @line)
        return
      end

      unparsed_part = String.new

      while (new_index = @line.index(TextRegexps::INTERPOLATION_START))
        if $1.nil?
          static_part = unparsed_part + @line.remove_first!(new_index)
          append_node(:static_text, value: static_part)

          @line.remove_first!(2) # #{ or &{

          dynamic_part = parse_ruby_code(TextRegexps::INTERPOLATION_END)
          node = append_node(:output, value: dynamic_part)
          node.escaped = $2 == '&'

          @line.remove_first! # ending }

          unparsed_part = String.new
        else
          unparsed_part << @line.remove_first!(new_index)
          @line.remove_first! # symbol \
          unparsed_part << @line.remove_first!(2) # #{ or &{
        end
      end

      # add the rest of line
      append_node(:static_text, value: unparsed_part + @line) unless @line.empty?
    end

    def parse_text_block(first_line, text_indent = nil)
      if !first_line || first_line.empty?
        text_indent = nil
      else
        @line = first_line
        parse_text
      end

      until @lines.empty?
        if @lines.first.blank?
          next_line
          append_node(:newline)
        else
          indent = get_indent(@lines.first)
          break if indent <= @indents.last

          next_line

          @line.remove_indent!(text_indent ? text_indent : indent, @tabsize)

          parse_text

          # The indentation of first line of the text block
          # determines the text base indentation.
          text_indent ||= indent
        end
      end
    end
  end
end
