# encoding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jibe_ruleset_bot/version"

Gem::Specification.new do |spec|
  spec.name          = "jibe_ruleset_bot"
  spec.version       = JibeRulesetBot::VERSION
  spec.authors       = ["Andrew Parrish"]
  spec.email         = ["m.andrewparrish@gmail.com"]

  spec.summary       = "A metadata-driven browser automation."
  spec.description   = "A metadata-driven browser automation."
  spec.homepage      = "https://github.com/jibeinc/jibe_ruleset_bot"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
