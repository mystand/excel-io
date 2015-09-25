class ExcelIO::ExcelDate < ExcelIO::ExcelField

  def get
    if @obj.send(@name)
      @obj.send(@name).strftime("%d.%m.%y")
    else
      ""
    end
  end

  def set(value)
    @obj.send "#{@name}=", Date.parse(value) unless value.blank?
  end

  def valid?(value)
    @errors = []
    unless value.blank?
      begin
        Date.parse(value)
      rescue
        @errors.push :must_be_date
      end
    end
    @errors.empty?
  end

end