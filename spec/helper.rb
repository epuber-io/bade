require 'rspec'

require_relative '../lib/rjade/parser'
require_relative '../lib/rjade/generator/html_generator'
require_relative '../lib/rjade/generator/ruby_generator'



module RJade::Spec
	include RJade

	# Render source to html
	#
	# @param [String] expectation
	# @param [String] source
	#
	def assert_html(expectation, source)

		parser = RJade::Parser.new

		parsed = parser.parse(source)

		lam = RJade::RubyGenerator.node_to_lambda(parsed, new_line: '', indent: '')

		str = lam.call

		if str != expectation
			puts RJade::RubyGenerator.node_to_lambda_string(parsed, new_line: '', indent: '')
		end

		expect(lam.call).to eq expectation
	end
end
