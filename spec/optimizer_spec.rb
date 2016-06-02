require_relative 'helper'


describe Bade::Optimizer do
  include ASTHelper

  context 'merging static texts' do
    it 'can join multiple static texts together' do
      # Given
      root = n(:root,
               text('empty1'),
               text('empty'),
               text('empty'),
               text('empty'),
               text('empty'),
               text('empty'),
               text('empty'),
               text('empty2'))

      # When
      optimizer = Bade::Optimizer.new(root)
      new_root = optimizer.optimize

      # Then
      expected_root = n(:root,
                        n(:static_text, value: 'empty1emptyemptyemptyemptyemptyemptyempty2'))

      expect(new_root).to eq expected_root
    end

    it 'can join static texts separated' do
      # Given
      root = n(:root,
               text('empty1'),
               text('empty'),
               text('empty'),
               text('empty'),
               newline,
               text('empty'),
               text('empty'),
               text('empty'),
               text('empty2'))

      # When
      optimizer = Bade::Optimizer.new(root)
      new_root = optimizer.optimize

      # Then
      expected_root = n(:root,
                        text('empty1emptyemptyempty'),
                        newline,
                        text('emptyemptyemptyempty2'))

      expect(new_root).to eq expected_root
    end
  end
end
