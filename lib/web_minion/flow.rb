require "json"
require "web_minion/bots/mechanize_bot"
require "web_minion/action"
require "web_minion/cycle_checker"
require "web_minion/histories/flow_history"
require "web_minion/histories/action_history"

module WebMinion
  # A flow represents the top level watcher of a series of actions that are to
  # be performed. It tracks the sucess or failure, where to go next given an
  # outcome, and a history of all actions performed.
  class Flow
    class NoStartingActionError < StandardError; end
    class CyclicalFlowError < StandardError; end

    attr_accessor :actions, :bot, :history, :name, :vars
    attr_reader :curr_action, :starting_action, :saved_values

    def initialize(actions, bot, vars = {}, name = "")
      @actions = actions
      @bot = bot
      @name = name
      @vars = vars
      @history = nil
      @saved_values = {}
    end

    def self.build_via_json(rule_json, vars = {})
      ruleset = JSON.parse(rule_json)
      driver = ruleset["config"]["driver"] || "mechanize"
      bot = if driver == "mechanize"
              MechanizeBot.new(ruleset["config"])
            else
              CapybaraBot.new(ruleset["config"])
            end
      build_from_hash(ruleset["flow"].merge(bot: bot, vars: vars))
    end

    def self.build_from_hash(fields = {})
      flow = new([], nil, nil)
      flow.vars = fields[:vars] if fields[:vars]
      fields.each_pair do |k, v|
        flow.send("#{k}=", v)
      end
      flow
    end

    def actions=(actions)
      @actions = {}
      actions.each do |act|
        action = Action.build_from_hash(act, @vars)
        @actions[action.key] = action
        @starting_action = action if action.starting_action?
      end

      set_next_actions
      validate_actions
    end

    def all_actions
      @actions.values
    end

    def perform
      @history = FlowHistory.new
      status = execute_action(@starting_action, @saved_values)
      @history.end_time = Time.now
      @history.status = status
      results
    end

    private

    def results
      {
        history: @history,
        saved_values: @saved_values
      }
    end

    def execute_action(action, saved_values = {})
      @curr_action = action
      @history.action_history << ActionHistory.new(action.name, action.key)
      status = action.perform(@bot, saved_values)
      update_action_history(status)
      if status
        action.ending_action? ? true : execute_action(action.on_success, saved_values)
      else
        action.on_failure ? execute_action(action.on_failure, saved_values) : false
      end
    end

    def update_action_history(status)
      @history.action_history.last.end_time = Time.now
      @history.action_history.last.status = status
    end

    def set_next_actions
      all_actions.each { |act| act.generate_edges(@actions) }
    end

    def validate_actions
      if all_actions.count(&:starting_action?) == 0
        raise(NoStartingActionError, "Flow: #{@name} has no starting action!")
      end

      if CycleChecker.new(@starting_action).cycle?
        raise(CyclicalFlowError,
              "Flow: #{@name} is cyclical and could enter an infinite loop")
      end

      true
    end
  end
end
