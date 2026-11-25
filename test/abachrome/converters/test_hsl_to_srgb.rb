# frozen_string_literal: true

require_relative "../../test_helper"

class TestHslToSrgb < Minitest::Test
  def convert(h, s, l, a = 1.0)
    Abachrome::Converters::HslToSrgb.convert(Abachrome::Color.from_hsl(h, s, l, a))
  end

  def test_returns_srgb_color
    srgb = convert(0, 1, 0.5)
    assert_kind_of Abachrome::Color, srgb
    assert_equal :srgb, srgb.color_space.name
  end

  def test_primary_hues
    assert_coordinates_equal [1, 0, 0], convert(0, 1, 0.5).coordinates
    assert_coordinates_equal [1, 1, 0], convert(60, 1, 0.5).coordinates
    assert_coordinates_equal [0, 1, 0], convert(120, 1, 0.5).coordinates
    assert_coordinates_equal [0, 1, 1], convert(180, 1, 0.5).coordinates
    assert_coordinates_equal [0, 0, 1], convert(240, 1, 0.5).coordinates
    assert_coordinates_equal [1, 0, 1], convert(300, 1, 0.5).coordinates
  end

  def test_zero_saturation_is_gray
    assert_coordinates_equal [0.5, 0.5, 0.5], convert(0, 0, 0.5).coordinates
    assert_coordinates_equal [0.25, 0.25, 0.25], convert(210, 0, 0.25).coordinates
  end

  def test_lightness_extremes
    assert_coordinates_equal [0, 0, 0], convert(120, 1, 0).coordinates
    assert_coordinates_equal [1, 1, 1], convert(120, 1, 1).coordinates
  end

  def test_partial_saturation
    assert_coordinates_equal [0.25, 0.25, 0.75], convert(240, 0.5, 0.5).coordinates
  end

  def test_hue_wraps_at_360
    assert_coordinates_equal convert(0, 1, 0.5).coordinates, convert(360, 1, 0.5).coordinates
    assert_coordinates_equal convert(120, 1, 0.5).coordinates, convert(480, 1, 0.5).coordinates
  end

  def test_negative_hue_wraps
    assert_coordinates_equal convert(300, 1, 0.5).coordinates, convert(-60, 1, 0.5).coordinates
  end

  def test_alpha_is_preserved
    assert_in_delta 0.4, convert(120, 1, 0.5, 0.4).alpha, 0.001
  end

  def test_raises_for_wrong_color_space
    assert_raises(RuntimeError) do
      Abachrome::Converters::HslToSrgb.convert(Abachrome::Color.from_rgb(1, 0, 0))
    end
  end
end
