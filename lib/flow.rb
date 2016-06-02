require 'json'
require 'mechanize_bot'

class NoStartingActionError < StandardError; end

class Flow
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

    validate_actions
  end

  def all_actions
    @actions.values
  end

  # Simplest form (boilerplate for now). Executes all actions in order
  # ignoring error handling
  def perform
    !@actions.map { |action| action.perform(bot) }.include?(false)
  end

  private

  def validate_actions
    if all_actions.count(&:starting_action?) == 0
      raise(NoStartingActionError, "Flow #{@name} has no starting action!")
    end

    true
  end
end
