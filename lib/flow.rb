class Flow
  attr_reader :actions, :bot

  def initialize(actions, bot)
    @actions = actions
    @bot = bot
  end

  # Simplest form (boilerplate for now). Executes all actions in order
  # ignoring error handling
  def perform
    @actions.each { |action| action.perform(bot) }
  end
end
