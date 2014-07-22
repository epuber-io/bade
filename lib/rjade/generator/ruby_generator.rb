require_relative 'generator'

module RJade
	class RubyGenerator < Generator

		BUFF_NAME = '_buff'
		START_STRING =	"
lambda {
	#{BUFF_NAME} = []
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

			@buff << START_STRING


			visit_node(root)


			@buff << END_STRING

			@buff.join("\n")
		end

		# @param [String] text
		#
		def print_text(text, indent: false, new_line: false)
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
				@buff << "\t#{BUFF_NAME} << " + '%Q(' + prepended_text + ')'
			end
		end

		def visit_node(current_node)

			append_childrens = lambda { |indent_plus|
				current_node.childrens.each { |node|
					@indent += indent_plus
					visit_node(node)
					@indent -= indent_plus
				}
			}

			case current_node.type
				when :root
					append_childrens.call(0)

				when :text
					print_text current_node.data

				when :tag
					attributes = formatted_attributes current_node

					if attributes.length > 0
						print_text "<#{current_node.name} #{attributes}>", new_line: true, indent: true
					else
						print_text "<#{current_node.name}>", new_line: true, indent: true
					end

					append_childrens.call(1)

					print_text "</#{current_node.name}>", new_line: true, indent: true

				when :ruby_code
					@buff << current_node.data

				when :html_comment
					print_text '<!-- '
					append_childrens.call 0
					print_text ' -->'
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

		# @param [String] str
		#
		# @return [Void]
		#
		def escape_double_quotes!(str)
			str.gsub!(/"/, '\"')
		end
	end
end
