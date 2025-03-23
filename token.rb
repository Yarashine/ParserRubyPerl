class Token
  attr_reader :type, :value, :subtype

  def initialize(type, value, subtype = nil)
    @type = type
    @value = value
    @subtype = subtype
  end

  def to_s
    subtype_str = @subtype ? ":#{@subtype}" : ""
    "#{@type}#{subtype_str}: #{@value}"
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
