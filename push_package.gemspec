# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'push_package/version'

Gem::Specification.new do |gem|
  gem.name          = "push_package"
  gem.version       = PushPackage::VERSION
  gem.authors       = ["Stefan Natchev", "Adam Duke"]
  gem.email         = ["stefan.natchev@gmail.com", "adam.v.duke@gmail.com"]
  gem.summary       = %q{A gem for creating Safari push notification push packages.}
  gem.description   = %q{As of OSX 10.9 Safari can receive push notifications when it is closed.}
  gem.homepage      = "https://github.com/symmetricinfinity/push_package"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.required_ruby_version = '>= 1.9'

  gem.add_development_dependency 'minitest',      '~> 4.7.0'
  gem.add_development_dependency 'rake',          '~> 10.0.3'
end
