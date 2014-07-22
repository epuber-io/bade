require 'rspec'

require_relative '../../lib/rjade/parser'

module RJade

	describe Parser do
		context '#get_indent' do

			def assert_indent(string, expected_indent, options = {})
				sut = Parser.new(options)
				indent = sut.get_indent string
				expect(indent).to eq expected_indent
			end


			it 'space indents' do
				assert_indent 'abc', 0
				assert_indent ' abc', 1
				assert_indent '  abc', 2
				assert_indent '   abc', 3
				assert_indent '    abc', 4
			end

			it 'tab indents' do
				assert_indent 'abc', 0, :tabsize => 4

				assert_indent "\tabc", 4, :tabsize => 4
				assert_indent "\tabc", 1, :tabsize => 1

				assert_indent "\t\tabc", 4, :tabsize => 2
				assert_indent "\t\tabc", 8, :tabsize => 4
			end

			it 'tabs and spaces can be combined' do
				assert_indent "\t abc", 2, :tabsize => 1
				assert_indent "\t \tabc", 9, :tabsize => 4
			end

			it 'default tab size is 4' do
				assert_indent "\ta", 4
			end

		end


		context '#remove_indent!' do
			def assert_remove(indent, string, expected_string, options = {})
				sut = Parser.new(options)

				string_dup = string.dup

				sut.remove_indent! string_dup, indent

				expect(string_dup).to eq expected_string
			end

			it 'removes spaces' do
				assert_remove 4, '    abc', 'abc'
				assert_remove 3, '    abc', ' abc'
				assert_remove 2, '    abc', '  abc'
				assert_remove 1, '    abc', '   abc'
				assert_remove 0, '    abc', '    abc'
			end

			it 'removes tabs' do
				assert_remove 4, "\tabc", 'abc', :tabsize => 4
				assert_remove 4, "\t\tabc", 'abc', :tabsize => 2
			end
		end



		context '#parse_ruby_code' do
			def assert_ruby_code(source, expected_ruby, end_delimiter = ',)', options = {})
				sut = Parser.new(options)

				sut.instance_eval { @lines = [source] }
				sut.next_line

				result_ruby = sut.parse_ruby_code end_delimiter

				expect(result_ruby).to eq expected_ruby
			end

			it 'parse string' do
				assert_ruby_code ' "abc" ,', '"abc"'
			end
			it 'parse string with colons' do
				assert_ruby_code ' "abc ,fd ,, fds f" ,   ', '"abc ,fd ,, fds f"'
			end
			it 'parse string with mixed quotes' do
				source = %Q{ "text with \\', \\" quotes" 'other, text ' }
				expected = %Q{"text with \\', \\" quotes" 'other, text '}
				assert_ruby_code source, expected
			end

			it 'should not parse uncomplete text' do
				source = ' some_method(param   , '

				expect {
					assert_ruby_code source, nil
				}.to raise_error
			end

			it 'parse simple variable' do
				assert_ruby_code 'abc,', 'abc'
			end
			it 'parse simple variable with calling method' do
				assert_ruby_code 'abc.lowercase,', 'abc.lowercase'
			end

			it 'parse calling function with parameter' do
				assert_ruby_code 'function(abc)   ,', 'function(abc)'
			end
			it 'parse calling function with more parameters' do
				assert_ruby_code 'function(abc, 123)    ,', 'function(abc, 123)'
			end

			it 'parsed value is striped' do
				assert_ruby_code '    some code     ', 'some code'
			end

			it 'parse accessing with square brackets' do
				assert_ruby_code ' hash[text]   ,', 'hash[text]'
			end
			it 'parse accessing with square brackets with string' do
				assert_ruby_code ' hash["text"]   ,', 'hash["text"]'
			end
			it 'parse accessing with square brackets with multiple parameters' do
				assert_ruby_code ' hash[text,text2]   ,', 'hash[text,text2]'
			end

			it 'parse blocks' do
				assert_ruby_code '  hash.map { |baf| baf, baf }  ', 'hash.map { |baf| baf, baf }'
			end

			it 'parse multi lined code' do
				source = '
test code multi lined
	code
'

				expected = 'test code multi lined
	code'
				assert_ruby_code source, expected
			end
		end
	end
end
