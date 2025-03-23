class SemanticAnalyzer
  def initialize
    @symbol_table = []  # Массив для хранения символов
    @function_table = []
  end

  def analyze(ast)
    ast.each do |node|
      case node[:type]
      when :variable_declaration
        process_variable_declaration(node)
      when :assignment
        process_assignment(node)
      when :function
        process_function(node)
      else

      end
    end
    @symbol_table
  end

  def symbol_table
    @symbol_table
  end

  def print_symbol_table
    # Определяем ширину столбцов для красивого форматирования
    column_widths = {
      name: 15,
      type: 15,
      subtype: 15,
      value: 15,
      scope: 15
    }
  
    # Выводим заголовок таблицы
    puts "-" * (column_widths.values.sum + 16)
    printf "| %-#{column_widths[:name]}s | %-#{column_widths[:type]}s | %-#{column_widths[:subtype]}s | %-#{column_widths[:value]}s | %-#{column_widths[:scope]}s |\n",
           "Name", "Type", "Subtype", "Value", "Scope"
    puts "-" * (column_widths.values.sum + 16)
  
    # Выводим данные из symbol_table
    @symbol_table.each do |entry|
      printf "| %-#{column_widths[:name]}s | %-#{column_widths[:type]}s | %-#{column_widths[:subtype]}s | %-#{column_widths[:value]}s | %-#{column_widths[:scope]}s |\n",
             entry[:name] || "", entry[:type] || "", entry[:subtype] || "", entry[:value] || "", entry[:scope] || ""
    end
  
    puts "-" * (column_widths.values.sum + 16)
    puts @function_table
  end

  private

  # Обработка объявления переменной
  def process_variable_declaration(node)
    # Проверяем, что у переменной есть имя и тип
    raise "We can create only variable, with type: scalar, array and hash" if (node[:name].nil? || node[:name][:subtype].nil?) && node[:names].nil?
    if node[:names].is_a?(Array)
      node[:names].each do |var|
        existing_var = @symbol_table.find { |var2| var2[:name] == var[:name] }
        if !existing_var
          @symbol_table << {
            name: var[:name],  # Получаем имя переменной
            type: var[:subtype],
            subtype: nil,  # Указываем тип (scalar, array, hash)
            value: nil,  # Значение пока пустое
            scope: node[:scope]
          }
        else
          existing_var[:scope] = node[:scope]
        end
    end
    else
      existing_var = @symbol_table.find { |var| var[:name] == node[:name][:value]}
      if !existing_var
        @symbol_table << {
          name: node[:name][:value],
          type: node[:name][:subtype],
          subtype: nil,
          value: nil,
          scope: node[:scope]
        }
      else
        existing_var[:scope] = node[:scope]
      end
    end

  end

  # Обработка присваивания
  def process_assignment(node)
    # Проверяем, что у присваивания есть имя и значение
    raise "We can use assignment only for scalar, array and hash" if node[:value].nil? || node[:subtype].nil?
    existing_var = @symbol_table.find { |var| var[:name] == node[:name] }
    if !existing_var
      @symbol_table << {
        name: node[:name],
        type: node[:subtype],
        subtype: nil,
        value: nil,
        scope: nil
      }
    end
  end

  # Обработка функции
  def process_function(node)
    # Проверяем, что имя функции задано и его подтип не nil
    raise "Function must have a valid name" if node[:name].nil? || !node[:name][:subtype].nil?

    # Добавляем функцию в таблицу символов
    existing_var = @symbol_table.find { |var| var[:name] == node[:name][:value] }
    if !existing_var
      @symbol_table << {
        name: node[:name][:value],
        type: :function,
        subtype: nil,
        value: nil,# Указатель на тело функци
        scope: nil
      }
      @function_table << {name: node[:name][:value], body: node[:body]}
    else      
      existing_func = @function_table.find { |var| var[:name] == node[:name][:value] }
      existing_func[:body] = node[:body]
    end


    # Обрабатываем тело функции
    node[:body].each do |body_node|
      case body_node[:type]
      when :variable_declaration
        process_variable_declaration(body_node)
      when :assignment
        process_assignment(body_node)
      else
        
      end
    end
  end
end

