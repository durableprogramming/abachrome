# frozen_string_literal: true

require_relative "../../test_helper"

class TestLabToSrgb < Minitest::Test
  def lab(l, a, b, alpha = 1.0)
    Abachrome::Converters::LabToSrgb.convert(Abachrome::Color.from_lab(l, a, b, alpha))
  end

  def lch(l, c, h, alpha = 1.0)
    Abachrome::Converters::LchToSrgb.convert(Abachrome::Color.from_lch(l, c, h, alpha))
  end

  def test_returns_srgb_color
    assert_equal :srgb, lab(50, 0, 0).color_space.name
    assert_equal :srgb, lch(50, 0, 0).color_space.name
  end

  def test_lab_primaries
    assert_coordinates_equal [1, 1, 1], lab(100, 0, 0).coordinates
    assert_coordinates_equal [0, 0, 0], lab(0, 0, 0).coordinates
    assert_coordinates_equal [1, 0, 0], lab(53.2408, 80.0925, 67.2032).coordinates, 0.01
    assert_coordinates_equal [0, 0, 1], lab(32.297, 79.1875, -107.8602).coordinates, 0.01
  end

  def test_lch_primaries
    assert_coordinates_equal [1, 1, 1], lch(100, 0, 0).coordinates
    assert_coordinates_equal [1, 0, 0], lch(53.2408, 104.5518, 39.999).coordinates, 0.01
    assert_coordinates_equal [0, 1, 0], lch(87.7347, 119.7759, 136.016).coordinates, 0.01
  end

  def test_lab_and_lch_agree
    assert_coordinates_equal lab(53.2408, 80.0925, 67.2032).coordinates,
                             lch(53.2408, 104.5518, 39.999).coordinates, 0.001
  end

  def test_alpha_is_preserved
    assert_in_delta 0.5, lab(50, 0, 0, 0.5).alpha, 0.001
    assert_in_delta 0.5, lch(50, 0, 0, 0.5).alpha, 0.001
  end
end
