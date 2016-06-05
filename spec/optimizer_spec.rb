require_relative 'helper'


describe Bade::Optimizer do
  context 'merging static texts' do
    it 'can join multiple static texts together' do
      # Given
      insts = [
          Bade::AssemblyInstruction.new(:static_text, 'empty1'),
          Bade::AssemblyInstruction.new(:static_text, 'empty'),
          Bade::AssemblyInstruction.new(:static_text, 'empty'),
          Bade::AssemblyInstruction.new(:static_text, 'empty'),
          Bade::AssemblyInstruction.new(:static_text, 'empty'),
          Bade::AssemblyInstruction.new(:static_text, 'empty'),
          Bade::AssemblyInstruction.new(:static_text, 'empty2'),
      ]

      # When
      optimizer = Bade::Optimizer.new(insts)
      new_insts = optimizer.optimize

      # Then
      expected = [
          Bade::AssemblyInstruction.new(:static_text, 'empty1emptyemptyemptyemptyemptyempty2'),
      ]
      expect(new_insts).to eq expected
    end

    it 'can join static texts separated' do
      # Given
      insts = [
          Bade::AssemblyInstruction.new(:static_text, 'empty1'),
          Bade::AssemblyInstruction.new(:static_text, 'empty'),
          Bade::AssemblyInstruction.new(:static_text, 'empty'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty'),
          Bade::AssemblyInstruction.new(:static_text, 'empty'),
          Bade::AssemblyInstruction.new(:static_text, 'empty'),
          Bade::AssemblyInstruction.new(:static_text, 'empty2'),
      ]

      # When
      optimizer = Bade::Optimizer.new(insts)
      new_insts = optimizer.optimize

      # Then
      expected = [
          Bade::AssemblyInstruction.new(:static_text, 'empty1emptyempty'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty'),
          Bade::AssemblyInstruction.new(:static_text, 'emptyemptyempty2'),
      ]

      expect(new_insts).to eq expected
    end

    it 'keeps dynamic' do
      # Given
      insts = [
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty1'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty2'),
      ]

      # When
      optimizer = Bade::Optimizer.new(insts)
      new_insts = optimizer.optimize

      # Then
      expected = [
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty1'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty'),
          Bade::AssemblyInstruction.new(:dynamic_value, 'empty2'),
      ]

      expect(new_insts).to eq expected
    end
  end
end
