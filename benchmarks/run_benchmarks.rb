# frozen_string_literal: true

require 'benchmark/ips'

require_relative '../lib/bade'
require_relative 'constants'


# Benchmark.ips do |b|
#   b.report('render always') do
#     Bade::Renderer.from_file(TEMPLATE_PATH).with_locals(TEMPLATE_VARS).render(new_line: '')
#   end
#
#   precompiled = Bade::Renderer.from_file(TEMPLATE_PATH).precompiled
#   b.report('prerendered') do
#     Bade::Renderer.from_precompiled(precompiled).with_locals(TEMPLATE_VARS).render(new_line: '')
#   end
# end


Benchmark.ips do |b|
  renderer = Bade::Renderer.from_file(File.join(File.dirname(__FILE__), 'long_static_template.bade'))
                           .with_locals(TEMPLATE_VARS)
                           .optimized

  puts renderer.lambda_string

  renderer.render(new_line: '')

  b.report('render_long_static') do
    renderer.render(new_line: '')
  end
end
