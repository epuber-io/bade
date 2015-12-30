# frozen_string_literal: true

require_relative 'runtime'

require_relative 'ast/document'

module Bade
  class Generator

    BUFF_NAME = '__buff'
    MIXINS_NAME = '__mixins'
    NEW_LINE_NAME = '__new_line'
    CURRENT_INDENT_NAME = '__indent'
    BASE_INDENT_NAME = '__base_indent'

    START_STRING =	"
# frozen_string_literal: true

lambda { |#{NEW_LINE_NAME}: \"\n\", #{BASE_INDENT_NAME}: '  '|
#  #{CURRENT_INDENT_NAME} = #{BASE_INDENT_NAME}

  #{BUFF_NAME} = []
  #{MIXINS_NAME} = Hash.new { |hash, key| raise \"Undefined mixin '\#{key}'\" }
"

    END_STRING =	"
  #{BUFF_NAME}.join
}"

    # @param [Document] document
    #
    # @return [Proc]
    #
    def self.document_to_lambda(document, filename: nil)
      generator = self.new
      generator.generate_lambda(document, filename)
    end

    # @param [Document] document
    #
    # @return [String]
    #
    def self.document_to_lambda_string(document)
      generator = self.new
      generator.generate_lambda_string(document)
    end


    # @param [Document] document
    # @param [String] filename
    #
    def generate_lambda(document, filename)
      eval(generate_lambda_string(document), nil, filename || '(__template__)')
    end

    # @param [Document] document
    #
    # @return [String] string to parse with Ruby
    #
    def generate_lambda_string(document)
      @buff = []
      @indent = 0
      @code_indent = 1

      @buff << START_STRING

      visit_document(document)

      @buff << END_STRING

      @buff.join("\n")
    end

    # @param [String] text
    #
    def buff_print_text(text, indent: false, new_line: false)
      buff_print_value(%Q{%Q{#{text}}}) if text.length > 0
    end

    def buff_print_value(value)
      # buff_code %Q{#{BUFF_NAME} << #{CURRENT_INDENT_NAME}} if indent
      buff_code(%Q{#{BUFF_NAME} << #{value}})
    end

    def buff_code(text)
      @buff << '  ' * @code_indent + text
    end


    # @param document [Bade::Document]
    #
    def visit_document(document)
      document.sub_documents.each do |sub_document|
        visit_document(sub_document)
      end

      buff_code("# ----- start file #{document.file_path}") unless document.file_path.nil?
      visit_node(document.root)
      buff_code("# ----- end file #{document.file_path}") unless document.file_path.nil?
    end

    # @param current_node [Node]
    #
    def visit_node_children(current_node)
      visit_nodes(current_node.children)
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
          visit_node_children(current_node)

        when :text
          buff_print_text current_node.value

        when :tag
          visit_tag(current_node)

        when :ruby_code
          buff_code current_node.value

        when :html_comment
          buff_print_text '<!-- '
          visit_node_children(current_node)
          buff_print_text ' -->'

        when :comment
          comment_text = '#' + current_node.children.map(&:value).join("\n#")
          buff_code(comment_text)

        when :doctype
          buff_print_text current_node.xml_output

        when :mixin_declaration
          params = formatted_mixin_params(current_node)
          buff_code "#{MIXINS_NAME}['#{current_node.name}'] = lambda { |#{params}|"

          indent {
            blocks_name_declaration(current_node)
            visit_nodes(current_node.children - current_node.params)
          }

          buff_code '}'

        when :mixin_call
          params = formatted_mixin_params(current_node)
          buff_code "#{MIXINS_NAME}['#{current_node.name}'].call(#{params})"

        when :output
          data = current_node.value
          output_code = if current_node.escaped
                          "\#{html_escaped(#{data})}"
                        else
                          "\#{#{data}}"
                        end
          buff_print_text output_code

        when :newline
          buff_print_value(NEW_LINE_NAME)

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
      children_wo_attributes = (current_node.children - current_node.attributes)

      text = "<#{current_node.name}"

      if attributes.length > 0
        text += "#{attributes}"
      end

      other_than_new_lines = children_wo_attributes.any? { |node|
        node.type != :newline
      }

      if other_than_new_lines
        text += '>'
      else
        text += '/>'
      end

      buff_print_text text, new_line: true, indent: true

      if other_than_new_lines
        last_node = children_wo_attributes.last
        is_last_newline = !last_node.nil? && last_node.type == :newline
        nodes = if is_last_newline
                  children_wo_attributes[0...-1]
                else
                  children_wo_attributes
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
        joined = all_attributes[attr_name].join('), (')
        %Q{\#{tag_render_attribute('#{attr_name}', (#{joined}))}}
      end.join
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
        blocks = mixin_node.blocks

        other_children = (mixin_node.children - mixin_node.blocks - mixin_node.params)
        if other_children.reject { |n| n.type == :newline }.count > 0
          def_block_node = AST::NodeRegistrator.create(:mixin_block, mixin_node.lineno)
          def_block_node.children.replace(other_children)

          blocks << def_block_node
        end

        if blocks.length > 0
          buff_code '__blocks = {}'

          blocks.each { |block|
            block_name = block.name || 'default_block'
            buff_code "__blocks['#{block_name}'] = __create_block('#{block_name}') do"
            indent {
              visit_node_children(block)
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
        param.value
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
        block_name_declaration(param.value)
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

  # backward compatibility
  RubyGenerator = Generator
end
