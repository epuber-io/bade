require_relative 'generator'
require_relative '../runtime'

module Bade
	class RubyGenerator < Generator

		BUFF_NAME = '__buff'
		MIXINS_NAME = '__mixins'
		START_STRING =	"
lambda {
	#{BUFF_NAME} = []
	#{MIXINS_NAME} = {}
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
			indent_text = ''
			new_line_text = ''

			if indent
				indent_text = @indent_string * @indent
			end

			if new_line
				new_line_text = @new_line_string
			end

			prepended_text = indent_text + text + new_line_text

#			escape_double_quotes!(prepended_text)

			if prepended_text.length > 0
				buff_code "#{BUFF_NAME} << " + '%Q(' + prepended_text + ')'
			end
		end

		def buff_code(text)
			@buff << "\t" * @code_indent + text
		end

		def visit_node_childrens(current_node)
			current_node.childrens.each { |node|
				visit_node(node)
			}
		end

		def visit_node(current_node)
			case current_node.type
				when :root
					visit_node_childrens(current_node)

				when :text
					buff_print_text current_node.data

				when :tag
					attributes = formatted_attributes current_node

					if attributes.length > 0
						buff_print_text "<#{current_node.name} #{attributes}>", new_line: true, indent: true
					else
						buff_print_text "<#{current_node.name}>", new_line: true, indent: true
					end

					indent {
						visit_node_childrens(current_node)
					}

					buff_print_text "</#{current_node.name}>", new_line: true, indent: true

				when :ruby_code
					buff_code current_node.data

				when :html_comment
					buff_print_text '<!-- '
					visit_node_childrens(current_node)
					buff_print_text ' -->'

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
			end
		end

		# @param [Node] tag_node
		#
		# @return [String] formatted attributes
		#
		def formatted_attributes(tag_node)
			tag_node.attributes.map { |attr|
				"#{attr.name}=\"\#{#{attr.value}}\""
			}.join ' '
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
				buff_code '__blocks = {}'

				mixin_node.blocks.each { |block|
					block_name = block.data ? block.data : 'default_block'
					buff_code "__blocks['#{block_name}'] = block('#{block_name}') {"
					indent {
						visit_node_childrens(block)
					}
					buff_code '}'
				}

				result << '__blocks'
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
			buff_code "#{block_name} = __blocks.delete('#{block_name}') { block('#{block_name}') }"
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
