class InvalidMethodError < StandardError; end

class Step
  attr_accessor :name, :target, :method, :value, :validator

  VALID_METHODS = [
    :select,
  ].freeze

  def initialize(fields = {})
    fields.each_pair do |k, v|
      send("#{k}=", v)
    end
  end

  def method=(method)
    raise(InvalidMethodError, "Method: #{method} is not valid") unless valid_method?(method)
    self.method = method
  end

  def valid_method?(method)
    VALID_METHODS.include?(method)
  end
end
