$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

if ENV["CI"]
  require "coveralls"
  Coveralls.wear!
else
  require "simplecov"
  SimpleCov.start
  add_filter "/test/"
end

require "pry"
require "jibe_ruleset_bot"
require "step"
require "action"
require "flow"
require "histories/history"
require "mechanize_bot"
require "minitest/autorun"
require "minitest/unit"
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new,
                          Minitest::Reporters::SpecReporter.new]
