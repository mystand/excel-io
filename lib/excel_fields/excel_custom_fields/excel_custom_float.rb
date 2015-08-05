class ExcelCustomFloat < ExcelCustomField

  def get
    return nil if @obj.custom_values.nil?
    @obj.custom_values[@custom_field.id.to_s]
  end

  def set(value)
    @obj.custom_values ||= {}
    value_to_save = value.nil? ? nil : value.to_f
    @obj.custom_values[@custom_field.id] = value_to_save
  end

  def valid?(value)
    @errors = []
    regexp = /(^(\d+)(\.)?(\d+)?)|(^(\d+)?(\.)(\d+))/
    
    if @custom_field.nil?
      @errors.push :custom_field_not_present
      return false
    end

    if value.present? && !regexp.match(value.to_s)
      @errors.push :must_be_float
      false
    else
      true
    end
  end

end