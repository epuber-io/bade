require_relative '../node'


module Bade
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
    def allowed_parameter_types
      [:mixin_param, :mixin_key_param, :mixin_block_param]
    end
  end

  class MixinCallNode < MixinCommonNode
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
            # skip newlines at start
            return self
          end

          @default_block = Node.create(:mixin_block, self)
        end

        @default_block << node
      end
    end
  end
end
