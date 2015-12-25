require_relative '../../helper'

include Bade::Spec

describe Parser do

	it 'should parse one attribute' do
		source = "
a(href: 'href_text')
"

		expected = '<a href="href_text"/>'

		assert_html expected, source
	end

	it 'should parse one attribute and text after' do
		source = "
a(href: 'href_text') abc
"

		expected = '<a href="href_text">abc</a>'

		assert_html expected, source
	end


	it 'should parse two attributes' do
		source = "
a(href: 'href_text', id : 'id_text')
"

		expected = '<a href="href_text" id="id_text"/>'

		assert_html expected, source
	end


	it 'should parse two attributes and text' do
		source = "
a(href: 'href_text', id : 'id_text') abc_text_haha
"

		expected = '<a href="href_text" id="id_text">abc_text_haha</a>'

		assert_html expected, source
	end


	it 'should parse two attributes without spaces' do
		source = "
a(href:'href_text',id:'id_text')
"

		expected = '<a href="href_text" id="id_text"/>'

		assert_html expected, source
	end


	it 'should parse two attributes and text nested' do
		source = "
a(href : 'href_text', id : 'id_text') abc_text_haha
	b(class : 'aaa') bbb
"

		expected = '<a href="href_text" id="id_text">abc_text_haha<b class="aaa">bbb</b></a>'

		assert_html expected, source
	end

	it 'should parse attributes with double quoted attributes' do
		source = '
a(href : "href_text", id:"id_text") abc_text_haha
	b(class : "aaa") bbb
'

		expected = '<a href="href_text" id="id_text">abc_text_haha<b class="aaa">bbb</b></a>'

		assert_html expected, source
  end

  it 'removes attributes when the value is nil' do
    source = 'a(href: nil)'
    expected = '<a/>'
    assert_html expected, source
  end

  it 'support if in attributes' do
    source = %q{a(href: 'selected' if true)}
    expected = %q{<a href="selected"/>}
    assert_html expected, source
  end

	it 'support if in attributes' do
		source = %q{a(href: 'selected' if false)}
		expected = %q{<a/>}
		assert_html expected, source
	end
end
