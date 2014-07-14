
module JadeRuby
	class HTMLGenerator

		# @param [Node] root node
		# @return [String]
		#
		def self.node_to_html(root, new_line: "\n", indent: "\t")
			node_to_html_array(root, new_line: new_line, indent: indent).join
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
					buff << root.text

				when :tag
					buff << "<#{root.text}>" + new_line
					append_childrens.call(1)
					buff << "</#{root.text}>" + new_line
			end

			buff
		end
	end
end
