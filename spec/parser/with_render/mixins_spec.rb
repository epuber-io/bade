require_relative '../../helper'


describe Bade::Parser do
  context 'mixins' do
    it 'parse mixin declaration' do
      source = <<-BADE.strip_heredoc
        mixin mixin_name()
          div
      BADE

      expected = ''
      assert_html expected, source
    end

    it 'can parse mixin with colon in name' do
      source = <<-BADE.strip_heredoc
        mixin ab:c
          <a>
          | ab:c
          = default_block.render
          </a>

        +ab:c
        +ab:c :text starting with color
      BADE

      expected = '<a>ab:c</a><a>ab:c:text starting with color</a>'
      assert_html expected, source
    end

    it 'parse mixin declaration and call' do
      source = <<-BADE.strip_heredoc
        mixin mixin_name()
          div

        +mixin_name()
      BADE

      expected = '<div/>'
      assert_html expected, source
    end

    it 'parse mixin declaration and call, brackets can be omitted' do
      source = <<-BADE.strip_heredoc
        mixin mixin_name
          div

        +mixin_name
      BADE

      expected = '<div/>'
      assert_html expected, source
    end



    context 'arguments' do
      it 'parse mixin declaration and call with one normal parameter' do
        source = <<-BADE.strip_heredoc
        mixin mixin_name(param)
          div
            &= param

        +mixin_name("abc")
        BADE

        expected = '<div>abc</div>'
        assert_html expected, source
      end

      it 'parse mixin declaration and call with more normal parameters' do
        source = <<-BADE.strip_heredoc
        mixin mixin_name(param1, param2, param3)
          div
            &= param1
          p
            &= param2
          a
            &= param3

        +mixin_name("abc","abc".upcase,"ASD")
        BADE

        expected = '<div>abc</div><p>ABC</p><a>ASD</a>'
        assert_html expected, source
      end

      it 'parse mixin declaration and call with several normal and several keyed parameters' do
        source = <<-BADE.strip_heredoc
        mixin mixin_name(a, b, c: "abc", d: {})
          a
            &= a
          b
            &= b
          c
            &= c
          d
            &= d.to_s

        +mixin_name("aa", "bb", c: "cc")
        BADE

        expected = '<a>aa</a><b>bb</b><c>cc</c><d>{}</d>'
        assert_html expected, source
      end

      it 'parse mixin declaration and call with key-value parameter with symbols' do
        source = <<-BADE.strip_heredoc
        mixin mixin_name(a, c: :abc, d: {})
          a
            &= a.inspect
          c
            &= c.inspect
          d
            &= d.to_s

        +mixin_name(:abc, c: :cc)
        BADE

        expected = '<a>:abc</a><c>:cc</c><d>{}</d>'
        assert_html expected, source
      end

      it 'support multiline mixin call' do
        source = <<-BADE.strip_heredoc
        mixin m(a, b)
          a= a
          b= b
        +m('a_text',
           'b_text')
        BADE

        expected = '<a>a_text</a><b>b_text</b>'
        assert_html expected, source
      end

      it 'support complex multiline mixin calling' do
        source = <<-BADE.strip_heredoc
        mixin chapter(title: nil, name: nil, items: nil)
          title= title
          name= name
          items= items.join(' — ')

        +chapter(title: 'PROLOG',
           name: 'Na letišti',
           items: [
             'Scéna letiště',
             'Proč studovat tradiční společnosti?',
           ])
        BADE

        expected = '<title>PROLOG</title><name>Na letišti</name><items>Scéna letiště — Proč studovat tradiční společnosti?</items>'

        assert_html expected, source
      end
    end

    context 'blocks' do
      it 'parse mixin with default block' do
        source = <<-BADE.strip_heredoc
          mixin m()
            default
              - default_block.call
  
          +m()
            | text
        BADE

        expected = '<default>text</default>'
        assert_html expected, source
      end


      it 'should raise error on required block' do
        source = <<-BADE.strip_heredoc
          mixin m()
            - default_block.call!
          +m()
        BADE

        expect do
          assert_html '', source, print_error_if_error: false
        end.to raise_error Bade::Runtime::Block::MissingBlockDefinitionError
      end

      it 'parse mixin with custom blocks' do
        source = <<-BADE.strip_heredoc
          mixin m(a, &head)
            head
              - head.call
  
          +m("aa")
            block head
              a text
        BADE

        expected = '<head><a>text</a></head>'
        assert_html expected, source
      end

      it 'parse mixin with default block and custom block' do
        source = <<-BADE.strip_heredoc
          mixin m(a, &head)
            default
              - default_block.call
            head
              - head.call
  
          +m("aa")
            a text in default block
  
            block head
              a text
        BADE

        expected = '<default><a>text in default block</a></default><head><a>text</a></head>'
        assert_html expected, source
      end

      it 'block keyword can be used outside of mixin call' do
        source = <<-BADE.strip_heredoc
          block
            | text
        BADE

        expected = '<block>text</block>'
        assert_html expected, source
      end


      it 'parse text after mixin call' do
        source = <<-BADE.strip_heredoc
          mixin m()
            a
              - default_block.call
  
          +m() text
        BADE

        expected = '<a>text</a>'
        assert_html expected, source
      end

      context 'block expansion' do
        it 'parse two mixins' do
          source = <<-BADE.strip_heredoc
            mixin m()
              a
                - default_block.call
  
            mixin f()
              b
                - default_block.call
  
            +m(): +f() aaa
          BADE

          expected = '<a><b>aaa</b></a>'
          assert_html expected, source
        end
      end

      it 'support output after mixin calling' do
        source = <<-BADE.strip_heredoc
          mixin m()
            a
              - default_block.call
  
          +m()= 'aaa'
        BADE

        expected = '<a>aaa</a>'
        assert_html expected, source
      end
    end

    context 'rendered content of block' do
      it 'support for mutating of rendered content of block' do
        source = <<-BADE.strip_heredoc
          mixin a
            = default_block.render!.upcase

          +a abc
        BADE

        expected = 'ABC'
        assert_html expected, source
      end

      it '#render! raises error when the block is not specified' do
        source = <<-BADE.strip_heredoc
          mixin a
            - default_block.render!.upcase

          +a
        BADE

        message = 'Mixin `a` requires block to get rendered content of block `default_block`'
        expect do
          assert_html '', source, print_error_if_error: false
        end.to raise_error Bade::Runtime::Block::MissingBlockDefinitionError, message
      end

      it 'support for mutating of rendered content of block without specified block' do
        source = <<-BADE.strip_heredoc
          mixin a
            - default_block.render.upcase

          +a
        BADE

        expect do
          assert_html '', source
        end.to_not raise_error
      end
    end
  end
end
