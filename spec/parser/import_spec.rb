
require_relative '../helper'

include Bade::Spec

describe Parser, 'import' do
  it 'parse import statement' do
    root = Parser.new.parse('import "ahoj"')
    import_nodes = root.childrens.reject { |node| node.type == :newline }

    expect(import_nodes.length).to eq 1
    expect(import_nodes.first.data).to eq %q{"ahoj"}
  end
end
