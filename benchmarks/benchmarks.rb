
require 'benchmark/ips'
require_relative '../lib/bade'

Benchmark.ips do |b|
  template_path = File.join(File.dirname(__FILE__), 'template.bade')
  vars = {
      item: [
          {name: 'red', current: true, url: '#red'},
          {name: 'green', current: false, url: '#green'},
          {name: 'blue', current: false, url: '#blue'}
      ]
  }

  b.report('render always') { Bade::Renderer.from_file(template_path).with_locals(vars).render }
end
