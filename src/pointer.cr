# A typed pointer to some memory.
#
# This is an unsafe type in Crystal. If you are using a pointer, you are writing
# unsafe code because a pointer doesn't know if it's address points to valid
# memory, nor how much memory starting from the address is valid. However,
# pointers make it possible to interface with non-Crystal code, and to implement
# some more efficient data structures. For example, both `Array` and `Hash` are
# implemented using pointers.
#
# `pointerof(x)`, where *x* is a variable or an instance variable, returns a
# pointer to that variable:
#
# ```
# x = 1
# ptr = pointerof(x)
# ptr.store(2)
# x # => 2
# ```
#
# Use `#load` to dereference the pointer.
#
# Note that a pointer is *falsey* if it's null (if its address is zero).
#
# When calling a C function that expects a pointer you can also pass `nil`
# instead of using `Pointer.null` to construct a null pointer.
#
# For a safe alternative, see `Slice`, which is a pointer with a size and with
# bounds checking.
struct Pointer(T)
  # Returns a pointer that points to the memory at *address*.
  #
  # ```
  # ptr = Pointer(Int32).new(1234_u64)
  # ptr.address # => 1234_u64
  # ```
  @[Primitive(:pointer_new)]
  def self.new(address : UInt64) : Pointer(T)
  end

  # Returns a pointer that points to the address 0.
  def self.null : Pointer(T)
    new(0)
  end

  # Returns the memory address pointed to by this pointer.
  #
  # ```
  # ptr = Pointer(Int32).new(1234)
  # ptr.address # => 1234
  # ```
  @[Primitive(:pointer_address)]
  def address : UInt64
  end

  # Two pointers are equal if their `address` is the same.
  def ==(other : Pointer(T)) : Bool
    self.address == other.address
  end

  # Returns a new pointer whose address is this pointer's address
  # incremented by `offset * sizeof(T)`.
  #
  # ```
  # ptr = Pointer(Int32).new(1234)
  # ptr.address # => 1234
  #
  # # An Int32 occupies four bytes
  # ptr2 = ptr + 1
  # ptr2.address # => 1238
  # ```
  @[Primitive(:pointer_add)]
  def +(offset : Int64) : self
  end

  # An AtomicOrdering can be attached to loads, stores, or fences to control the
  # ordering of memory operations seen by programs executing in parallel on the
  # same or other addresses.
  #
  # For a more thorough introduction, see https://llvm.org/docs/Atomics.html.
  # For detailed information on LLVM's memory model, see
  # https://llvm.org/docs/LangRef.html#memory-model-for-concurrent-operations.
  enum AtomicOrdering
    NotAtomic              = 0
    Unordered              = 1
    Monotonic              = 2
    Acquire                = 4
    Release                = 5
    AcquireRelease         = 6
    SequentiallyConsistent = 7
  end

  @[Primitive(:load_atomic)]
  protected def self.primitive_atomic_load(ptr : T*, ordering : AtomicOrdering, volatile : Bool) : T forall T
  end

  @[Primitive(:store_atomic)]
  protected def self.primitive_atomic_store(ptr : T*, value : T, ordering : AtomicOrdering, volatile : Bool) : Nil forall T
  end

  # Read from memory at this pointer's memory address.
  #
  # The pointer must be properly aligned, `address` must be a multiple of
  # `alignof(T)`. It is undefined behaviour to load from a misaligned pointer.
  # UInt8 is guaranteed to have byte alignment.
  @[Primitive(:pointer_get)]
  def load : T
  end

  # Read from memory at this pointer's memory address.
  #
  # The pointer must be properly aligned, `address` must be a multiple of
  # `alignof(T)`. It is undefined behaviour to load from a misaligned pointer.
  # UInt8 is guaranteed to have byte alignment.
  #
  # The load can be made *volatile*, which should be used for loads with side
  # effects, for example memory-mapped hardware registers. Volatile loads and
  # stores cannot change order, be removed, or added. For more details see
  # https://llvm.org/docs/LangRef.html#volatile.
  @[AlwaysInline]
  def load(*, volatile : Bool = false) : T
    if volatile
      Pointer.primitive_atomic_load(self, :not_atomic, true)
    else
      load
    end
  end

  # Write *value* in memory at this pointer's memory address.
  #
  # The pointer must be properly aligned, `address` must be a multiple of
  # `alignof(T)`. It is undefined behaviour to store to a misaligned pointer.
  # UInt8 is guaranteed to have byte alignment.
  @[Primitive(:pointer_set)]
  def store(value : T) : T
  end

  # Write *value* in memory at this pointer's memory address.
  #
  # The pointer must be properly aligned, `address` must be a multiple of
  # `alignof(T)`. It is undefined behaviour to store to a misaligned pointer.
  # UInt8 is guaranteed to have byte alignment.
  #
  # The store can be made *volatile*, which should be used for stores with side
  # effects, for example memory-mapped hardware registers. Volatile loads and
  # stores cannot change order, be removed, or added. For more details see
  # https://llvm.org/docs/LangRef.html#volatile.
  @[AlwaysInline]
  def store(value : T, *, volatile : Bool = false) : T
    if volatile
      Pointer.primitive_atomic_store(self, value, :not_atomic, true)
      value
    else
      store(value)
    end
  end
end
