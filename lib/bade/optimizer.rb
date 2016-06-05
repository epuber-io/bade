# frozen_string_literal: true


module Bade
  class Optimizer
    # @param [Array<Bade::AssemblyInstruction>] instructions
    #
    def initialize(instructions)
      @instructions = Marshal.load(Marshal.dump(instructions))
    end

    # @return [Bade::Node]
    #
    def optimize
      previous_inst = nil

      @instructions.delete_if do |inst|
        if previous_inst && previous_inst.type == :static_text && inst.type == :static_text
          previous_inst.value += inst.value
          true
        else
          previous_inst = inst
          false
        end
      end
    end
  end
end
