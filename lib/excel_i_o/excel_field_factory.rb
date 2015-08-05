require 'excel_i_o/excel_fields/excel_field'
require 'excel_i_o/excel_fields/excel_custom_fields/excel_custom_field.rb'

Dir['excel_i_o/excel_fields/**/*.rb'].each {|file| require file }

module ExcelIO
  class ExcelFieldFactory

    def getField(obj, name, type, custom)
      klass = "Excel#{custom ? 'Custom' : ''}#{type.to_s.camelize}".constantize
      klass.new obj, name
    end

  end
end