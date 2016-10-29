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

      it 'generates totally shit string' do
        path = File.join(File.dirname(__FILE__), 'part_1/chapter_3.bade')
        renderer = Bade::Renderer.from_file(path)
        output = renderer.render(new_line: '')

        expect(output).to eq '<div class="green_box"><p class="title">ŠKODÍ ZDRAVÍ</p><p>Abychom byli fér: mléko zase vápník. Čtěte dál…</p></div>'
      end
    end
  end
end
