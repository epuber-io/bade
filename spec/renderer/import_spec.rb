
require_relative '../../lib/bade/renderer'

describe Bade::Renderer, 'import feature' do
  it 'supports importing another file' do
    output = Bade::Renderer.from_file(File.new(File.join(File.dirname(__FILE__), 'files/base.bade'), 'r'))
                           .render(new_line: '')

    expect(output).to eq ''
  end
end
