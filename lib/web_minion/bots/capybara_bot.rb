require "capybara"
require "web_minion/bots/bot"
require "forwardable"

module WebMinion
  class CapybaraBot < WebMinion::Bot
    extend Forwardable
    attr_reader :bot
    delegate [:body] => :@bot

    # Initializes a CapybaraBot
    #
    # @param config [Hash] the configuration for the CapybaraBot
    # @option options [Symbol] :driver The Capybara Driver to use.
    # @return [CapybaraBot]
    def initialize(config = {})
      super(config)
      @driver = config.fetch("driver").to_sym

      if block_given?
        yield
      else
        Capybara.register_driver @driver do |app|
          Capybara::Selenium::Driver.new(app, browser:  @driver)
        end unless Capybara.drivers.include?(@driver)
      end

      @bot = Capybara::Session.new(@driver)
      @bot.driver.resize(config["dimensions"]["width"], config["dimensions"]["height"]) if config["dimensions"]
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
    # @return [nil]
    def click(target, _value, _element)
      @bot.click_link_or_button(target)
    end

    # Clicks the button in the provided form
    #
    # @param target [String] the target (css or xpath) to be clicked
    # @param _value [String] the value (unused)
    # @param element [Capybara::Node::Element] the element (form) containing the target
    # @return [nil]
    def click_button_in_form(target, _value, element)
      element.find(target).click
    end

    # Sets the file to be uploaded
    #
    # @param target [String] the target
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [nil]
    def set_file_upload(target, value, element)
      if target.is_a?(String) && %w(first last).include?(target)
        file_upload = element.find_all(:css, "input[type='file']").send(target)
      elsif target.is_a?(String)
        target_type = %r{^//} =~ target ? :xpath : :css
        file_upload = element.find(target_type, target, match: :first)
      elsif target.is_a?(Hash)
        key, input_name = target.first
        locator = "input[#{key}='#{input_name}']"
        file_upload = element.find(:css, locator, match: :first)
      end

      raise Errno::ENOENT unless File.exist?(File.absolute_path(value))

      file_upload.set(File.absolute_path(value))
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
    # @return [Hash]
    def save_value(target, value, _element, val_hash)
      target_type = %r{^/} =~ target ? :xpath : :css
      elements = @bot.find_all(target_type, target)
      return val_hash if elements.empty?

      val_hash[value.to_sym] = if elements.size == 1
                                 Nokogiri::XML(elements.first["outerHTML"]).children.first
                               else
                                 val_hash[value.to_sym] = elements.map { |e| Nokogiri::XML(e["outerHTML"]).children.first }
                               end

      val_hash
    end

    ## FORM METHODS ##
    # Must have an element passed to them (except get form)

    # Gets a form element
    #
    # @param target [String] the target
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [Capybara::Node::Element]
    def get_form(target, _value, _element)
      if target.is_a?(Hash)
        type, target = target.first
        case type.to_sym
        when :class
          target = ".#{target}"
        when :id
          target = "##{target}"
        end
        return @bot.find(target)
      elsif target.is_a?(String) && %w(first last).include?(target)
        index = target == "first" ? 0 : -1
        @bot.find_all("form")[index]
      else
        raise "Invalid Target"
      end
    end

    # Finds the form field for a given element.
    #
    # @param target [String] the target (name) of the field
    # @param _value [String] the value (unused)
    # @param element [Capybara::Node::Element] the element containing the field
    # @return [Capybara::Node::Element]
    def get_field(target, _value, element)
      # NOTE: Replace strings with symbols so that Capybara::Node::Element#find_field
      #       does not throw an "invalid keys" ArgumentError.
      target = Hash[target.map{|(k,v)| [k.to_sym,v]}]

      element.find_field(target)
    end

    # Fills in a input element
    #
    # @param target [String] the target
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [Capybara::Node::Element]
    def fill_in_input(target, value, element)
      key, input_name = target.first
      input = element.find("[#{key}='#{input_name}']")
      raise(NoInputFound, "For target: #{target}") unless input
      input.set value

      element
    end

    # Submit a form
    #
    # @param _target [String] the target (unused)
    # @param _value [String] the value (unused)
    # @param element [Capybara::Node::Element] the element
    # @return [nil]
    def submit(_target, _value, element)
      element.find('[type="submit"]').click
    rescue Capybara::ElementNotFound
      element.click
    end

    # Selects the options from a <select> input.Clicks/
    #
    # @param target [String] the target, the label or value for the Select Box
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [Capybara::Node::Element]
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
      if target.is_a?(Hash)
        key, value = target.first
        element.find("option[#{key}='#{value}']").select_option
      else
        element.select(target)
      end
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
    # @return [nil]
    def select_checkbox(target, _value, element)
      if target.is_a?(Array)
        target.each do |tar|
          key, value = tar.first
          element.find(:css, "input[#{key}='#{value}']").set(true)
        end
      else
        begin
          element.check(target)
        rescue Capybara::ElementNotFound
          element.find(:css, target).set(true)
        end
      end
    end

    # Select a radio button
    #
    # @param target [String] the target
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [Capybara::Node::Element]
    def select_radio_button(target, value, element)
      if target.is_a?(Array)
        return target.map { |tar| select_radio_button(tar, value, element) }
      elsif target.is_a?(Hash)
        key, value = target.first
        radio = element.find(:css, "input[#{key}='#{value}']")
        radio.set(true)
      else
        begin
          element.choose(target)
        rescue Capybara::ElementNotFound
          radio = element.find(:css, target)
          radio.set(true)
        end
      end

      radio || element.find(target)
    end

    # Selects the first radio button
    #
    # @param target [String] the target
    # @param value [String] the value
    # @param element [Capybara::Node::Element] the element
    # @return [Capybara::Node::Element]
    def select_first_radio_button(_target, _value, element)
      radio = element.find(:css, "input[type='radio']", match: :first)
      radio.set(true)

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
    # @param target [String] the target
    # @param value [String, Regexp, Array[String, Regexp]] the value
    # @param element [Capybara::Node::Element] the element
    # @return [Boolean]
    def body_includes(target, value, element)
      if value.is_a?(Array)
        # FIXME: this should probably return true if all the values exist.
        val_check_arr = value.map { |v| body_includes(target, v, element) }
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
