require_relative '../helper'

include RJade::Spec

describe Parser do

	it 'should parse simple string' do
		source = 'abc ahoj'
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



	it 'should parse block expansion' do
		source = 'a: b text'
		expected = '<a><b>text</b></a>'

		assert_html expected, source
	end

	it 'should parse tags with namespace' do
		source = 'a:b text'
		expected = '<a:b>text</a:b>'

		assert_html expected, source
	end

	it 'should parse more nested block expansion' do
		source = 'a: b: c: d text'
		expected = '<a><b><c><d>text</d></c></b></a>'

		assert_html expected, source
	end

	it 'should parse more nested block expansion and normal tag' do
		source = '
a: b: c: d text
abc text_abc
'
		expected = '<a><b><c><d>text</d></c></b></a><abc>text_abc</abc>'

		assert_html expected, source
	end

	it 'should parse more nested block expansion and normal sub tag' do
		source = '
a: b: c: d text
	abc text_abc
'
		expected = '<a><b><c><d>text<abc>text_abc</abc></d></c></b></a>'

		assert_html expected, source
	end
end
