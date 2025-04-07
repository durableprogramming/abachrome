# frozen_string_literal: true

require "bigdecimal"
require "forwardable"

module Abachrome
  class AbcDecimal
    extend Forwardable
    DEFAULT_PRECISION = (ENV["ABC_DECIMAL_PRECISION"] || "24").to_i

    attr_accessor :value, :precision

    def_delegators :@value, :to_i, :to_f, :zero?, :nonzero?

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

    def to_s
      if @value.is_a?(Rational)
        BigDecimal(@value, precision).to_s("F")
      else
        @value.to_s("F") # different behaviour than default BigDecimal
      end
    end

    def to_f
      @value.to_f
    end

    def self.from_string(str, precision = DEFAULT_PRECISION)
      new(str, precision)
    end

    def self.from_rational(rational, precision = DEFAULT_PRECISION)
      new(rational, precision)
    end

    def self.from_float(float, precision = DEFAULT_PRECISION)
      new(float, precision)
    end

    def self.from_integer(integer, precision = DEFAULT_PRECISION)
      new(integer, precision)
    end

    def +(other)
      other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
      self.class.new(@value + other_value)
    end

    def -(other)
      other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
      self.class.new(@value - other_value)
    end

    def *(other)
      other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
      self.class.new(@value * other_value)
    end

    def /(other)
      other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
      self.class.new(@value / other_value)
    end

    def %(other)
      other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
      self.class.new(@value % other_value)
    end

    def clamp(min,max)
      @value.clamp(AbcDecimal(min),AbcDecimal(max))
    end

    def **(other)
      if other.is_a?(Rational)
        self.class.new(@value**other)
      else
        other_value = other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value
        self.class.new(@value**other_value)
      end
    end

    def coerce(other)
      [self.class.new(other), self]
    end

    def inspect
      "#{self.class}('#{self}')"
    end

    def ==(other)
      @value == (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    def <=>(other)
      @value <=> (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    def >(other)
      @value > (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    def >=(other)
      @value >= (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    def <(other)
      @value < (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    def <=(other)
      @value <= (other.is_a?(AbcDecimal) ? other.value : AbcDecimal(other).value)
    end

    def clamp(*args)
      AbcDecimal(@value.clamp(*args))
    end

    def round(*args)
      AbcDecimal(@value.round(*args))
    end

    def abs(*args)
      AbcDecimal(@value.abs(*args))
    end

    def sqrt
      AbcDecimal(Math.sqrt(@value))
    end

    def negative?
      @value.negative?
    end

    def self.atan2(y, x)
      y_value = y.is_a?(AbcDecimal) ? y.value : AbcDecimal(y).value
      x_value = x.is_a?(AbcDecimal) ? x.value : AbcDecimal(x).value
      new(Math.atan2(y_value, x_value))
    end
  end
end

def AbcDecimal(*args)
  Abachrome::AbcDecimal.new(*args)
end

def AD(*args)
  Abachrome::AbcDecimal.new(*args)
end
