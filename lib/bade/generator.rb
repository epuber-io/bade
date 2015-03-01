require_relative 'node'

module Bade
	class Generator
    require_relative 'generator/html_generator'
    require_relative 'generator/ruby_generator'

		# @param [Node] root
		#
		# @return [Lambda]
		#
		def self.node_to_lambda(root, new_line: "\n", indent: "\t", filename: '')

		end
	end
end
