class ExcelCustomString < ExcelCustomField

  def get
    return nil if @obj.custom_values.nil?
    @obj.custom_values[@custom_field.id.to_s]
  end

  def set(value)
    @obj.custom_values ||= {}
    @obj.custom_values[@custom_field.id] = value
  end

  def valid?(value)
    @errors = []
    
    if @custom_field.nil?
      @errors.push :custom_field_not_present
      return false
    end

    true
  end

end