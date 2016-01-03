# frozen_string_literal: true

require_relative '../../../helper'


describe Bade::Renderer do
  context 'real problems' do
    context 'whole30' do
      it "undefined local variable or method `__new_line' for #<Bade::Runtime::RenderBinding:0x007f86a3f29640>" do
        path = File.join(File.dirname(__FILE__), 'intro_text.bade')
        renderer = Bade::Renderer.from_file(path)

        expect do
          renderer.with_locals({})
                  .render(new_line: '')
        end.to_not raise_error
      end
    end
  end
end
