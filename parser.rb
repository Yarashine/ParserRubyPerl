require_relative 'token'
require_relative 'lexer'

class Parser
  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  
  def print_tree(data, indent = 0)
    if data.is_a?(Array)
      puts "["
      # Добавляем элементы массива, разделённые запятой
      data.each_with_index do |element, index|
        print ' ' * (indent + 2)
        print_tree(element, indent + 2)
        print ',' unless index == data.length - 1  # добавляем запятую, если это не последний элемент
        puts # переходим на новую строку
      end
      puts "#{' ' * indent}]"
    elsif data.is_a?(Hash)
      puts "{"
      data.each do |key, value|
        print "#{' ' * (indent + 2)}#{key}: "
        print_tree(value, indent + 2)
        puts # после каждого ключа/значения переходим на новую строку
      end
      puts "#{' ' * indent}}"
    else
      print "#{' ' * indent}#{data.inspect}"
    end
  end
  
  

  def parse
    ast = []
    while !(peek.value == "EOF")
      ast << statement
    end
    ast
  end

  private

  def statement
    if peek.type == :keyword
      if (peek.value == "my" || peek.value == "our") 
        variable_declaration
      elsif peek.value == "print"
        print_declaration
      elsif peek.value == "use"
        use_declaration
      elsif peek.value == "while"
        while_declaration
      elsif peek.value == "until"
        until_declaration
      elsif peek.value == "unless"
        unless_declaration
      elsif peek.value == "for"
        for_declaration
      elsif peek.value == "foreach"
        foreach_declaration
      elsif peek.value == "sub"
        function_declaration
      elsif peek.value == "return"
        return_declaration
      elsif ["if", "elsif", "given", "when"].include?(peek.value)
        condition_declaration
      elsif ["default", "else"].include?(peek.value)
        remaining_condition_declaration
      end
    elsif peek.type == :identifier
      advance
      if peek.type == :operator && peek.value == "="
        assignment_statement
      elsif peek.type == :punctuation && peek.value == "("
        func = function_call
        if peek.type == :punctuation && peek.value == ";"
          advance
        end
        return func
      elsif peek.type == :operator && peek.value == "++"
        value = postfix_increment
        advance if peek.type == :punctuation && peek.value == ";"
        return value;
      end
    else
      raise "Неожиданный токен1: #{peek.value}"
    end
  end

  def use_declaration
    advance
    if peek.type == :keyword && peek.value == "constant"
      advance
      if peek.type == :identifier
        name = peek.value
        subtype = peek.subtype
        advance
        if peek.type == :operator && peek.value == "=>"
          advance
          value = expression_until([";"]);
          return { type: :constant, subtype: subtype, name: name , value: value  }
        end
      end
    elsif peek.type == :keyword && peek.value == "feature"
      advance
      value = expression_until([";"]);
      return { type: :feature, value: value  }
    end
    raise "Неожиданный токен use: #{peek.value}"
  end

  def body_declaration
    body_ast = []
    while !(peek.value == "}")
      body_ast << statement
    end
    advance
    return body_ast
  end

  def foreach_declaration
    advance
    if peek.type == :keyword && peek.value == "my"
      advance
      if peek.type == :identifier
        element = peek.value
        subtype = peek.subtype
        advance
        if peek.type == :punctuation && peek.value == "("
          advance
          if peek.type == :identifier
            collection = peek.value
            colSubtype = peek.subtype
            advance
            if peek.type == :punctuation && peek.value == ")"
              advance
              if peek.type == :punctuation && peek.value == "{"
                advance
                body = body_declaration
                return { type: :foreach, collection: { type: :identifier, subtype: subtype, value:collection}, element: { type: :identifier, subtype: colSubtype, value: element}, body: body }
              end              
            end
          end
        end
      end
    end
    raise "Неожиданный токен foreach: #{peek.value}"
  end

  def for_declaration
    advance
    if peek.type == :punctuation && peek.value == "("
      advance
      condition1 = statement
      condition2 = expression_until([";"]) 
      condition3 = expression_until([")"]) 
      if peek.type == :punctuation && peek.value == "{"
        advance
        body = body_declaration
        return { type: :for, condition1: condition1, condition2: condition2, condition3: condition3, body: body }
      end
    end
    raise "Неожиданный токен while: #{peek.value}"
  end

  def condition_declaration
    name = peek.value
    puts peek.value
    advance
    if peek.type == :punctuation && peek.value == "("
      advance
      expression = expression_until([")"]) 
      if peek.type == :punctuation && peek.value == "{"
        advance
        puts peek.value
        body = body_declaration
        return { type: name, condition: expression, body: body }
      end
    end
    raise "Неожиданный токен conditional: #{peek.value}"
  end

  def remaining_condition_declaration
    name = peek.value
    advance
    if peek.type == :punctuation && peek.value == "{"
      advance
      body = body_declaration
      return { type: name, body: body }
    end
  end

  def function_declaration
    advance
    if peek.type == :identifier
      name = peek.value
      subtype = peek.subtype
      advance
      if peek.type == :punctuation && peek.value == "{"
        advance
        body = body_declaration
        return { type: :function, name:{ type: :identifier, subtype: subtype, value:  name}, body: body }
      end
    end
    raise "Неожиданный токен while: #{peek.value}"
  end

  def return_declaration
    advance
    expression = expression_until([";"]) 
    return { type: :return, value: expression}
  end


  def while_declaration
    advance
    if peek.type == :punctuation && peek.value == "("
      advance
      expression = expression_until([")"]) 
      if peek.type == :punctuation && peek.value == "{"
        advance
        body = body_declaration
        return { type: :while, condition: expression, body: body }
      end
    end
    raise "Неожиданный токен while: #{peek.value}"
  end

  def until_declaration
    advance
    if peek.type == :punctuation && peek.value == "("
      advance
      expression = expression_until([")"]) 
      if peek.type == :punctuation && peek.value == "{"
        advance
        body = body_declaration
        return { type: :until, condition: expression, body: body }
      end
    end
    raise "Неожиданный токен until: #{peek.value}"
  end

  def unless_declaration
    advance
    if peek.type == :punctuation && peek.value == "("
      advance
      expression = expression_until([")"]) 
      if peek.type == :punctuation && peek.value == "{"
        advance
        body = body_declaration
        return { type: :unless, condition: expression, body: body }
      end
    end
    raise "Неожиданный токен unless: #{peek.value}"
  end

  def print_declaration
    elements = []
    advance
    until previous.type == :punctuation && previous.value == ";"
      elements << expression_until([",", ";"]) 
    end
    return { type: :print, parameters: elements }
  end

  def variable_declaration
    type = peek.value  # "my"
    names = []
    advance
    if peek.type == :punctuation && peek.value == "("
      advance
      until previous.type == :punctuation && previous.value == ")"
        names << expression_until([",", ")"]) 
      end
    elsif peek.type == :identifier
      name = peek.value
      subtype = peek.subtype
      advance
    end
  
    value = nil
    if peek.type == :operator && peek.value == "="
      value = assignment_statement
    elsif peek.type == :punctuation && peek.value == ";"
      advance
    end

    if names.size == 0
      { type: :variable_declaration, scope: type, name:{ type: :identifier, subtype: subtype, value:  name}, value: value }
    else
      { type: :variable_declaration, scope: type, names: names, value: value }
    end
  end  

  def assignment_statement
    name = previous.value
    subtype = previous.subtype
    if name == ")"
      name = "names"
    end
    value = nil
    if peek.type == :operator && peek.value == "="
      advance
      value = expression_until([";"])
    end
    { type: :assignment, name: name, subtype: subtype, value: value }
  end

  # Новый метод, который парсит выражение **до точки с запятой**
  def expression_until(val)
    left = ternary  # Начинаем с тернарного оператора

    while !((peek.type == :punctuation) && val.include?(peek.value))
      if (peek.type == :operator) && ["&&", "||"].include?(peek.value)
        operator = peek.value
        advance
        right = ternary
        left = { type: :binary_expression, operator: operator, left: left, right: right }
      else
        break
      end
    end    
    advance
    left
  end

  def ternary
    condition = equality  # Начинаем с условия

    if (peek.type == :operator) &&  peek.value == "?"  # Проверяем на тернарный оператор '?'
      advance
      true_case = expression_until([":"])  # Обрабатываем истинную часть
      false_case = expression_until([";"])  # Обрабатываем ложную часть
      back
      return { type: :ternary_expression, condition: condition, true_case: true_case, false_case: false_case }
    end

    condition
  end

  def equality
    left = comparison  # Начинаем с сравнения

    if (peek.type == :operator) && ["==", "!=", "<", ">", "<=", ">="].include?(peek.value)
      operator = peek.value
      advance
      right = comparison
      left = { type: :binary_expression, operator: operator, left: left, right: right }
    end

    left
  end

  def comparison
    left = term  # Начинаем с термина

    if (peek.type == :operator) && ["+", "-"].include?(peek.value)
      operator = peek.value
      advance
      right = term
      left = { type: :binary_expression, operator: operator, left: left, right: right }
    end

    left
  end

  def term
    left = factor  # Начинаем с фактора

    if (peek.type == :operator) && ["*", "/", "%"].include?(peek.value)
      operator = peek.value
      advance
      right = factor
      left = { type: :binary_expression, operator: operator, left: left, right: right }
    end
    left
  end

  def string_declaration
    elements = []
    string = peek.value  # Получаем строку
    
    # Регулярное выражение ищет в строке переменные: $scalar, @array, %hash
    while string =~ /(?<text>[^$@%]*)(?<var>[$@%]\w+)?/
      break if string.empty?
  
      text_part = $~[:text]
      var_part = $~[:var]
  
      elements << { type: :string, value: text_part } unless text_part.empty?
      
      if var_part
        subtype = case var_part[0]
                  when '$' then :scalar
                  when '@' then :array
                  when '%' then :hash
                  end
        elements << {type: :identifier, value: var_part, subtype: subtype}
      end
  
      string = $'  # Обрезаем обработанную часть строки
    end
  
    advance
    
    if elements.size > 1
      { type: :string, elements: elements }
    else
      { type: :string, value: previous.value }
    end
  end
  

  def factor
    if peek.type == :operator && peek.value == "!"  # Проверяем на унарный оператор '!'
      advance
      right = factor  # Парсим правое выражение
      return { type: :unary_expression, operator: "!", value: right }
    elsif peek.type == :number
      advance
      { type: :number, subtype: previous.subtype, value: previous.value }
    elsif peek.type == :string  # Поддержка строк
      string_declaration
    elsif peek.type == :identifier
      name = peek.value
      subtype = peek.subtype
      advance
      if peek.type == :punctuation && peek.value == "[" 
        advance
        index = expression_until(["]"])  # Получаем индексное выражение
        return { type: :index_expression, name: { type: :identifier, subtype: subtype, value: name}, index: index }
      end

      if peek.type == :punctuation && peek.value == "(" 
        return function_call
      end

      if peek.type == :punctuation && peek.value == "{" 
        advance
        index = expression_until(["}"])  # Получаем индексное выражение
          return { type: :index_hash_expression, name: { type: :identifier, subtype: subtype, value: name}, index: index }
      end

      if peek.type == :operator && peek.value == "->" 
        advance
        if peek.type == :punctuation && peek.value == "[" 
          advance
          index = expression_until(["]"])  # Получаем индексное выражение
          return { type: :ref_index_expression, name:{ type: :identifier, subtype: subtype, value:  name}, index: index }
        end
        raise "Неожиданное выражение (после -> ожидалось [): #{peek.value}"
      end
  
      if peek.type == :operator && peek.value == "++" 
        return postfix_increment
      end
  
      return { type: :identifier, name: name, subtype: subtype }
    elsif peek.type == :punctuation && peek.value == "["
      elements = []
      advance
      until previous.type == :punctuation && previous.value == "]"
        elements << expression_until([",", "]"]) 
      end
      return { type: :array, elements: elements }
      # if (elements.size > 1)
      #   return { type: :array, elements: elements }
      # end
      # return elements
    elsif peek.type == :punctuation && peek.value == "("
      elements = []
      hash = []
      advance
      is_hash = false
      until previous.type == :punctuation && previous.value == ")"
        value = expression_until([",", ")", "=>"]) 
        if previous.type == :operator && previous.value == "=>"
          hash_value = expression_until([",", ")"]) 
          hash << { key: value, value: hash_value}
          is_hash = true
        else 
          elements << value
        end
      end
      if is_hash && elements.size > 0
        raise "Неожиданное выражение3 (в hash объявлении только хэш объявления)"                
      end
      if hash.size > 0
        return { type: :hash, elements: hash }
      elsif (elements.size > 1)
        return { type: :array, elements: elements }
      elsif (elements.size == 1)
        return elements[0]
      end
      return elements
    elsif peek.type == :keyword && peek.value == "defined"
      advance
      right = factor  # Парсим правое выражение
      return { type: :defined,  value: right }
    else
      raise "Неожиданное выражение2: #{peek.value}"
    end
  end

  def postfix_increment
    if peek.type == :operator && peek.value == "++"
      name = previous.value
      advance      
      return { type: :postfix_increment, name: name }
    end
  end

  def function_call        
    parameters = []
    advance
    until previous.type == :punctuation && previous.value == ")"
      parameters << expression_until([",", ")"]) 
    end
    return { type: :function, parameters: parameters }
  end

  def advance
    @current += 1 unless @current >= @tokens.size
    previous
  end

  def back
    @current -= 1 unless @current <= 0
    peek
  end

  def previous
    @tokens[@current - 1]
  end

  def peek
    @tokens[@current]
  end

end
