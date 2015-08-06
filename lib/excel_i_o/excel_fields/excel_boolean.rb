class ExcelIO::ExcelBoolean < ExcelIO::ExcelField

  def get
    @obj.send(@name) ? "Да" : "Нет"
  end

  def set(value)
    @obj.send "#{@name}=", word_to_boolean(value)
  end

  def valid?(value)
    @errors = []
    
    if value.present? && !is_boolean?(value)
      @errors.push :must_be_boolean
      false
    else
      true
    end
  end

  private

  def word_to_boolean(value)
    %w(yes ok да есть ок 1 true присутствует).include? value.mb_chars.downcase.to_s
  end

  def is_boolean?(value)
    %w(yes ok да есть ок 1 true no false нет присутствует отсутствует).include? value.mb_chars.downcase.to_s
  end

end