# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'observed/logstash/version'

Gem::Specification.new do |spec|
  spec.name          = "observed-logstash"
  spec.version       = Observed::Logstash::VERSION
  spec.authors       = ["Chris Birchall"]
  spec.email         = ["chris.birchall@gmail.com"]
  spec.description   = %q{observed-logstash}
  spec.summary       = %q{observed-logstash is a plugin for Observed that runs an Elasticsearch query and checks the number of results as a sign of healthiness.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "observed", "~> 0.1.0"
  spec.add_dependency "elasticsearch", "~> 0.4.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "fakefs"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"
end
