require_relative '../helper'

include RJade::Spec

describe Parser do

	it 'should parse code' do
		source = '
- if true
	a text
- else
	b text_b
- end
'
		expected = '<a>text</a>'

		assert_html expected, source
	end


	it 'parse output from ruby code' do
		source = '
div
	!= "abc".upcase
'
		expected = '<div>ABC</div>'

		assert_html expected, source
	end

end
