
module RJade
	module Runtime
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
					raise "`#{@name}` must have block definition"
				else
					@block.call(*args)
				end
			end
		end
	end
end
