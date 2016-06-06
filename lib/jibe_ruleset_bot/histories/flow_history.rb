require "jibe_ruleset_bot/histories/history"

module JibeRulesetBot
  class FlowHistory < JibeRulesetBot::History
    attr_reader :action_history

    def initialize
      super()
      @action_history = []
    end
  end
end
