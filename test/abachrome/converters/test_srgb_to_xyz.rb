# frozen_string_literal: true

require_relative "../../test_helper"

class TestSrgbToXyz < Minitest::Test
  def convert(r, g, b, alpha = 1.0)
    Abachrome::Converters::SrgbToXyz.convert(Abachrome::Color.from_rgb(r, g, b, alpha))
  end

  def test_returns_xyz_color
    xyz = convert(0.5, 0.5, 0.5)
    assert_kind_of Abachrome::Color, xyz
    assert_equal :xyz, xyz.color_space.name
  end

  def test_white_maps_to_d65_white_point
    assert_coordinates_equal [0.95047, 1.0, 1.08883], convert(1, 1, 1).coordinates, 0.001
  end

  def test_black
    assert_coordinates_equal [0, 0, 0], convert(0, 0, 0).coordinates
  end

  def test_roundtrips_back_through_lrgb
    [[0.2, 0.6, 0.9], [1, 1, 1], [0, 0, 0], [0.5, 0.1, 0.7]].each do |coords|
      xyz = convert(*coords)
      lrgb = Abachrome::Converters::XyzToLrgb.convert(xyz)
      assert_coordinates_equal coords,
                              Abachrome::Converters::LrgbToSrgb.convert(lrgb).coordinates,
                              0.00001
    end
  end

  def test_alpha_is_preserved
    assert_in_delta 0.35, convert(0.5, 0.5, 0.5, 0.35).alpha, 0.001
  end
end
