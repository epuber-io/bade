require_relative 'generator'

module Bade
	class HTMLGenerator < Generator

		# @param [Node] root node
		# @return [String]
		#
		def self.node_to_lambda(root, new_line: "\n", indent: "\t")
			str = node_to_html_array(root, new_line: new_line, indent: indent).join

			lambda {
				str
			}
		end


		private

		# @param [Node] root node
		# @return [Array<String>]
		#
		def self.node_to_html_array(root, new_line: "\n", indent: "\t", indent_level: 0)
			unless root.kind_of? Node
				return [ root.inspect ]
			end

			buff = []

			if indent_level > 0 and not indent.empty?
				buff << indent * indent_level
			end

			append_childrens = lambda { |indent_plus|
				root.childrens.each { |node|
					buff += node_to_html_array(node, new_line: new_line, indent: indent, indent_level: indent_level+indent_plus)
				}
			}


			case root.type
				when :root
					append_childrens.call(0)

				when :text
					buff << root.data

				when :tag
					attributes = formatted_attributes root

					if attributes.length > 0
						buff << "<#{root.data} #{attributes}>" + new_line
					else
						buff << "<#{root.data}>" + new_line
					end

					append_childrens.call(1)

					buff << "</#{root.data}>" + new_line
			end

			buff
		end

		# @param [Node] tag_node
		#
		# @return [String] formatted attributes
		#
		def self.formatted_attributes(tag_node)

			attributes = tag_node.childrens.select { |child|
				child.type == :tag_attribute
			}.map { |attr|
				"#{attr.data}=\"#{attr.childrens.first.data}\""
			}

			attributes.join ' '
		end
	end
end
