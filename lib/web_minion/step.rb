module WebMinion
  class InvalidMethodError < StandardError; end
  class NoValueForVariableError < StandardError; end
  # A Step represents the individual operation that the bot will perform. This
  # often includes grabbing an element from the DOM tree, or performing some
  # operation on an element that has already been found.
  class Step
    attr_accessor :name, :target, :method, :value, :is_validator, :retain_element, :skippable
    attr_reader :saved_values, :vars

    VALID_METHODS = {
      select: [
        :field,
        :radio_button,
        :first_radio_button,
        :checkbox
      ],
      main_methods: [
        :set_file_upload,
        :get_field,
        :get_form,
        :go,
        :select,
        :click,
        :click_button_in_form,
        :submit,
        :fill_in_input,
        :url_equals,
        :value_equals,
        :body_includes,
        :save_page_html,
        :save_value
      ]
    }.freeze

    def initialize(fields = {})
      fields.each_pair do |k, v|
        if valid_method?(k.to_sym)
          send("method=", k)
          @target = v
        else
          send("#{k}=", v)
        end
      end

      replace_all_variables
    end

    def vars=(vars)
      @vars = Hash[vars.collect{ |k, v| [k.to_s, v] }]
    end

    def perform(bot, element = nil, saved_values)
      bot.execute_step(@method, @target, @value, element, saved_values)
    end

    def method=(method)
      raise(InvalidMethodError, "Method: #{method} is not valid") unless valid_method?(method.to_sym)
      split = method.to_s.split("/").map(&:to_sym)
      @method = split.count > 1 ? "#{split[0]}_#{split[1]}".to_sym : method.to_sym
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
        return true if VALID_METHODS[split[0]].include?(split[1])
      end
      VALID_METHODS[:main_methods].include?(method)
    end

    private

    def replace_all_variables
      %w(value target).each do |field|
        next if send(field).nil?
        send("#{field}=", replace_variable(send(field)))
      end
    end

    def replace_variable(var)
      if var.is_a?(Hash)
        return handle_hash_replacement(var)
      else
        return var unless var.is_a?(String)
        # This will handle email addresses
        return var if var.match(/\w+@\D+\.\D+/)
        if replace_var = var.match(/@(\D+)/)
          raise(NoValueForVariableError, "no variable to use found for #{replace_var}") unless @vars[replace_var[1]]
          var = @vars[replace_var[1]]
        end
      end
      var
    end

    def handle_hash_replacement(hash)
      hash.each_pair do |k, v|
        hash[k] = replace_variable(v)
      end
      hash
    end
  end
end
