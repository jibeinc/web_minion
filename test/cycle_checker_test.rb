require "test_helper"
require "jibe_ruleset_bot/step"
require "jibe_ruleset_bot/action"
require "jibe_ruleset_bot/cycle_checker"

# Testing the cycle checking class
class CycleCheckerTest < Minitest::Test
  include JibeRulesetBot

  ACTIONS = [
    {
      name: "One",
      key: :action_one,
      starting: true,
      on_success: :action_two,
      steps: [Step.new(is_validator: true)]
    },
    {
      name: "Two",
      key: :action_two,
      starting: false,
      on_success: :action_three,
      steps: [Step.new(is_validator: true)]
    },
    {
      name: "Three",
      key: :action_three,
      starting: false,
      on_success: :action_one,
      steps: [Step.new(is_validator: true)]
    }
  ].freeze

  def setup
    @action_one = Action.new(ACTIONS.first)
    @action_two = Action.new(ACTIONS[1])
    @action_three = Action.new(ACTIONS.last)
    @action_map = {
      ACTIONS[0][:key] => @action_one,
      ACTIONS[1][:key] => @action_two,
      ACTIONS[2][:key] => @action_three
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
