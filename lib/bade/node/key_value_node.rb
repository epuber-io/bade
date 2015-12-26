# frozen_string_literal: true

module Bade
  class KeyValueNode < Node
    # @return [String]
    #
    attr_accessor :name

    # @return [Any]
    #
    attr_accessor :value
  end
end
