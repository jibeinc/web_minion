require "test_helper"
require "web_minion/step"
require "web_minion/action"
require "web_minion/flow"

# Testing for the flow functionality
class FlowTest < Minitest::Test
  include WebMinion

  def setup
    @json = json_read("test_json_one.json")
    @json_two = json_read("no_start.json")
    @json_three = json_read("test_set_next.json")
    @json_four = json_read("infinite_cycle_flow.json")
    @json_five = json_read("test_saved_values.json")
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

  def test_saved_values_returned_properly
    filename = "file://#{Dir.pwd}/test/test_html/full_flow_test/first_page.html"
    flow = Flow.build_via_json(@json_five, filename: filename)
    flow.perform
    assert flow.saved_values[:saved_value]
  end

  def test_dynamic_value_set_works
    json = json_read("variable_usage.json")
    flow = Flow.build_via_json(json, save_value: "new_value")
    assert_equal "new_value", flow.actions[1].steps[1].target
  end
end
