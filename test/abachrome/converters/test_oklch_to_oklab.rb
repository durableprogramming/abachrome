# frozen_string_literal: true

require_relative "../../test_helper"

class TestOklchToOklab < Minitest::Test
  def setup
    @oklch_color = Abachrome::Color.from_oklch(0.5, 0.2, 120)
  end

  def test_oklch_to_oklab_conversion
    oklab = Abachrome::Converters::OklchToOklab.convert(@oklch_color)
    assert_kind_of Abachrome::Color, oklab
    assert_equal :oklab, oklab.color_space.name
  end

  def test_zero_chroma_conversion
    oklch = Abachrome::Color.from_oklch(0.5, 0.0, 0)
    oklab = Abachrome::Converters::OklchToOklab.convert(oklch)
    assert_in_delta 0.5, oklab.coordinates[0], 0.001
    assert_in_delta 0.0, oklab.coordinates[1], 0.001
    assert_in_delta 0.0, oklab.coordinates[2], 0.001
  end

  def test_hue_360_equals_hue_0
    oklch_0 = Abachrome::Color.from_oklch(0.5, 0.2, 0)
    oklch_360 = Abachrome::Color.from_oklch(0.5, 0.2, 360)

    oklab_0 = Abachrome::Converters::OklchToOklab.convert(oklch_0)
    oklab_360 = Abachrome::Converters::OklchToOklab.convert(oklch_360)

    assert_coordinates_equal oklab_0.coordinates, oklab_360.coordinates
  end

  def test_90_degree_conversion
    oklch = Abachrome::Color.from_oklch(0.5, 0.2, 90)
    oklab = Abachrome::Converters::OklchToOklab.convert(oklch)

    # At 90 degrees, a should be 0 and b should be positive
    assert_in_delta 0.5, oklab.coordinates[0], 0.001
    assert_in_delta 0.0, oklab.coordinates[1], 0.001
    assert_in_delta 0.2, oklab.coordinates[2], 0.001
  end

  def test_270_degree_conversion
    oklch = Abachrome::Color.from_oklch(0.5, 0.2, 270)
    oklab = Abachrome::Converters::OklchToOklab.convert(oklch)

    # At 270 degrees, a should be 0 and b should be negative
    assert_in_delta 0.5, oklab.coordinates[0], 0.001
    assert_in_delta 0.0, oklab.coordinates[1], 0.001
    assert_in_delta(-0.2, oklab.coordinates[2], 0.001)
  end

  def test_alpha_preservation
    oklch = Abachrome::Color.from_oklch(0.5, 0.2, 120, 0.5)
    oklab = Abachrome::Converters::OklchToOklab.convert(oklch)
    assert_equal 0.5, oklab.alpha
  end

  def test_lightness_preservation
    oklch = Abachrome::Color.from_oklch(0.7, 0.2, 180)
    oklab = Abachrome::Converters::OklchToOklab.convert(oklch)
    assert_equal oklch.coordinates[0], oklab.coordinates[0]
  end

  def test_chroma_conversion
    oklch = Abachrome::Color.from_oklch(0.5, 0.3, 0)
    oklab = Abachrome::Converters::OklchToOklab.convert(oklch)

    # At 0 degrees, all chroma should go to a coordinate
    assert_in_delta 0.5, oklab.coordinates[0], 0.001
    assert_in_delta 0.3, oklab.coordinates[1], 0.001
    assert_in_delta 0.0, oklab.coordinates[2], 0.001
  end
end
