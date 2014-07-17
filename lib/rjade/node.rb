
require_relative 'node/base_node'
require_relative 'node/tag_node'

module RJade

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
