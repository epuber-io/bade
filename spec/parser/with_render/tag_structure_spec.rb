require_relative '../../helper'

describe Bade::Parser do
  it 'should parse simple string' do
    source = <<-BADE.strip_heredoc
      abc ahoj
    BADE

    expected = '<abc>ahoj</abc>'
    assert_html expected, source
  end

  it 'should parse simple multi lined string' do
    source = <<-BADE.strip_heredoc
      a baf
        b
          ab ad
      c aaaa
        d abc
    BADE

    expected = '<a>baf<b><ab>ad</ab></b></a><c>aaaa<d>abc</d></c>'
    assert_html expected, source
  end

  it 'should parse simple multi lined html' do
    source = <<-BADE.strip_heredoc
      html
        head
          title Title
        body
          div
            p text
    BADE

    expected = <<-HTML.strip_heredoc.gsub(/\s/, '')
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
    HTML

    assert_html expected, source
  end


  it 'should parse piped text' do
    source = <<-BADE.strip_heredoc
      | text
      a
        | a_text1
    BADE

    expected = 'text<a>a_text1</a>'
    assert_html expected, source
  end

  it 'should parse advanced piped text' do
    source = <<-BADE.strip_heredoc
      | text
          text2
           text3
            text4
      a
        | a_text1
          a_text2
    BADE

    expected = 'texttext2 text3  text4<a>a_text1a_text2</a>'
    assert_html expected, source
  end

  it 'should parse piped text started on next line' do
    source = <<-BADE.strip_heredoc
      |
        text aaa
    BADE

    expected = 'text aaa'
    assert_html expected, source
  end

  it 'should handle trailing colon in tag name' do
    source = <<-BADE.strip_heredoc
      tag: baf
    BADE

    expected = '<tag><baf/></tag>'
    assert_html expected, source
  end

  context 'block expansion' do
    it 'should parse block expansion' do
      source = <<-BADE.strip_heredoc
        a: b text
      BADE

      expected = '<a><b>text</b></a>'
      assert_html expected, source
    end

    it 'should parse tags with namespace' do
      source = <<-BADE.strip_heredoc
        a:b text
      BADE

      expected = '<a:b>text</a:b>'
      assert_html expected, source
    end

    it 'should parse more nested block expansion' do
      source = <<-BADE.strip_heredoc
        a: b: c: d text
      BADE

      expected = '<a><b><c><d>text</d></c></b></a>'
      assert_html expected, source
    end

    it 'should parse more nested block expansion and normal tag' do
      source = <<-BADE.strip_heredoc
        a: b: c: d text
        abc text_abc
      BADE

      expected = '<a><b><c><d>text</d></c></b></a><abc>text_abc</abc>'
      assert_html expected, source
    end

    it 'should parse more nested block expansion and normal sub tag' do
      source = <<-BADE.strip_heredoc
        a: b: c: d text
          abc text_abc
      BADE

      expected = '<a><b><c><d>text<abc>text_abc</abc></d></c></b></a>'
      assert_html expected, source
    end

    it 'supports mixin expansion' do
      source = <<-BADE.strip_heredoc
        mixin abc()
          div
            - default_block.call

        a: +abc() text
      BADE

      expected = '<a><div>text</div></a>'
      assert_html expected, source
    end

    it 'supports tag class with expansion' do
      source = <<-BADE.strip_heredoc
        li.selected: a(href: "/href/text") text
      BADE

      expected = '<li class="selected"><a href="/href/text">text</a></li>'
      assert_html expected, source
    end

    it 'supports tag id with expansion' do
      source = <<-BADE.strip_heredoc
        li#selected: a(href: "/href/text") text
      BADE

      expected = '<li id="selected"><a href="/href/text">text</a></li>'
      assert_html expected, source
    end

    it 'supports tag id and class with expansion' do
      source = <<-BADE.strip_heredoc
        li.selected#id_li: a(href: "/href/text") text
      BADE

      expected = '<li class="selected" id="id_li"><a href="/href/text">text</a></li>'
      assert_html expected, source
    end
  end

  context 'normal comments' do
    it 'should parse one lined comment' do
      source = <<-BADE.strip_heredoc
        // commented text
      BADE

      expected = ''
      assert_html expected, source

      lambda_str = lambda_str_from_bade_code(source)
      expect(lambda_str).to include '# commented text'
    end

    it 'should parse multi lined comment' do
      source = <<-BADE.strip_heredoc
        // comment
            that continues to next line
             so we can comment our code
               and other people will understand us
      BADE

      expected = ''
      assert_html expected, source

      lambda_str = lambda_str_from_bade_code(source)
      expect(lambda_str).to include <<-BADE.strip_heredoc.strip
        # comment
        #that continues to next line
        # so we can comment our code
        #   and other people will understand us
      BADE
    end

    it 'should parse multi lined comment with other tags' do
      source = <<-BADE.strip_heredoc
        a text
        // comment
            that continues to next line
             so we can comment our code
              and other people will understand us
        a text
      BADE

      expected = '<a>text</a><a>text</a>'
      assert_html expected, source
    end


    it 'should parse simple comment nested in tag' do
      source = <<-BADE.strip_heredoc
        a text
          // comment
          | text2
      BADE

      expected = '<a>texttext2</a>'
      assert_html expected, source
    end

    it 'should parse comment with immediate text after' do
      source = <<-BADE.strip_heredoc
        //<p>baf</p>
      BADE

      expected = ''
      assert_html expected, source
    end

    it 'should parse comment in html tag block' do
      source = <<-BADE.strip_heredoc
        <h1>Header</h1>
          //<p>baf</p>
      BADE

      expected = '<h1>Header</h1>'
      assert_html expected, source
    end
  end

  context 'html comments' do
    it 'should parse html comments' do
      source = <<-BADE.strip_heredoc
        //! html comment
      BADE

      expected = '<!-- html comment -->'
      assert_html expected, source
    end

    it 'should parse multi lined comments' do
      source = <<-BADE.strip_heredoc
        //! html comment
          _nested
      BADE

      expected = '<!-- html comment_nested -->'
      assert_html expected, source
    end

    it 'should parse multi lined comments in between tags' do
      source = <<-BADE.strip_heredoc
        a text
        //! html comment
          _nested
        b b_text
      BADE

      expected = '<a>text</a><!-- html comment_nested --><b>b_text</b>'
      assert_html expected, source
    end
  end

  context 'class' do
    it 'should parse tag with class name' do
      source = <<-BADE.strip_heredoc
        a.class_name text
      BADE

      expected = '<a class="class_name">text</a>'
      assert_html expected, source
    end

    it 'should parse tags with only class name' do
      source = <<-BADE.strip_heredoc
        .class_name text
      BADE

      expected = '<div class="class_name">text</div>'
      assert_html expected, source
    end

    it 'should merge all classes to one attribute item' do
      source = <<-BADE.strip_heredoc
        a.class_1.class_2 some text
      BADE

      expected = '<a class="class_1 class_2">some text</a>'
      assert_html expected, source
    end
  end

  context 'id' do
    it 'should parse tag with id name' do
      source = <<-BADE.strip_heredoc
        a#id_name text
      BADE

      expected = '<a id="id_name">text</a>'
      assert_html expected, source
    end

    it 'should parse tags with only id name' do
      source = <<-BADE.strip_heredoc
        #id_name text
      BADE

      expected = '<div id="id_name">text</div>'
      assert_html expected, source
    end
  end

  context 'id and classes' do
    it 'should parse both' do
      source = <<-BADE.strip_heredoc
          a.class_name#id_name text
      BADE

      expected = '<a class="class_name" id="id_name">text</a>'
      assert_html expected, source
    end

    it 'should parse both' do
      source = <<-BADE.strip_heredoc
          a#id_name.class_name text
      BADE

      expected = '<a id="id_name" class="class_name">text</a>'
      assert_html expected, source
    end
  end

  context 'autoclose tag' do
    it 'should autoclose tag when there is no content' do
      source = <<-BADE.strip_heredoc
          a
      BADE

      expected = '<a/>'
      assert_html expected, source
    end
  end

  context 'inline html code' do
    it 'should support inline xhtml code' do
      source = <<-BADE.strip_heredoc
          <a href="dasdsad">asdfsfds</a>
      BADE

      expected = source.strip
      assert_html expected, source
    end

    it 'should support inline nested xhtml code' do
      source = <<-BADE.strip_heredoc
        <a href="dasdsad">
          | asdfsfds
        </a>
      BADE

      expected = '<a href="dasdsad">asdfsfds</a>'
      assert_html expected, source
    end
  end

  context 'conditional output code' do
    it 'should not render tag when the value is nil' do
      source = <<-SOURCE.strip_heredoc
        tag?= nil
      SOURCE

      expected = ''
      assert_html expected, source
    end

    it 'should not render tag when the value is nil' do
      source = <<-SOURCE.strip_heredoc
        tag
          ?= nil
      SOURCE

      expected = ''
      assert_html expected, source
    end

    it 'should not render tag when the value is nil' do
      source = <<-SOURCE.strip_heredoc
        tag
          ?= val
      SOURCE

      expected = ''
      assert_html expected, source, vars: {val: nil}
    end

    it 'should not render tag when values are nil' do
      source = <<-SOURCE.strip_heredoc
        tag
          ?= val
          ?= val2
          ?= val3
      SOURCE

      expected = ''
      assert_html expected, source, vars: {val: nil, val2: nil, val3: nil}
    end

    it 'should render tag when the value is not nil' do
      source = <<-SOURCE.strip_heredoc
        tag
          ?= val
      SOURCE

      expected = '<tag>abc</tag>'
      assert_html expected, source, vars: {val: 'abc'}
    end

    it 'should render tag when values are not nil' do
      source = <<-SOURCE.strip_heredoc
        tag
          ?= val
          ?= val2
          ?= val3
      SOURCE

      expected = '<tag>truetruetrue</tag>'
      assert_html expected, source, vars: {val: true, val2: true, val3: true}
    end

    it 'should render tag when the value is not nil' do
      source = <<-SOURCE.strip_heredoc
        tag?= "abc"
      SOURCE

      expected = '<tag>abc</tag>'
      assert_html expected, source
    end
  end
end
