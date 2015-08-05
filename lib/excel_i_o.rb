require "excel_i_o/engine"

module ExcelIO
  VERSION = "0.0.1"

  autoload :ExcelMapper, 'excel_i_o/excel_mapper'
  autoload :ExcelFieldFactory, 'excel_i_o/excel_field_factory'
end