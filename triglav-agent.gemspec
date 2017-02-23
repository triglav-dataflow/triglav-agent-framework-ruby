# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'triglav/agent/version'

Gem::Specification.new do |spec|
  spec.name          = "triglav-agent"
  spec.version       = Triglav::Agent::VERSION
  spec.authors       = ["Naotoshi Seo"]
  spec.email         = ["sonots@gmail.com"]

  spec.summary       = %q{Framework of Triglav Agent in Ruby.}
  spec.description   = %q{Framework of Triglav Agent in Ruby.}
  spec.homepage      = "https://github.com/triglav-dataflow/triglav-agent-framework-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "serverengine"
  spec.add_dependency "dotenv"
  spec.add_dependency "triglav_client"
  spec.add_dependency "parallel"
  spec.add_dependency "connection_pool"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "test-unit-rr"
  spec.add_development_dependency "yard"
end
