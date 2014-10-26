require_relative '../helper'

include Bade::Spec

describe Parser do
	context 'mixins' do

		it 'parse mixin declaration' do
			source = '
mixin mixin_name()
	div
'
			expected = ''

			assert_html expected, source
		end

		it 'parse mixin declaration and call' do
			source = '
mixin mixin_name()
	div

+mixin_name()
'

			expected = '<div></div>'

			assert_html expected, source
		end

		it 'parse mixin declaration and call, brackets can be omitted' do
			source = '
mixin mixin_name
	div

+mixin_name
'

			expected = '<div></div>'

			assert_html expected, source
		end

		it 'parse mixin declaration and call with one normal parameter' do
			source = '
mixin mixin_name(param)
	div
		&= param

+mixin_name("abc")
'
			expected = '<div>abc</div>'
			assert_html expected, source
		end

		it 'parse mixin declaration and call with more normal parameters' do
			source = '
mixin mixin_name(param1, param2, param3)
	div
		&= param1
	p
		&= param2
	a
		&= param3

+mixin_name("abc","abc".upcase,"ASD")'

			expected = '<div>abc</div><p>ABC</p><a>ASD</a>'

			assert_html expected, source
		end

		it 'parse mixin declaration and call with several normal and several keyed parameters' do
			source = '
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
'

			expected = '<a>aa</a><b>bb</b><c>cc</c><d>{}</d>'
			assert_html expected, source
		end

		it 'parse mixin with default block' do
			source = '
mixin m()
	default
		- default_block.call

+m()
	| text
'
			expected = '<default>text</default>'
			assert_html expected, source
		end


		it 'should raise error on required block' do
			source = '
mixin m()
	- default_block.call!
+m()
'
			expect {
				assert_html nil, source, print_error_if_error: false
			}.to raise_error Bade::Runtime::RuntimeError
		end

		it 'parse mixin with custom blocks' do
			source = '
mixin m(a, &head)
	head
		- head.call

+m("aa")
	block head
		a text
'
			expected = '<head><a>text</a></head>'
			assert_html expected, source
		end

		it 'parse mixin with default block and custom block' do
			source = '
mixin m(a, &head)
	default
		- default_block.call
	head
		- head.call

+m("aa")
	a text in default block

	block head
		a text
'
			expected = '<default><a>text in default block</a></default><head><a>text</a></head>'
			assert_html expected, source
		end

		it 'block keyword can be used outside of mixin call' do
			source = '
block
	| text'
			expected = '<block>text</block>'
			assert_html expected, source
		end


		it 'parse text after mixin call' do
			source = '
mixin m()
	a
		- default_block.call

+m() text'
			expected = '<a>text</a>'
			assert_html expected, source
		end




		# it 'experiments' do
		# 	__mixins = {}
    #
		# 	__mixins['aaa'] = lambda { |arg, something: 10, default_block: nil, other_block: nil|
		# 		this = __mixins['aaa']
    #
		# 		default_block.call unless default_block.nil?
		# 		other_block.call unless other_block.nil?
    #
		# 		p this.parameters
    #
		# 		str = this.parameters.first(2).last.last.to_s
    #
		# 		p eval(str)
    #
		# 		p arg
		# 		p something
		# 	}
    #
		# 	__mixins['aaa'].call('fdfs', something: 100, default_block: lambda {
		# 		p 'default block'
		# 	}, other_block: lambda {
		# 		p 'other block'
		# 	})
		# end

	end
end
