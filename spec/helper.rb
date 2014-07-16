require 'rspec'

require_relative '../lib/rjade/parser'
require_relative '../lib/rjade/generator/html_generator'
require_relative '../lib/rjade/generator/ruby_generator'



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

		RJade::RubyGenerator.node_to_lambda(result, new_line: '', indent: '').call
	end

	def assert_html(expectation, source)

		result = render(source)

		expect(result).to eq expectation
	end
end
