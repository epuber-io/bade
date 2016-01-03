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

			expect {
				assert_html '', source, print_error_if_error: false
			}.to raise_error Bade::Runtime::Block::MissingBlockDefinitionError
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

        expected = %q{<a><b>aaa</b></a>}
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

      expected = %q{<a>aaa</a>}
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

        expect do
          assert_html '', source, print_error_if_error: false
        end.to raise_error Bade::Runtime::Block::MissingBlockDefinitionError, 'Mixin `a` requires block to get rendered content of block `default_block`'
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
