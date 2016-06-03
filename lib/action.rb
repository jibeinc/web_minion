require 'step'

# Represents a group of steps that the bot can perform and valdiate have
# performed as expected
class Action
  attr_reader :name, :key, :steps, :starting_action
  attr_accessor :on_success, :on_failure

  def initialize(fields = {})
    @name = fields[:name]
    @key = fields[:key] || @name
    @starting_action = fields[:starting]
    @on_success = fields[:on_success]
    @on_failure = fields[:on_failure]
    send('steps=', fields[:steps])
  end

  def self.build_from_hash(fields = {})
    steps = fields['steps'].map { |step| Step.new(step) }
    starting = fields['starting'] || false
    starting = starting == 'false' ? false : true unless !!starting == starting
    new(name: fields['name'], steps: steps, key: fields['key'],
        starting: starting, on_success: fields['on_success'],
        on_failure: fields['on_failure'])
  end

  def starting_action?
    @starting_action
  end

  def ending_action?
    @on_success.nil?
  end

  def next_actions
    [on_success, on_failure].compact
  end

  def generate_edges(all_actions)
    @on_success = all_actions[on_success]
    @on_failure = all_actions[on_failure]
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
        if step.retain?
          step.perform(bot, element)
        else
          element = step.perform(bot, element)
        end
        nil
      end
    end
    !status.reject(&:nil?).include?(false)
  rescue StandardError => e
    puts e
    return false
  end
end
