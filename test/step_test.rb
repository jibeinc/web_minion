require "test_helper"
require "jibe_ruleset_bot/step"

class StepTest < Minitest::Test
  include JibeRulesetBot

  def test_takes_only_valid_methods
    step = Step.new(is_validator: true)
    assert(step.validator?)
    assert(step.valid_method?(:select))
    refute(step.valid_method?(:foo))
    assert_raises(InvalidMethodError) { Step.new(method: :foo) }
  end
end
