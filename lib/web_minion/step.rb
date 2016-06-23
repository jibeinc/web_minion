module WebMinion
  class InvalidMethodError < StandardError; end

  # A Step represents the individual operation that the bot will perform. This
  # often includes grabbing an element from the DOM tree, or performing some
  # operation on an element that has already been found.
  class Step
    attr_accessor :name, :target, :method, :value, :is_validator, :retain_element

    VALID_METHODS = {
      get: {
        form: :get_form,
        form_in_index: :get_form_in_index,
        field: :get_field
      },
      select: [
        :field,
        :radio_button,
        :first_radio_button,
        :checkbox
      ],
      main_methods: [
        :go,
        :select,
        :click,
        :click_button_in_form,
        :submit,
        :fill_in_input,
        :url_equals,
        :value_equals,
        :body_includes,
        :save_page_html
      ]
    }.freeze

    def initialize(fields = {})
      fields.each_pair do |k, v|
        if valid_method?(k)
          send("method=", k)
          @target = v
        else
          send("#{k}=", v)
        end
      end
    end

    def perform(bot, element = nil)
      bot.execute_step(@method, @target, @value, element)
    end

    def method=(method)
      raise(InvalidMethodError, "Method: #{method} is not valid") unless valid_method?(method.to_sym)
      split = method.to_s.split("/").map(&:to_sym)
      @method = split.count > 1 ? VALID_METHODS[split[0]][split[1]] : method.to_sym
    end

    def retain?
      retain_element
    end

    def validator?
      is_validator
    end

    def valid_method?(method)
      split = method.to_s.split("/").map(&:to_sym)
      if split.count > 1
        return true unless VALID_METHODS[split[0]][split[1]].nil?
      end
      VALID_METHODS[:main_methods].include?(method)
    end
  end
end
