
require_relative '../../lib/bade/renderer'

describe Bade::Renderer, 'import feature' do
  it 'supports importing another file' do
    base_path = File.expand_path('files/base.bade', File.dirname(__FILE__))
    output = Bade::Renderer.from_file(File.new(base_path, 'r'))
                           .render(new_line: '')

    expect(output).to eq '<div>ahoj</div>'
  end
end
