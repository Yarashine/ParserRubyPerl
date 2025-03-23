require_relative 'token'



class Lexer2
  KEYWORDS = %w[my our use sub if else unless while until for foreach given when default print return constant feature]
  OPERATORS = %w[= ++ + - * / == != < > <= >= && || ! => . ->]
  PUNCTUATION = %w[( ) { } [ ] , ;]
  
  

  def initialize(code)
    @code = code
    @last_token_is_identifier = false
    @tokens = []
  end
  def tokenize
    until @code.empty?
      case @code
      when /\A#(.*)/ 
        @tokens << Token.new(:comment, $1)
      when /\A(-?\d+(?:\.\d*)?(?:[eE][+-]?\d+)?)/  
        subtype = $1.include?('.') || $1.include?('e')|| $1.include?('E') ? :float : :integer
        check_identificator(true, $1)
        @tokens << Token.new(:number, $1, subtype)
      when /\A"(.*?)"/  
        check_identificator(true, $1)
        @tokens << Token.new(:string, $1)
      when /\A'(.*?)'/  
        check_identificator(true, $1)
        @tokens << Token.new(:string, $1)
      when /\A(my|our|use|sub|if|else|unless|while|until|for|foreach|given|when|default|print|return|defined|constant|feature)\b/
        check_identificator(true, $1)
        @tokens << Token.new(:keyword, $1)
      when /\A(\$\w+)/  
        check_identificator(true, $1)
        @tokens << Token.new(:identifier, $1, :scalar)
      when /\A(@\w+)/  
        check_identificator(true, $1)
        @tokens << Token.new(:identifier, $1, :array)
      when /\A(%\w+)/  
        check_identificator(true, $1)
        @tokens << Token.new(:identifier, $1, :hash)
      when /\A(\w+)/ 
        check_identificator(true, $1)
        @tokens << Token.new(:identifier, $1)
      when /\A(\+\+|\*|\/|==|!=|<=|>=|&&|\|\||!|=>|->|\+|\-|=|\?|<|>|:)/
        check_identificator(false, $1)
        @tokens << Token.new(:operator, $1)
      when /\A([\(\)\{\}\[\],;])/  
        check_identificator(false, $1)
        @tokens << Token.new(:punctuation, $1)
      when /\A\s+/  
        check_identificator(false, $1)
      else
        raise "Неизвестная лексема: #{@code}"
      end
      @code = $' 
    end
    @tokens << Token.new(:eof, "EOF")  
    @tokens
  end

  def check_identificator(last_token_is_identifier_p, val)
    if @last_token_is_identifier && last_token_is_identifier_p
      raise "Неизвестная конструкция после #{@tokens.last.value}: #{val}"
    end
    @last_token_is_identifier = last_token_is_identifier_p
  end

  COL_NUM_WIDTH = 4
  COL_VALUE_WIDTH = 60
  COL_TYPE_WIDTH = 12
  TABLE_WIDTH = COL_NUM_WIDTH + COL_VALUE_WIDTH + COL_TYPE_WIDTH + 8

  def print_tokens()
    tokens = tokenize.uniq { |token| [token.type, token.value] }
    grouped_tokens = tokens.group_by(&:type)

    grouped_tokens = tokens.reject { |t| t.type == :eof }.group_by(&:type)

    def print_table(title, tokens)
      return if tokens.empty?

      puts "\n#{title}"
      puts "-" * (TABLE_WIDTH + 1)
      puts "| №   | #{'Значение'.ljust(COL_VALUE_WIDTH)} | #{'Тип'.ljust(COL_TYPE_WIDTH)} |"
      puts "-" * (TABLE_WIDTH + 1)

      tokens.each_with_index do |token, index|
        display_type = token.subtype || token.type
        puts "| #{(index + 1).to_s.ljust(COL_NUM_WIDTH - 1)} | #{token.value.ljust(COL_VALUE_WIDTH)} | #{display_type.to_s.ljust(COL_TYPE_WIDTH)} |"
      end

      puts "-" * (TABLE_WIDTH + 1)
    end

    TOKEN_TYPES.each do |type, title|
      print_table(title, grouped_tokens[type] || [])
    end
  end
end
