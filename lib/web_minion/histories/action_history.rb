require "web_minion/histories/action_history"

module WebMinion
  class ActionHistory < WebMinion::History
    attr_reader :action_name, :action_key

    def initialize(action_name, action_key)
      super()
      @action_name = action_name
      @action_key = action_key
    end
  end
end
