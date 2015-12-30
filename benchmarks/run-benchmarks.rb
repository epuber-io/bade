
require 'benchmark/ips'

require_relative '../lib/bade'
require_relative 'constants'


Benchmark.ips do |b|
  b.report('render always') { Bade::Renderer.from_file(TEMPLATE_PATH).with_locals(TEMPLATE_VARS).render }
end
