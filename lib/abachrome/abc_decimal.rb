# Abachrome::AbcDecimal - High-precision decimal arithmetic for color calculations
#
# This class provides a wrapper around Ruby's BigDecimal to ensure consistent precision
# across color space conversions and calculations. It handles the precision requirements
# needed for accurate color manipulation while providing a convenient interface that
# supports standard arithmetic operations and type coercion.
#
# The class is designed to work seamlessly with Ruby's numeric types while maintaining
# the high precision necessary for color science calculations. It includes methods for
# conversion between different numeric representations and implements the full set of
# comparison and arithmetic operators.
#
# Default precision can be configured via the ABC_DECIMAL_PRECISION environment variable,
# falling back to 24 significant digits if not specified.

require "bigdecimal"
require "forwardable"

module Abachrome
  class AbcDecimal
    extend Forwardable
    DEFAULT_PRECISION = (ENV["ABC_DECIMAL_PRECISION"] || "24").to_i

    attr_accessor :value, :precision

    def_delegators :@value, :to_i, :zero?, :nonzero?, :finite?

    # Initializes a new AbcDecimal object with the specified value and precision.
    # 
    # @param value [AbcDecimal, BigDecimal, Rational, #to_s] The numeric value to represent.
    # If an AbcDecimal is provided, its internal value is used.
    # If a BigDecimal or Rational is provided, it's used directly.
    # Otherwise, the value is converted to a string and parsed as a BigDecimal.
    # @param precision [Integer] The decimal precision to use (number of significant digits).
    # Defaults to DEFAULT_PRECISION.
    # @return [AbcDecimal] A new AbcDecimal instance.
    def initialize(value, precision = DEFAULT_PRECISION)
      @precision = precision
      @value = case value
               when AbcDecimal
                 value.value
               when BigDecimal
                 value
               when Rational
                 value
               else
                 BigDecimal(value.to_s, precision)
               end
    end

    # Returns a string representation of the decimal value.
    # 
    # This method converts the internal value to a String, using a fixed-point
    # notation format. If the internal value is a Rational, it's first converted
    # to a BigDecimal with the configured precision before string conversion.
    # 
    # @return [String] The decimal value as a string in fixed-point notation
    def to_s
      if @value.is_a?(Rational)
        BigDecimal(@value, precision).to_s("F")
      else
        @value.to_s("F") # different behaviour than default BigDecimal
      end
    end

    # Converts the decimal value to a floating-point number.
    # 
    # @return [Float] the floating-point representation of the AbcDecimal value
    def to_f
      @value.to_f
    end

    # Creates a new AbcDecimal from a string representation of a number.
    # 
    # @param str [String] The string representation of a number to convert to an AbcDecimal
    # @param precision [Integer] The precision to use for the decimal value (number of significant digits after the decimal point). Defaults to DEFAULT_PRECISION
    # @return [AbcDecimal] A new AbcDecimal instance initialized with the given string value and precision
    def self.from_string(str, precision = DEFAULT_PRECISION)
      new(str, precision)
    end

    # Creates a new AbcDecimal from a Rational number.
    # 
    # @param rational [Rational] The rational number to convert to an AbcDecimal
    # @param precision [Integer] The precision to use for the decimal representation, defaults to DEFAULT_PRECISION
    # @return [AbcDecimal] A new AbcDecimal instance with the value of the given rational number
    def self.from_rational(rational, precision = DEFAULT_PRECISION)
      new(rational, precision)
    end

    # Creates a new AbcDecimal instance from a float value.
    # 
    # @param float [Float] The floating point number to convert to an AbcDecimal
    # @param precision [Integer] The precision to use for the decimal representation (default: DEFAULT_PRECISION)
    # @return [AbcDecimal] A new AbcDecimal instance representing the given float value
    def self.from_float(float, precision = DEFAULT_PRECISION)
      new(float, precision)
    end

    # Creates a new AbcDecimal from an integer value.
    # 
    # @param integer [Integer] The integer value to convert to an AbcDecimal
    # @param precision [Integer] The precision to use for the decimal, defaults to DEFAULT_PRECISION
    # @return [AbcDecimal] A new AbcDecimal instance with the specified integer value and precision
    def self.from_integer(integer, precision = DEFAULT_PRECISION)
      new(integer, precision)
    end

    # # Addition operation
    # #
    # # Adds another value to this decimal.
    # #
    # # @param other [AbcDecimal, Numeric] The value to add. If not an AbcDecimal,
    # #   it will be converted to one.
    # # @return [AbcDecimal] A new AbcDecimal instance with the sum of the two values
    def +(other)
      other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
      self.class.new(@value + other_value)
    end

    # Subtracts another numeric value from this AbcDecimal.
    # 
    # @param other [AbcDecimal, Numeric] The value to subtract from this AbcDecimal.
    # @return [AbcDecimal] A new AbcDecimal representing the result of the subtraction.
    def -(other)
      other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
      self.class.new(@value - other_value)
    end

    # Multiplies this AbcDecimal by another value.
    # 
    # @param other [Object] The value to multiply by. If not an AbcDecimal, it will be converted to one.
    # @return [AbcDecimal] A new AbcDecimal instance representing the product of this decimal and the other value.
    # @example
    # dec1 = AbcDecimal.new(5)
    # dec2 = AbcDecimal.new(2)
    # result = dec1 * dec2 # => AbcDecimal representing 10
    # 
    # # With a non-AbcDecimal value
    # result = dec1 * 3 # => AbcDecimal representing 15
    def *(other)
      other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
      self.class.new(@value * other_value)
    end

    # Divides this decimal by another value.
    # 
    # @param other [Numeric, AbcDecimal] The divisor, which can be an AbcDecimal instance or any numeric value
    # @return [AbcDecimal] A new AbcDecimal representing the result of the division
    # @example
    # decimal = AbcDecimal.new(10)
    # result = decimal / 2
    # # => AbcDecimal.new(5)
    def /(other)
      other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
      self.class.new(@value / other_value)
    end

    # Performs modulo operation with another value.
    # 
    # @param other [Numeric, AbcDecimal] The divisor for the modulo operation
    # @return [AbcDecimal] A new AbcDecimal containing the remainder after division
    def %(other)
      other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
      self.class.new(@value % other_value)
    end

    # Constrains the value to be between the specified minimum and maximum values.
    # 
    # @param min [Numeric, AbcDecimal] The minimum value to clamp to
    # @param max [Numeric, AbcDecimal] The maximum value to clamp to
    # @return [AbcDecimal] A new AbcDecimal within the specified range
    # @example
    # AbcDecimal(5).clamp(0, 10)   # => 5
    # AbcDecimal(15).clamp(0, 10)  # => 10
    # AbcDecimal(-5).clamp(0, 10)  # => 0
    def clamp(min,max)
      @value.clamp(AbcDecimal(min),AbcDecimal(max))
    end

    # Raises self to the power of another value.
    # This method handles different input types, including Rational values and
    # other AbcDecimal instances.
    # 
    # @param other [Numeric, Rational, AbcDecimal] The exponent to raise this value to
    # @return [AbcDecimal] A new AbcDecimal representing self raised to the power of other
    def **(other)
      if other.is_a?(Rational)
        self.class.new(@value**other)
      else
        other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
        self.class.new(@value**other_value)
      end
    end

    # Allows for mixed arithmetic operations between AbcDecimal and other numeric types.
    # 
    # @param other [Numeric] The other number to be coerced into an AbcDecimal object
    # @return [Array<AbcDecimal>] A two-element array containing the coerced value and self,
    # allowing Ruby to perform arithmetic operations with mixed types
    def coerce(other)
      [self.class.new(other), self]
    end

    # Returns a string representation of the decimal value for inspection purposes.
    # This method returns a formatted string that includes the class name and
    # the string representation of the decimal value itself.
    # 
    # @return [String] A string in the format "ClassName('value')"
    def inspect
      "#{self.class}('#{self}')"
    end

    # Compares this decimal value with another value for equality.
    # Attempts to convert the other value to an AbcDecimal if it isn't one already.
    # 
    # @param other [Object] The value to compare against this AbcDecimal
    # @return [Boolean] True if the values are equal, false otherwise
    def ==(other)
      @value == (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    # Compares this AbcDecimal instance with another AbcDecimal or a value that can be
    # converted to an AbcDecimal.
    # 
    # @param other [Object] The value to compare with this AbcDecimal.
    # If not an AbcDecimal, it will be converted using AbcDecimal().
    # @return [Integer, nil] Returns -1 if self is less than other,
    # 0 if they are equal,
    # 1 if self is greater than other,
    # or nil if the comparison is not possible.
    def <=>(other)
      @value <=> (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    # Compares this decimal with another value.
    # 
    # @param other [Object] The value to compare with. Can be an AbcDecimal or any value
    # convertible to AbcDecimal
    # @return [Boolean] true if this decimal is greater than the other value, false otherwise
    def >(other)
      @value > (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    # Compares this decimal value with another value.
    # 
    # @param other [Object] The value to compare against. If not an AbcDecimal,
    # it will be converted to one.
    # @return [Boolean] true if this decimal is greater than or equal to the other value,
    # false otherwise.
    def >=(other)
      @value >= (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    # Compares this decimal with another value.
    # 
    # @param other [Object] The value to compare with. Will be coerced to AbcDecimal if not already an instance.
    # @return [Boolean] true if this decimal is less than the other value, false otherwise.
    # @example
    # dec1 = AbcDecimal.new(1.5)
    # dec2 = AbcDecimal.new(2.0)
    # dec1 < dec2 #=> true
    # dec1 < 2.0  #=> true
    def <(other)
      @value < (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    # Compares this AbcDecimal with another value.
    # 
    # @param other [AbcDecimal, Numeric] The value to compare with. If not an AbcDecimal,
    # it will be converted to one.
    # @return [Boolean] true if this AbcDecimal is less than or equal to the other value,
    # false otherwise.
    def <=(other)
      @value <= (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    # @overload round(*args)
    # Rounds this decimal to a specified precision.
    # 
    # @param args [Array] Arguments to be passed to BigDecimal#round. Can include
    # the number of decimal places to round to and the rounding mode.
    # @return [AbcDecimal] A new AbcDecimal instance with the rounded value
    # @example Round to 2 decimal places
    # decimal = AbcDecimal(3.14159)
    # decimal.round(2) #=> 3.14
    # @example Round with specific rounding mode
    # decimal = AbcDecimal(3.5)
    # decimal.round(0, half: :up) #=> 4
    def round(*args)
      AbcDecimal(@value.round(*args))
    end

    # Returns the absolute value (magnitude) of the decimal number.
    # 
    # Wraps BigDecimal#abs to ensure return values are properly converted to AbcDecimal.
    # 
    # @param args [Array] Optional arguments to pass to BigDecimal#abs
    # @return [AbcDecimal] The absolute value of the decimal number
    def abs(*args)
      AbcDecimal(@value.abs(*args))
    end

    # Returns the square root of the AbcDecimal value.
    # Calculates the square root by using Ruby's built-in Math.sqrt function
    # and converting the result back to an AbcDecimal.
    # 
    # @return [AbcDecimal] A new AbcDecimal representing the square root of the value
    def sqrt
      AbcDecimal(Math.sqrt(@value))
    end

    # Returns true if the internal value is negative, false otherwise.
    # 
    # @return [Boolean] true if the value is negative, false otherwise
    def negative?
      @value.negative?
    end

    # Calculates the arctangent of y/x using the signs of the arguments to determine the quadrant.
    # Unlike the standard Math.atan2, this method accepts AbcDecimal objects or any values
    # that can be converted to AbcDecimal.
    # 
    # @param y [AbcDecimal, Numeric] The y coordinate
    # @param x [AbcDecimal, Numeric] The x coordinate
    # @return [AbcDecimal] The angle in radians between the positive x-axis and the ray to the point (x,y)
    def self.atan2(y, x)
      y_value = y.is_a?(AbcDecimal) ? y.value : AbcDecimal(y).value
      x_value = x.is_a?(AbcDecimal) ? x.value : AbcDecimal(x).value
      new(Math.atan2(y_value, x_value))
    end
  end
end

# Creates a new AbcDecimal instance.
# 
# This is a convenience method that allows creating AbcDecimal objects
# without explicitly referencing the Abachrome namespace.
# 
# @param args [Array] Arguments to pass to the AbcDecimal constructor
# @return [Abachrome::AbcDecimal] A new AbcDecimal instance
def AbcDecimal(*args)
  Abachrome::AbcDecimal.new(*args)
end

# Creates a new AbcDecimal instance.
# 
# @param args [Array] Arguments to pass to AbcDecimal.new
# @return [Abachrome::AbcDecimal] A new AbcDecimal instance
# @example
# AD(3.14) # => #<Abachrome::AbcDecimal:0x... @value=3.14>
# AD("2.718") # => #<Abachrome::AbcDecimal:0x... @value=2.718>
def AD(*args)
  Abachrome::AbcDecimal.new(*args)
end
