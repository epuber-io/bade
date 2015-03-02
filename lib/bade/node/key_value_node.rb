require_relative '../node'


module Bade
  class KeyValueNode < Node
    attr_forw_accessor :name, :data

    attr_accessor :value
  end
end
