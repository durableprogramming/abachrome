# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/abachrome/abc_decimal"

class TestAbcDecimal < Minitest::Test
  def setup
    @precision = 16
  end

  def test_initialize_with_integer
    dec = AbcDecimal(42)
    assert_instance_of(Abachrome::AbcDecimal, dec)
    assert_equal("42.0", dec.to_s)
  end

  def test_initialize_with_float
    dec = AbcDecimal(42.5)
    assert_instance_of(Abachrome::AbcDecimal, dec)
    assert_equal("42.5", dec.to_s)
  end

  def test_initialize_with_string
    dec = AbcDecimal("42.5")
    assert_instance_of(Abachrome::AbcDecimal, dec)
    assert_equal("42.5", dec.to_s)
  end

  def test_initialize_with_rational
    dec = AbcDecimal(Rational(85, 2))
    assert_instance_of(Abachrome::AbcDecimal, dec)
    assert_equal("42.5", dec.to_s)
  end

  def test_initialize_with_precision
    dec = AbcDecimal("42.5", 5)
    assert_instance_of(Abachrome::AbcDecimal, dec)
    assert_equal("42.5", dec.to_s)
  end

  def test_from_string
    dec = Abachrome::AbcDecimal.from_string("42.5")
    assert_instance_of(Abachrome::AbcDecimal, dec)
    assert_equal("42.5", dec.to_s)
  end

  def test_from_rational
    dec = Abachrome::AbcDecimal.from_rational(Rational(85, 2))
    assert_instance_of(Abachrome::AbcDecimal, dec)
    assert_equal("42.5", dec.to_s)
  end

  def test_from_float
    dec = Abachrome::AbcDecimal.from_float(42.5)
    assert_instance_of(Abachrome::AbcDecimal, dec)
    assert_equal("42.5", dec.to_s)
  end

  def test_from_integer
    dec = Abachrome::AbcDecimal.from_integer(42)
    assert_instance_of(Abachrome::AbcDecimal, dec)
    assert_equal("42.0", dec.to_s)
  end

  def test_addition
    dec1 = AbcDecimal("42.5")
    dec2 = AbcDecimal("7.5")
    result = dec1 + dec2
    assert_equal("50.0", result.to_s)
  end

  def test_subtraction
    dec1 = AbcDecimal("42.5")
    dec2 = AbcDecimal("7.5")
    result = dec1 - dec2
    assert_equal("35.0", result.to_s)
  end

  def test_multiplication
    dec1 = AbcDecimal("42.5")
    dec2 = AbcDecimal("2")
    result = dec1 * dec2
    assert_equal("85.0", result.to_s)
  end

  def test_division
    dec1 = AbcDecimal("42.5")
    dec2 = AbcDecimal("2")
    result = dec1 / dec2
    assert_equal("21.25", result.to_s)
  end

  def test_power
    dec1 = AbcDecimal("2")
    dec2 = AbcDecimal("3")
    result = dec1**dec2
    assert_equal("8.0", result.to_s)
  end

  def test_coerce
    dec = AbcDecimal("42.5")
    result = 2 * dec
    assert_equal("85.0", result.to_s)
  end

  def test_equality
    dec1 = AbcDecimal("42.5")
    dec2 = AbcDecimal("42.5")
    dec3 = AbcDecimal("42.6")
    assert_equal(true, dec1 == dec2)
    assert_equal(false, dec1 == dec3)
  end

  def test_comparison
    dec1 = AbcDecimal("42.5")
    dec2 = AbcDecimal("42.6")
    dec3 = AbcDecimal("42.5")
    assert_equal(-1, dec1 <=> dec2)
    assert_equal(1, dec2 <=> dec1)
    assert_equal(0, dec1 <=> dec3)
  end

  def test_greater_than
    dec1 = AbcDecimal("42.6")
    dec2 = AbcDecimal("42.5")
    assert_equal(true, dec1 > dec2)
    assert_equal(false, dec2 > dec1)
  end

  def test_greater_than_or_equal
    dec1 = AbcDecimal("42.6")
    dec2 = AbcDecimal("42.5")
    dec3 = AbcDecimal("42.6")
    assert_equal(true, dec1 >= dec2)
    assert_equal(true, dec1 >= dec3)
    assert_equal(false, dec2 >= dec1)
  end

  def test_less_than
    dec1 = AbcDecimal("42.5")
    dec2 = AbcDecimal("42.6")
    assert_equal(true, dec1 < dec2)
    assert_equal(false, dec2 < dec1)
  end

  def test_less_than_or_equal
    dec1 = AbcDecimal("42.5")
    dec2 = AbcDecimal("42.6")
    dec3 = AbcDecimal("42.5")
    assert_equal(true, dec1 <= dec2)
    assert_equal(true, dec1 <= dec3)
    assert_equal(false, dec2 <= dec1)
  end

  def test_round
    dec = AbcDecimal("42.555")
    assert_equal("42.56", dec.round(2).to_s)
    assert_equal("43.0", dec.round(0).to_s)
  end

  def test_abs
    dec1 = AbcDecimal("-42.5")
    dec2 = AbcDecimal("42.5")
    assert_equal("42.5", dec1.abs.to_s)
    assert_equal("42.5", dec2.abs.to_s)
  end

  def test_zero_predicate
    dec1 = AbcDecimal("0")
    dec2 = AbcDecimal("42.5")
    assert_equal(true, dec1.zero?)
    assert_equal(false, dec2.zero?)
  end

  def test_nonzero_predicate
    dec1 = AbcDecimal("0")
    dec2 = AbcDecimal("42.5")
    assert_nil(dec1.nonzero?)
    assert_equal(dec2, dec2.nonzero?)
  end

  def test_to_s
    dec = AbcDecimal("42.5")
    assert_equal("42.5", dec.to_s)
  end

  def test_to_i
    dec = AbcDecimal("42.5")
    assert_equal(42, dec.to_i)
  end

  def test_to_f
    dec = AbcDecimal("42.5")
    assert_equal(42.5, dec.to_f)
  end

  def test_inspect
    dec = AbcDecimal("42.5")
    assert_equal("Abachrome::AbcDecimal('42.5')", dec.inspect)
  end

  def test_arithmetic_with_mixed_types
    dec = AbcDecimal("42.5")

    # Integer
    assert_equal("43.5", (dec + 1).to_s)
    assert_equal("41.5", (dec - 1).to_s)
    assert_equal("85.0", (dec * 2).to_s)
    assert_equal("21.25", (dec / 2).to_s)

    # Float
    assert_equal("43.0", (dec + 0.5).to_s)
    assert_equal("42.0", (dec - 0.5).to_s)
    assert_equal("21.25", (dec * 0.5).to_s)
    assert_equal("85.0", (dec / 0.5).to_s)

    # String
    assert_equal("52.5", (dec + "10").to_s)
    assert_equal("32.5", (dec - "10").to_s)
    assert_equal("425.0", (dec * "10").to_s)
    assert_equal("4.25", (dec / "10").to_s)
  end

  def test_sqrt
    dec = AbcDecimal("16.0")
    result = dec.sqrt
    assert_instance_of(Abachrome::AbcDecimal, result)
    assert_equal("4.0", result.to_s)

    dec = AbcDecimal("2.0")
    result = dec.sqrt
    assert_in_delta(1.414, result.to_f, 0.001)
  end

  def test_atan2
    y = AbcDecimal("1.0")
    x = AbcDecimal("1.0")
    result = Abachrome::AbcDecimal.atan2(y, x)
    assert_instance_of(Abachrome::AbcDecimal, result)
    assert_in_delta(Math::PI / 4, result.to_f, 0.0001)

    # Test with mixed types
    result = Abachrome::AbcDecimal.atan2(1, 0)
    assert_in_delta(Math::PI / 2, result.to_f, 0.0001)

    result = Abachrome::AbcDecimal.atan2(0, -1)
    assert_in_delta(Math::PI, result.to_f, 0.0001)
  end
end
