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

  def test_can_take_action_to_target
    test_map = {
      "get_form" => "xpath",
      "is_validator" => true
    }

    assert_equal "xpath", Step.new(test_map).target
  end

  def test_shortened_method_name_validation
    step = Step.new
    step.method = "select/field"
    assert_equal :select_field, step.method
  end

  def test_variable_replacement
    step = Step.new(value: '@replace', vars: { replace: 'new_value' }) 
    assert_equal 'new_value', step.value
    step = Step.new(target: { name: '@replace' }, vars: { replace: 'new_value' })
    assert_equal 'new_value', step.target[:name]
    step = Step.new(target: { name: { key: '@replace' } }, vars: { replace: 'new_value' })
    assert_equal 'new_value', step.target[:name][:key]
  end

  def test_variable_replacement_to_array
    step = Step.new(value: '@replace', vars: { replace: ['value_one', 'value_two'] })
    assert_equal ['value_one', 'value_two'], step.value
  end

  def test_raises_error_for_no_variable
    assert_raises(WebMinion::NoValueForVariableError) { Step.new(value: '@replace', vars: {}) }
  end
end
