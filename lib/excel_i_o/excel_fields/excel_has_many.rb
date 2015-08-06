class ExcelIO::ExcelHasMany < ExcelIO::ExcelField

  def initialize(obj, field_name)
    super obj, field_name
    @has_many_splitter = "\n"
  end

  def get
    objects = @obj.send "#{@name}"
    objects.map { |o| o.try(:title) || o.try(:name) }.join @has_many_splitter
  end

  def set(value)
    return unless value
    names = value.split @has_many_splitter
    relation_class = @name.to_s.singularize.camelize.constantize
    attr_name = relation_class.attribute_names.include?("title") ? "title" : "name"
    relation_objs = relation_class.where "#{attr_name}->'#{I18n.locale}' in (?)", names
    
    @obj.send "#{@name}=", relation_objs
  end

  def valid?(value)
    @errors = []
    return true unless value

    names = value.split @has_many_splitter
    relation_class = @name.to_s.singularize.camelize.constantize
    attr_name = relation_class.attribute_names.include?("title") ? "title" : "name"
    
    names.each do |name|
      item = relation_class.where("#{attr_name}->'#{I18n.locale}' in (?)", name).first
      if item.nil?
        @errors.push :must_be_has_many
        break
      end
    end

    return @errors.empty?
  end

end