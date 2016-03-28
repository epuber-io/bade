require_relative '../../helper'

describe Bade::Parser do
  context 'interpolation' do
    it 'parse simple unescaping interpolation' do
      source = <<-BADE.strip_heredoc
        tag text bla \#{'text'}
      BADE

      expected = '<tag>text bla text</tag>'
      assert_html expected, source
    end

    it 'parse simple escaping interpolation' do
      source = <<-BADE.strip_heredoc
        tag text bla &{ '<>' }
      BADE

      expected = '<tag>text bla &lt;&gt;</tag>'
      assert_html expected, source
    end

    it 'parse simple escaping interpolation' do
      source = <<-BADE.strip_heredoc
        tag text bla &{ '&&&&&&&&&&&' }
      BADE

      expected = '<tag>text bla &amp;&amp;&amp;&amp;&amp;&amp;&amp;&amp;&amp;&amp;&amp;</tag>'
      assert_html expected, source
    end
  end
end
