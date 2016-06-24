require "web_minion/bots/bot"
require "web_minion/bots/mechanize_bot"
require "web_minion/step"
require "web_minion/action"
require "web_minion/flow"
require "web_minion/histories/history"

# flow = JSON.parse(File.read("./test/test_json/test_json_one.json"))
# wm = WebMinion.perform flow; wm.perform
module WebMinion
  ##
  # The general error that this library uses when it wants to raise.
  Error = Class.new(StandardError)

  class << self
    def create(flow)
      config = flow.fetch("config") { {} }
      @bot = set_bot(config["bot"])
      flow = flow.fetch("flow") { {} } if flow["flow"]
      @flow = WebMinion::Flow.new(flow["actions"], @bot.new(config), flow["name"])
    end

    def perform(flow = nil)
      raise Error if flow.nil? && @flow.nil?
      @flow = create(flow) unless @flow

      @flow.perform
    end

    private

    def set_bot(bot)
      bot ||= :mechanize

      case bot.to_sym
      when :mechanize
        WebMinion::MechanizeBot
      else
        raise InvalidBotError, "#{bot} is not a valid bot"
      end
    end
  end
end
