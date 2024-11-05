# A named tuple is a fixed-size, immutable, stack-allocated mapping
# of a fixed set of keys to values.
#
# You can think of a `NamedTuple` as an immutable `Hash` whose keys (which
# are of type `Symbol`), and the types for each key, are known at compile time.
#
# See [`NamedTuple` literals](https://crystal-lang.org/reference/syntax_and_semantics/literals/named_tuple.html)
# in the language reference.
#
# The compiler knows what types are in each key, so when indexing a named tuple
# with a symbol or string literal the compiler will return the value for that
# key and with the expected type, like in the above snippet. Indexing with a
# symbol or string literal for which there's no key will give a compile-time
# error.
#
# Indexing with a symbol or string that is only known at runtime will return
# a value whose type is the union of all the types in the named tuple,
# and might raise `KeyError`.
#
# Indexing with `#[]?` does not make the return value nilable if the key is
# known to exist:
#
# ```
# language = {name: "Crystal", year: 2011}
# language[:name]?         # => "Crystal"
# typeof(language[:name]?) # => String
# ```
#
# `NamedTuple`'s own instance classes may also be indexed in a similar manner,
# returning their value types instead:
#
# ```
# tuple = NamedTuple(name: String, year: Int32)
# tuple[:name]   # => String
# tuple["year"]  # => Int32
# tuple[:other]? # => nil
# ```
struct NamedTuple
  # Create a named tuple containing the given arguments.
  #
  # Using named tuple literals, you cannot create an empty named tuple. This
  # constructor does not have that limitation, making it especially useful in
  # macro code.
  #
  # ```
  # NamedTuple.new(name: "Crystal", year: 2011) #=> {name: "Crystal", year: 2011}
  # NamedTuple.new # => {}
  # {}             # syntax error
  # ```
  def self.new(**options : **T)
    options
  end

  # Return a new named tuple with identical keys, but the values transformed by
  # the provided block. The key is provided as an optional second argument to the block.
  #
  # ```
  # {foo: 1, bar: 2}.transform_values { |v| v + 1 }      # => {foo: 2, bar: 3}
  # {bob: nil, alice: nil}.transform_values { |_, k| k } # => {bob: :bob, alice: :alice}
  # ```
  def transform_values(&)
    {% begin %}
      NamedTuple.new(
        {% for key in T %}
          {{key.stringify}}: yield(self[{{key.symbolize}}], {{key.symbolize}}),
        {% end %}
      )
    {% end %}
  end
end
