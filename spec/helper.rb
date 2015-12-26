require 'coveralls'
Coveralls.wear!


require 'rspec'

require_relative '../lib/bade'



# Render source to html
#
# @param [String] expectation
# @param [String] source
#
def assert_html(expectation, source, print_error_if_error: true, vars: {})
  renderer = Bade::Renderer.from_source(source).with_locals(vars)

  begin
    str = renderer.render(new_line: '', indent: '')

    expect(str).to eq expectation

  rescue Exception
    if print_error_if_error
      puts renderer.lambda_string
    end

    raise
  end
end

def lambda_str_from_bade_code(source)
  parser = Bade::Parser.new
  parsed = parser.parse(source)
  Bade::RubyGenerator.document_to_lambda_string(parsed, indent: '')
end

