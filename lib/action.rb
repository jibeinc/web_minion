class Action
  attr_reader :name, :steps

  def initialize(name, steps)
    @name = name
    send("steps=", steps)
  end

  def steps=(steps)
    unless steps.last.validator?
      warn "WARNING: The final step for action: #{@name} is not a validation step!"
      warn "Without a final validation step an action can not confirm success!"
    end
    @steps = steps
  end

  # Again, boilerplate for initial setup
  def perform(bot)
    element = nil
    status = @steps.map do |step|
      if step.validator?
        step.perform(bot, element)
      else
        element = step.perform(bot, element)
        nil
      end
    end

    !status.reject(&:nil?).include?(false)
  end
end
