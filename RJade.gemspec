# coding: utf-8

require_relative 'lib/rjade'


Gem::Specification.new do |spec|
	spec.name        = 'rjade'
	spec.version     = RJade::VERSION
	spec.authors     = ['Roman Kříž']
	spec.email       = ['samnung@gmail.com']
	spec.summary     = %q{Reimplementation of Jade in Ruby.}
	spec.homepage    = ''
	spec.license     = 'MIT'

	spec.files         = `git ls-files -z`.split("\x0")
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ['lib']

	spec.add_runtime_dependency 'activesupport', '>= 3.2.15'

	spec.add_development_dependency 'bundler', '~> 1.6'
	spec.add_development_dependency 'rake'

	spec.add_development_dependency 'rspec'
end
