module ExcelIO
  class ExcelFieldFactory

    def getField(obj, name, type, custom)
      klass = "ExcelIO::Excel#{custom ? 'Custom' : ''}#{type.to_s.camelize}".constantize
      klass.new obj, name
    end

  end
end