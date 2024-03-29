# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "futurist/version"

Gem::Specification.new do |spec|
  spec.name          = "futurist"
  spec.version       = Futurist::VERSION
  spec.authors       = ["Aaron Kuehler"]
  spec.email         = ["aaron.kuehler@gmail.com"]

  spec.license       = "MIT"
  spec.homepage      = "http://www.github.com/indiebrain/futurist.git"
  spec.summary       = "A Process based Future"
  spec.description   = <<-EOS.gsub(/^\s+/, "")
                         An implementation of the Future construct
                         (https://en.wikipedia.org/wiki/Futures_and_promises)
                         which uses system Processes for background value
                         evaluation
                       EOS

  spec.files         = `git ls-files -z`.
                         split("\x0").
                         reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.7.0"
  spec.add_development_dependency "rubocop", "~> 0.51.0"
end
