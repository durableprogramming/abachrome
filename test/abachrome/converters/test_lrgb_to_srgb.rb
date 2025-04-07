# frozen_string_literal: true

require_relative "../../test_helper"

class TestLrgbToSrgb < Minitest::Test
  def setup
    @lrgb_color = Abachrome::Color.new(Abachrome::ColorSpace.find(:lrgb), [0.5, 0.2, 0.8])
  end

  def test_lrgb_to_srgb_conversion
    srgb = Abachrome::Converters::LrgbToSrgb.convert(@lrgb_color)
    assert_kind_of Abachrome::Color, srgb
    assert_equal :srgb, srgb.color_space.name
  end

  def test_zero_conversion
    lrgb = Abachrome::Color.new(Abachrome::ColorSpace.find(:lrgb), [0, 0, 0])
    srgb = Abachrome::Converters::LrgbToSrgb.convert(lrgb)
    assert_coordinates_equal [0, 0, 0], srgb.coordinates
  end

  def test_one_conversion
    lrgb = Abachrome::Color.new(Abachrome::ColorSpace.find(:lrgb), [1, 1, 1])
    srgb = Abachrome::Converters::LrgbToSrgb.convert(lrgb)
    assert_coordinates_equal [1, 1, 1], srgb.coordinates
  end

  def test_mid_gray_conversion
    lrgb = Abachrome::Color.new(Abachrome::ColorSpace.find(:lrgb), [0.5, 0.5, 0.5])
    srgb = Abachrome::Converters::LrgbToSrgb.convert(lrgb)
    assert_in_delta 0.735, srgb.coordinates[0], 0.001
    assert_in_delta 0.735, srgb.coordinates[1], 0.001
    assert_in_delta 0.735, srgb.coordinates[2], 0.001
  end

  def test_small_value_conversion
    lrgb = Abachrome::Color.new(Abachrome::ColorSpace.find(:lrgb), [0.0031, 0.0031, 0.0031])
    srgb = Abachrome::Converters::LrgbToSrgb.convert(lrgb)
    assert_in_delta 0.04, srgb.coordinates[0], 0.01
    assert_in_delta 0.04, srgb.coordinates[1], 0.01
    assert_in_delta 0.04, srgb.coordinates[2], 0.01
  end

  def test_alpha_preservation
    lrgb = Abachrome::Color.new(Abachrome::ColorSpace.find(:lrgb), [0.5, 0.2, 0.8], 0.5)
    srgb = Abachrome::Converters::LrgbToSrgb.convert(lrgb)
    assert_equal 0.5, srgb.alpha
  end

  def test_mixed_values_conversion
    lrgb = Abachrome::Color.new(Abachrome::ColorSpace.find(:lrgb), [0.002, 0.5, 1.0])
    srgb = Abachrome::Converters::LrgbToSrgb.convert(lrgb)
    # Values verified against known good implementation
    assert_in_delta 0.026, srgb.coordinates[0], 0.001
    assert_in_delta 0.735, srgb.coordinates[1], 0.001
    assert_in_delta 1.000, srgb.coordinates[2], 0.001
  end

  def test_round_trip_conversion
    original = @lrgb_color
    converted = Abachrome::Converters::SrgbToLrgb.convert(
      Abachrome::Converters::LrgbToSrgb.convert(original)
    )
    assert_coordinates_equal original.coordinates, converted.coordinates, 0.001
  end
end
