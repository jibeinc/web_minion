require "mechanize"
require "web_minion/bots/bot"
require "web_minion/bots/elements/form_element"
require "web_minion/bots/elements/file_upload_element"

# Mechanize driven bot. More efficient, but can't handle any dynamic js-driven
# pages
module WebMinion
  class MechanizeBot < WebMinion::Bot
    def initialize(config = {})
      super(config)
      @bot = Mechanize.new
    end

    def page
      @bot.page
    end

    def body
      page.body.to_s
    end

    def go(target, _value, _element)
      @bot.get(target)
    end

    def click(target, _value, _element)
      button = @bot.page.at(target)
      @bot.click(button)
    end

    def click_button_in_form(target, _value, element)
      element.button_with(target).click
    end

    def set_file_upload(target, value, element)
      FileUploadElement.new(@bot, target, value, element).set_file
    end

    # ability to save dynamic dates in the filename with string "INSERT_DATE"
    # so a value of "myfilename-INSERT_DATE.html" will look like this:
    # "myfilename-2016-09-19_18-51-40.html"
    # if you want multiple steps saving at the same time without overwriting,
    # rename save_html step in your json (i.e. 'save_html_confirmation' etc)
    def save_page_html(_target, value, _element)
      if value.include?("INSERT_DATE")
        time = Time.now.strftime('%Y-%m-%d_%H-%M-%S').to_s
        value = value.split("INSERT_DATE").insert(1, time).join
      end
      write_html_file(value)
    end

    def save_value(target, value, _element, val_hash)
      element = @bot.page.search(target)

      if val_hash[value.to_sym]
        val_hash[value.to_sym] << element if element
      else
        val_hash[value.to_sym] = element if element
      end

      val_hash
    end

    ## FORM METHODS ##
    # Must have an element passed to them (except get form)
    def get_form(target, _value, _element)
      FormElement.new(@bot, target, nil, nil).get
    end

    def get_field(target, _value, element)
      element.field_with(target)
    end

    def fill_in_input(target, value, element)
      input = element[target]
      raise(NoInputFound, "For target: #{target}") unless input
      element[target] = value
      element
    end

    # Element should be an instance of a form
    def submit(_target, _value, element)
      @bot.submit element
    end

    def select_field(target, _value, element)
      options = element.options_with(target)
      raise(MultipleOptionsFoundError, "For target: #{target}") if options.count > 1
      options.first.click
    end

    def select_checkbox(target, _value, element)
      if target.is_a?(Array)
        target.each { |tar| select_checkbox(tar, nil, element) }
      else
        element.checkbox_with(target).check
      end
    end

    def select_radio_button(target, _value, element)
      radio = element.radiobutton_with(target)
      radio.checked = true
      radio
    end

    def select_first_radio_button(_target, _value, element)
      radio = element.radiobuttons.first
      radio.checked = true
      radio
    end

    ## VALIDATION METHODS ##

    def url_equals(_target, value, _element)
      !!(@bot.page.uri.to_s == value)
    end

    def body_includes(_target, value, _element)
      if value.is_a?(Array)
        val_check_arr = []
        value.each do |val|
          val_check_arr << !!(body.index(val) && body.index(val) > 0)
        end
        val_check_arr.uniq.include?(true)
      else
        !!(body.index(value) && body.index(value) > 0)
      end
    end

    def value_equals(_target, value, element)
      !!(element && (element.value == value))
    end

    private

    def write_html_file(filename)
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, "w") { |f| f.puts body }
    end
  end
end
