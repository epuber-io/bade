# frozen_string_literal: true

require 'ruby-prof'
require 'flamegraph'

require_relative '../lib/bade'
require_relative 'constants'



# profile the code
RubyProf.start

500.times do
  Bade::Renderer.from_file(TEMPLATE_PATH).with_locals(TEMPLATE_VARS).render
end

result = RubyProf.stop
result.eliminate_methods!([/Bade::Parser#append_node/])
result.eliminate_methods!([/Integer#times/])


call_stack_path = File.join(File.dirname(__FILE__), 'call_stack.html')
call_stack_file = File.open(call_stack_path, 'w')

printer = RubyProf::CallStackPrinter.new(result)
printer.print(call_stack_file, min_percent: 0.1)





Flamegraph.generate(File.join(File.dirname(__FILE__), 'flamegraph.html')) do
  Bade::Renderer.from_file(TEMPLATE_PATH).with_locals(TEMPLATE_VARS).render
end
