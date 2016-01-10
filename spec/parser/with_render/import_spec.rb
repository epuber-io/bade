
require_relative '../../helper'

describe Bade::Parser, 'import' do
  it 'parse import statement' do
    parser = Bade::Parser.new
    document = parser.parse('import "ahoj"')
    import_nodes = document.root.children.reject { |node| node.type == :newline }

    expect(parser.dependency_paths).to eq %w(ahoj)

    expect(import_nodes.length).to eq 1
    expect(import_nodes.first.value).to eq 'ahoj'
  end
end
