# frozen_string_literal: true

require_relative "../../test_helper"

class TestOklchToLrgb < Minitest::Test
  def setup
    @oklch_color = Abachrome::Color.from_oklch(0.5, 0.2, 120)
  end

  def test_oklch_to_lrgb_conversion
    lrgb = Abachrome::Converters::OklchToLrgb.convert(@oklch_color)
    assert_kind_of Abachrome::Color, lrgb
    assert_equal :lrgb, lrgb.color_space.name
  end

  def test_zero_chroma_conversion
    oklch = Abachrome::Color.from_oklch(0.5, 0.0, 0)
    lrgb = Abachrome::Converters::OklchToLrgb.convert(oklch)
    # For zero chroma, all RGB components should be equal (grayscale)
    r, g, b = lrgb.coordinates
    assert_in_delta r, g, 0.001
    assert_in_delta g, b, 0.001
  end

  def test_hue_360_equals_hue_0
    oklch_0 = Abachrome::Color.from_oklch(0.5, 0.2, 0)
    oklch_360 = Abachrome::Color.from_oklch(0.5, 0.2, 360)

    lrgb_0 = Abachrome::Converters::OklchToLrgb.convert(oklch_0)
    lrgb_360 = Abachrome::Converters::OklchToLrgb.convert(oklch_360)

    assert_coordinates_equal lrgb_0.coordinates, lrgb_360.coordinates
  end

  def test_lightness_0_gives_black
    oklch = Abachrome::Color.from_oklch(0, 0.2, 120)
    lrgb = Abachrome::Converters::OklchToLrgb.convert(oklch)
    assert_coordinates_equal [0, 0, 0], lrgb.coordinates, 0.1
  end

  def test_lightness_1_gives_bright_color
    oklch = Abachrome::Color.from_oklch(1, 0.2, 120)
    lrgb = Abachrome::Converters::OklchToLrgb.convert(oklch)
    assert lrgb.coordinates.max > 0.9
  end

  def test_alpha_preservation
    oklch = Abachrome::Color.from_oklch(0.5, 0.2, 120, 0.5)
    lrgb = Abachrome::Converters::OklchToLrgb.convert(oklch)
    assert_equal 0.5, lrgb.alpha
  end

  def test_150_degree_hue
    oklch = Abachrome::Color.from_oklch(0.5, 0.2, 150)
    lrgb = Abachrome::Converters::OklchToLrgb.convert(oklch)
    # At 150 degrees in OKLCh, we expect more green
    r, g, b = lrgb.coordinates

    assert g > r
    assert g > b
  end

  def test_270_degree_hue
    oklch = Abachrome::Color.from_oklch(0.5, 0.2, 270)
    lrgb = Abachrome::Converters::OklchToLrgb.convert(oklch)
    # At 270 degrees in OKLCh, we expect more blue
    r, g, b = lrgb.coordinates
    assert b > r
    assert b > g
  end

  def test_round_trip_conversion
    original = Abachrome::Color.from_oklch(0.65, 0.167, 326)
    converted = Abachrome::Converters::OklchToLrgb.convert(original)
    round_trip = Abachrome::Color.from_oklch(*converted.to_oklch.coordinates)

    assert_coordinates_equal original.coordinates, round_trip.coordinates, 0.01
  end

  def test_high_chroma_conversion
    oklch = Abachrome::Color.from_oklch(0.5, 0.4, 120)
    lrgb = Abachrome::Converters::OklchToLrgb.convert(oklch)

    # Verify the color is still valid RGB
    lrgb.coordinates.each do |component|
      assert component >= -0.01 # Allow small negative values due to floating point
      assert component <= 1.01  # Allow small over-1 values due to floating point
    end
  end
end
