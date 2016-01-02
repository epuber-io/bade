require_relative '../../helper'

describe Bade::Parser do
	context 'interpolation' do
		it 'parse simple unescaping interpolation' do
			source = <<-BADE.strip_heredoc
				tag text bla \#{'text'}
			BADE

      expected = %q{<tag>text bla text</tag>}
			assert_html expected, source
		end

		it 'parse simple escaping interpolation' do
			source = <<-BADE.strip_heredoc
        tag text bla &{ '<>' }
      BADE

      expected = %q{<tag>text bla &lt;&gt;</tag>}
			assert_html expected, source
		end
	end
end
