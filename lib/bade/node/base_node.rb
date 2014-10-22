
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


module Bade
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

		# @param [Symbol] type
		# @param [Node] parent
		#
		def initialize(type, parent = nil)
			@type = type
			@childrens = []

			if parent
				parent << self
			end
		end

		# @param [Node] node
		#
		def << (node)
			node.parent = self
			@childrens << node

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
			raise StandardError, "Class #{klass} should be subclass of #{self}" unless klass <= Node

			self.registered_types[type] = klass
		end

	end

	class KeyValueNode < Node
		attr_forw_accessor :name, :data

		attr_accessor :value
	end
end
