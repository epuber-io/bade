
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
	Node.register_type :mixin_block_param
	Node.register_type :mixin_block


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
			super

			@params = []
		end

		def << (node)
			if allowed_parameter_types.include?(node.type)
				node.parent = self
				@params << node
			else
				super
			end
		end
	end

	class MixinDeclarationNode < MixinCommonNode
		register_type :mixin_declaration

		def allowed_parameter_types
			[:mixin_param, :mixin_key_param, :mixin_block_param]
		end
	end

	class MixinCallNode < MixinCommonNode
		register_type :mixin_call

		attr_reader :blocks

		attr_reader :default_block

		def initialize(*args)
			super

			@blocks = []
		end

		def allowed_parameter_types
			[:mixin_param, :mixin_key_param]
		end

		def << (node)
			if allowed_parameter_types.include?(node.type)
				node.parent = self
				@params << node
			elsif node.type == :mixin_block
				node.parent = self
				@blocks << node
			else
				if @default_block.nil?
					if node.type == :newline
						return self
					end

					@default_block = Node.create(:mixin_block, self)
				end

				puts node.type.inspect
				@default_block << node
			end
		end
	end


	class MixinKeyedParamNode < Node
		register_type :mixin_key_param

		attr_forw_accessor :name, :data

		attr_accessor :value
	end
end
