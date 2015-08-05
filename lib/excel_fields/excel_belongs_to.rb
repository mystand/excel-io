class ExcelBelongsTo < ExcelField

  def initialize(obj, field_name)
    super obj, field_name
    association = obj.class.reflect_on_all_associations(:belongs_to).find{|t| t.name == @name.to_sym}
    @klass = association.klass
  end

  def get
    relation_obj = @obj.send @name
    relation_obj.try(:title) || relation_obj.try(:name) || relation_obj.try(:to_s) || ""
  end

  def set(value)
    relation_obj = nil
    unless value.nil?
      field_name = @klass.attribute_names.include?("title") ? "title" : "name"
      relation_obj = @klass.where("#{field_name}->'#{I18n.locale}' = ?", value).first
    end
    @obj.send "#{@name}=", relation_obj
  end

  def valid?(value)
    @errors = []

    if value.nil?
      true
    else
      field_name = @klass.attribute_names.include?("title") ? "title" : "name"
      relation_obj = @klass.where("#{field_name}->'#{I18n.locale}' = ?", value).first

      if relation_obj
        true
      else
        @errors = [:must_be_belongs_to]
        false
      end
    end
  end

end