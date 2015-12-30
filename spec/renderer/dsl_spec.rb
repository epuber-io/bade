
require_relative '../../lib/bade/renderer'

describe Bade::Renderer do
  let(:template_path) { File.join(File.dirname(__FILE__), 'from_file.bade') }

  it 'supports simple rendering from source string' do
    output = Bade::Renderer.from_source('a some text')
                           .render(new_line: '')
    expect(output).to eq('<a>some text</a>')
  end

  it 'supports simple rendering from source string with locals' do
    output = Bade::Renderer.from_source('a= magic')
                           .with_locals(magic: 'magic string')
                           .render(new_line: '')

    expect(output).to eq('<a>magic string</a>')
  end

  it 'supports simple rendering from file path' do
    output = Bade::Renderer.from_file(template_path)
                           .with_locals(magic: 'woohoo')
                           .render(new_line: '')

    expect(output).to eq('<a class="some">text</a>woohoo')
  end

  it 'supports simple rendering from file obj' do
    output = Bade::Renderer.from_file(File.new(template_path, 'r'))
                           .with_locals(magic: 'woohoo')
                           .render(new_line: '')

    expect(output).to eq('<a class="some">text</a>woohoo')
  end

  it 'supports rendering from source with file path' do
    output = Bade::Renderer.from_source('a abc', template_path)
                           .render(new_line: '')
    expect(output).to eq('<a>abc</a>')
  end

  it 'supports rendering from source with imports' do
    source = 'import "files/imported.bade"
+baf("abc")'
    output = Bade::Renderer.from_source(source, template_path)
                           .render(new_line: '')
    expected = '<div>abc</div>'
    expect(output).to eq expected
  end

  context 'it supports rendering precompiled string' do
    it 'can precompile file to some object usable later' do
      precompiled = Bade::Renderer.from_file(template_path)
                                  .precompiled

      output = Bade::Renderer.from_precompiled(precompiled, template_path)
                             .with_locals(magic: 'woohoo')
                             .render(new_line: '')

      expect(output).to eq('<a class="some">text</a>woohoo')
    end

    it 'can precompile file with imported files' do
      source = 'import "files/imported.bade"
+baf("abc")'
      precompiled = Bade::Renderer.from_source(source, template_path)
                                  .precompiled

      output = Bade::Renderer.from_precompiled(precompiled, template_path)
                             .render(new_line: '')

      expected = '<div>abc</div>'
      expect(output).to eq expected
    end
  end
end
