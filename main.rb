require_relative 'lexer'
require_relative 'parser'
require_relative 'lexerTree'
require_relative 'parseTree'
require_relative 'semantic'
require_relative 'interpreter'

# Загружаем код из файла
#code = File.read("test.pl")
code = File.read("code.pl")

#puts code
# Разбираем код
lexer = Lexer.new(code)

tokens = lexer.tokenize

puts tokens

lexer.print_tokens


# lexer2 = Lexer2.new(code)

# tokens2 = lexer2.tokenize

#parser2 = Parser2.new(tokens2)
#pt = parser2.parse
#puts "\nPT:"
#parser2.print_tree(pt)
#print pt


parser = Parser.new(tokens)
ast = parser.parse
puts "\nPT:"
#parser.print_tree(ast)ast = parser.parse
puts "[" + ast.map { |element| element.inspect }.join(", ") + "]"





analyzer = SemanticAnalyzer.new
symbol_table = analyzer.analyze(ast)



puts "Symbol Table:"
#analyzer.print_symbol_table()
puts symbol_table



interpreter = Interpreter.new(symbol_table)
interpreter.interpret(ast)


