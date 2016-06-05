$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

if ENV["CI"]
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start
end

require 'jibe_ruleset_bot'
require 'step'
require 'action'
require 'flow'
require 'pry'
require 'mechanize_bot'
require 'minitest/autorun'
