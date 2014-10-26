require_relative '../helper'

include Bade::Spec

describe Parser do

  context 'inline code' do
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
  end

  context 'output code' do
    context 'parse output from ruby code' do
      it 'not-escaped text' do
        source = '
div
  &= "abc".upcase
abc
  &= "<>"
'
        expected = '<div>ABC</div><abc><></abc>'

        assert_html expected, source
      end

      it 'escaped text' do
        source = '
div
  = "abc".upcase
abc
  = "<>"
'
        expected = '<div>ABC</div><abc>&lt;&gt;</abc>'

        assert_html expected, source
      end

      it 'normal code after tag'
      it 'unescaped text after tag'
    end
  end
end
