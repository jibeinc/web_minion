require 'mechanize'

class MechanizeBot < JibeRulesetBot::Bot

  def initialize
    @bot = Mechanize.new
  end

  def page
    @bot.page
  end

  def go(target, _value)
    @bot.get(target)
  end

  def click(target, _value)
    button = @bot.page.at(target)
    @bot.click(button)
  end

  def url_equals(_target, value)
    @bot.page.uri.to_s == value
  end
end
