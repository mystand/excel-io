class ExcelController < ::Admin::AdminController
  before_action :fill_variables
  skip_before_filter :verify_authenticity_token, :only => [:import, :preview_import]

  def export_form
    @model = params[:model]
    klass = @model.singularize.camelize.constantize
    @field_names = make_field_names_for klass
    @factory = ExcelFieldFactory.new
    @example_data = klass.accessible_by(current_ability).limit(10).map do |obj|
      d = {}
      @field_names.each do |field_name|
        data =  get_data_for_field_name klass, field_name
        d[field_name] = @factory.getField(obj, data[:name], data[:type], data[:custom]).get
      end
      d
    end

    @rules = make_rules_for @model
  end


  def import_form
    model = params[:model]
    klass = model.singularize.camelize.constantize
    @field_names = make_field_names_for klass
    @example_data = klass.accessible_by(current_ability).limit(10).map do |obj|
      d = {}
      @field_names.each do |f|
        d[f] = obj.send(f)
      end
      d
    end

    @rules = make_rules_for model
  end

  def preview_import
    # because tmp files do not have extensions
    xls = Roo::Excelx.new params[:file].path, file_warning: :ignore

    result = []
    xls.each do |row|
      result << []
      row.each do |cell|
        result.last << cell
      end
    end

    render json: result
  end

  def import
    rules = JSON.parse params[:rules]
    old_file_path = params[:file].path
    file_path = "#{old_file_path}.xlsx"

    rules.map! do |rule|
      {
        field_name: rule['fieldName'],
        number: rule['number'],
        custom: rule['custom'],
        type: rule['type']
      }
    end
    FileUtils.mv old_file_path, file_path

    result = @mapper.import class: "TestItem", file_name: file_path,
               rules: rules

    if result[:cells].any?
      render json: result[:cells], status: 501
    else
      render json: result[:objects], status: 200
    end
  end

  def export
    file_name = @mapper.export make_mapper_options
    render :text => File.join("/excel", File.basename(file_name))
  end

  def template
    render text: "template"
  end

  private

  def make_mapper_options
    {rules: prepare_rules(params[:rules]), class: params[:model].singularize.camelize}
  end

  def prepare_rules rules_data
    rules_data.values.map do |obj|
      res = HashWithIndifferentAccess.new obj.clone
      res[:field_name] = obj["fieldName"]
      res[:number] = obj[:number].to_i
      res[:custom] = obj[:custom] == "false" ? false : true
      res
    end

  end

  def fill_variables
    @mapper = ExcelMapper.new
  end

  private

  def make_field_names_for klass_name
    klass = klass_name.to_s.singularize.camelize.constantize
    field_names = klass.attribute_names + make_localized_field_names_for(klass_name)
    #field_names + klass.reflect_on_all_associations.map(&:plural_name) - ['custom_values']
    field_names - ['custom_values']
  end

  def make_localized_field_names_for klass_name
    klass = klass_name.to_s.singularize.camelize.constantize
    hstore_attrs = klass.columns.select do |item|
      item.type == :hstore
    end.map do |item|
      item.name
    end
    res = []
    hstore_attrs.each do |name|
      res += I18n.available_locales.map { |l| "#{name}_#{l}" } if klass.method_defined?("#{name}_#{I18n.locale}")
    end
    res
  end

  def make_rules_for klass_name
    klass = klass_name.to_s.singularize.camelize.constantize
    field_names = make_field_names_for klass_name
    res = {}
    field_names.each do |field_name|
      res[field_name] = get_data_for_field_name klass, field_name
    end
    res
  end

  def get_data_for_field_name klass, field_name
    sql_type = klass.column_types[field_name].try :sql_type
    res = case sql_type
            when "hstore"
              {type: "text", custom: false}
            when "character varying(255)"
              {type: "string", custom: false}
            when nil
              if make_localized_field_names_for(klass.name).include? field_name
                {type: "localized", custom: false}
              else
                {type: "text", custom: false}
              end
            else
              {type: sql_type, custom: false}
          end
    res[:name] = field_name
    res[:type] = 'geo_data' if res[:type] == 'geography(Geometry,4326)'
    res[:type] = 'float' if res[:type] == 'double precision'
    if field_name.match(/(.*)_id/)
      res[:type] = "belongs_to"
      res[:name] = /(.*)_id/.match(res[:name])[1]
    elsif klass.reflect_on_all_associations.map(&:plural_name).include? field_name
      res[:type] = "has_many"
    end
    res
  end

end