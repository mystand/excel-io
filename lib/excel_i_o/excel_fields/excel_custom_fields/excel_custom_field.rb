class ExcelIO::ExcelCustomField < ExcelIO::ExcelField

  def initialize(obj, field_name)
    super obj, field_name
    @custom_field = @obj.custom_fields.where("name->'#{I18n.locale}' in (?)", @name).first
  end

end