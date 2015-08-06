class ExcelIO::ExcelFloat < ExcelIO::ExcelField

  def get
    @obj.send @name
  end

  def set(value)
    @obj.send "#{@name}=", value
  end

  def valid?(value)
    @errors = []
    regexp = /(^(\d+)(\.)?(\d+)?)|(^(\d+)?(\.)(\d+))/

    if value.present? && !regexp.match(value.to_s)
      @errors.push :must_be_float 
      false
    else
      true
    end
  end

end