# frozen_string_literal: true

# Abachrome::Floatify - Float-based arithmetic for color calculations
#
# This module monkey-patches AbcDecimal to use Float instead of BigDecimal.
# Require this file to make AbcDecimal use floats throughout the codebase.
#
# Usage:
#   require 'abachrome/floatify'
#
# This makes AbcDecimal a drop-in replacement that uses Float arithmetic
# for performance-critical applications where BigDecimal precision is not required.

require_relative "abc_decimal"

module Abachrome
  class AbcDecimal
    # Remove the precision-related constant and attribute
    remove_const(:DEFAULT_PRECISION) if defined?(DEFAULT_PRECISION)

    attr_accessor :value

    # Initializes a new AbcDecimal object with the specified value.
    # Precision parameter is ignored when floatify is loaded.
    #
    # @param value [AbcDecimal, Rational, #to_f] The numeric value to represent.
    # If an AbcDecimal is provided, its internal value is used.
    # Otherwise, the value is converted to a float.
    # @param _precision [Integer] Ignored - included for API compatibility
    # @return [AbcDecimal] A new AbcDecimal instance.
    def initialize(value, _precision = nil)
      @value = case value
               when AbcDecimal
                 value.value
               else
                 value.to_f
               end
    end

    # Returns a string representation of the float value.
    #
    # @return [String] The float value as a string
    def to_s
      @value.to_s
    end

    # Converts the value to a floating-point number.
    #
    # @return [Float] the floating-point representation of the AbcDecimal value
    def to_f
      @value
    end

    # Creates a new AbcDecimal from a string representation of a number.
    #
    # @param str [String] The string representation of a number to convert to an AbcDecimal
    # @param _precision [Integer] Ignored - included for API compatibility
    # @return [AbcDecimal] A new AbcDecimal instance initialized with the given string value
    def self.from_string(str, _precision = nil)
      new(str)
    end

    # Creates a new AbcDecimal from a Rational number.
    #
    # @param rational [Rational] The rational number to convert to an AbcDecimal
    # @param _precision [Integer] Ignored - included for API compatibility
    # @return [AbcDecimal] A new AbcDecimal instance with the value of the given rational number
    def self.from_rational(rational, _precision = nil)
      new(rational)
    end

    # Creates a new AbcDecimal instance from a float value.
    #
    # @param float [Float] The floating point number to convert to an AbcDecimal
    # @param _precision [Integer] Ignored - included for API compatibility
    # @return [AbcDecimal] A new AbcDecimal instance representing the given float value
    def self.from_float(float, _precision = nil)
      new(float)
    end

    # Creates a new AbcDecimal from an integer value.
    #
    # @param integer [Integer] The integer value to convert to an AbcDecimal
    # @param _precision [Integer] Ignored - included for API compatibility
    # @return [AbcDecimal] A new AbcDecimal instance with the specified integer value
    def self.from_integer(integer, _precision = nil)
      new(integer)
    end

    # Addition operation
    #
    # Adds another value to this float.
    #
    # @param other [AbcDecimal, Numeric] The value to add. If not an AbcDecimal,
    #   it will be converted to one.
    # @return [AbcDecimal] A new AbcDecimal instance with the sum of the two values
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
    # @return [AbcDecimal] A new AbcDecimal instance representing the product of this float and the other value.
    def *(other)
      other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
      self.class.new(@value * other_value)
    end

    # Divides this float by another value.
    #
    # @param other [Numeric, AbcDecimal] The divisor, which can be an AbcDecimal instance or any numeric value
    # @return [AbcDecimal] A new AbcDecimal representing the result of the division
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
    # @return [Float] A float within the specified range
    def clamp(min, max)
      @value.clamp(AbcDecimal(min).value, AbcDecimal(max).value)
    end

    # Raises self to the power of another value.
    #
    # @param other [Numeric, AbcDecimal] The exponent to raise this value to
    # @return [AbcDecimal] A new AbcDecimal representing self raised to the power of other
    def **(other)
      other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
      self.class.new(@value**other_value)
    end

    # Allows for mixed arithmetic operations between AbcDecimal and other numeric types.
    #
    # @param other [Numeric] The other number to be coerced into an AbcDecimal object
    # @return [Array<AbcDecimal>] A two-element array containing the coerced value and self,
    # allowing Ruby to perform arithmetic operations with mixed types
    def coerce(other)
      [self.class.new(other), self]
    end

    # Returns a string representation of the float value for inspection purposes.
    #
    # @return [String] A string in the format "ClassName('value')"
    def inspect
      "#{self.class}('#{self}')"
    end

    # Compares this float value with another value for equality.
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

    # Compares this float with another value.
    #
    # @param other [Object] The value to compare with. Can be an AbcDecimal or any value
    # convertible to AbcDecimal
    # @return [Boolean] true if this float is greater than the other value, false otherwise
    def >(other)
      @value > (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    # Compares this float value with another value.
    #
    # @param other [Object] The value to compare against. If not an AbcDecimal,
    # it will be converted to one.
    # @return [Boolean] true if this float is greater than or equal to the other value,
    # false otherwise.
    def >=(other)
      @value >= (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    # Compares this float with another value.
    #
    # @param other [Object] The value to compare with. Will be coerced to AbcDecimal if not already an instance.
    # @return [Boolean] true if this float is less than the other value, false otherwise.
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

    # Rounds this float to a specified precision.
    #
    # @param args [Array] Arguments to be passed to Float#round. Can include
    # the number of decimal places to round to.
    # @return [AbcDecimal] A new AbcDecimal instance with the rounded value
    def round(*args)
      AbcDecimal(@value.round(*args))
    end

    # Returns the absolute value (magnitude) of the float number.
    #
    # @param _args [Array] Ignored - included for API compatibility
    # @return [AbcDecimal] The absolute value of the float number
    def abs(*_args)
      AbcDecimal(@value.abs)
    end

    # Returns the square root of the AbcDecimal value.
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

    # Returns true if the internal value is positive, false otherwise.
    #
    # @return [Boolean] true if the value is positive, false otherwise
    def positive?
      @value > 0
    end

    # Calculates the arctangent of y/x using the signs of the arguments to determine the quadrant.
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

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
