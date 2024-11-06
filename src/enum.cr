# Enum is the base type of all enums.
#
# See [Enums](https://crystal-lang.org/reference/1.13/syntax_and_semantics/enum.html).
abstract struct Enum
  # Returns the underlying value held by the enum instance.
  #
  # ```
  # enum Color
  #   Red
  #   Green
  #   Blue
  #   Other = 99
  # end
  #
  # Color::Red.to_int   # => 0
  # Color::Blue.to_int  # => 2
  # Color::Other.to_int # => 99
  # ```
  def to_int : Int::Primitive
    self.value
  end

  # Returns `true` if this enum member and *other* have the same underlying
  # value.
  #
  # ```
  # Color::Red == Color::Red  # => true
  # Color::Red == Color::Blue # => false
  # ```
  def ==(other : self) : Bool
    value == other.value
  end

  def self.new!(value : Int) : self
    from_int?(value) || panic("Unknown enum value")
  end

  def self.from_int?(value : Int) : self?
    {% if @type.annotation(Flags) %}
      {% raise "Not Implemented" %}
    {% else %}
      {% for member in @type.constants %}
        return new({{@type.constant(member)}}) if {{@type.constant(member)}}.to_int == value
      {% end %}
    {% end %}
  end
end
