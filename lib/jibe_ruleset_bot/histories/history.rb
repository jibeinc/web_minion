module JibeRulesetBot
  # Histories are used to log the events as the bot performs its flows, steps, and
  # actions
  class History
    attr_reader :runtime, :status, :start_time, :end_time

    def initialize(start_time = nil)
      @start_time = start_time || Time.now
      @status = nil
    end

    def status=(status)
      @status = status ? "Successful" : "Unsuccessful"
    end

    def end_time=(end_time)
      @end_time = end_time
      @runtime = @end_time - @start_time if @start_time && @end_time
    end
  end
end
