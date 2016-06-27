class MechanizeElement
  class InvalidTargetType < StandardError; end

  attr_reader :bot, :target, :value, :element, :target_type

  def initialize(bot, target, value = nil, element = nil)
    @bot = bot
    @target = target
    @target_type = determine_target_type(target)
    @value = value
    @element = element
  end

  private

  def determine_target_type(target)
    if target.is_a? Integer
      return :index
    end
    :string_path
  end
end
