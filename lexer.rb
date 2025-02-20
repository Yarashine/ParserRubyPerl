require_relative 'token'

class Lexer
  KEYWORDS = %w[my our use sub if else unless while until for foreach given when default print return constant feature]
  OPERATORS = %w[= ++ + - * / == != < > <= >= && || ! => . ->]
  PUNCTUATION = %w[( ) { } [ ] , ;]
  
  def initialize(code)
    @code = code
    @tokens = []
  end

  def tokenize
    until @code.empty?
      case @code
      when /\A#(.*)/  # Комментарий
        #@tokens << Token.new(:comment, $1)
      when /\A(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)/  # Число
        @tokens << Token.new(:number, $1)
      when /\A"(.*?)"/  # Строка
        @tokens << Token.new(:string, $1)
      when /\A'(.*?)'/  # Строка в одинарных кавычках
        @tokens << Token.new(:string, $1)
      when /\A(my|our|use|sub|if|else|unless|while|until|for|foreach|given|when|default|print|return|defined|constant|feature)\b/
        @tokens << Token.new(:keyword, $1)
      when /\A([\$\@\%]?\w+)/  # Переменные Perl-стиля ($var, @array, %hash)
        @tokens << Token.new(:identifier, $1)
      when /\A(\+\+|\*|\/|==|!=|<=|>=|&&|\|\||!|=>|->|\+|\-|=|\?|<|>|:)/
        @tokens << Token.new(:operator, $1)      
      when /\A([\(\)\{\}\[\],;])/  # Разделители (скобки, запятые, точки с запятой)
        @tokens << Token.new(:punctuation, $1)
      when /\A\s+/  # Пропуск пробелов
        # Ничего не делаем
      else
        raise "Неизвестный токен: #{@code}"
      end
      @code = $'  # Обрезаем распознанную часть
    end
    @tokens << Token.new(:eof, "EOF")  # Конец файла
    @tokens
  end
end
