# coding: utf-8

require_relative 'lib/bade'

Gem::Specification.new do |spec|
	spec.name        = 'bade'
	spec.version     = Bade::VERSION
	spec.authors     = ['Roman Kříž']
	spec.email       = ['samnung@gmail.com']
	spec.summary     = %q{Implementation of templating language for Ruby.}
	spec.homepage    = ''
	spec.license     = 'MIT'

	spec.files         = `git ls-files -z`.split("\x0")
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ['lib']

	spec.add_development_dependency 'bundler'
	spec.add_development_dependency 'rspec'
end
