require 'json'
require 'mechanize_bot'
require 'action'
require 'cycle_checker'

class Flow
  class NoStartingActionError < StandardError; end
  class CyclicalFlowError < StandardError; end

  attr_accessor :actions, :bot
  attr_writer :name
  attr_reader :curr_action, :starting_action

  def initialize(actions, bot, name = '')
    @actions = actions
    @bot = bot
    @name = name
  end

  def self.build_via_json(rule_json)
    ruleset = JSON.parse(rule_json)
    bot = MechanizeBot.new(ruleset['config'])
    build_from_hash(ruleset['flow'].merge(bot: bot))
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

  # Simplest form (boilerplate for now). Executes all actions in order
  # ignoring error handling
  # TODO: Update this now that we use the starting action
  def perform
    execute_action(@starting_action)
  end

  private

  def execute_action(action)
    @curr_action = action
    status = action.perform(@bot)
    if status
      action.ending_action? ? true : execute_action(action.on_success)
    else
      action.on_failure ? execute_action(action.on_failure) : false
    end
  end

  def set_next_actions
    all_actions.each { |act| act.generate_edges(@actions) }
  end

  def validate_actions
    if all_actions.count(&:starting_action?) == 0
      raise(NoStartingActionError, "Flow: #{@name} has no starting action!")
    end

    if CycleChecker.new(@starting_action).cycle?
      raise(CyclicalFlowError, "Flow: #{@name} is cyclical and could enter an infinite loop")
    end
    true
  end
end
