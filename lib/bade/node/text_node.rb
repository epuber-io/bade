# frozen_string_literal: true

module Bade
  class TextNode < Node
    # @return [String]
    #
    attr_accessor :text

    # @return [Bool]
    #
    attr_accessor :escaped

    def to_s
      text || type
    end

    def inspect
      if text
        text.inspect
      else
        type.inspect
      end
    end
  end
end
