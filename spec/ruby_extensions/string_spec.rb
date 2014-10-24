
require_relative '../../lib/bade/ruby_extensions/string'

describe String do
	context '#get_indent' do

		def assert_indent(string, expected_indent, tabsize: 4)
			indent = string.get_indent(tabsize)
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
		def assert_remove(indent, string, expected_string, tabsize: 4)
			string_dup = string.dup

			string_dup.remove_indent! indent, tabsize

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
end
