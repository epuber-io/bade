# frozen_string_literal: true


module Bade
  require_relative '../parser'

  class Parser
    module LineIndicatorRegexps
      IMPORT = /\Aimport /
      MIXIN_DECL = /\Amixin #{NAME_RE_STRING}/
      MIXIN_CALL = /\A\+#{NAME_RE_STRING}/
      BLOCK_DECLARATION = /\Ablock #{NAME_RE_STRING}/
      HTML_COMMENT = /\A\/\/! /
      NORMAL_COMMENT = /\A\/\//
      TEXT_BLOCK_START = /\A\|( ?)/
      INLINE_HTML = /\A</
      CODE_BLOCK = /\A-/
      OUTPUT_BLOCK = /\A(\??)(&?)=/
      DOCTYPE = /\Adoctype\s/i
      TAG_CLASS_START_BLOCK = /\A\./
      TAG_ID_START_BLOCK = /\A#/
    end

    def reset(lines = nil, stacks = nil)
      # Since you can indent however you like in Slim, we need to keep a list
      # of how deeply indented you are. For instance, in a template like this:
      #
      #   doctype       # 0 spaces
      #   html          # 0 spaces
      #    head         # 1 space
      #       title     # 4 spaces
      #
      # indents will then contain [0, 1, 4] (when it's processing the last line.)
      #
      # We uses this information to figure out how many steps we must "jump"
      # out when we see an de-indented line.
      @indents = [0]

      # Whenever we want to output something, we'll *always* output it to the
      # last stack in this array. So when there's a line that expects
      # indentation, we simply push a new stack onto this array. When it
      # processes the next line, the content will then be outputted into that
      # stack.
      @stacks = stacks

      @lineno = 0
      @lines = lines

      # @return [String]
      @line = @orig_line = nil
    end

    def next_line
      if @lines.empty?
        @orig_line = @line = nil

        last_newlines = remove_last_newlines
        @root.children += last_newlines

        nil
      else
        @orig_line = @lines.shift
        @lineno += 1
        @line = @orig_line.dup
      end
    end

    def parse_line
      if @line.strip.length == 0
        append_node(:newline) unless @lines.empty?
        return
      end

      indent = get_indent(@line)

      # left strip
      @line.remove_indent!(indent, @tabsize)

      # If there's more stacks than indents, it means that the previous
      # line is expecting this line to be indented.
      expecting_indentation = @stacks.length > @indents.length

      if indent > @indents.last
        @indents << indent
      else
        # This line was *not* indented more than the line before,
        # so we'll just forget about the stack that the previous line pushed.
        if expecting_indentation
          last_newlines = remove_last_newlines

          @stacks.pop

          new_node = @stacks.last.last
          new_node.children += last_newlines
        end

        # This line was deindented.
        # Now we're have to go through the all the indents and figure out
        # how many levels we've deindented.
        while indent < @indents.last
          last_newlines = remove_last_newlines

          @indents.pop
          @stacks.pop

          new_node = @stacks.last.last
          new_node.children += last_newlines
        end

        # Remove old stacks we don't need
        while not @stacks[indent].nil? and indent < @stacks[indent].length - 1
          last_newlines = remove_last_newlines

          @stacks[indent].pop

          new_node = @stacks.last.last
          new_node.children += last_newlines
        end

        # This line's indentation happens lie "between" two other line's
        # indentation:
        #
        #   hello
        #       world
        #     this      # <- This should not be possible!
        syntax_error('Malformed indentation') if indent != @indents.last
      end

      parse_line_indicators
    end

    def parse_line_indicators(add_newline: true)
      case @line
      when LineIndicatorRegexps::IMPORT
        @line = $'
        parse_import

      when LineIndicatorRegexps::MIXIN_DECL
        # Mixin declaration
        @line = $'
        parse_mixin_declaration($1)

      when LineIndicatorRegexps::MIXIN_CALL
        # Mixin call
        @line = $'
        parse_mixin_call($1)

      when LineIndicatorRegexps::BLOCK_DECLARATION
        @line = $'
        if @stacks.last.last.type == :mixin_call
          node = append_node(:mixin_block, add: true)
          node.name = $1
        else
          # keyword block used outside of mixin call
          parse_tag($&)
        end

      when LineIndicatorRegexps::HTML_COMMENT
        # HTML comment
        append_node(:html_comment, add: true)
        parse_text_block $', @indents.last + @tabsize

      when LineIndicatorRegexps::NORMAL_COMMENT
        # Comment
        append_node(:comment, add: true)
        parse_text_block $', @indents.last + @tabsize

      when LineIndicatorRegexps::TEXT_BLOCK_START
        # Found a text block.
        parse_text_block $', @indents.last + @tabsize

      when LineIndicatorRegexps::INLINE_HTML
        # Inline html
        append_node(:text, value: @line)

      when LineIndicatorRegexps::CODE_BLOCK
        # Found a code block.
        append_node(:code, value: $'.strip)

      when LineIndicatorRegexps::OUTPUT_BLOCK
        # Found an output block.
        # We expect the line to be broken or the next line to be indented.
        @line = $'
        output_node = append_node(:output)
        output_node.conditional = $1.length == 1
        output_node.escaped = $2.length == 1
        output_node.value = parse_ruby_code(ParseRubyCodeRegexps::END_NEW_LINE)

      when LineIndicatorRegexps::DOCTYPE
        # Found doctype declaration
        append_node(:doctype, value: $'.strip)

      when TAG_RE
        # Found a HTML tag.
        @line = $' if $1
        parse_tag($&)

      when LineIndicatorRegexps::TAG_CLASS_START_BLOCK
        # Found class name -> implicit div
        parse_tag 'div'

      when LineIndicatorRegexps::TAG_ID_START_BLOCK
        # Found id name -> implicit div
        parse_tag 'div'

      else
        syntax_error 'Unknown line indicator'
      end

      append_node(:newline) if add_newline && !@lines.empty?
    end
  end
end
