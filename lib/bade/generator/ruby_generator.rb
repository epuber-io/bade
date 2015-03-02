require_relative '../generator'
require_relative '../runtime'

module Bade
  class RubyGenerator < Generator

    BUFF_NAME = '__buff'
    MIXINS_NAME = '__mixins'
    START_STRING =	"
lambda {
  #{BUFF_NAME} = []
  #{MIXINS_NAME} = Hash.new { |hash, key| raise \"Undefined mixin '\#{key}'\" }
"

    END_STRING =	"
  #{BUFF_NAME}.join
}"

    # @param [Node] root
    #
    # @return [Proc]
    #
    def self.node_to_lambda(root, new_line: "\n", indent: "\t", filename: '')
      generator = self.new(new_line, indent)
      generator.generate_lambda(root, filename)
    end

    # @param [Node] root
    #
    # @return [String]
    #
    def self.node_to_lambda_string(root, new_line: "\n", indent: "\t", filename: '')
      generator = self.new(new_line, indent)
      generator.generate_lambda_string(root)
    end



    # @param [String] new_line_string
    # @param [String] indent_string
    #
    def initialize(new_line_string, indent_string)
      @new_line_string = new_line_string
      @indent_string = indent_string
    end

    # @param [String] filename
    #
    def generate_lambda(root, filename)
      eval(generate_lambda_string(root), nil, filename)
    end

    # @param [Node] root
    #
    # @return [String] string to parse with Ruby
    #
    def generate_lambda_string(root)
      @buff = []
      @indent = 0
      @code_indent = 1

      @buff << START_STRING


      visit_node(root)


      @buff << END_STRING

      @buff.join("\n")
    end

    # @param [String] text
    #
    def buff_print_text(text, indent: false, new_line: false)
      indent_text = if indent
                      @indent_string * @indent
                    else
                      ''
                    end

      prepended_text = indent_text + text

      if prepended_text.length > 0
        buff_code %Q{#{BUFF_NAME} << %Q{#{prepended_text}}}
      end
    end

    def buff_code(text)
      @buff << "\t" * @code_indent + text
    end

    # @param current_node [Node]
    #
    def visit_node_childrens(current_node)
      visit_nodes(current_node.childrens)
    end

    # @param nodes [Array<Node>]
    #
    def visit_nodes(nodes)
      nodes.each { |node|
        visit_node(node)
      }
    end

    # @param current_node [Node]
    #
    def visit_node(current_node)
      case current_node.type
        when :root
          visit_node_childrens(current_node)

        when :text
          buff_print_text current_node.data

        when :tag
          visit_tag(current_node)

        when :ruby_code
          buff_code current_node.data

        when :html_comment
          buff_print_text '<!-- '
          visit_node_childrens(current_node)
          buff_print_text ' -->'

        when :comment
          comment_text = current_node.childrens.select { |node|
            !node.data.nil?
          }.map { |node|
            node.data
          }.join(@new_line_string + '#')

          buff_code '#' + comment_text

        when :doctype
          buff_print_text current_node.xml_output

        when :mixin_declaration
          params = formatted_mixin_params(current_node)
          buff_code "#{MIXINS_NAME}['#{current_node.data}'] = lambda { |#{params}|"

          indent {
            blocks_name_declaration(current_node)
            visit_node_childrens(current_node)
          }

          buff_code '}'

        when :mixin_call
          params = formatted_mixin_params(current_node)
          buff_code "#{MIXINS_NAME}['#{current_node.data}'].call(#{params})"

        when :output
          data = current_node.data
          output_code = if current_node.escaped
                          "\#{::Bade::html_escaped(#{data})}"
                        else
                          "\#{#{data}}"
                        end
          buff_print_text output_code

        when :newline
          buff_print_text @new_line_string if @new_line_string.length > 0

        when :import
          # nothing

        else
          raise "Unknown type #{current_node.type}"
      end
    end

    # @param [TagNode] current_node
    #
    def visit_tag(current_node)
      attributes = formatted_attributes current_node

      text = "<#{current_node.name}"

      if attributes.length > 0
        text += " #{attributes}"
      end

      other_than_new_lines = current_node.childrens.any? { |node|
        node.type != :newline
      }

      if other_than_new_lines
        text += '>'
      else
        text += '/>'
      end

      buff_print_text text, new_line: true, indent: true

      if other_than_new_lines
        last_node = current_node.childrens.last
        is_last_newline = !last_node.nil? && last_node.type == :newline
        nodes = if is_last_newline
                  current_node.childrens[0...-1]
                else
                  current_node.childrens
                end

        indent do
          visit_nodes(nodes)
        end

        buff_print_text "</#{current_node.name}>", new_line: true, indent: true

        # print new line after the tag
        visit_node(last_node) if is_last_newline
      end
    end

    # @param [TagNode] tag_node
    #
    # @return [String] formatted attributes
    #
    def formatted_attributes(tag_node)
      all_attributes = Hash.new { |hash, key| hash[key] = [] }
      xml_attributes = []

      tag_node.attributes.each do |attr|
        unless all_attributes.include?(attr.name)
          xml_attributes << attr.name
        end

        all_attributes[attr.name] << attr.value
      end

      xml_attributes.map do |attr_name|
        joined = all_attributes[attr_name].join('} #{')
        %Q{#{attr_name}="\#{#{joined}}"}
      end.join(' ')
    end

    def indent(plus = 1)
      @code_indent += plus
      yield
      @code_indent -= plus
    end

    # @param [MixinCommonNode] mixin_node
    #
    # @return [String] formatted params
    #
    def formatted_mixin_params(mixin_node)
      params = mixin_node.params
      result = []



      if mixin_node.type == :mixin_call
        if mixin_node.blocks.length > 0
          buff_code '__blocks = {}'

          mixin_node.blocks.each { |block|
            block_name = block.data ? block.data : 'default_block'
            buff_code "__blocks['#{block_name}'] = __create_block('#{block_name}') do"
            indent {
              visit_node_childrens(block)
            }
            buff_code 'end'
          }

          result << '__blocks.dup'
        else
          result << '{}'
        end
      elsif mixin_node.type == :mixin_declaration
        result << '__blocks'
      end


      # normal params
      result += params.select { |param|
        param.type == :mixin_param
      }.map { |param|
        param.data
      }

      result += params.select { |param|
        param.type == :mixin_key_param
      }.map { |param|
        "#{param.name}: #{param.value}"
      }

      result.join(', ')
    end


    # @param [String] block_name
    #
    def block_name_declaration(block_name)
      buff_code "#{block_name} = __blocks.delete('#{block_name}') { __create_block('#{block_name}') }"
    end

    # @param [MixinDeclarationNode] mixin_node
    #
    def blocks_name_declaration(mixin_node)
      mixin_node.params.select { |param|
        param.type == :mixin_block_param
      }.each { |param|
        block_name_declaration(param.data)
      }

      block_name_declaration('default_block')
    end



    # @param [String] str
    #
    # @return [Void]
    #
    def escape_double_quotes!(str)
      str.gsub!(/"/, '\"')
    end
  end
end
