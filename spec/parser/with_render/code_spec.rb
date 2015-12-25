require_relative '../../helper'

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
            __const: Hash.new { |hash, key| raise KeyError, "Not found key #{key}" }
        }

        source = %q{
div
    h1.section NADEŠEL ČAS PRO PRÁCI NA DÁLKU
    p= __const[:some_undefined_key]
}
        expected = '<div>some text</div><div><div>some text</div></div>'
        expect do
          assert_html expected, source, vars: vars
        end.to raise_exception KeyError
      end


      context 'corner cases' do
        it 'parse input source' do
          source = %q{
h1.section NADEŠEL ČAS PRO PRÁCI NA DÁLKU

= 'dsafdsgfd'}

          expected = '<h1 class="section">NADEŠEL ČAS PRO PRÁCI NA DÁLKU</h1>dsafdsgfd'
          assert_html expected, source
        end

        it 'parse empty code line' do
          source = %q{
a text
-
b text}
          expected = '<a>text</a><b>text</b>'
          assert_html expected, source
        end
      end
    end
  end
end
