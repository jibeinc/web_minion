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
end
