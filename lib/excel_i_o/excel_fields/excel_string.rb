class ExcelIO::ExcelString < ExcelIO::ExcelField

  def get
    @obj.send @name
  end

  def set(value)
    @obj.send "#{@name}=", value
  end

  def valid?(value)
    @errors = []
    true
  end

end