# `Object` is the base type of all Crystal objects.
#
# `Object` has two descendants: `Reference`, representing all class types; and
# `Value`, representing all user-defined struct types and the primitive types.
abstract class Object
  # Returns the runtime `Class` of an object.
  #
  # ```
  # 1.class       # => Int32
  # "hello".class # => String
  # ```
  #
  # Compare it with `typeof`, which returns the **compile-time** type of an
  # object:
  #
  # ```
  # random_value = rand # => 0.627423
  # value = random_value < 0.5 ? 1 : "hello"
  # value         # => "hello"
  # value.class   # => String
  # typeof(value) # => Int32 | String
  # ```
  @[Primitive(:class)]
  def class : Class
  end

  # Case equality.
  #
  # The `===` method is used in a `case ... when ... end` expression.
  # Object implements `===` by invoking `==`, but subclasses can override it to
  # provide different equality semantics in `case` to their regular `==`
  # semantics.
  #
  # For example, this code:
  #
  # ```
  # case value
  # when x
  #   # something when x
  # when y
  #   # something when y
  # end
  # ```
  #
  # Is equivalent to this code:
  #
  # ```
  # if x === value
  #   # something when x
  # elsif y === value
  #   # something when y
  # end
  # ```
  #
  def ===(other) : Bool
    self == other
  end
end
