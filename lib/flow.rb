require 'json'
require 'mechanize_bot'

class Flow
  attr_accessor :actions, :bot
  attr_writer :name

  def initialize(actions, bot, name = '')
    @actions = actions
    @bot = bot
    @name = name
  end

  def self.build_via_json(rule_json)
    ruleset = JSON.parse(rule_json)
    bot = MechanizeBot.new(ruleset['config'])
    build_from_hash(ruleset['flow'].merge({ bot: bot }))
  end

  def self.build_from_hash(fields = {})
    flow = new([], nil, nil)
    fields.each_pair do |k, v|
      flow.send("#{k}=", v)
    end
    flow
  end

  def actions=(actions)
    @actions = actions.map do |action|
      return action if action.class == Action
      Action.build_from_hash(action)
    end
  end

  # Simplest form (boilerplate for now). Executes all actions in order
  # ignoring error handling
  def perform
    !@actions.map { |action| action.perform(bot) }.include?(false)
  end
end
