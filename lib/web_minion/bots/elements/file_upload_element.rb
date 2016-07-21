require 'web_minion/bots/elements/file_upload_element'

class FileUploadElement < MechanizeElement
  def initialize(bot, target, value, element)
    super(bot, target, value, element)
  end

  def set_file
    case @target_type
    when :index
      index_set
    when :string_path
      string_set
    when :first_last
      first_last_set
    else
      raise(InvalidTargetType, "#{@target_type} is not valid!")
    end
  end

  private

  def index_set
    @element.file_uploads[@target].file_name = @value
  end
  
  def string_set
    @element.file_upload_with(@target).file_name = @value
  end

  def first_last_set
    if @target == "first"
      @element.file_uploads.first.file_name = @value
    elsif @target == "last"
      @element.file_uploads.last.file_name = @value
    else
      raise(InvalidTargetType, "#{@target} is not first or last!")
    end
  end
end
