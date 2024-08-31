# Int is the base type of all integer types.
#
# See [Integers](https://crystal-lang.org/reference/syntax_and_semantics/literals/integers.html)
# in the language reference.
abstract struct Int
  # All signed primitive integer types.
  alias Signed = Int8 | Int16 | Int32 | Int64 | Int128

  # All unsigned primitive integer types.
  alias Unsigned = UInt8 | UInt16 | UInt32 | UInt64 | UInt128

  # All primitive integer types.
  alias Primitive = Signed | Unsigned

  # Returns `true` if all bits in *mask* are set in `self`.
  def bits_set?(mask : Int) : Bool
    (self & mask) == mask
  end

  # Returns `self`.
  #
  # `to_int` may be implemented on other classes, to convert them into integers.
  # On such classes, `to_int` should not change the signedness or width if
  # possible.
  def to_int : Int::Primitive
    self
  end

  # Execute the block `self` times.
  #
  # ```
  # i = 10
  # 3.times { i += 1 }
  # i # => 13
  # ````
  def times(& : self ->) : Nil
    i = self.class.zero
    while i < self
      yield i
      i &+= 1
    end
  end
end

{% begin %}
  {% ints = {i8: Int8, i16: Int16, i32: Int32, i64: Int64, i128: Int128,
             u8: UInt8, u16: UInt16, u32: UInt32, u64: UInt64, u128: UInt128} %}
  {% for shortcode, type in ints %}
    {% signed = shortcode.starts_with? "i" %}
    struct {{type}}
      # Cast *value* to {{type}}.
      # In case of overflow, the value is truncated.
      def self.new!(value : Int) : {{type}}
        value.to_{{shortcode}}!
      end

      # The zero value for {{type}}.
      # Mostly used for writing code that is generic over multiple integer types.
      def self.zero : {{type}}
        0_{{shortcode}}
      end

      # Add `self` and *other*.
      # Wraps in case of overflow.
      def &+(other : Int::Primitive) : {{type}}
      end

      # Add `self` and *other*.
      # TODO: overflow behaviour? Currently always wraps.
      @[AlwaysInline]
      def +(other : Int::Primitive) : {{type}}
        self &+ other
      end

      # Subtract *other* from `self`.
      # Wraps in case of overflow.
      def &-(other : Int::Primitive) : {{type}}
      end

      # Subtract *other* from `self`.
      # TODO: overflow behaviour? Currently always wraps.
      @[AlwaysInline]
      def -(other : Int::Primitive) : {{type}}
        self &- other
      end

      # Multiply `self` and *other.
      # Wraps in case of overflow.
      def &*(other : Int::Primitive) : {{type}}
      end

      # Multiply `self` and *other.
      # TODO: overflow behaviour? Currently always wraps.
      @[AlwaysInline]
      def *(other : Int::Primitive) : {{type}}
        self &* other
      end

      # Returns `true` if `self` is equal to *other*.
      def ==(other : Int::Primitive) : Bool
      end

      # Returns `true` if `self` is not equal to *other*.
      def !=(other : Int::Primitive) : Bool
      end

      # Returns `true` if `self` is less than *other*.
      def <(other : Int::Primitive) : Bool
      end

      # Returns `true` if `self` is less than or equal to *other*.
      def <=(other : Int::Primitive) : Bool
      end

      # Returns `true` if `self` is greater than *other*.
      def >(other : Int::Primitive) : Bool
      end

      # Returns `true` if `self` is greater than or equal to *other*.
      def >=(other : Int::Primitive) : Bool
      end

      {% for other_shortcode, other_type in ints %}
        # :nodoc:
        @[Primitive(:binary)]
        def &+(other : {{other_type}}) : {{type}}
        end

        # :nodoc:
        @[Primitive(:binary)]
        def &-(other : {{other_type}}) : {{type}}
        end

        # :nodoc:
        @[Primitive(:binary)]
        def &*(other : {{other_type}}) : {{type}}
        end

        {% for op, desc in {"==", "!=", "<", "<=", ">", ">="} %}
          # :nodoc:
          @[Primitive(:binary)]
          def {{op.id}}(other : {{other_type}}) : Bool
          end
        {% end %}

        @[Primitive(:binary)]
        protected def unsafe_shl(count : {{other_type}}) : self
        end

        @[Primitive(:binary)]
        protected def unsafe_shr(count : {{other_type}}) : self
        end

        # Returns `self` converted to `{{other_type}}`.
        # In case of overflow, the value is truncated.
        @[Primitive(:unchecked_convert)]
        def to_{{other_shortcode}}! : {{other_type}}
        end
      {% end %}

      {% if signed %}
        # Returns `self` with inverted sign.
        #
        # ```
        # val = 10
        # -val # => -10
        # ```
        def - : {{type}}
          0_{{shortcode}} - self
        end
      {% end %}

      # Bitwise AND of `self` and *other*.
      @[Primitive(:binary)]
      def &(other : {{type}}) : {{type}}
      end

      # Bitwise OR of `self` and *other*.
      @[Primitive(:binary)]
      def |(other : {{type}}) : {{type}}
      end

      # Shift this number's bits *count* positions to the left.
      #
      # - If *count* is greater than the number of bits representing this
      #   integer, the result is 0.
      # - If *count* is negative, a{% if signed %}n arithmetic{% end %} right shift is performed.
      #
      # ```
      # 8000 << 1  # => 16000
      # 8000 << 2  # => 32000
      # 8000 << 32 # => 0
      # 8000 << -1 # => 4000
      # ```
      def <<(count : Int::Primitive) : {{type}}
        if count < 0
          self >> count.abs
        elsif count < sizeof(self) * 8
          unsafe_shl(count)
        else
          0_{{shortcode}}
        end
      end

      # Shift this number's bits *count* positions to the right.
      #
      {% if signed %}
      # The sign is extended to fill any empty bits, performing an arithmetic
      # shift.
      {% end %}
      #
      # - If *count* is greater than the number of bits representing this
      #   integer, the result is 0.
      # - If *count* is negative, a left shift is performed.
      #
      # ```
      # 8000 >> 1  # => 4000
      # 8000 >> 2  # => 2000
      # 8000 >> 32 # => 0
      # 8000 >> -1 # => 16000
      {% if signed %}
      #
      # -8000 >> 1 # => -4000
      {% end %}
      # ```
      def >>(count : Int::Primitive) : {{type}}
        if count < 0
          self << count.abs
        elsif count < sizeof(self) * 8
          unsafe_shr(count)
        else
          0_{{shortcode}}
        end
      end

      # Returns the absolute value of this number.
      #
      # ```
      # 10.abs  # => 10
      # -10.abs # => 10
      # ```
      def abs : {{type}}
        {% if signed %}
          self >= 0 ? self : -self
        {% else %}
          self
        {% end %}
      end
    end
  {% end %}
{% end %}
