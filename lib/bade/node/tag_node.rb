require_relative '../node'


module Bade
	class TagNode < Node
		attr_forw_accessor :name, :data

		# @return [Array<TagAttributeNode>]
		#
		attr_reader :attributes

		def initialize(*args)
			super(*args)

			@attributes = []
		end

		# @param [Node] node
		#
		def << (node)
			if node.type == :tag_attribute
				node.parent = self
				@attributes << node
			else
				super
			end
		end
	end
end
