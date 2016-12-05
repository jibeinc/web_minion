require "test_helper"
require "web_minion/drivers/capybara"

class CapybaraBotTest < Minitest::Test
  include WebMinion

  def setup
    @bot = CapybaraBot.new("driver" => :poltergeist) do
      Capybara.register_driver :poltergeist do |app|
        options = {
          js_errors: false,
          timeout: 120,
          debug: false,
          phantomjs_options: ["--load-images=no", "--disk-cache=false"],
          inspector: false,
        }
        Capybara::Poltergeist::Driver.new(app, options)
      end
    end
    file_path = "file://#{Dir.pwd}/test/test_html"

    @select_test_file = "#{file_path}/select_test.html"
    @radio_test_file = "#{file_path}/radio_button_test.html"
    @input_test_file = "#{file_path}/input_test.html"
    @input_textarea_test_file = "#{file_path}/input_textarea_test.html"

    @checkbox_test_file = "#{file_path}/checkbox_test.html"
    @multiple_form_file = "#{file_path}/multiple_forms_test.html"
    @file_upload_file = "#{file_path}/file_upload_test.html"
  end

  def test_body_includes
    @bot.execute_step(:go, "https://news.ycombinator.com/")
    assert @bot.execute_step(:body_includes, nil, "Hacker News")
  end

  def test_body_multi_includes
    body_file = "file://#{Dir.pwd}/test/test_html/body_text_test.html"
    @bot.execute_step(:go, body_file)
    assert @bot.execute_step(:body_includes, nil, ["Test Two", "Nothing"])
    refute @bot.execute_step(:body_includes, nil, %w(Nothing Here))
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
    assert @bot.execute_step(:value_equals,
                             "//*[@id='select_id']",
                             "110",
                             field)
  end

  def test_select_value_method
    @bot.execute_step(:go, @select_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    field = @bot.execute_step(:get_field, { name: "select_id" }, nil, form)
    @bot.execute_step(:select_field, { value: "120" }, nil, field)
    assert @bot.execute_step(:value_equals,
                             "//*[@id='select_id']",
                             "120",
                             field)
  end

  def test_checking_multiple_values
    @bot.execute_step(:go, @checkbox_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    @bot.execute_step(:select_checkbox, [{ value: "110" }, { value: "120" }], nil, form)
    assert @bot.bot.has_checked_field? "one"
    assert @bot.bot.has_checked_field? "two"
    assert @bot.bot.has_no_checked_field? "three"
  end

  def test_checking_multiple_values_with_css
    @bot.execute_step(:go, @checkbox_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    @bot.execute_step(:select_checkbox, ".checkbox1", nil, form)
    assert @bot.bot.has_checked_field? "one"
    assert @bot.bot.has_no_checked_field? "two"
    assert @bot.bot.has_no_checked_field? "three"
  end

  def test_save_value
    @bot.execute_step(:go, @checkbox_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    @bot.execute_step(:select_checkbox, ".checkbox1", nil, form)
    val_hash = {}
    @bot.save_value("//input", "checkboxes", nil, val_hash)
    assert val_hash[:checkboxes]
  end

  def test_radio_button_select_method
    @bot.execute_step(:go, @radio_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    el = @bot.execute_step(:select_radio_button, { value: "150" }, nil, form)
    assert el.checked?
    assert_equal "150", el.value
  end

  def test_input_method
    @bot.execute_step(:go, @input_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    el = @bot.execute_step(:fill_in_input, { name: "Username" }, "Andrew", form)
    assert_equal "Andrew", el.find("input[name='Username']").value
  end

  def test_fill_in_textarea
    @bot.execute_step(:go, @input_textarea_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    el = @bot.execute_step(:fill_in_input, { name: "Username" }, "Andrew", form)
    assert_equal "Andrew", el.find("[name='Username']").value
  end

  def test_select_first_radio_button
    @bot.execute_step(:go, @radio_test_file)
    form = @bot.execute_step(:get_form, id: "form_id")
    el = @bot.execute_step(:select_first_radio_button, nil, nil, form)
    assert_equal "140", el.value
    assert el.checked?
  end

  def test_save_html
    file_path = "#{Dir.pwd}/test/test_html.html"
    @bot.execute_step(:go, @input_test_file)
    @bot.execute_step(:save_page_html, nil, file_path, nil)
    assert File.exist? file_path
    File.delete(file_path) if File.exist? file_path
  end

  def test_save_html_w_date
    file_path = "#{Dir.pwd}/test/test_html-%{timestamp}.html"
    @bot.execute_step(:go, @input_test_file)
    @bot.execute_step(:save_page_html, nil, file_path, nil)
    new_file_path = Dir.glob("#{Dir.pwd}/test/test_html-*.html").first
    assert File.exist? new_file_path
    refute new_file_path == file_path
    File.delete(new_file_path) if File.exist? new_file_path
  end

  def test_first_last_form_select
    @bot.execute_step(:go, @multiple_form_file)
    form = @bot.execute_step(:get_form, "first")
    assert_equal "form_one", form[:id]

    form_two = @bot.execute_step(:get_form, "last")
    assert_equal "form_two", form_two[:id]
  end

  def test_first_last_form_with_single_form
    @bot.execute_step(:go, @input_test_file)
    form = @bot.execute_step(:get_form, "first")
    assert_equal "form_id", form[:id]

    form_two = @bot.execute_step(:get_form, "last")
    assert_equal "form_id", form_two[:id]
  end

  def test_file_upload_functionality
    file = URI.parse(@file_upload_file)
    @bot.execute_step(:go, @file_upload_file)
    form = @bot.execute_step(:get_form, "first")
    @bot.execute_step(:set_file_upload, "first", file.path, form)
    # NOTE: value #=> "C:\fakepath\file"
    assert form.find("input[type='file']", match: :first).value.include?(file.path.split("/").last)
  end
end
