require "json"
require "jibe_ruleset_bot/bots/mechanize_bot"
require "jibe_ruleset_bot/action"
require "jibe_ruleset_bot/cycle_checker"
require "jibe_ruleset_bot/histories/flow_history"
require "jibe_ruleset_bot/histories/action_history"

module JibeRulesetBot
  # A flow represents the top level watcher of a series of actions that are to
  # be performed. It tracks the sucess or failure, where to go next given an
  # outcome, and a history of all actions performed.
  class Flow
    class NoStartingActionError < StandardError; end
    class CyclicalFlowError < StandardError; end

    attr_accessor :actions, :bot, :history
    attr_writer :name
    attr_reader :curr_action, :starting_action

    def initialize(actions, bot, name = "")
      @actions = actions
      @bot = bot
      @name = name
      @history = nil
    end

    def self.build_via_json(rule_json)
      ruleset = JSON.parse(rule_json)
      bot = MechanizeBot.new(ruleset["config"])
      build_from_hash(ruleset["flow"].merge(bot: bot))
    end

    def self.build_from_hash(fields = {})
      flow = new([], nil, nil)
      fields.each_pair do |k, v|
        flow.send("#{k}=", v)
      end
      flow
    end

    def actions=(actions)
      @actions = {}
      actions.each do |act|
        action = Action.build_from_hash(act)
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
      status = execute_action(@starting_action)
      @history.end_time = Time.now
      @history.status = status
      @history
    end

    private

    def execute_action(action)
      @curr_action = action
      @history.action_history << ActionHistory.new(action.name, action.key)
      status = action.perform(@bot)
      update_action_history(status)
      if status
        action.ending_action? ? true : execute_action(action.on_success)
      else
        action.on_failure ? execute_action(action.on_failure) : false
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
