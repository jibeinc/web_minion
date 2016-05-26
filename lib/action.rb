class Action
  attr_reader :name, :steps

  def initialize(name, steps)
    @name = name
    @steps = steps
  end

  # Again, boilerplate for initial setup
  def perform(bot)
    @steps.each { |step| step.perform(bot) }
  end
end
