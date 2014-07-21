require_relative '../helper'

include RJade::Spec

describe Parser do

	it 'should parse simple string' do
		source   = 'abc ahoj'
		expected = '<abc>ahoj</abc>'

		assert_html expected, source
	end

	it 'should parse simple multi lined string' do

		source = '
a baf
	b
		ab ad
c aaaa
	d abc
'

		expected = '<a>baf<b><ab>ad</ab></b></a><c>aaaa<d>abc</d></c>'

		assert_html expected, source
	end

	it 'should parse simple multi lined html' do

		source = '
html
	head
		title Title
	body
		div
			p text
'

		expected = '
<html>
	<head>
		<title>Title</title>
	</head>
	<body>
		<div>
			<p>text</p>
		</div>
	</body>
</html>
'.gsub(/\s/, '')

		assert_html expected, source
	end


	it 'should parse piped text' do
		source = '
| text
a
	| a_text1'

		expected = 'text<a>a_text1</a>'

		assert_html expected, source
	end

	it 'should parse advanced piped text' do
		source = '
| text
	text2
	 text3
	  text4
a
	| a_text1
		a_text2'

		expected = 'texttext2 text3  text4<a>a_text1a_text2</a>'

		assert_html expected, source
	end

	context 'block expansion' do
		it 'should parse block expansion' do
			source   = 'a: b text'
			expected = '<a><b>text</b></a>'

			assert_html expected, source
		end

		it 'should parse tags with namespace' do
			source   = 'a:b text'
			expected = '<a:b>text</a:b>'

			assert_html expected, source
		end

		it 'should parse more nested block expansion' do
			source   = 'a: b: c: d text'
			expected = '<a><b><c><d>text</d></c></b></a>'

			assert_html expected, source
		end

		it 'should parse more nested block expansion and normal tag' do
			source   = '
a: b: c: d text
abc text_abc
'
			expected = '<a><b><c><d>text</d></c></b></a><abc>text_abc</abc>'

			assert_html expected, source
		end

		it 'should parse more nested block expansion and normal sub tag' do
			source   = '
a: b: c: d text
	abc text_abc
'
			expected = '<a><b><c><d>text<abc>text_abc</abc></d></c></b></a>'

			assert_html expected, source
		end
	end


	context 'normal comments' do
		it 'should parse one lined comment' do
			source = '// commented text'
			expected = ''
			assert_html expected, source
		end

		it 'should parse multi lined comment' do
			source = '
// comment
	that continues to next line
		so we can comment our code
			and other people will understand us'

			expected = ''
			assert_html expected, source
		end

		it 'should parse multi lined comment with other tags' do
			source = '
a text
// comment
	that continues to next line
		so we can comment our code
			and other people will understand us
a text
'

			expected = '<a>text</a><a>text</a>'
			assert_html expected, source
		end


		it 'should parse simple comment nested in tag' do
			source = '
a text
	// comment
	| text2
'
			expected = '<a>texttext2</a>'

			assert_html expected, source
		end
	end
end
