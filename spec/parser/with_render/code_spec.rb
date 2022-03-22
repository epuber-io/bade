require_relative '../../helper'


describe Bade::Parser do
  context 'inline code' do
    it 'should parse code' do
      source = <<~BADE
        - if true
          a text
        - else
          b text_b
        - end
      BADE

      expected = '<a>text</a>'

      assert_html expected, source
    end

    it 'case be used' do
      source = <<~BADE
        - abc = 1
        - case abc
        - when 1
          a text_a
        - when 2
          b text_b
        - else
          a else
        - end
      BADE

      expected = '<a>text_a</a>'

      assert_html expected, source
    end

    it 'case be used (example 2)' do
      source = <<~BADE
        - abc = 2
        - value = case abc
        -         when 1
        -           'text_a'
        -         when 2
        -           'text_b'
        -         else
        -          'else'
        -         end
        a= value
      BADE

      expected = '<a>text_b</a>'

      assert_html expected, source
    end
  end

  context 'output code' do
    context 'parse output from ruby code' do
      it 'not-escaped text' do
        source = <<~BADE
          div
            = "abc".upcase
          abc
            = "<>"
        BADE

        expected = '<div>ABC</div><abc><></abc>'
        assert_html expected, source
      end

      it 'escaped text' do
        source = <<~BADE
          div
            &= "abc".upcase
          abc
            &= "<>"
        BADE

        expected = '<div>ABC</div><abc>&lt;&gt;</abc>'
        assert_html expected, source
      end

      it 'escaped after tag' do
        source = <<~BADE
          div&= "text"
          div&= "<>"
        BADE

        expected = '<div>text</div><div>&lt;&gt;</div>'
        assert_html expected, source
      end

      it 'unescaped after tag' do
        source = <<~BADE
          div= "text"
          div= "<>"
        BADE

        expected = '<div>text</div><div><></div>'
        assert_html expected, source
      end

      it 'normal variable eval' do
        vars = {
          __const: Hash.new { |_hash, key| raise KeyError, "Not found key #{key}" },
        }

        source = <<~BADE
          div
              h1.section NADEŠEL ČAS PRO PRÁCI NA DÁLKU
              p= __const[:some_undefined_key]
        BADE

        expected = '<div>some text</div><div><div>some text</div></div>'

        expect do
          assert_html expected, source, vars: vars, print_error_if_error: false
        end.to(raise_error do |error|
          expect(error.cause).to be_a(::KeyError)
        end)
      end
    end


    context 'corner cases' do
      it 'parse input source' do
        source = <<~BADE
          h1.section NADEŠEL ČAS PRO PRÁCI NA DÁLKU

          = 'dsafdsgfd'
        BADE

        expected = '<h1 class="section">NADEŠEL ČAS PRO PRÁCI NA DÁLKU</h1>dsafdsgfd'
        assert_html expected, source
      end

      it 'parse empty code line' do
        source = <<~BADE
          a text
          -
          b text
        BADE

        expected = '<a>text</a><b>text</b>'
        assert_html expected, source
      end
    end
  end
end
