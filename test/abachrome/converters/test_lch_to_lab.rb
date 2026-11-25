# frozen_string_literal: true

require_relative "../../test_helper"

class TestLchToLab < Minitest::Test
  def convert(l, c, h, alpha = 1.0)
    Abachrome::Converters::LchToLab.convert(Abachrome::Color.from_lch(l, c, h, alpha))
  end

  def test_returns_lab_color
    lab = convert(50, 20, 120)
    assert_kind_of Abachrome::Color, lab
    assert_equal :lab, lab.color_space.name
  end

  def test_lightness_is_unchanged
    assert_in_delta 53.2408, convert(53.2408, 104.5518, 39.999).coordinates[0], 0.001
  end

  def test_zero_chroma_is_neutral
    assert_coordinates_equal [50, 0, 0], convert(50, 0, 0).coordinates
  end

  def test_zero_degrees_is_positive_a
    lab = convert(50, 30, 0)
    assert_in_delta 30, lab.coordinates[1], 0.001
    assert_in_delta 0, lab.coordinates[2], 0.001
  end

  def test_ninety_degrees_is_positive_b
    lab = convert(50, 30, 90)
    assert_in_delta 0, lab.coordinates[1], 0.001
    assert_in_delta 30, lab.coordinates[2], 0.001
  end

  def test_srgb_red_reference_values
    assert_coordinates_equal [53.2408, 80.0925, 67.2032],
                             convert(53.2408, 104.5518, 39.999).coordinates, 0.01
  end

  def test_hue_360_equals_hue_0
    assert_coordinates_equal convert(50, 30, 0).coordinates, convert(50, 30, 360).coordinates
  end

  def test_alpha_is_preserved
    assert_in_delta 0.3, convert(50, 30, 120, 0.3).alpha, 0.001
  end

  def test_raises_for_wrong_color_space
    assert_raises(RuntimeError) do
      Abachrome::Converters::LchToLab.convert(Abachrome::Color.from_rgb(1, 0, 0))
    end
  end
end
