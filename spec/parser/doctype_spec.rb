require_relative '../helper'

include Bade::Spec

describe Parser do
  describe 'doctype' do

    it 'supports `doctype xml`' do
      source = 'doctype xml'
      expected = '<?xml version="1.0" encoding="utf-8" ?>'
      assert_html expected, source
    end

    it 'supports `doctype html`' do
      source = 'doctype html'
      expected = '<!DOCTYPE html>'
      assert_html expected, source
    end

  end
end
