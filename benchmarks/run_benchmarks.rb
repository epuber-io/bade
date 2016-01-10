
require 'benchmark/ips'

require_relative '../lib/bade'
require_relative 'constants'


Benchmark.ips do |b|
  b.report('render always') do
    Bade::Renderer.from_file(TEMPLATE_PATH).with_locals(TEMPLATE_VARS).render(new_line: '')
  end

  precompiled = Bade::Renderer.from_file(TEMPLATE_PATH).precompiled
  b.report('prerendered') do
    Bade::Renderer.from_precompiled(precompiled).with_locals(TEMPLATE_VARS).render(new_line: '')
  end
end
