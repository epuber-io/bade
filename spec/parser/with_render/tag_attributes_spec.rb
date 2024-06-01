require_relative '../../helper'

describe Bade::Parser do
  context 'tag attributes' do
    it 'should parse one attribute' do
      source = <<~BADE
        a(href: 'href_text')
      BADE

      expected = '<a href="href_text"/>'
      assert_html expected, source
    end

    it 'should parse one attribute and text after' do
      source = <<~BADE
        a(href: 'href_text') abc
      BADE

      expected = '<a href="href_text">abc</a>'
      assert_html expected, source
    end


    it 'should parse two attributes' do
      source = <<~BADE
        a(href: 'href_text', id : 'id_text')
      BADE

      expected = '<a href="href_text" id="id_text"/>'
      assert_html expected, source
    end


    it 'should parse two attributes and text' do
      source = <<~BADE
        a(href: 'href_text', id : 'id_text') abc_text_haha
      BADE

      expected = '<a href="href_text" id="id_text">abc_text_haha</a>'
      assert_html expected, source
    end


    it 'should parse two attributes without spaces' do
      source = <<~BADE
        a(href:'href_text',id:'id_text')
      BADE

      expected = '<a href="href_text" id="id_text"/>'

      assert_html expected, source
    end


    it 'should parse two attributes and text nested' do
      source = <<~BADE
        a(href : 'href_text', id : 'id_text') abc_text_haha
          b(class : 'aaa') bbb
      BADE

      expected = '<a href="href_text" id="id_text">abc_text_haha<b class="aaa">bbb</b></a>'

      assert_html expected, source
    end

    it 'should parse attributes with double quoted attributes' do
      source = <<~BADE
        a(href : "href_text", id:"id_text") abc_text_haha
          b(class : "aaa") bbb
      BADE

      expected = '<a href="href_text" id="id_text">abc_text_haha<b class="aaa">bbb</b></a>'
      assert_html expected, source
    end

    it 'removes attributes when the value is nil' do
      source = <<~BADE
        a(href: nil)
      BADE

      expected = '<a/>'
      assert_html expected, source
    end

    it 'support if in attributes' do
      source = <<~BADE
        a(href: 'selected' if true)
      BADE

      expected = '<a href="selected"/>'
      assert_html expected, source
    end

    it 'support if in attributes' do
      source = <<~BADE
        a(href: 'selected' if false)
      BADE

      expected = '<a/>'
      assert_html expected, source
    end

    it 'marks spaces between tag and attributes as start of text' do
      source = <<~BADE
        tag (start of the text)
      BADE

      expected = '<tag>(start of the text)</tag>'
      assert_html expected, source
    end

    it 'escapes tag attributes' do
      source = <<~BADE
        tag(class: 'a&b + "c"')
      BADE

      expected = '<tag class="a&amp;b + &quot;c&quot;"/>'
      assert_html expected, source
    end
  end
end
