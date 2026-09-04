# frozen_string_literal: true

require_relative "../../test_helper"
require "abachrome"

class TestXyzToLrgb < Minitest::Test
  def convert(x, y, z, alpha = 1.0)
    Abachrome::Converters::XyzToLrgb.convert(Abachrome::Color.from_xyz(x, y, z, alpha))
  end

  def test_returns_lrgb_color
    lrgb = convert(0.5, 0.3, 0.2)
    assert_kind_of Abachrome::Color, lrgb
    assert_equal :lrgb, lrgb.color_space.name
    assert_equal 3, lrgb.coordinates.length
  end

  def test_white_point_maps_to_white
    assert_coordinates_equal [1, 1, 1], convert(0.9504700, 1.0000000, 1.0888356).coordinates
  end

  def test_black
    assert_coordinates_equal [0, 0, 0], convert(0, 0, 0).coordinates
  end

  def test_inverts_lrgb_to_xyz
    [[0.2, 0.6, 0.9], [1, 1, 1], [0.5, 0.1, 0.7], [0, 0, 0], [0.7, 0.4, 0.3]].each do |coords|
      lrgb = Abachrome::Color.from_lrgb(*coords)
      xyz = Abachrome::Converters::LrgbToXyz.convert(lrgb)
      assert_coordinates_equal coords,
                              Abachrome::Converters::XyzToLrgb.convert(xyz).coordinates,
                              0.000001
    end
  end

  def test_alpha_is_preserved
    assert_in_delta 0.8, convert(0.5, 0.3, 0.2, 0.8).alpha, 0.001
  end

  def test_raises_for_wrong_color_space
    assert_raises(RuntimeError) do
      Abachrome::Converters::XyzToLrgb.convert(Abachrome::Color.from_rgb(1, 0, 0))
    end

    assert_raises(RuntimeError) do
      Abachrome::Converters::XyzToLrgb.convert(Abachrome::Color.from_lrgb(0.5, 0.5, 0.5))
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
