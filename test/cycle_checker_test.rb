require "test_helper"
require "jibe_ruleset_bot/step"
require "jibe_ruleset_bot/action"
require "jibe_ruleset_bot/cycle_checker"

# Testing the cycle checking class
class CycleCheckerTest < Minitest::Test
  include JibeRulesetBot

  def setup
    @action_one = Action.new(name: "One", key: 1, starting: true, on_success: 2,
                             steps: [Step.new(is_validator: true)])
    @action_two = Action.new(name: "Two", key: 2, starting: false, on_success: 3,
                             steps: [Step.new(is_validator: true)])
    @action_three = Action.new(name: "Three", key: 3, starting: false,
                               on_success: 1, steps: [Step.new(is_validator: true)])
    @action_map = {
      1 => @action_one,
      2 => @action_two,
      3 => @action_three
    }
    @actions = [@action_one, @action_two, @action_three]
    @actions.each { |act| act.generate_edges(@action_map) }
    @starting_action = @action_one
  end

  def test_cycle_checking_functionality
    assert CycleChecker.new(@starting_action).cycle?
  end

  def test_refute_cycle
    @action_two.on_success = nil
    refute CycleChecker.new(@action_one).cycle?
  end
end
