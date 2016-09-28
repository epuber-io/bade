# frozen_string_literal: true

require_relative 'helper'


describe Bade::Precompiled do
  it 'handles loading empty precompiled files with raising LoadError' do
    File.write('/tmp/bade_experiment', '')

    expect do
      Bade::Precompiled.from_yaml_file('/tmp/bade_experiment')
    end.to raise_error LoadError
  end
end
