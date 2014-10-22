require 'rspec'

require_relative '../lib/rjade/parser'
require_relative '../lib/rjade/generator/html_generator'
require_relative '../lib/rjade/generator/ruby_generator'



module Bade::Spec
	include Bade

	# Render source to html
	#
	# @param [String] expectation
	# @param [String] source
	#
	def assert_html(expectation, source, print_error_if_error: true)


		parser = Bade::Parser.new

		parsed = parser.parse(source)

		begin
			lam = Bade::RubyGenerator.node_to_lambda(parsed, new_line: '', indent: '')

			str = lam.call

			expect(str).to eq expectation

		rescue Exception
			if print_error_if_error
				puts Bade::RubyGenerator.node_to_lambda_string(parsed, new_line: '', indent: '')
			end

			raise
		end
	end
end
