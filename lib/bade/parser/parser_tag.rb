# frozen_string_literal: true


module Bade
  require_relative '../parser'

  class Parser
    module TagRegexps
      BLOCK_EXPANSION = /\A:\s+/
      OUTPUT_CODE = LineIndicatorRegexps::OUTPUT_BLOCK
      TEXT_START = /\A /

      PARAMS_ARGS_DELIMITER = /\A\s*,/
      PARAMS_END = /\A\s*\)/
    end

    # @param [String] tag  tag name
    #
    def parse_tag(tag)
      tag = fixed_trailing_colon(tag)

      if tag.is_a?(AST::Node)
        tag_node = tag
      else
        tag_node = append_node(:tag, add: true)
        tag_node.name = tag
      end

      parse_tag_attributes

      case @line
      when TagRegexps::BLOCK_EXPANSION
        # Block expansion
        @line = $'
        parse_line_indicators(add_newline: false)

      when TagRegexps::OUTPUT_CODE
        # Handle output code
        parse_line_indicators(add_newline: false)

      when CLASS_TAG_RE
        # Class name
        @line = $'

        attr_node = append_node(:tag_attr)
        attr_node.name = 'class'
        attr_node.value = fixed_trailing_colon($1).single_quote

        parse_tag tag_node

      when ID_TAG_RE
        # Id name
        @line = $'

        attr_node = append_node(:tag_attr)
        attr_node.name = 'id'
        attr_node.value = fixed_trailing_colon($1).single_quote

        parse_tag tag_node

      when TagRegexps::TEXT_START
        # Text content
        @line = $'
        parse_text

      when ''
        # nothing

      else
        syntax_error "Unknown symbol after tag definition #{@line}"
      end
    end

    def parse_tag_attributes
      # Check to see if there is a delimiter right after the tag name

      # between tag name and attribute must not be space
      # and skip when is nothing other
      if @line.start_with?('(')
        @line.remove_first!
      else
        return
      end

      loop do
        case @line
        when CODE_ATTR_RE
          # Value ruby code
          @line = $'
          attr_node = append_node(:tag_attr)
          attr_node.name = $1
          attr_node.value = parse_ruby_code(ParseRubyCodeRegexps::END_PARAMS_ARG)

        when TagRegexps::PARAMS_ARGS_DELIMITER
          # args delimiter
          @line = $'
          next

        when TagRegexps::PARAMS_END
          # Find ending delimiter
          @line = $'
          break

        else
          # Found something where an attribute should be
          @line.lstrip!
          syntax_error('Expected attribute') unless @line.empty?

          # Attributes span multiple lines
          append_node(:newline)
          syntax_error('Expected closing tag attributes delimiter `)`') if @lines.empty?
          next_line
        end
      end
    end
  end
end
