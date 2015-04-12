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
  = "abc".upcase
abc
  = "<>"
'
        expected = '<div>ABC</div><abc><></abc>'

        assert_html expected, source
      end

      it 'escaped text' do
        source = '
div
  &= "abc".upcase
abc
  &= "<>"
'
        expected = '<div>ABC</div><abc>&lt;&gt;</abc>'

        assert_html expected, source
      end

      it 'escaped after tag' do
        source = %q{
div&= "text"
div&= "<>"
}
        expected = %q{<div>text</div><div>&lt;&gt;</div>}
        assert_html expected, source
      end

      it 'unescaped after tag' do
        source = %q{
div= "text"
div= "<>"
}
        expected = %q{<div>text</div><div><></div>}
        assert_html expected, source
      end

      it 'normal variable eval' do
        vars = {
            __const: {
                some_text: 'some text'
            }
        }

        source = %q{
div= __const[:some_text]
div
  div= __const[:some_text]
}
        expected = '<div>some text</div><div><div>some text</div></div>'
        assert_html expected, source, vars: vars
      end
    end
  end
end
