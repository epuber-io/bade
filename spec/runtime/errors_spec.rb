# frozen_string_literal: true

require_relative '../helper'


describe Bade::Renderer do
  context 'mixins wrong usage errors' do
    it 'raises meaningful message about wrong number of parameters' do
      source = <<-BADE.strip_heredoc
        mixin abc(one)

        +abc()
      BADE

      expect do
        assert_html('', source, print_error_if_error: false)
      end.to raise_error ArgumentError, 'wrong number of arguments (given 0, expected 1) for mixin `abc`'
    end

    it 'raises meaningful message about unknown key-value parameter' do
      source = <<-BADE.strip_heredoc
        mixin abc(one: nil)

        +abc(two: 'str')
      BADE

      expect do
        assert_html('', source, print_error_if_error: false)
      end.to raise_error ArgumentError, 'unknown key-value argument `two` for mixin `abc`'
    end

    it 'not raises error when calling mixin with empty block' do
      source = <<-BADE.strip_heredoc
        mixin abc
        +abc
      BADE

      expect do
        assert_html('', source, print_error_if_error: false)
      end.to_not raise_error
    end
  end
end
