$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

if ENV["CI"]
  require "coveralls"
  Coveralls.wear!
else
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
  end
end

require "pry"
require "minitest/autorun"
require "minitest/unit"
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new,
                          Minitest::Reporters::SpecReporter.new]
module Minitest
  class Test
    def json_read(file)
      File.read("./test/test_json/#{file}") 
    end

    def html_read(file)
      File.read("./test/test_html/#{file}")
    end
  end
end


