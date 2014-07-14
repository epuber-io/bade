require 'rspec'

require_relative '../lib/jade_ruby/parser'
require_relative '../lib/jade_ruby/html_generator'

module JadeRuby
	describe do

		parser = Parser.new

		it 'should parse simple string' do

			str = 'abc ahoj'

			result = parser.parse(str)

			result_html = HTMLGenerator.node_to_html(result, new_line: '', indent: '')

			expect(result_html).to eq '<abc>ahoj</abc>'
		end


		it 'should parse simple multi lined string' do

			str = <<-END
a baf
	b haf
		ab ad
c aaaa
	d abc
			END

			result = parser.parse(str)

			result_html = HTMLGenerator.node_to_html(result, new_line: "\n", indent: '\t')

			expect(result_html).to eq '<a>baf<b>haf<ab>ad</ab></b></a><c>aaaa<d>abc</d></c>'
		end
	end
end
