# frozen_string_literal: true

require_relative "../test_helper"
require "bigdecimal"
require_relative "../../lib/abachrome/color"
require_relative "../../lib/abachrome/color_space"

class TestRGBToOKLABConversions < Minitest::Test
  def setup
    @color_rgb = Abachrome::Color.from_rgb(0.5, 0.2, 0.8)
    @color_oklab = Abachrome::Color.from_oklab(0.591, 0.103, -0.183)
  end

  def test_rgb_to_oklab_conversion
    rgb = Abachrome::Color.from_rgb(1.0, 0.0, 0.0)
    oklab = rgb.to_oklab
    assert_kind_of Abachrome::Color, oklab
    assert_equal :oklab, oklab.color_space.name
  end

  def test_white_conversion
    rgb = Abachrome::Color.from_rgb(1.0, 1.0, 1.0)
    oklab = rgb.to_oklab
    assert_in_delta 1.0, oklab.coordinates[0], 0.001
    assert_in_delta 0.0, oklab.coordinates[1], 0.001
    assert_in_delta 0.0, oklab.coordinates[2], 0.001
  end

  def test_black_conversion
    rgb = Abachrome::Color.from_rgb(0.0, 0.0, 0.0)
    oklab = rgb.to_oklab
    assert_in_delta 0.0, oklab.coordinates[0], 0.001
    assert_in_delta 0.0, oklab.coordinates[1], 0.001
    assert_in_delta 0.0, oklab.coordinates[2], 0.001
  end

  def test_red_conversion
    rgb = Abachrome::Color.from_rgb(1.0, 0.0, 0.0)
    oklab = rgb.to_oklab
    assert_in_delta 0.627, oklab.coordinates[0], 0.001
    assert_in_delta 0.224, oklab.coordinates[1], 0.001
    assert_in_delta 0.125, oklab.coordinates[2], 0.001
  end

  def test_alpha_preservation
    rgb = Abachrome::Color.from_rgb(0.5, 0.5, 0.5, 0.5)
    oklab = rgb.to_oklab
    assert_equal 0.5, oklab.alpha
  end

  def test_round_trip_conversion
    original = Abachrome::Color.from_rgb(0.5, 0.2, 0.8)
    converted = original.to_oklab.to_rgb
    assert_in_delta original.coordinates[0], converted.coordinates[0], 0.001
    assert_in_delta original.coordinates[1], converted.coordinates[1], 0.001
    assert_in_delta original.coordinates[2], converted.coordinates[2], 0.001
  end
end
