require 'test_helper'
require 'mechanize_bot'

class MechanizeBotTest < Minitest::Test
  def setup
    @bot = MechanizeBot.new
  end

  def test_body_includes
    @bot.execute_step(:go, 'https://news.ycombinator.com/')
    assert @bot.execute_step(:body_includes, nil, 'Hacker News')
  end
end
