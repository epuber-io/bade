# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bade/version'


Gem::Specification.new do |spec|
	spec.name        = 'bade'
	spec.version     = Bade::VERSION
	spec.authors     = ['Roman Kříž']
	spec.email       = ['samnung@gmail.com']
	spec.summary     = %q{Implementation of templating language for Ruby.}
	spec.homepage    = ''
	spec.license     = 'MIT'

	spec.files         = Dir['bin/**/*'] + Dir['lib/**/*'] + %w(Bade.gemspec Gemfile Gemfile.lock)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ['lib']

	spec.add_runtime_dependency 'bundler', '~> 1'

	spec.add_development_dependency 'rspec', '~> 3.2'
	spec.add_development_dependency 'rake', '~> 10.4'
end
