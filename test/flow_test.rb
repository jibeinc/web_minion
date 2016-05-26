require 'test_helper'

class FlowTest < Minitest::Test
  def test_basic_flow_execution
    step_one = Step.new(name: 'Step One',
                        target: 'https://pgp.mit.edu/',
                        method: :go, value: nil, is_validator: false)
    step_two = Step.new(name: 'Step Two',
                        target: "/html/body/a[1]",
                        method: :click, value: nil, is_validator: false)
    action = Action.new("Action", [step_one, step_two])
    bot = MechanizeBot.new
    flow = Flow.new([action], bot)
    flow.perform
    assert_equal 'https://pgp.mit.edu/extracthelp.html', bot.page.uri.to_s
  end
end
