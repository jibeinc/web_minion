require 'test_helper'

class ActionTest < Minitest::Test
  def setup
    @bot = MechanizeBot.new
    @select_test_file = "file://#{Dir.pwd}/test/test_html/select_test.html"
    @step_one = Step.new(name: 'Get Page', target: @select_test_file, method: :go,
                         value: nil, is_validator: false)
    @step_two = Step.new(name: 'Get form', target: { id: 'form_id' }, value: nil,
                         is_validator: false, method: :get_form)
    @step_three = Step.new(name: 'Get field', target: { name: 'select_id' },
                           value: nil, is_validator: false, method: :get_field)
    @validate_one = Step.new(name: 'Check select', target: nil, value: '110',
                             method: :value_equals, is_validator: true)
  end

  def test_simple_action
    action = Action.new('Action', [@step_one, @step_two, @step_three,
                                   @validate_one])
    assert action.perform(@bot)
  end

  def test_no_validation_throws_warning
    steps = [@step_one, @step_two, @step_three]
    assert_output(nil, /warning/i) { Action.new('Action', steps) }
  end
end
