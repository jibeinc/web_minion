require 'jibe_ruleset_bot/version'

module JibeRulesetBot

  class Bot
    attr_reader :config
    attr_accessor :bot

    def intialize(config)
    end

    def execute_step(method, target, value = nil, element = nil)
      method(method).call(target, value, element)
    end
  end
end
