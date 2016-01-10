# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bade/version'


Gem::Specification.new do |spec|
  spec.name        = 'bade'
  spec.version     = Bade::VERSION
  spec.authors     = ['Roman Kříž']
  spec.email       = ['samnung@gmail.com']
  spec.summary     = 'Minimalistic template engine for Ruby.'
  spec.homepage    = 'https://github.com/epuber-io/bade'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 2.0'

  spec.files         = Dir['bin/**/*'] + Dir['lib/**/*'] + %w(Bade.gemspec Gemfile README.md)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rubocop', '~> 0.35'
end
