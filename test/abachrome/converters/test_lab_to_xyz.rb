# frozen_string_literal: true

require_relative "../../test_helper"

class TestLabToXyz < Minitest::Test
  def convert(l, a, b, alpha = 1.0)
    Abachrome::Converters::LabToXyz.convert(Abachrome::Color.from_lab(l, a, b, alpha))
  end

  def test_returns_xyz_color
    xyz = convert(50, 0, 0)
    assert_kind_of Abachrome::Color, xyz
    assert_equal :xyz, xyz.color_space.name
  end

  def test_reference_white
    # L*=100 with no chroma is the D65 white point itself.
    assert_coordinates_equal [0.95047, 1.0, 1.08883], convert(100, 0, 0).coordinates
  end

  def test_black
    assert_coordinates_equal [0, 0, 0], convert(0, 0, 0).coordinates
  end

  def test_mid_gray
    # L*=50 neutral corresponds to Y = 0.18419 relative luminance.
    assert_in_delta 0.18419, convert(50, 0, 0).coordinates[1], 0.0001
  end

  def test_srgb_red_reference_values
    assert_coordinates_equal [0.4124, 0.2126, 0.0193],
                             convert(53.2408, 80.0925, 67.2032).coordinates
  end

  def test_linear_segment_below_epsilon
    # Dark colors fall on the linear segment of the inverse transfer function.
    # The 16/116 term must be evaluated as a float; integer division would zero it
    # out and flatten the whole dark range.
    assert_in_delta 0.0055353, convert(5, 0, 0).coordinates[1], 0.0000001
    assert_in_delta 0.0011071, convert(1, 0, 0).coordinates[1], 0.0000001
  end

  def test_dark_values_stay_distinct
    # With the 16/116 term dropped, L*=1 and L*=5 collapse to nearly the same value.
    y1 = convert(1, 0, 0).coordinates[1].to_f
    y5 = convert(5, 0, 0).coordinates[1].to_f
    assert y5 > y1 * 4, "expected L*=5 to be well above L*=1, got #{y1} and #{y5}"
  end

  def test_alpha_is_preserved
    assert_in_delta 0.6, convert(50, 0, 0, 0.6).alpha, 0.001
  end

  def test_raises_for_wrong_color_space
    assert_raises(RuntimeError) do
      Abachrome::Converters::LabToXyz.convert(Abachrome::Color.from_rgb(1, 0, 0))
    end
  end
end
