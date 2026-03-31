# frozen_string_literal: true

require_relative "../../test_helper"
require "abachrome"

class TestXyzToLrgb < Minitest::Test
  def test_converts_xyz_to_lrgb
    xyz = Abachrome::Color.from_xyz(0.5, 0.3, 0.2)
    lrgb = Abachrome::Converters::XyzToLrgb.convert(xyz)

    assert_equal :lrgb, lrgb.color_space.name
    assert_equal 3, lrgb.coordinates.length
  end

  def test_converts_d65_white_to_lrgb
    # D65 white point should convert to (1, 1, 1) in linear RGB
    xyz = Abachrome::Color.from_xyz(0.9504700, 1.0000000, 1.0888356)
    lrgb = Abachrome::Converters::XyzToLrgb.convert(xyz)

    assert_equal :lrgb, lrgb.color_space.name
    assert_in_delta 1.0, lrgb.coordinates[0].to_f, 0.001
    assert_in_delta 1.0, lrgb.coordinates[1].to_f, 0.001
    assert_in_delta 1.0, lrgb.coordinates[2].to_f, 0.001
  end

  def test_converts_black_to_lrgb
    xyz = Abachrome::Color.from_xyz(0, 0, 0)
    lrgb = Abachrome::Converters::XyzToLrgb.convert(xyz)

    assert_equal :lrgb, lrgb.color_space.name
    assert_in_delta 0.0, lrgb.coordinates[0].to_f, 0.001
    assert_in_delta 0.0, lrgb.coordinates[1].to_f, 0.001
    assert_in_delta 0.0, lrgb.coordinates[2].to_f, 0.001
  end

  def test_preserves_alpha
    xyz = Abachrome::Color.from_xyz(0.5, 0.3, 0.2, 0.8)
    lrgb = Abachrome::Converters::XyzToLrgb.convert(xyz)

    assert_equal BigDecimal("0.8"), lrgb.alpha
  end

  def test_raises_error_for_non_xyz_input
    lrgb = Abachrome::Color.from_lrgb(0.5, 0.5, 0.5)
    assert_raises(RuntimeError) do
      Abachrome::Converters::XyzToLrgb.convert(lrgb)
    end
  end

  def test_roundtrip_with_lrgb_to_xyz
    original = Abachrome::Color.from_lrgb(0.5, 0.3, 0.2)
    xyz = Abachrome::Converters::LrgbToXyz.convert(original)
    back = Abachrome::Converters::XyzToLrgb.convert(xyz)

    original.coordinates.zip(back.coordinates).each do |orig, converted|
      assert_in_delta orig.to_f, converted.to_f, 0.0001
    end
  end

  def test_inverse_transformation_matrix
    # Test that the XYZ to LRGB matrix is the inverse of LRGB to XYZ
    lrgb1 = Abachrome::Color.from_lrgb(0.7, 0.4, 0.3)
    xyz = Abachrome::Converters::LrgbToXyz.convert(lrgb1)
    lrgb2 = Abachrome::Converters::XyzToLrgb.convert(xyz)

    lrgb1.coordinates.zip(lrgb2.coordinates).each do |v1, v2|
      assert_in_delta v1.to_f, v2.to_f, 0.000001
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
