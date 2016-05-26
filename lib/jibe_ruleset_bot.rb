require 'jibe_ruleset_bot/version'

module JibeRulesetBot

  class Bot
    attr_reader :config
    attr_accessor :bot

    def intialize(config)
    end

    def execute_step(method, target, value)
      method(method).call(target, value)
    end

    def select(target, value)
      puts "SELECT: #{target}, #{value}"
    end
  end
end
