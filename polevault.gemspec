# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'polevault/version'

Gem::Specification.new do |spec|
  spec.name          = "polevault"
  spec.version       = Polevault::VERSION
  spec.authors       = ["Ryan Canty"]
  spec.email         = ["jrcanty@gmail.com"]

  spec.summary       = %q{Bootstrap Vault}
  spec.description   = %q{An opinionated and automated way to bootstrap vault from an EC2 instance}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'pry'

  spec.add_runtime_dependency 'vault', '~> 0.1'
  spec.add_runtime_dependency 'aws-sdk', '~> 2'
  spec.add_runtime_dependency 'figly', '~> 1.1'
  spec.add_runtime_dependency 'thor'
end
