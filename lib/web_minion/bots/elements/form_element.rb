require "web_minion/bots/elements/mechanize_element"

class FormElement < MechanizeElement
  def initialize(bot, target, value = nil, element = nil)
    super(bot, target, value, element)
  end

  def get
    case @target_type
    when :index
      index_get
    when :string_path
      string_get
    when :first_last
      first_last_get
    else
      raise(InvalidTargetType, "#{@target_type} is not valid!")
    end
  end

  private

  def first_last_get
    if @target == "first"
      @bot.page.forms.first
    elsif @target == "last"
      @bot.page.forms.last
    else
      raise(InvalidTargetType, "#{@target} is not first or last!")
    end
  end

  def index_get
    @bot.page.forms[@target]
  end

  def string_get
    @bot.page.form_with(@target)
  end
end
