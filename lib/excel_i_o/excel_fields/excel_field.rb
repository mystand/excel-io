class ExcelField

  attr_accessor :errors

  def initialize(obj, field_name)
    @obj = obj
    @name = field_name
  end

  def get
    raise 'you must overwrite this method'
  end

  def set(value)
    raise 'you must overwrite this method'
  end

  def valid?(value)
    raise 'you must overwrite this method'
  end

end