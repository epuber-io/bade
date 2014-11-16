
require_relative 'node/base_node'
require_relative 'node/tag_node'
require_relative 'node/mixin_node'
require_relative 'node/doctype_node'
require_relative 'parser'

module Bade

	Node.register_type :text
	Node.register_type :newline
	Node.register_type :ruby_code

	Node.register_type :comment
	Node.register_type :html_comment

  TagNode.register_type :tag
  KeyValueNode.register_type :tag_attribute

  Node.register_type :output

	Node.register_type :mixin_param
	Node.register_type :mixin_block_param
	Node.register_type :mixin_block

  MixinCallNode.register_type :mixin_call
  MixinDeclarationNode.register_type :mixin_declaration
	KeyValueNode.register_type :mixin_key_param

	DoctypeNode.register_type :doctype


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
end
