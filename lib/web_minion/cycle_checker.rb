module WebMinion
  class CycleChecker
    attr_accessor :checked, :on_stack, :actions, :starting_action, :cyclical

    def initialize(starting_action)
      @checked = []
      @on_stack = []
      @starting_action = starting_action
      @cyclical = false
      check_for_cycle(starting_action)
    end

    def cycle?
      @cyclical && !@cyclical.nil?
    end

    private

    def check_for_cycle(action)
      @checked << action
      @on_stack << action

      action.next_actions.each do |act|
        if !@checked.include?(act)
          check_for_cycle(act)
        elsif @on_stack.include?(act)
          @cyclical = true
          return nil
        end
      end

      @on_stack.delete(action)
    end
  end
end
