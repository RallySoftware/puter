# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'puter/version'

Gem::Specification.new do |spec|
  spec.name          = "puter"
  spec.version       = Puter::VERSION
  spec.authors       = ['Brian Dupras', 'Dave Smith', 'Gerred Dillon']
  spec.email         = ['brian@duprasville.com', 'dawsmith8@gmail.com', 'hello@gerred.com']
  spec.summary       = %q{To be determined.}
  spec.description   = %q{To be determined.}
  spec.homepage      = 'https://github.com/vmtricks/puter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'rspec-its'

  spec.add_dependency 'thor', '~> 0.18'
  spec.add_dependency 'vmonkey', '~> 0.11'
  spec.add_dependency 'net-ssh', '~> 2.9'
  spec.add_dependency 'net-scp', '~> 1.2'
end
