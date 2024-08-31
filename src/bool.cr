# Bool has only two possible values: `true` and `false`. They are constructed using these literals:
#
# ```
# true  # A Bool that is true
# false # A Bool that is false
# ```
#
# See [`Bool` literals](https://crystal-lang.org/reference/syntax_and_semantics/literals/bool.html) in the language reference.
struct Bool
  # Returns `true` if `self` is equal to *other*.
  @[Primitive(:binary)]
  def ==(other : Bool) : Bool
  end

  # Returns `true` if `self` is not equal to *other*.
  @[Primitive(:binary)]
  def !=(other : Bool) : Bool
  end

  # Returns 1 if true, else 0.
  def to_int : Int32
    self ? 1 : 0
  end
end
