class Token
  attr_reader :type, :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  def to_s
    "#{@type}: #{@value}"
  end
end

# Возможные типы токенов
TOKEN_TYPES = {
  keyword: "KEYWORD",
  identifier: "IDENTIFIER",
  number: "NUMBER",
  string: "STRING",
  operator: "OPERATOR",
  punctuation: "PUNCTUATION",
  comment: "COMMENT",
  eof: "EOF"
}
