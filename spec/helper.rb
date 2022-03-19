# frozen_string_literal: true

require 'pp'
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
  rescue StandardError
    puts renderer.lambda_string if print_error_if_error

    raise
  end
end

def assert_ast(root_node, source)
  parser = Bade::Parser.new
  document = parser.parse(source)

  expect(document.root).to eq root_node
end

def lambda_str_from_bade_code(source)
  parser = Bade::Parser.new
  parsed = parser.parse(source)
  Bade::Generator.document_to_lambda_string(parsed)
end

# Module for easier creating AST in code
#
module ASTHelper
  def n(type, properties = {}, *children)
    node = if type == :root
             Bade::AST::Node.new(:root, lineno: nil)
           else
             Bade::AST::NodeRegistrator.create(type, nil)
           end

    if properties.is_a?(Bade::AST::Node)
      children.unshift(properties)
      properties = nil
    end

    properties&.each do |key, value|
      node.send("#{key}=", value)
    end

    node.children.replace(children)

    node
  end

  def tag(name, *children)
    n(:tag, { name: name }, *children)
  end

  def text(text)
    n(:static_text, value: text)
  end

  def code(text)
    n(:code, value: text)
  end

  def output(text)
    n(:output, value: text)
  end

  def newline
    n(:newline)
  end
end
