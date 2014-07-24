
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

	Node.register_type :mixin_param


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


	class MixinCommonNode < Node

		# @return [Array<Node>]
		#
		attr_reader :params

		def initialize(*args)
			super(*args)

			@params = []
		end

		def << (node)
			if node.type == :mixin_param || node.type == :mixin_key_param
				@params << node
			else
				super(node)
			end
		end
	end

	class MixinDeclarationNode < MixinCommonNode
		register_type :mixin_declaration
	end

	class MixinCallNode < MixinCommonNode
		register_type :mixin_call
	end


	class MixinKeyedParamNode < Node
		register_type :mixin_key_param

		attr_forw_accessor :name, :data

		attr_accessor :value
	end
end
