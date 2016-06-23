require "test_helper"
require "web_minion/step"
require "web_minion/action"
require "web_minion/flow"

# Testing for the flow functionality
class FlowTest < Minitest::Test
  include WebMinion

  def setup
    json_folder = "/test/test_json/"
    @json = File.read("#{Dir.pwd}#{json_folder}test_json_one.json")
    @json_two = File.read("#{Dir.pwd}#{json_folder}no_start.json")
    @json_three = File.read("#{Dir.pwd}#{json_folder}test_set_next.json")
    @json_four = File.read("#{Dir.pwd}#{json_folder}infinite_cycle_flow.json")
    @flow = Flow.build_via_json(@json)
  end

  def test_building_from_json
    assert @flow.all_actions.first.is_a? Action
    assert @flow.actions["Action one"].is_a? Action
  end

  def test_starting_action_properly_set
    assert_equal "Action one", @flow.starting_action.name
  end

  def test_validating_no_start_error
    [
      [Flow::NoStartingActionError, @json_two],
      [Flow::CyclicalFlowError, @json_four]
    ].each do |exception, json|
      assert_raises(exception) { Flow.build_via_json(json) }
    end
  end

  def test_generating_edges_for_success_and_failure_graph
    flow = Flow.build_via_json(@json_three)
    assert flow.actions[1].on_success.is_a? Action
    assert flow.actions[1].on_failure.nil?
    assert_equal [Action], flow.actions[1].next_actions.map(&:class)
  end
end
