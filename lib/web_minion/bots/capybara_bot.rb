require "mechanize"
require "web_minion/bots/bot"
require "forwardable"

module WebMinion
  class CapybaraBot < WebMinion::Bot
    extend Forwardable
    delegate [:body] => :@bot

    # Initializes a CapybaraBot
    #
    # @param config [Hash] the configuration for the CapybaraBot
    # @option options [Symbol] :driver The Capybara Driver to use.
    # @return [CapybaraBot]
    def initialize(config = {})
      super(config)
      Capybara.register_driver config[:driver] do |app|
        options = {
          browser: config.fetch(:driver)
        }

        Capybara::Selenium::Driver.new(app, options)
      end

      @bot = Capybara::Session.new(config[:driver])
    end

    def page
      @bot.html
    end

    # Goes to the provided url
    #
    # @param target [String] the target (URL) of the site to visit.
    # @param _value [String] the value (unused)
    # @param _element [Capybara::Node::Element] the element (unused)
    # @return [nil]
    def go(target, _value, _element)
      @bot.visit(target)
    end

    # Clicks the provided target.
    #
    # @param target [String] the target (css or xpath) to be clicked
    # @param _value [String] the value (unused)
    # @param _element [Capybara::Node::Element] the element (unused)
    # @return [String]
    def click(target, _value, _element)
      @bot.click_link_or_button(target)
    end

    # Clicks the button in the provided form
    #
    # @param target [String] the target (css or xpath) to be clicked
    # @param _value [String] the value (unused)
    # @param element [Capybara::Node::Element] the element (form) containing the target
    # @return [String]
    def click_button_in_form(target, _value, element)
      element.find(target).click
    end

    # Sets the file to be uploaded
    #
    # @param target [String] the target
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [String]
    def set_file_upload(target, value, element)
      raise NotImplementedError
      # FileUploadElement.new(@bot, target, value, element).set_file
    end

    # Saves the current page.
    #
    # @param _target [String] the target (unused)
    # @param value [String] the value, i.e. the filename
    # @param _element [Capybara::Node::Element] the element (unused)
    # @return [String]
    # Examples:
    #
    #    bot.save_html(nil, "/tmp/myfile-%{timestamp}.html")
    #    # => "/tmp/myfile-%{timestamp}.html"
    def save_page_html(_target, value, _element)
      filename = value % { timestamp: Time.now.strftime("%Y-%m-%d_%H-%M-%S") }
      @bot.save_page(filename)
    end

    # Saves a value to a given hash
    #
    # @param target [String] the target
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [String]
    def save_value(target, value, _element, val_hash)
      raise NotImplementedError
      element = @bot.page.search(target)
      if val_hash[value.to_sym]
        val_hash[value.to_sym] << element if element
      else
        val_hash[value.to_sym] = element if element
      end
    end

    ## FORM METHODS ##
    # Must have an element passed to them (except get form)

    # Gets a form element
    #
    # @param target [String] the target
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [String]
    def get_form(target, _value, _element)
      raise NotImplementedError
      FormElement.new(@bot, target, nil, nil).get
    end

    # Finds the form field for a given element.
    #
    # @param target [String] the target (name) of the field
    # @param _value [String] the value (unused)
    # @param element [Capybara::Node::Element] the element containing the field
    # @return [Capybara::Node::Element]
    def get_field(target, _value, element)
      # raise no element passed in? Invalid element?
      element.find_field(target)
    end

    # Fills in a input element
    #
    # @param target [String] the target
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [String]
    def fill_in_input(target, value, element)
      raise NotImplementedError
      input = element[target]
      raise(NoInputFound, "For target: #{target}") unless input
      element[target] = value
      element
    end

    # Submit a form
    #
    # @param _target [String] the target (unused)
    # @param _value [String] the value (unused)
    # @param element [Capybara::Node::Element] the element
    # @return [String]
    def submit(_target, _value, element)
      element.find('input[type="submit"]').click
    rescue Capybara::ElementNotFound
      element.click
    end

    # Selects the options from a <select> input.Clicks/
    #
    # @param target [String] the target, the label or value for the Select Box
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [String]
    def select_field(target, _value, element)
      # NOTE: Capybara selects from the option's label, i.e. the text, not the
      #       option value. If it can't find the matching text, it raises a
      #       Capybara::ElementNotFound error. In this situation, we should find
      #       that select option manually.
      #
      #       <select>
      #         <option value="1">Hello</option>
      #         <option value="2">Hi</option>
      #       </select>
      #
      #       These two commands are equivalent
      #
      #       1. element.select("Hello")
      #       2. element.find("option[value='1']").select_option
      element.select(target)
    rescue Capybara::ElementNotFound
      element.find("option[value='#{target}']").select_option
    rescue Capybara::Ambiguous
      raise(MultipleOptionsFoundError, "For target: #{target}")
    end

    # Checks a checkbox
    #
    # @param target [String] the target
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [String]
    def select_checkbox(target, _value, element)
      raise NotImplementedError
      if target.is_a?(Array)
        target.each { |tar| select_checkbox(tar, nil, element) }
      else
        element.checkbox_with(target).check
      end
    end

    # Select a radio button
    #
    # @param target [String] the target
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [String]
    def select_radio_button(target, _value, element)
      raise NotImplementedError
      radio = element.radiobutton_with(target)
      radio.checked = true
      radio
    end

    # Selects the first radio button
    #
    # @param target [String] the target
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [String]
    def select_first_radio_button(_target, _value, element)
      raise NotImplementedError
      radio = element.radiobuttons.first
      radio.checked = true
      radio
    end

    ## VALIDATION METHODS ##

    # Tests if the value provided equals the current URL.
    #
    # @param _target [String] the target (unused)
    # @param value [String] the value
    # @param _element [Capybara::Node::Element] the element (unused)
    # @return [Boolean]
    def url_equals(_target, value, _element)
      !!(@bot.current_url == value)
    end

    # Tests if the body includes the value or values provided.
    #
    # @param _target [String] the target (unused)
    # @param value [String, Regexp, Array[String, Regexp]] the value
    # @param _element [Capybara::Node::Element] the element
    # @return [Boolean]
    def body_includes(_target, value, _element)
      if value.is_a?(Array)
        # FIXME: use this (but test first)
        # value.find { |v| body_includes(_target, v, _element) }
        val_check_arr = []
        value.each do |val|
          val_check_arr << !!(body.index(val) && body.index(val) > 0)
        end
        val_check_arr.uniq.include?(true)
      else
        !!(body.index(value) && body.index(value) > 0)
      end
    end

    # Tests if the value provided equals the value of the element
    #
    # @param _target [String] the target (unused)
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [Boolean]
    def value_equals(_target, value, element)
      !!(element && (element.value == value))
    end
  end
end
