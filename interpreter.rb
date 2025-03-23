class Interpreter
  def initialize(symbol_table)
    @symbol_table = symbol_table
  end

  def interpret(ast)
    ast.each { |node| visit(node) }
  end

  def visit(node)
    if node == nil
      puts 1
      puts node
    else
      method_name = "visit_#{node[:type]}"
      if respond_to?(method_name)
        send(method_name, node)
      else
        raise "No visit method for #{node[:type]}"
      end
    end
  end

  def visit_variable_declaration(node)
    var_name = node[:name][:value]
    value = visit(node[:value])
    #new_scope = visit(node[:scope])

    existing_symbol = @symbol_table.find { |entry| entry[:name] == var_name }
    #puts node
  if existing_symbol
    # If the existing symbol's scope is lower priority, update its scope and value
    # if existing_symbol[:scope] < new_scope
    #   existing_symbol[:scope] = new_scope
    # else
    #   existing_symbol[:value] = value
    # end
    #existing_symbol[:scope] = new_scope
    existing_symbol[:value] = value
    else
      # Create a new entry in the symbol table for the variable
      @symbol_table << {
        name: var_name,
        type: "variable",
        subtype: :scalar,
        value: value,
        scope: "my" # or use the appropriate scope value
      }
    end
  end

  def visit_assignment(node)
    var_name = node[:name]
    value = visit(node[:value])

    # Find the symbol table entry for the variable
    symbol = @symbol_table.find { |entry| entry[:name] == var_name }

    if symbol
      symbol[:value] = value
    else
      raise "Undefined variable '#{var_name}'"
    end
  end

  def visit_number(node)
    case node[:subtype]
    when :integer then node[:value].to_i
    when :float then node[:value].to_f
    else raise "Unknown number subtype '#{node[:subtype]}'"
    end
  end

  def visit_string(node)
    #puts node
    node[:value].to_s
  end

  def visit_identifier(node)
    var_name = node[:name]
    
    # Find the symbol table entry for the identifier
    symbol = @symbol_table.find { |entry| entry[:name] == var_name }

    if symbol
      symbol[:value]
    else
      raise "Undefined variable '#{var_name}'"
    end
  end

  def visit_print(node)
    output = node[:parameters].map { |param| visit(param) }.join(" ")
    puts output
  end
end
