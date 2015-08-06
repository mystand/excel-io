class ExcelIO::ExcelCustomBoolean < ExcelIO::ExcelCustomField

  def get
    return nil if @obj.custom_values[@custom_field.id.to_s].nil?
    return nil if !is_boolean?(@obj.custom_values[@custom_field.id.to_s])
    @obj.custom_values[@custom_field.id.to_s]
  end

  def set(value)
    @obj.custom_values ||= {}
    value_to_save = value.nil? ? nil : word_to_boolean(value)
    @obj.custom_values[@custom_field.id] = value_to_save
  end

  def valid?(value)
    @errors = []

    if @custom_field.nil?
      @errors.push :custom_field_not_present
      return false
    end
    
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