# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'switch_point/version'

Gem::Specification.new do |spec|
  spec.name          = "switch_point"
  spec.version       = SwitchPoint::VERSION
  spec.authors       = ["Kohei Suzuki"]
  spec.email         = ["eagletmt@gmail.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0.rc1"
  spec.add_development_dependency "sqlite3"
  spec.add_dependency "activerecord", ">= 3.2.0"
end
