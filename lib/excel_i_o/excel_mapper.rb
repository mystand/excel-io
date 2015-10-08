module ExcelIO
  class ExcelMapper

    def initialize
      @factory = ExcelFieldFactory.new
    end

    public

    def import(options = {})
      raise "blank mapping rules" if options[:rules].blank?
      rules = prepare_rules options[:rules]
      
      klass = options[:class].to_s.singularize.camelize.constantize
      file_name = options[:file_name]
      result_info = {cells: {}}
      objects = []
      xlsx = Roo::Excelx.new file_name

      ActiveRecord::Base.transaction do
        xlsx.each_with_index do |row, row_index|
          next if row_index.zero?
          obj = build_object klass, rules, row
          row.each_with_index do |cell, index|
            rule = rules[index + 1]
            if rule
              type = rule[:type]
              custom = rule[:custom] || false
              field_name = rule[:field_name]
              field_value = cell

              field = @factory.getField obj, field_name, type, custom

              if field.valid? field_value
                field.set field_value
              else
                add_errors stack: result_info[:cells],
                           errors: field.errors,
                           row_index: row_index + 1,
                           column_index: index + 1
              end
            end
          end
          objects.push obj
        end

        if result_info[:cells].empty?
          ok_status = true

          objects.each_with_index do |object, row_index|
            unless object.save
              object.errors.messages.each do |field, errors|
                rule = rules.values.find{|obj| obj[:field_name] == field}
                column_index = rule.nil? ? :other : rule[:number]
                add_errors stack: result_info[:cells],
                            errors: errors,
                            row_index: row_index + 2,
                            column_index: column_index
              end
              ok_status = false
            end
            puts object.errors.messages.inspect.cyan
          end
          raise ActiveRecord::Rollback unless ok_status
        end
      end
      result_info[:objects] = objects
      result_info
    end

    def export(options = {})
      raise "blank mapping rules" if options[:rules].blank?
      rules = prepare_rules options[:rules]
      tmp_path = Rails.root.join 'public/excel'
      file_name = File.join tmp_path, SecureRandom.hex + '.xlsx'
      klass = options[:class].to_s.singularize.camelize.constantize
      xlsx = Axlsx::Package.new

      # belongs_to options prepare

      belongs_to_rules = rules.select{|key, value| value[:type] == :belongs_to}
      index = 0
      belongs_to_rules.each do |key, rule|
        rule[:index] = index
        rule[:size] = get_belongs_to_class(rule[:field_name], klass).all.count
        index += 1
      end

      # first sheet

      xlsx.workbook.add_worksheet(name: 'Basic Worksheet') do |sheet|
        row_values = []
        rules.each do |number, rule|
          row_values[number - 1] = get_excel_title klass, rule
        end
        sheet.add_row row_values

        if options[:objects]
          objects = options[:objects]
        elsif options[:scope]
          scope = options[:scope]
          objects = scope.(klass)
        else
          objects = klass.all
        end

        objects.each_with_index do |record, index|
          row_values = []
          rules.keys.max.times { row_values << "" }

          rules.each do |number, rule|
            field = @factory.getField record, rule[:field_name], rule[:type], rule[:custom]

            if rule[:type] == :belongs_to
              sheet.add_data_validation number_to_word(number - 1, index + 2),
                type: :list,
                formula1: "Options!#{number_to_word(rule[:index], 1)}:#{number_to_word(rule[:index], rule[:size])}"
            end

            row_values[number - 1] = field.get
          end

          sheet.add_row row_values
        end

        # additional validation for belongs_to
        from = objects.count
        to = (objects.count <= 90) ? 100 - objects.count : objects.count + 9
        for index in from..to
          rules.each do |number, rule|
            if rule[:type] == :belongs_to
              sheet.add_data_validation number_to_word(number - 1, index + 2),
                type: :list,
                formula1: "Options!#{number_to_word(rule[:index], 1)}:#{number_to_word(rule[:index], rule[:size])}"
            end
          end
        end

        # freeze (lock) first row
        sheet.sheet_view.pane do |pane|
          pane.y_split = 1
          pane.state = :frozen
        end
      end

      # second sheet

      if belongs_to_rules.any?
        values = []
        max_size = 0

        xlsx.workbook.add_worksheet(name: 'Options') do |sheet|
          belongs_to_rules.each do |key, value|
            relation = get_belongs_to_class(value[:field_name], klass).all
            max_size = [relation.count, max_size].max

            values << relation.all.map{|item| item.try(:name) || item.try(:title)}
          end
          if max_size > 0
            values.each do |array|
              array[max_size - 1] ||= nil # increase its size to max_size for transposition
            end
          end

          values.transpose.each do |row_values|
            sheet.add_row row_values
          end

          # set read only attribute
          sheet.sheet_protection.password = 'mystand'
        end


      end

      xlsx.use_shared_strings = true
      xlsx.serialize(file_name)
      file_name
    end

    private

    def get_belongs_to_class(field_name, klass)
      association = klass.reflect_on_all_associations(:belongs_to).find do |t|
        t.association_foreign_key == field_name.to_s
      end
      @klass = association.klass
    end

    def get_excel_title(klass, rule)
      if rule[:title]
        rule[:title]
      else
        if rule[:custom]
          rule[:field_name]
        else
          if rule[:field_name].to_s == "id"
            "ID"
          else
            I18n.t "activerecord.attributes.#{klass.name.underscore}.#{rule[:field_name]}"
          end
        end
      end
    end

    def build_object(klass, rules, row)
      id_config_obj = rules.values.find{|o| o[:field_name] == :id}
      obj = nil
      if id_config_obj
        id  = row[id_config_obj[:number].to_i - 1]
        obj = klass.find_by_id id.to_i unless id.blank?
      end
      obj || klass.new
    end

    def prepare_rules(rules)
      res = {}
      rules.each do |rule|
        rule.each do |key, value|
          if value.is_a? String
            rule[key] = value.to_sym
          end
        end
        res[rule[:number]] = rule
      end
      res
    end

    def add_errors(stack:, errors:, row_index:, column_index:)
      stack[row_index] ||= {}
      stack[row_index][column_index] ||= []
      stack[row_index][column_index].push errors
    end

    def number_to_word(row_id, column_id)
      "#{get_name_from_number row_id}#{column_id}"
    end

    def get_name_from_number(num) # from number to 'AB' etc
      numeric = num % 26
      letter = (65 + numeric).chr
      num2 = (num / 26).to_i
      if num2 > 0
        "#{get_name_from_number(num2 - 1)}#{letter}"
      else
        letter
      end
    end

  end
end