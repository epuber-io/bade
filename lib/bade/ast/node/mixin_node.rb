# frozen_string_literal: true

module Bade
  module AST
    class MixinCommonNode < Node
      # @return [String]
      #
      attr_accessor :name

      # @return [Array<Node>]
      #
      def params
        children.select { |n| allowed_parameter_types.include?(n.type) }
      end

      # @param [MixinCommonNode] other
      #
      def ==(other)
        super && name == other.name
      end
    end

    class MixinDeclarationNode < MixinCommonNode
      def allowed_parameter_types
        %i[mixin_param mixin_key_param mixin_block_param]
      end
    end

    class MixinBlockNode < MixinCommonNode
      def allowed_parameter_types
        %i[mixin_param mixin_key_param]
      end
    end

    class MixinCallNode < MixinCommonNode
      def allowed_parameter_types
        %i[mixin_param mixin_key_param]
      end

      def blocks
        children.select { |a| a.type == :mixin_block }
      end
    end
  end
end
