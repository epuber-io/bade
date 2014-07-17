
class Object
	def self.attr_forw_accessor(name, forw_name)
		define_method(name) {
			self.send(forw_name)
		}
		define_method(name.to_s + '=') { |*args|
			self.send(forw_name.to_s + '=', *args)
		}
	end
end


module RJade
	class Node

		# @return [Symbol]
		#
		attr_reader :type


		# @return [Int] line number
		#
		attr_accessor :lineno

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

		# @param [Node] node
		#
		def << (node)
			if node.is_a? Symbol
				Node.new(node, self)
			else
				@childrens << node
			end

			self
		end


		@@registered_types = {}

		# @return [Hash<Symbol, Class>]
		def self.registered_types
			@@registered_types
		end

		# @param [Symbol] type
		# @param [Class] klass  registering class
		#
		def self.register_type(type, klass = self)
			raise StandardError, "Class #{klass} should be subclass of #{self}" unless klass < Node

			self.registered_types[type] = klass
		end
	end
end
