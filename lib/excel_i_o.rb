require "excel_i_o/engine"

module ExcelIO
  autoload :ExcelMapper, 'excel_i_o/excel_mapper'
  autoload :ExcelFieldFactory, 'excel_i_o/excel_field_factory'

  #todo better?
  [:ExcelBelongsTo, :ExcelBoolean, :ExcelField, :ExcelFloat, :ExcelGeoData,
    :ExcelHasMany, :ExcelInteger, :ExcelLocalized, :ExcelString, :ExcelText].each do |klass_name|

    autoload klass_name, "excel_i_o/excel_fields/#{klass_name.to_s.underscore}"
  end

end