require "jibe_ruleset_bot/histories/action_history"

module JibeRulesetBot
  class ActionHistory < JibeRulesetBot::History
    attr_reader :action_name, :action_key

    def initialize(action_name, action_key)
      super()
      @action_name = action_name
      @action_key = action_key
    end
  end
end
