# frozen_string_literal: true

require_relative '../helper'


describe Bade::Renderer do
  context 'mixins wrong usage errors' do
    it 'raises meaningful message about wrong number of parameters' do
      source = <<~BADE
        mixin abc(one)

        +abc()
      BADE

      expect do
        assert_html('', source, print_error_if_error: false)
      end.to raise_error(Bade::Runtime::ArgumentError) { |error|
        expect(error.message).to match(/wrong number of arguments \(given 0, expected 1\) for mixin `abc`/)
      }
    end

    it 'raises meaningful message about unknown key-value parameter' do
      source = <<~BADE
        mixin abc(one: nil)

        +abc(two: 'str')
      BADE

      expect do
        assert_html('', source, print_error_if_error: false)
      end.to raise_error(Bade::Runtime::ArgumentError) { |error| expect(error.message).to match(/^unknown key-value argument `:?two` for mixin `abc`$/) }
    end

    it 'not raises error when calling mixin with empty block' do
      source = <<~BADE
        mixin abc
        +abc
      BADE

      expect do
        assert_html('', source, print_error_if_error: false)
      end.to_not raise_error
    end
  end
end
