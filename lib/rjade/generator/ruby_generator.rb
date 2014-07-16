require_relative 'generator'

module RJade
	class RubyGenerator < Generator

		START_STRING =	'
						lambda {
							_buff = []
						'

		END_STRING =	'
							_buff.join
						}
						'

		# @param [Node] root
		#
		def self.node_to_lambda(root, new_line: "\n", indent: "\t", filename: '')
			generator = self.new(new_line, indent)
			generator.generate_lambda(root, filename)
		end



		# @param [String] new_line_string
		# @param [String] indent_string
		#
		def initialize(new_line_string, indent_string)
			@new_line_string = new_line_string
			@indent_string = indent_string
		end

		# @param [Node] root
		# @param [String] filename
		#
		def generate_lambda(root, filename)
			@buff = []
			@indent = 0

			@buff << START_STRING


			node_to_lambda_array(root)


			@buff << END_STRING

			str = @buff.join("\n")

			eval(str, nil, filename)
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

			@buff << "_buff << '#{prepended_text}'\n"
		end

		def node_to_lambda_array(root)

			append_childrens = lambda { |indent_plus|
				root.childrens.each { |node|
					node_to_lambda_array(node)
				}
			}

			case root.type
				when :root
					append_childrens.call(0)

				when :text
					print_text root.data

				when :tag
					attributes = formatted_attributes root

					if attributes.length > 0
						print_text "<#{root.data} #{attributes}>", new_line: true, indent: true
					else
						print_text "<#{root.data}>", new_line: true, indent: true
					end

					append_childrens.call(1)

					print_text "</#{root.data}>", new_line: true, indent: true
			end
		end

		# @param [Node] tag_node
		#
		# @return [String] formatted attributes
		#
		def formatted_attributes(tag_node)

			attributes = tag_node.childrens.select { |child|
				child.type == :tag_attribute
			}.map { |attr|
				"#{attr.data}=\"#{attr.childrens.first.data}\""
			}

			attributes.join ' '
		end
	end
end
