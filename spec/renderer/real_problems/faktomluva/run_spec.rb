# frozen_string_literal: true

require_relative '../../../helper'


describe Bade::Renderer do
  context 'real problems' do
    context 'faktomluve' do
      it "text dubling" do
        text = <<-TEXT
          p.copyright Podle anglického originálu Factfulness: Ten Reasons We're Wrong About the World – and Why Things Are Better Than You Think vydalo v edici Pod povrchem nakladatelství Jan Melvil Publishing v Brně roku 2018.
        TEXT

        renderer = Bade::Renderer.from_source(text)
        output = renderer.render(new_line: '')

        expect(output).to eq %Q(<p class="copyright">Podle anglického originálu Factfulness: Ten Reasons We're Wrong About the World – and Why Things Are Better Than You Think vydalo v edici Pod povrchem nakladatelství Jan Melvil Publishing v Brně roku 2018.</p>)
      end
    end
  end
end
