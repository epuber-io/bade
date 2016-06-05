# frozen_string_literal: true


module Bade
  class AssemblyInstruction
    VALID_TYPES = [:static_text, :dynamic_value, :code]

    # @return [Symbol]
    #
    attr_accessor :type

    # @return [String]
    #
    attr_accessor :value

    def initialize(type, value)
      raise "Invalid type #{type.inspect}" unless VALID_TYPES.include?(type)

      @type = type
      @value = value
    end

    def to_s
      "(#{type.inspect} #{value.inspect})"
    end

    def inspect
      to_s
    end

    # @param other [AssemblyInstruction]
    #
    # @return [Bool]
    #
    def ==(other)
      return false unless self.class == other.class

      type == other.type && value && other.value
    end
  end
end
