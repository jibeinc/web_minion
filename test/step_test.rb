require "test_helper"
require "web_minion/step"

class StepTest < Minitest::Test
  include WebMinion

  def test_takes_only_valid_methods
    step = Step.new(is_validator: true)
    assert(step.validator?)
    assert(step.valid_method?(:select))
    refute(step.valid_method?(:foo))
    assert_raises(InvalidMethodError) { Step.new(method: :foo) }
  end
end
