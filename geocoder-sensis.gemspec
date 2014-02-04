# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'geocoder/sensis/version'

Gem::Specification.new do |spec|
  spec.name          = "geocoder-sensis"
  spec.version       = Geocoder::Sensis::VERSION
  spec.authors       = ["Daniel Heath"]
  spec.email         = ["daniel@heath.cc"]
  spec.summary       = %q{Implements a Sensis Geocoder backend for the geocoder gem.}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "geocoder"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-debugger"
end
