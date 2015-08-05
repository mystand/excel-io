class ExcelGeoData < ExcelField

  def get
    @obj.send "#{@name}_geojson"
  end

  def set(value)
    @obj.send "#{@name}_geojson=", value
  end

  def valid?(value)
    @errors = []
    if value.present? && !is_json?(value)
      @errors.push :must_be_geo_data
      false
    else
      true
    end
  end

  private

  def is_json? str
    begin
      JSON.parse str
      true
    rescue
      false
    end
  end

end