require 'rspec'

require_relative '../lib/rjade/parser'
require_relative '../lib/rjade/html_generator'



module RJade::Spec
	include RJade

	# Render source to html
	#
	# @param [String] source
	#
	# @return [String]
	#
	def render(source)
		parser = RJade::Parser.new

		result = parser.parse(source)

		RJade::HTMLGenerator.node_to_html(result, new_line: '', indent: '')
	end

	def assert_html(expectation, source)

		result = render(source)

		expect(result).to eq expectation
	end
end
