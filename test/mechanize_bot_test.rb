require "test_helper"
require "jibe_ruleset_bot/bots/mechanize_bot"

class MechanizeBotTest < Minitest::Test
  include JibeRulesetBot
  
  def setup
    @bot = MechanizeBot.new
    @select_test_file = "file://#{Dir.pwd}/test/test_html/select_test.html"
    @radio_test_file = "file://#{Dir.pwd}/test/test_html/radio_button_test.html"
    @input_test_file = "file://#{Dir.pwd}/test/test_html/input_test.html"
  end

  def test_body_includes
    @bot.execute_step(:go, "https://news.ycombinator.com/")
    assert @bot.execute_step(:body_includes, nil, "Hacker News")
  end

  def test_get_form
    @bot.execute_step(:go, @select_test_file)
    assert @bot.execute_step(:get_form, id: "form_id")
  end

  def test_get_field
    @bot.execute_step(:go, @select_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    assert @bot.execute_step(:get_field, { name: "select_id" }, nil, form)
  end

  def test_value_validation_method
    @bot.execute_step(:go, @select_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    field = @bot.execute_step(:get_field, { name: "select_id" }, nil, form)
    assert @bot.execute_step(:value_equals, "//*[@id='select_id']", "110", field)
  end

  def test_select_value_method
    @bot.execute_step(:go, @select_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    field = @bot.execute_step(:get_field, { name: "select_id" }, nil, form)
    @bot.execute_step(:select_field, { value: "120" }, nil, field)
    assert @bot.execute_step(:value_equals, "//*[@id='select_id']", "120", field)
  end

  def test_radio_button_select_method
    @bot.execute_step(:go, @radio_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    el = @bot.execute_step(:select_radio_button, { value: "150" }, nil, form)
    assert el.checked
    assert_equal "150", el.value
  end

  def test_input_method
    @bot.execute_step(:go, @input_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    el = @bot.execute_step(:fill_in_input, { name: "Username" }, "Andrew", form)
    assert_equal "Andrew", el["Username"]
  end

  def test_select_first_radio_button
    @bot.execute_step(:go, @radio_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    el = @bot.execute_step(:select_first_radio_button, nil, nil, form)
    assert_equal "140", el.value
    assert el.checked
  end

  def test_save_html
    file_path = "#{Dir.pwd}/test/test_html.html"
    @bot.execute_step(:go, @input_test_file)
    @bot.execute_step(:save_page_html, nil, file_path, nil)
    assert File.exist? file_path
    File.delete(file_path) if File.exist? file_path
  end
end
