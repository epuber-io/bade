
module Bade
	module Runtime
		class RuntimeError < ::StandardError; end

		class Block

			# @return [Proc]
			#
			attr_reader :block

			# @return [String]
			#
			attr_reader :name

			# @param [String] name
			#
			def initialize(name, &block)
				@name = name
				@block = lambda &block unless block.nil?
			end

			def call(*args)
				@block.call(*args) unless @block.nil?
			end

			def call!(*args)
				if @block.nil?
					raise RuntimeError, "`#{@name}` must have block definition"
				else
					@block.call(*args)
				end
			end
		end
	end

	def block(name, &block)
		Runtime::Block.new(name, &block)
	end
end
