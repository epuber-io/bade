module Bade
  class OutputNode < Node
    register_type :output

    # @return [TrueClass, FalseClass]
    #
    attr_accessor :escaped
  end
end
