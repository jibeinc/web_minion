class InvalidMethodError < StandardError; end

class Step
  attr_accessor :name, :target, :method, :value, :is_validator

  VALID_METHODS = [
    :go,
    :select,
    :click,
    :url_equals
  ].freeze

  def initialize(fields = {})
    fields.each_pair do |k, v|
      send("#{k}=", v)
    end
  end

  def perform(bot)
    bot.execute_step(@method, @target, @value)
  end

  def method=(method)
    raise(InvalidMethodError, "Method: #{method} is not valid") unless valid_method?(method)
    @method = method
  end

  def validator?
    is_validator
  end

  def valid_method?(method)
    VALID_METHODS.include?(method)
  end
end
