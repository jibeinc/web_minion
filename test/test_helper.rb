$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jibe_ruleset_bot'
require 'step'
require 'action'
require 'flow'
require 'pry'
require 'mechanize_bot'
require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/reporters'
require 'pry'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new,
                          Minitest::Reporters::SpecReporter.new]
