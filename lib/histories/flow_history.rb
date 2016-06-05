require 'histories/history'

class FlowHistory < History
  attr_reader :action_history

  def initialize
    super()
    @action_history = []
  end
end
