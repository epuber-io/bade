# frozen_string_literal: true

require_relative '../helper'
require 'fakefs/spec_helpers'

describe Bade::Renderer, 'import feature' do
  include FakeFS::SpecHelpers

  before(:each) do
    Bade::Renderer.clear_constants = true
  end

  it 'supports importing another file' do
    File.write('imported.bade', <<~BADE)
      mixin baf(text)
        div= text
    BADE

    File.write('base.bade', <<~BADE)
      import "imported.bade"

      +baf('ahoj')
    BADE

    output = Bade::Renderer.from_file('base.bade')
                           .render(new_line: '')

    expect(output).to eq '<div>ahoj</div>'
  end

  context 'importing ruby file' do
    it 'supports importing relatively with extension' do
      File.write('imported.rb', <<~RB)
        def z
          'imported_rb'
        end
      RB

      File.write('base.bade', <<~BADE)
        import "imported.rb"
        = z
      BADE

      output = Bade::Renderer.from_file('base.bade')
                             .render(new_line: '')

      expect(output).to eq 'imported_rb'
    end

    it 'supports importing relatively without extension' do
      File.write('imported.rb', <<~RB)
        def z
          'imported_rb_2'
        end
      RB

      File.write('base.bade', <<~BADE)
        import "imported"
        = z
      BADE

      output = Bade::Renderer.from_file('base.bade')
                             .render(new_line: '')

      expect(output).to eq 'imported_rb_2'
    end

    it 'pass correct __FILE__ variable to loaded ruby file' do
      File.write('imported.rb', <<~RB)
        def file_path
          __FILE__
        end
      RB

      File.write('base.bade', <<~BADE)
        import "imported"
        = file_path
      BADE

      output = Bade::Renderer.from_file('base.bade')
                             .render(new_line: '')

      expect(output).to eq '/imported.rb'
    end

    it 'raises error when referenced file name matches multiple files' do
      File.write('imported.bade', '')
      File.write('imported.rb', '')

      File.write('base.bade', <<~BADE)
        import "imported"
        = file_path
      BADE

      expect do
        Bade::Renderer.from_file('base.bade')
                      .render(new_line: '')
      end.to raise_error(Bade::Renderer::LoadError, 'Found both .bade and .rb files for `imported` in '\
                                                    'file base.bade, change the import path so it references uniq file.')
    end

    it 'can import ruby file from imported bade file' do
      File.write('root.bade', <<~BADE)
        import 'imported.bade'
        = abc1
      BADE

      File.write('imported.bade', <<~BADE)
        import 'ruby.rb'
      BADE

      File.write('ruby.rb', <<~RUBY)
        def abc1
          '123'
        end
      RUBY

      output = Bade::Renderer.from_file('root.bade')
                             .render(new_line: '')

      expect(output).to eq '123'
    end

    it 'can import ruby file from imported bade file' do
      File.write('root.bade', <<~BADE)
        import 'imported.bade'
        = abc2
      BADE

      File.write('imported.bade', <<~BADE)
        import 'ruby.rb'
      BADE

      File.write('ruby.rb', <<~RUBY)
        require_relative 'lib/utils.rb'
      RUBY

      FileUtils.mkdir_p('lib')
      File.write('lib/utils.rb', <<~RUBY)
        def abc2
          '123-123'
        end
      RUBY

      output = Bade::Renderer.from_file('root.bade')
                             .render(new_line: '')

      expect(output).to eq '123-123'
    end

    it 'can import ruby file with class' do
      File.write('abc.rb', <<~RB)
        class Abc
          def some_method
            "some_result"
          end
        end
      RB

      File.write('root.bade', <<~BADE)
        import 'abc.rb'
        = Abc.new.some_method
      BADE

      output = Bade::Renderer.from_file('root.bade')
                             .render(new_line: '')

      expect(output).to eq 'some_result'
    end

    it 'can import ruby file with class and change the file afterwards' do
      Bade::Renderer.clear_constants = true

      File.write('abc.rb', <<~RB)
        class Abc < Struct.new(:abc)
          def some_method
            "some_result"
          end
        end
      RB

      File.write('root.bade', <<~BADE)
        import 'abc.rb'
        = Abc.new(1).some_method
      BADE

      Bade::Renderer.from_file('root.bade')
                    .render(new_line: '')

      File.write('abc.rb', <<~RB)
        class Abc < Struct.new(:abc)
          def some_method
            "some_result_updated"
          end
        end
      RB

      output = Bade::Renderer.from_file('root.bade')
                             .render(new_line: '')

      expect(output).to eq 'some_result_updated'
    end
  end
end
