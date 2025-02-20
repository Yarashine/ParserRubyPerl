require_relative 'lexer'
require_relative 'parser'

# Загружаем код из файла
code = File.read("test.pl")

# Разбираем код
lexer = Lexer.new(code)

tokens = lexer.tokenize

puts tokens

# tokens = lexer.tokenize.uniq { |token| [token.type, token.value] }
# grouped_tokens = tokens.group_by(&:type)

# # Группировка токенов по типам, исключая EOF
# grouped_tokens = tokens.reject { |t| t.type == :eof }.group_by(&:type)

# # Определяем фиксированные ширины колонок
# COL_NUM_WIDTH = 4
# COL_VALUE_WIDTH = 60
# COL_TYPE_WIDTH = 12
# TABLE_WIDTH = COL_NUM_WIDTH + COL_VALUE_WIDTH + COL_TYPE_WIDTH + 8

# # Функция для вывода таблицы
# def print_table(title, tokens)
#   return if tokens.empty?

#   puts "\n#{title}"
#   puts "-" * (TABLE_WIDTH + 1)
#   puts "| №   | #{'Значение'.ljust(COL_VALUE_WIDTH)} | #{'Тип'.ljust(COL_TYPE_WIDTH)} |"
#   puts "-" * (TABLE_WIDTH + 1)

#   tokens.each_with_index do |token, index|
#     puts "| #{(index + 1).to_s.ljust(COL_NUM_WIDTH - 1)} | #{token.value.ljust(COL_VALUE_WIDTH)} | #{token.type.to_s.ljust(COL_TYPE_WIDTH)} |"
#   end

#   puts "-" * (TABLE_WIDTH + 1)
# end

# # Вывод таблиц по типам
# TOKEN_TYPES.each do |type, title|
#   print_table(title, grouped_tokens[type] || [])
# end



parser = Parser.new(tokens)
ast = parser.parse
puts "\nAST:"
puts ast.inspect
