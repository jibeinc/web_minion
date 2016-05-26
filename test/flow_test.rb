require 'test_helper'

class FlowTest < Minitest::Test
  def test_basic_flow_execution
    step_one = Step.new(name: 'Step One',
                        target: 'https://pgp.mit.edu/',
                        method: :go, value: nil, is_validator: false)
    step_two = Step.new(name: 'Step Two',
                        target: "/html/body/a[1]",
                        method: :click, value: nil, is_validator: false)
    step_three = Step.new(name: 'Validation', target: nil, method: :url_equals,
                          value: 'https://pgp.mit.edu/extracthelp.html',
                          is_validator: true)
    action = Action.new("Action", [step_one, step_two, step_three])
    bot = MechanizeBot.new
    assert action.perform(bot)

    step_three_alt = Step.new(name: 'Validation', target: nil, method: :url_equals,
                              value: 'https://pgp.mit.edu/foo.html',
                              is_validator: true)
    action = Action.new("Alt Action", [step_one, step_two, step_three_alt])
    refute action.perform(bot)
  end
end
