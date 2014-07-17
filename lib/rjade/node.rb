
module RJade
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


		def self.create(type, parent)
			klass = self.registered_types[type]

			if klass.nil?
				raise StandardError, "undefined type for #{type.inspect}"
			end

			klass.new(type, parent)
		end


		protected

		@@registered_types = {}

		# @return [Hash<Symbol, Class>]
		def self.registered_types
			@@registered_types
		end

		# @param [Symbol] type
		#
		def self.register_type(type)
			puts "Registering #{type.inspect} for class #{self}"

			self.registered_types[type] = self
		end
	end




	class TagNode < Node
		register_type :tag
	end

	class TagAttribute < Node
		register_type :tag_attribute
	end

	class TextNode < Node
		register_type :text
	end

	class NewLineNode < Node
		register_type :newline
	end

	class RubyCode < Node
		register_type :ruby_code
	end

end
