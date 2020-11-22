# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'switch_point/version'

Gem::Specification.new do |spec|
  spec.name          = 'switch_point'
  spec.version       = SwitchPoint::VERSION
  spec.authors       = ['Kohei Suzuki']
  spec.email         = ['eagletmt@gmail.com']
  spec.summary       = 'Switching database connection between readonly one and writable one.'
  spec.description   = 'Switching database connection between readonly one and writable one.'
  spec.homepage      = 'https://github.com/eagletmt/switch_point'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5.0'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'benchmark-ips'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'coveralls', '>= 0.8.22'
  spec.add_development_dependency 'rack'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'rubocop', '>= 0.50.0'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'  # XXX: The latest coveralls still depends on old version
  spec.add_dependency 'activerecord', '>= 3.2.0', '< 6.1.0'
end
