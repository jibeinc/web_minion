module WebMinion
  # Histories are used to log the events as the bot performs its flows, steps,
  # and actions
  class History
    class InvalidStatus < StandardError; end

    VALID_STATUSES = %w(Successful Unsuccessful Skipped).freeze

    attr_reader :runtime, :status, :start_time, :end_time

    def initialize(start_time = nil)
      @start_time = start_time || Time.now
      @status = nil
    end

    def status=(status)
      @status = parse_status(status)
    end

    def end_time=(end_time)
      @end_time = end_time
      @runtime = @end_time - @start_time if @start_time && @end_time
    end

    private

    def parse_status(status)
      if [TrueClass, FalseClass].include? status.class
        status ? "Successful" : "Unsuccessful"
      elsif [String, Symbol].include? status.class
        unless VALID_STATUSES.include? status.capitalize
          raise(InvalidStatus, "#{status} is not a valid!")
        end
        status.to_s.capitalize
      else
        raise(InvalidStatus, "#{status} must be a boolean, string, or symbol.")
      end
    end
  end
end
