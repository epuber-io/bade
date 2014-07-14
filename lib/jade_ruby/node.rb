
module JadeRuby
	class Node

		# @return [Int] line number
		#
		attr_accessor :lineno


		# @return [Symbol]
		#
		attr_accessor :type

		# @return [String]
		#
		attr_accessor :data


		# @return [Node]
		#
		attr_accessor :parent

		# @return [Array<Node>]
		#
		attr_accessor :childrens


		# @param [Node] parent
		#
		def initialize(type, parent = nil)
			@type = type
			@childrens = []

			if parent
				parent << self
				@parent = parent
			end
		end

		def << (node)
			if node.is_a? Symbol
				Node.new(node, self)
			else
				@childrens << node
			end

			self
		end
	end
end
