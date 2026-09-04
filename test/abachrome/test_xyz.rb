# frozen_string_literal: true

require "test_helper"
require "abachrome"

class XyzTest < Minitest::Test
  def setup
    @red = Abachrome::Color.from_rgb(1, 0, 0)
    @green = Abachrome::Color.from_rgb(0, 1, 0)
    @blue = Abachrome::Color.from_rgb(0, 0, 1)
    @white = Abachrome::Color.from_rgb(1, 1, 1)
    @black = Abachrome::Color.from_rgb(0, 0, 0)
    @gray = Abachrome::Color.from_rgb(0.5, 0.5, 0.5)
  end

    def test_to_xyz_returns_xyz_color_space
      xyz = @red.to_xyz
      assert_equal :xyz, xyz.color_space.name
    end

    def test_to_xyz_preserves_alpha
      color = Abachrome::Color.from_rgb(1, 0, 0, 0.5)
      xyz = color.to_xyz
      assert_equal BigDecimal("0.5"), xyz.alpha
    end

    def test_to_xyz_returns_self_when_already_xyz
      xyz = @red.to_xyz
      xyz2 = xyz.to_xyz
      assert_same xyz, xyz2
    end

    def test_to_xyz_bang_converts_in_place
      color = Abachrome::Color.from_rgb(1, 0, 0)
      original_object_id = color.object_id
      color.to_xyz!

      assert_equal :xyz, color.color_space.name
      assert_equal original_object_id, color.object_id
    end

    def test_to_xyz_bang_returns_self_when_already_xyz
      xyz = @red.to_xyz
      result = xyz.to_xyz!
      assert_same xyz, result
    end

    def test_x_component_accessor
      x_value = @red.x
      assert_instance_of Abachrome::AbcDecimal, x_value
      assert_in_delta 0.4124564, x_value.to_f, 0.001
    end

    def test_y_component_accessor
      y_value = @green.y
      assert_instance_of Abachrome::AbcDecimal, y_value
      assert_in_delta 0.7151522, y_value.to_f, 0.001
    end

    def test_z_component_accessor
      z_value = @blue.z
      assert_instance_of Abachrome::AbcDecimal, z_value
      assert_in_delta 0.9503041, z_value.to_f, 0.001
    end

    def test_xyz_values_returns_array
      values = @red.xyz_values
      assert_instance_of Array, values
      assert_equal 3, values.length
      values.each { |v| assert_instance_of Abachrome::AbcDecimal, v }
    end

    def test_xyz_array_returns_array
      array = @green.xyz_array
      assert_instance_of Array, array
      assert_equal 3, array.length
      array.each { |v| assert_instance_of Abachrome::AbcDecimal, v }
    end

    def test_xyz_values_and_xyz_array_are_identical
      assert_equal @blue.xyz_values, @blue.xyz_array
    end

    def test_from_xyz_factory_method
      xyz = Abachrome::Color.from_xyz(0.5, 0.3, 0.2)
      assert_equal :xyz, xyz.color_space.name
      assert_equal BigDecimal("0.5"), xyz.coordinates[0]
      assert_equal BigDecimal("0.3"), xyz.coordinates[1]
      assert_equal BigDecimal("0.2"), xyz.coordinates[2]
    end

    def test_from_xyz_with_alpha
      xyz = Abachrome::Color.from_xyz(0.5, 0.3, 0.2, 0.75)
      assert_equal BigDecimal("0.75"), xyz.alpha
    end

    def test_xyz_roundtrip_conversion
      original = @red
      xyz = original.to_xyz
      back = xyz.to_srgb

      # Check that values are very close (allowing for floating point precision)
      original.coordinates.zip(back.coordinates).each do |orig, converted|
        assert_in_delta orig.to_f, converted.to_f, 0.0001
      end
    end

    def test_white_xyz_values
      xyz = @white.to_xyz
      # D65 white point should be approximately (0.95, 1.0, 1.09)
      assert_in_delta 0.95, xyz.x.to_f, 0.01
      assert_in_delta 1.0, xyz.y.to_f, 0.01
      assert_in_delta 1.09, xyz.z.to_f, 0.01
    end

    def test_black_xyz_values
      xyz = @black.to_xyz
      assert_in_delta 0.0, xyz.x.to_f, 0.001
      assert_in_delta 0.0, xyz.y.to_f, 0.001
      assert_in_delta 0.0, xyz.z.to_f, 0.001
    end

    def test_gray_xyz_values
      xyz = @gray.to_xyz
      # Gray should have equal-ish XYZ values, with Y being luminance
      assert xyz.x.to_f > 0.1
      assert xyz.y.to_f > 0.1
      assert xyz.z.to_f > 0.1
    end

    def test_red_xyz_values
      xyz = @red.to_xyz
      # Red should have high X, medium Y, low Z
      assert xyz.x.to_f > xyz.y.to_f
      assert xyz.y.to_f > xyz.z.to_f
    end

    def test_green_xyz_values
      xyz = @green.to_xyz
      # Green should have high Y (luminance)
      assert xyz.y.to_f > xyz.x.to_f
      assert xyz.y.to_f > xyz.z.to_f
    end

    def test_blue_xyz_values
      xyz = @blue.to_xyz
      # Blue should have high Z
      assert xyz.z.to_f > xyz.x.to_f
      assert xyz.z.to_f > xyz.y.to_f
    end

    def test_xyz_component_accessors_convert_from_srgb
      # Test that component accessors work on sRGB colors
      assert_instance_of Abachrome::AbcDecimal, @red.x
      assert_instance_of Abachrome::AbcDecimal, @red.y
      assert_instance_of Abachrome::AbcDecimal, @red.z
    end

    def test_xyz_component_accessors_on_xyz_color
      xyz = @red.to_xyz
      # Accessing components on XYZ color should not re-convert
      x_val = xyz.x
      assert_equal xyz.coordinates[0], x_val
    end

    def test_to_xyz_from_different_color_spaces
      # Test conversion from OKLAB
      oklab = Abachrome::Color.from_oklab(0.5, 0.1, -0.1)
      xyz = oklab.to_xyz
      assert_equal :xyz, xyz.color_space.name

      # Test conversion from OKLCH
      oklch = Abachrome::Color.from_oklch(0.5, 0.1, 180)
      xyz2 = oklch.to_xyz
      assert_equal :xyz, xyz2.color_space.name

      # Test conversion from LRGB
      lrgb = Abachrome::Color.from_lrgb(0.5, 0.3, 0.2)
      xyz3 = lrgb.to_xyz
      assert_equal :xyz, xyz3.color_space.name
    end

    def test_xyz_values_precision
      xyz = @red.to_xyz
      values = xyz.xyz_values

      # Check that we maintain high precision
      values.each do |v|
        refute_nil v
        assert v.is_a?(Abachrome::AbcDecimal)
      end
    end

    def test_multiple_conversions_maintain_consistency
      # Convert multiple times and ensure consistency
      xyz1 = @red.to_xyz
      xyz2 = @red.to_xyz

      xyz1.coordinates.zip(xyz2.coordinates).each do |v1, v2|
        assert_equal v1, v2
      end
    end

    def test_xyz_with_fractional_rgb_values
      color = Abachrome::Color.from_rgb(0.25, 0.75, 0.5)
      xyz = color.to_xyz

      assert_equal :xyz, xyz.color_space.name
      assert xyz.x.to_f > 0
      assert xyz.y.to_f > 0
      assert xyz.z.to_f > 0
    end

    def test_xyz_component_order
      xyz = @red.to_xyz
      values = xyz.xyz_values

      assert_equal xyz.x, values[0]
      assert_equal xyz.y, values[1]
      assert_equal xyz.z, values[2]
    end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
