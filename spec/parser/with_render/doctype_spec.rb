require_relative '../../helper'

describe Bade::Parser do
  describe 'doctype' do

    it 'supports `doctype xml`' do
      source = <<-BADE.strip_heredoc
        doctype xml
      BADE

      expected = '<?xml version="1.0" encoding="utf-8" ?>'
      assert_html expected, source
    end

    it 'supports `doctype html`' do
      source = <<-BADE.strip_heredoc
        doctype html
      BADE

      expected = '<!DOCTYPE html>'
      assert_html expected, source
    end

  end
end
