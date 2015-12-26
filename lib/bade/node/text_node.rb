# frozen_string_literal: true

module Bade
  class TextNode < Node
    # @return [String]
    #
    attr_accessor :text

    # @return [Bool]
    #
    attr_accessor :escaped
  end
end
