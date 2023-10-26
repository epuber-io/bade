require 'tmpdir'

describe Bade::Renderer, 'import feature (real files)' do
  working_dir = nil

  before(:each) do
    Bade::Renderer.clear_constants = true

    working_dir = Dir.mktmpdir
  end

  after(:each) do
    FileUtils.remove_entry(working_dir)
  end

  write_file = ->(rel_path, content) do
    path = File.join(working_dir, rel_path)

    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  it 'supports importing another file' do
    write_file.call('epuber_common/lib/utils.rb', <<~RUBY)
      def abc
        '123'
      end
    RUBY

    write_file.call('epuber_common/base.bade', <<~BADE)
      - require_relative 'lib/utils.rb'

      mixin cover_page
        div= abc
    BADE

    write_file.call('epuber_common/default_pages/cover.bade', <<~BADE)
      import '../base.bade'

      +cover_page
    BADE


    output = Bade::Renderer.from_file(File.join(working_dir, 'epuber_common/default_pages/cover.bade'))
                           .render(new_line: '')

    expect(output).to eq '<div>123</div>'
  end

  it 'does not brake when dynamic value in string' do
    write_file.call('epuber_common/lib/utils.rb', <<~RUBY)
      def abc
        '123'
      end
    RUBY

    write_file.call('text/__base.bade', <<~BADE)
      - require_relative "\#{File.dirname(current_file_path)}/../epuber_common/lib/utils.rb"

      mixin cover_page
        div= abc
    BADE

    write_file.call('text/copyright.bade', <<~BADE)
      import '__base.bade'

      +cover_page
    BADE

    output = Bade::Renderer.from_file(File.join(working_dir, 'text/copyright.bade'))
                           .with_locals(
                              current_file_path: File.join(working_dir, 'text/copyright.bade'),
                            )
                           .render(new_line: '')

    expect(output).to eq '<div>123</div>'
  end
end
