require 'mechanize'

# Mechanize driven bot. More efficient, but can't handle any dynamic js-driven
# pages
class MechanizeBot < JibeRulesetBot::Bot

  def initialize
    @bot = Mechanize.new
  end

  def page
    @bot.page
  end

  def body
    page.body.to_s
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

  def body_includes(_target, value)
    body.index(value) > 0
  end
end
