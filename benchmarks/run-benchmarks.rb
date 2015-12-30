
require 'benchmark/ips'

require_relative '../lib/bade'
require_relative 'constants'


Benchmark.ips do |b|
  b.report('render always') { Bade::Renderer.from_file(TEMPLATE_PATH).with_locals(TEMPLATE_VARS).render }
end





text = 'abcdefghijklmnopqrstuvwxyz'.gsub(/./, "\t")

Benchmark.ips do |b|

  b.report('String#each_char with if') { |times|
    times.times {
      count = 0
      text.each_char do |char|
        if char == ' '
          count += 1
        elsif char == "\t"
          count += 4
        else
          break
        end
      end
    }
  }

  b.report('String#each_char with case') { |times|
    times.times {
      count = 0
      text.each_char do |char|
        case char
        when ' '
          count += 1
        when "\t"
          count += 4
        else
          break
        end
      end
    }
  }

  b.report('Manual with String#[] with if') { |times|
    times.times {
      count = 0
      text.length.times { |idx|
        if text[idx] == ' '
          count += 1
        elsif text[idx] == "\t"
          count += 4
        else
          break
        end
      }
    }
  }
end
