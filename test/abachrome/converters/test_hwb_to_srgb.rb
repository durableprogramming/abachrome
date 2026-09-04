# frozen_string_literal: true

require_relative "../../test_helper"

class TestHwbToSrgb < Minitest::Test
  def convert(h, w, b, a = 1.0)
    Abachrome::Converters::HwbToSrgb.convert(Abachrome::Color.from_hwb(h, w, b, a))
  end

  def test_returns_srgb_color
    srgb = convert(0, 0, 0)
    assert_kind_of Abachrome::Color, srgb
    assert_equal :srgb, srgb.color_space.name
  end

  def test_no_white_or_black_gives_pure_hue
    assert_coordinates_equal [1, 0, 0], convert(0, 0, 0).coordinates
    assert_coordinates_equal [0, 1, 0], convert(120, 0, 0).coordinates
    assert_coordinates_equal [0, 0, 1], convert(240, 0, 0).coordinates
  end

  def test_whiteness_tints_toward_white
    assert_coordinates_equal [1, 0.5, 0.5], convert(0, 0.5, 0).coordinates
  end

  def test_blackness_shades_toward_black
    assert_coordinates_equal [0.5, 0, 0], convert(0, 0, 0.5).coordinates
  end

  def test_full_whiteness_is_white
    assert_coordinates_equal [1, 1, 1], convert(0, 1, 0).coordinates
  end

  def test_full_blackness_is_black
    assert_coordinates_equal [0, 0, 0], convert(0, 0, 1).coordinates
  end

  def test_sum_over_one_is_normalized_gray
    # w and b are scaled proportionally, so 0.6/0.6 yields mid gray.
    assert_coordinates_equal [0.5, 0.5, 0.5], convert(0, 0.6, 0.6).coordinates
    assert_coordinates_equal [0.75, 0.75, 0.75], convert(120, 0.75, 0.25).coordinates
  end

  def test_hue_is_irrelevant_when_achromatic
    assert_coordinates_equal convert(0, 0.6, 0.6).coordinates, convert(240, 0.6, 0.6).coordinates
  end

  def test_alpha_is_preserved
    assert_in_delta 0.25, convert(0, 0.1, 0.1, 0.25).alpha, 0.001
  end

  def test_raises_for_wrong_color_space
    assert_raises(RuntimeError) do
      Abachrome::Converters::HwbToSrgb.convert(Abachrome::Color.from_rgb(1, 0, 0))
    end
  end
end
