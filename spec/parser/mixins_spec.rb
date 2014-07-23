require_relative '../helper'

include RJade::Spec

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









		it 'experiments' do
			__mixins = {}

			__mixins['aaa'] = lambda { |__blocks, arg, something: 10|
				__blocks.each { |_, block|
					block.call
				}

				puts __mixins['aaa'].parameters.inspect

				str = __mixins['aaa'].parameters.first(2).last.last.to_s

				puts eval(str)

				puts arg
				puts something
			}

			__mixins['aaa'].call({
									 'default' => lambda {
										 puts 'default block'
									 },
									 'head' => lambda {
										 puts 'head block'
									 }
								 }, 'fdfs', something: 100)
		end

	end
end
