
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

  context 'it supports using custom binding' do
    it 'can work with anonymous class instance' do
      binding_class = Class.new do
        def baf
          'abc'
        end
        def get_binding
          binding
        end
      end

      output = Bade::Renderer.from_source('= baf')
                             .with_binding(binding_class.new.get_binding)
                             .render
      expect(output).to eq 'abc'
    end
  end

  context 'it supports rendering precompiled string' do
    it 'can precompile file to some object usable later' do
      precompiled = Bade::Renderer.from_file(template_path)
                                  .precompiled

      output = Bade::Renderer.from_precompiled(precompiled)
                             .with_locals(magic: 'woohoo')
                             .render(new_line: '')

      expect(output).to eq('<a class="some">text</a>woohoo')
    end

    it 'can precompile file with imported files' do
      source = 'import "files/imported.bade"
+baf("abc")'
      precompiled = Bade::Renderer.from_source(source, template_path)
                                  .precompiled

      output = Bade::Renderer.from_precompiled(precompiled)
                             .render(new_line: '')

      expected = '<div>abc</div>'
      expect(output).to eq expected
    end

    it 'can write precompiled version to disk and read back' do
      source = 'div abc'
      precompiled = Bade::Renderer.from_source(source)
                                  .precompiled

      precompiled.write_yaml_to_file('/tmp/bade_experiment')
      expect(precompiled.source_file_path).to be_nil

      new_precompiled = Bade::Precompiled.from_yaml_file('/tmp/bade_experiment')
      expect(new_precompiled.source_file_path).to be_nil

      output = Bade::Renderer.from_precompiled(new_precompiled)
                             .render(new_line: '')

      expected = '<div>abc</div>'
      expect(output).to eq expected
    end

    it 'can write precompiled version to disk and read back from file from disk' do
      precompiled = Bade::Renderer.from_file(template_path)
                                  .precompiled

      precompiled.write_yaml_to_file('/tmp/bade_experiment')
      expect(precompiled.source_file_path).to eq template_path

      new_precompiled = Bade::Precompiled.from_yaml_file('/tmp/bade_experiment')
      expect(new_precompiled.source_file_path).to eq template_path

      output = Bade::Renderer.from_precompiled(new_precompiled)
                             .with_locals(magic: 'woohoo')
                             .render(new_line: '')

      expect(output).to eq('<a class="some">text</a>woohoo')
    end
  end

  context 'it clears after running' do
    it 'defined method in template is not visible after running' do
      source = '
- def abc(a)
-   self
- end
'

      # prepare first run
      renderer = Bade::Renderer.from_source(source)
      render_binding = renderer.render_binding

      # make sure the method doesn't exist
      expect do
        render_binding.method(:abc)
      end.to raise_error NameError


      # run the template to define method
      renderer.lambda_instance.call


      # reset render binding
      renderer.render_binding = nil
      new_render_binding = renderer.render_binding

      # now the method should not exist
      expect do
        new_render_binding.method(:abc)
      end.to raise_error NameError
    end
  end
end
