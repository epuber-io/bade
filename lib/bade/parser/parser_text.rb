# frozen_string_literal: true


module Bade
  require_relative '../parser'

  class Parser
    def parse_text
      text = @line
      text = text.gsub(/&\{/, '#{ __html_escaped ')
      append_node(:text, value: text)
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
