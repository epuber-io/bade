# frozen_string_literal: true


module Bade
  require_relative '../parser'

  class Parser
    module MixinRegexps
      TEXT_START = /\A /
      BLOCK_EXPANSION = /\A:\s+/
      OUTPUT_CODE = /\A(&?)=/

      PARAMS_END = /\A\s*\)/

      PARAMS_END_SPACES = /^\s*$/
      PARAMS_ARGS_DELIMITER = /\A\s*,/

      PARAMS_PARAM_NAME = /\A\s*#{NAME_RE_STRING}/
      PARAMS_BLOCK_NAME = /\A\s*&#{NAME_RE_STRING}/
      PARAMS_KEY_PARAM_NAME = CODE_ATTR_RE
    end

    def parse_mixin_call(mixin_name)
      mixin_name = fixed_trailing_colon(mixin_name)

      mixin_node = append_node(:mixin_call, add: true)
      mixin_node.name = mixin_name

      parse_mixin_call_params

      case @line
      when MixinRegexps::TEXT_START
        @line = $'
        parse_text

      when MixinRegexps::BLOCK_EXPANSION
        # Block expansion
        @line = $'
        parse_line_indicators(add_newline: false)

      when MixinRegexps::OUTPUT_CODE
        # Handle output code
        parse_line_indicators(add_newline: false)

      when ''
        # nothing

      else
        syntax_error "Unknown symbol after mixin calling, line = `#{@line}'"
      end
    end

    def parse_mixin_call_params
      # between tag name and attribute must not be space
      # and skip when is nothing other
      return unless @line.start_with?('(')

      # remove starting bracket
      @line.remove_first!

      loop do
        case @line
        when MixinRegexps::PARAMS_KEY_PARAM_NAME
          @line = $'
          attr_node = append_node(:mixin_key_param)
          attr_node.name = fixed_trailing_colon($1)
          attr_node.value = parse_ruby_code(ParseRubyCodeRegexps::END_PARAMS_ARG)

        when MixinRegexps::PARAMS_ARGS_DELIMITER
          # args delimiter
          @line = $'
          next

        when MixinRegexps::PARAMS_END_SPACES
          # spaces and/or end of line
          next_line
          next

        when MixinRegexps::PARAMS_END
          # Find ending delimiter
          @line = $'
          break

        else
          attr_node = append_node(:mixin_param)
          attr_node.value = parse_ruby_code(ParseRubyCodeRegexps::END_PARAMS_ARG)
        end
      end
    end

    def parse_mixin_declaration(mixin_name)
      mixin_node = append_node(:mixin_decl, add: true)
      mixin_node.name = mixin_name

      parse_mixin_declaration_params
    end

    def parse_mixin_declaration_params
      # between tag name and attribute must not be space
      # and skip when is nothing other
      return unless @line.start_with?('(')

      # remove starting bracket
      @line.remove_first!

      loop do
        case @line
        when MixinRegexps::PARAMS_KEY_PARAM_NAME
          # Value ruby code
          @line = $'
          attr_node = append_node(:mixin_key_param)
          attr_node.name = fixed_trailing_colon($1)
          attr_node.value = parse_ruby_code(ParseRubyCodeRegexps::END_PARAMS_ARG)

        when MixinRegexps::PARAMS_PARAM_NAME
          @line = $'
          append_node(:mixin_param, value: $1)

        when MixinRegexps::PARAMS_BLOCK_NAME
          @line = $'
          append_node(:mixin_block_param, value: $1)

        when MixinRegexps::PARAMS_ARGS_DELIMITER
          # args delimiter
          @line = $'
          next

        when MixinRegexps::PARAMS_END
          # Find ending delimiter
          @line = $'
          break

        else
          syntax_error('wrong mixin attribute syntax')
        end
      end
    end
  end
end
