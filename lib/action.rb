class Action
  attr_reader :name, :key, :steps, :starting_action

  def initialize(name, steps, key = nil, starting = false)
    @name = name
    @key = key || @name
    @starting_action = starting
    send('steps=', steps)
  end

  def self.build_from_hash(fields = {})
    steps = fields['steps'].map { |step| Step.new(step) }
    starting = fields['starting'] || false
    starting = starting == 'false' ? false : true unless !!starting == starting
    new(fields['name'], steps, fields['key'], starting)
  end

  def starting_action?
    @starting_action
  end

  def steps=(steps)
    unless steps.last.validator?
      warn "WARNING: The final step for action: #{@name} is not a validation step!"
      warn 'Without a final validation step an action can not confirm success!'
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
