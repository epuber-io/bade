
require_relative 'node/base_node'
require_relative 'node/tag_node'

module RJade

	Node.register_type :text
	Node.register_type :newline
	Node.register_type :ruby_code

	Node.register_type :comment
	Node.register_type :html_comment



	# Extend Node class, so we can instantiate typed class
	class Node
		def self.create(type, parent)
			klass = self.registered_types[type]

			if klass.nil?
				raise StandardError, "undefined type for #{type.inspect}"
			end

			klass.new(type, parent)
		end
	end

end
