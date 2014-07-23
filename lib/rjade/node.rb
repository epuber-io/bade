
require_relative 'node/base_node'
require_relative 'node/tag_node'
require_relative 'parser'

module RJade

	Node.register_type :text
	Node.register_type :newline
	Node.register_type :ruby_code

	Node.register_type :comment
	Node.register_type :html_comment

	Node.register_type :output



	# Extend Node class, so we can instantiate typed class
	class Node
		def self.create(type, parent)
			klass = self.registered_types[type]

			if klass.nil?
				raise Parser::ParserInternalError, "undefined type for #{type.inspect}"
			end

			klass.new(type, parent)
		end
	end

	class MixinDeclarationNode < Node
		register_type :mixin_declaration
	end

	class MixinCallNode < Node
		register_type :mixin_call
	end
end
