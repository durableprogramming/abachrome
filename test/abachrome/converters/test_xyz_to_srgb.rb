# frozen_string_literal: true

require_relative "../../test_helper"
require "abachrome"

class TestXyzToSrgb < Minitest::Test
  def test_converts_xyz_to_red
    # XYZ values for pure red
    xyz = Abachrome::Color.from_xyz(0.4124564, 0.2126729, 0.0193339)
    srgb = Abachrome::Converters::XyzToSrgb.convert(xyz)

    assert_equal :srgb, srgb.color_space.name
    assert_in_delta 1.0, srgb.coordinates[0].to_f, 0.001
    assert_in_delta 0.0, srgb.coordinates[1].to_f, 0.01
    assert_in_delta 0.0, srgb.coordinates[2].to_f, 0.01
  end

  def test_converts_xyz_to_green
    # XYZ values for pure green
    xyz = Abachrome::Color.from_xyz(0.3575761, 0.7151522, 0.1191920)
    srgb = Abachrome::Converters::XyzToSrgb.convert(xyz)

    assert_equal :srgb, srgb.color_space.name
    assert_in_delta 0.0, srgb.coordinates[0].to_f, 0.01
    assert_in_delta 1.0, srgb.coordinates[1].to_f, 0.001
    assert_in_delta 0.0, srgb.coordinates[2].to_f, 0.01
  end

  def test_converts_xyz_to_blue
    # XYZ values for pure blue
    xyz = Abachrome::Color.from_xyz(0.1804375, 0.0721750, 0.9503041)
    srgb = Abachrome::Converters::XyzToSrgb.convert(xyz)

    assert_equal :srgb, srgb.color_space.name
    assert_in_delta 0.0, srgb.coordinates[0].to_f, 0.01
    assert_in_delta 0.0, srgb.coordinates[1].to_f, 0.01
    assert_in_delta 1.0, srgb.coordinates[2].to_f, 0.001
  end

  def test_converts_d65_white
    # D65 white point
    xyz = Abachrome::Color.from_xyz(0.9504700, 1.0000000, 1.0888356)
    srgb = Abachrome::Converters::XyzToSrgb.convert(xyz)

    assert_equal :srgb, srgb.color_space.name
    assert_in_delta 1.0, srgb.coordinates[0].to_f, 0.001
    assert_in_delta 1.0, srgb.coordinates[1].to_f, 0.001
    assert_in_delta 1.0, srgb.coordinates[2].to_f, 0.001
  end

  def test_converts_black
    xyz = Abachrome::Color.from_xyz(0, 0, 0)
    srgb = Abachrome::Converters::XyzToSrgb.convert(xyz)

    assert_equal :srgb, srgb.color_space.name
    assert_in_delta 0.0, srgb.coordinates[0].to_f, 0.001
    assert_in_delta 0.0, srgb.coordinates[1].to_f, 0.001
    assert_in_delta 0.0, srgb.coordinates[2].to_f, 0.001
  end

  def test_preserves_alpha
    xyz = Abachrome::Color.from_xyz(0.5, 0.5, 0.5, 0.6)
    srgb = Abachrome::Converters::XyzToSrgb.convert(xyz)

    assert_equal BigDecimal("0.6"), srgb.alpha
  end

  def test_raises_error_for_non_xyz_input
    srgb = Abachrome::Color.from_rgb(0.5, 0.5, 0.5)
    assert_raises(RuntimeError) do
      Abachrome::Converters::XyzToSrgb.convert(srgb)
    end
  end

  def test_roundtrip_conversion
    original = Abachrome::Color.from_rgb(0.7, 0.3, 0.5)
    xyz = Abachrome::Converters::SrgbToXyz.convert(original)
    back = Abachrome::Converters::XyzToSrgb.convert(xyz)

    original.coordinates.zip(back.coordinates).each do |orig, converted|
      assert_in_delta orig.to_f, converted.to_f, 0.0001
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
