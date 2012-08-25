# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'weak_observable/version'

Gem::Specification.new do |gem|
  gem.name          = "weak_observable"
  gem.version       = WeakObservable::VERSION
  gem.authors       = ["Kim Burgestrand"]
  gem.email         = ["kim@burgestrand.se"]
  gem.summary       = "Like Observer from the standard library, but allows the subscribers to be garbage collected."
  gem.description   = <<-DESC.gsub(/ {2,}/, '')
    Observable::Weak is very similar to Observable from ruby’ standard library, but
    with the very important difference in that it allows it’s subscribers to be
    garbage collected.
  DESC
  gem.homepage      = "http://github.com/Burgestrand/weak_observable"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'ref', '~> 1.0.0'
  gem.add_development_dependency 'rspec', '~> 2.11.0'
end
