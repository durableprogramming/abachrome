# frozen_string_literal: true

require_relative "../../test_helper"
require "abachrome"

class TestSrgbToXyz < Minitest::Test
  def test_converts_red_to_xyz
    red = Abachrome::Color.from_rgb(1, 0, 0)
    xyz = Abachrome::Converters::SrgbToXyz.convert(red)

    assert_equal :xyz, xyz.color_space.name
    assert_in_delta 0.4124564, xyz.coordinates[0].to_f, 0.001
    assert_in_delta 0.2126729, xyz.coordinates[1].to_f, 0.001
    assert_in_delta 0.0193339, xyz.coordinates[2].to_f, 0.001
  end

  def test_converts_green_to_xyz
    green = Abachrome::Color.from_rgb(0, 1, 0)
    xyz = Abachrome::Converters::SrgbToXyz.convert(green)

    assert_equal :xyz, xyz.color_space.name
    assert_in_delta 0.3575761, xyz.coordinates[0].to_f, 0.001
    assert_in_delta 0.7151522, xyz.coordinates[1].to_f, 0.001
    assert_in_delta 0.1191920, xyz.coordinates[2].to_f, 0.001
  end

  def test_converts_blue_to_xyz
    blue = Abachrome::Color.from_rgb(0, 0, 1)
    xyz = Abachrome::Converters::SrgbToXyz.convert(blue)

    assert_equal :xyz, xyz.color_space.name
    assert_in_delta 0.1804375, xyz.coordinates[0].to_f, 0.001
    assert_in_delta 0.0721750, xyz.coordinates[1].to_f, 0.001
    assert_in_delta 0.9503041, xyz.coordinates[2].to_f, 0.001
  end

  def test_converts_white_to_xyz
    white = Abachrome::Color.from_rgb(1, 1, 1)
    xyz = Abachrome::Converters::SrgbToXyz.convert(white)

    assert_equal :xyz, xyz.color_space.name
    # D65 white point
    assert_in_delta 0.9504700, xyz.coordinates[0].to_f, 0.001
    assert_in_delta 1.0000000, xyz.coordinates[1].to_f, 0.001
    assert_in_delta 1.0888356, xyz.coordinates[2].to_f, 0.001
  end

  def test_converts_black_to_xyz
    black = Abachrome::Color.from_rgb(0, 0, 0)
    xyz = Abachrome::Converters::SrgbToXyz.convert(black)

    assert_equal :xyz, xyz.color_space.name
    assert_in_delta 0.0, xyz.coordinates[0].to_f, 0.001
    assert_in_delta 0.0, xyz.coordinates[1].to_f, 0.001
    assert_in_delta 0.0, xyz.coordinates[2].to_f, 0.001
  end

  def test_preserves_alpha
    color = Abachrome::Color.from_rgb(0.5, 0.5, 0.5, 0.75)
    xyz = Abachrome::Converters::SrgbToXyz.convert(color)

    assert_equal BigDecimal("0.75"), xyz.alpha
  end

  def test_raises_error_for_non_srgb_input
    lrgb = Abachrome::Color.from_lrgb(0.5, 0.5, 0.5)
    assert_raises(RuntimeError) do
      Abachrome::Converters::SrgbToXyz.convert(lrgb)
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
