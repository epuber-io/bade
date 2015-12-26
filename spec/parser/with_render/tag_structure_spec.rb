require_relative '../../helper'

describe Bade::Parser do

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

  it 'should parse piped text started on next line' do
    source = '
|
  text aaa'
    expected = 'text aaa'
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

    it 'supports mixin expansion' do
      source = %q{
mixin abc()
  div
    - default_block.call

a: +abc() text
}
      expected = %q{<a><div>text</div></a>}
      assert_html expected, source
    end

    it 'supports tag class with expansion' do
      source = %q{
li.selected: a(href: "/href/text") text
}
      expected = %q{<li class="selected"><a href="/href/text">text</a></li>}
      assert_html expected, source
    end

    it 'supports tag id with expansion' do
      source = %q{
li#selected: a(href: "/href/text") text
}
      expected = %q{<li id="selected"><a href="/href/text">text</a></li>}
      assert_html expected, source
    end

    it 'supports tag id and class with expansion' do
      source = %q{
li.selected#id_li: a(href: "/href/text") text
}
      expected = %q{<li class="selected" id="id_li"><a href="/href/text">text</a></li>}
      assert_html expected, source
    end
  end


  context 'normal comments' do
    it 'should parse one lined comment' do
      source = '// commented text'
      expected = ''
      assert_html expected, source

      lambda_str = lambda_str_from_bade_code(source)
      expect(lambda_str).to include '# commented text'
    end

    it 'should parse multi lined comment' do
      source = '
// comment
    that continues to next line
     so we can comment our code
       and other people will understand us'

      expected = ''
      assert_html expected, source

      lambda_str = lambda_str_from_bade_code(source)
      expect(lambda_str).to include %q{# comment
#that continues to next line
# so we can comment our code
#   and other people will understand us}
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

    it 'should parse comment with immediate text after' do
      source = %q{

      //<p>baf</p>

}
      expected = ''
      assert_html expected, source
    end

    it 'should parse comment in html tag block' do
      source = %q{
<h1>Header</h1>
  //<p>baf</p>

}
      expected = '<h1>Header</h1>'
      assert_html expected, source
    end
  end

  context 'html comments' do
    it 'should parse html comments' do
      source = '//! html comment'
      expected = '<!-- html comment -->'
      assert_html expected, source
    end

    it 'should parse multi lined comments' do
      source = '
//! html comment
  _nested
'
      expected = '<!-- html comment_nested -->'

      assert_html expected, source
    end

    it 'should parse multi lined comments in between tags' do
      source = '
a text
//! html comment
  _nested
b b_text
'
      expected = '<a>text</a><!-- html comment_nested --><b>b_text</b>'

      assert_html expected, source
    end
  end

  context 'class' do
    it 'should parse tag with class name' do
      source = 'a.class_name text'
      expected = '<a class="class_name">text</a>'
      assert_html expected, source
    end

    it 'should parse tags with only class name' do
      source = '.class_name text'
      expected = '<div class="class_name">text</div>'
      assert_html expected, source
    end

    it 'should merge all classes to one attribute item' do
      source = 'a.class_1.class_2 some text'
      expected = '<a class="class_1 class_2">some text</a>'
      assert_html expected, source
    end
  end

  context 'id' do
    it 'should parse tag with id name' do
      source = 'a#id_name text'
      expected = '<a id="id_name">text</a>'
      assert_html expected, source
    end

    it 'should parse tags with only id name' do
      source = '#id_name text'
      expected = '<div id="id_name">text</div>'
      assert_html expected, source
    end
  end

  context 'id and classes' do
    it 'should parse both' do
      source = 'a.class_name#id_name text'
      expected = '<a class="class_name" id="id_name">text</a>'
      assert_html expected, source
    end

    it 'should parse both' do
      source = 'a#id_name.class_name text'
      expected = '<a id="id_name" class="class_name">text</a>'
      assert_html expected, source
    end
  end

  context 'autoclose tag' do
    it 'should autoclose tag when there is no content' do
      source = 'a'
      expected = '<a/>'
      assert_html expected, source
    end
  end

  context 'inline html code' do
    it 'should support inline xhtml code' do
      source = '<a href="dasdsad">asdfsfds</a>'
      expected = source
      assert_html expected, source
    end

    it 'should support inline nested xhtml code' do
      source = '
<a href="dasdsad">
  | asdfsfds
</a>
'
      expected = '<a href="dasdsad">asdfsfds</a>'
      assert_html expected, source
    end
  end
end
