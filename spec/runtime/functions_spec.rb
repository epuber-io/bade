# frozen_string_literal: true

require_relative '../helper'


describe Bade::Runtime::RenderBinding do
  context '#__html_escaped' do
    let(:binding) { Bade::Runtime::RenderBinding.new }

    it 'supports nil values' do
      value = binding.__html_escaped(nil)
      expect(value).to be_nil
    end

    it 'escapes single quotes' do
      value = binding.__html_escaped('""')
      expect(value).to eq '&quot;&quot;'
    end
  end
end
