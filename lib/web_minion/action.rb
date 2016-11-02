require "web_minion/step"

module WebMinion
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
      send("steps=", fields[:steps])
    end

    def self.build_from_hash(fields = {}, vars = {})
      steps = fields["steps"].map do |step|
        begin
          Step.new(step.merge("vars" => vars))
        rescue NoValueForVariableError => e
          (step["skippable"] && (step["is_validator"].nil? || !step["is_validator"])) ? nil : raise(e, "Current step is missing variable. (step: #{step['name']})")
        end
      end
      steps = steps.reject(&:nil?)

      starting = (fields["starting"] || "false") == "false" ? false : true
      new(name: fields["name"], steps: steps, key: fields["key"],
          starting: starting, on_success: fields["on_success"],
          on_failure: fields["on_failure"])
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
        warn "WARNING: Action: #{@name}'s final step is not a validation step!"
        warn "An action can not confirm its success without a validation step!"
      end
      @steps = steps
    end

    # Again, boilerplate for initial setup
    def perform(bot, saved_values)
      element = nil
      status = @steps.map do |step|
        if step.validator?
          step.perform(bot, element, saved_values)
        else
          if step.retain?
            step.perform(bot, element, saved_values)
          else
            element = step.perform(bot, element, saved_values)
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
end
