require "test_helper"
require "web_minion/bots/elements/form_element"
require "web_minion/bots/mechanize_bot"

class ElementTest < Minitest::Test
  include WebMinion
  
  def setup
    @bot = MechanizeBot.new
  end

  def test_form_get
    input_test_file = "file://#{Dir.pwd}/test/test_html/input_test.html"
    @bot.execute_step(:go, input_test_file)
    assert_equal @bot.execute_step(:get_form, 0),
                 @bot.execute_step(:get_form, id: "form_id")
  end
end
