# frozen_string_literal: true

require "test_helper"
require "abachrome"

class LmsTest < Minitest::Test
  def setup
    @red = Abachrome::Color.from_rgb(1, 0, 0)
    @green = Abachrome::Color.from_rgb(0, 1, 0)
    @blue = Abachrome::Color.from_rgb(0, 0, 1)
    @white = Abachrome::Color.from_rgb(1, 1, 1)
    @black = Abachrome::Color.from_rgb(0, 0, 0)
    @gray = Abachrome::Color.from_rgb(0.5, 0.5, 0.5)
  end

    def test_to_lms_returns_lms_color_space
      lms = @red.to_lms
      assert_equal :lms, lms.color_space.name
    end

    def test_to_lms_preserves_alpha
      color = Abachrome::Color.from_rgb(1, 0, 0, 0.5)
      lms = color.to_lms
      assert_equal BigDecimal("0.5"), lms.alpha
    end

    def test_to_lms_returns_self_when_already_lms
      lms = @red.to_lms
      lms2 = lms.to_lms
      assert_same lms, lms2
    end

    def test_to_lms_bang_converts_in_place
      color = Abachrome::Color.from_rgb(1, 0, 0)
      original_object_id = color.object_id
      color.to_lms!

      assert_equal :lms, color.color_space.name
      assert_equal original_object_id, color.object_id
    end

    def test_to_lms_bang_returns_self_when_already_lms
      lms = @red.to_lms
      result = lms.to_lms!
      assert_same lms, result
    end

    def test_long_component_accessor
      long_value = @red.long
      assert_instance_of Abachrome::AbcDecimal, long_value
      assert long_value.to_f > 0
    end

    def test_medium_component_accessor
      medium_value = @green.medium
      assert_instance_of Abachrome::AbcDecimal, medium_value
      assert medium_value.to_f > 0
    end

    def test_short_component_accessor
      short_value = @blue.short
      assert_instance_of Abachrome::AbcDecimal, short_value
      assert short_value.to_f > 0
    end

    def test_lms_values_returns_array
      values = @red.lms_values
      assert_instance_of Array, values
      assert_equal 3, values.length
      values.each { |v| assert_instance_of Abachrome::AbcDecimal, v }
    end

    def test_lms_array_returns_array
      array = @green.lms_array
      assert_instance_of Array, array
      assert_equal 3, array.length
      array.each { |v| assert_instance_of Abachrome::AbcDecimal, v }
    end

    def test_lms_values_and_lms_array_are_identical
      assert_equal @blue.lms_values, @blue.lms_array
    end

    def test_from_lms_factory_method
      lms = Abachrome::Color.from_lms(0.5, 0.3, 0.2)
      assert_equal :lms, lms.color_space.name
      assert_equal BigDecimal("0.5"), lms.coordinates[0]
      assert_equal BigDecimal("0.3"), lms.coordinates[1]
      assert_equal BigDecimal("0.2"), lms.coordinates[2]
    end

    def test_from_lms_with_alpha
      lms = Abachrome::Color.from_lms(0.5, 0.3, 0.2, 0.75)
      assert_equal BigDecimal("0.75"), lms.alpha
    end

    def test_lms_roundtrip_conversion
      original = @red
      lms = original.to_lms
      back = lms.to_srgb

      # Check that values are very close (allowing for floating point precision)
      original.coordinates.zip(back.coordinates).each do |orig, converted|
        assert_in_delta orig.to_f, converted.to_f, 0.001
      end
    end

    def test_white_lms_values
      lms = @white.to_lms
      # White should have positive values for all cone responses
      assert lms.long.to_f > 0.5
      assert lms.medium.to_f > 0.5
      assert lms.short.to_f > 0.5
    end

    def test_black_lms_values
      lms = @black.to_lms
      assert_in_delta 0.0, lms.long.to_f, 0.001
      assert_in_delta 0.0, lms.medium.to_f, 0.001
      assert_in_delta 0.0, lms.short.to_f, 0.001
    end

    def test_gray_lms_values
      lms = @gray.to_lms
      # Gray should have positive values for all cone responses
      assert lms.long.to_f > 0.1
      assert lms.medium.to_f > 0.1
      assert lms.short.to_f > 0.1
    end

    def test_red_lms_cone_response
      lms = @red.to_lms
      # Red should primarily stimulate L cones (long wavelength)
      # with some M cone response
      assert lms.long.to_f > 0
      assert lms.medium.to_f > 0
      # Red has minimal blue, so S should be relatively small
      assert lms.short.to_f >= 0
    end

    def test_green_lms_cone_response
      lms = @green.to_lms
      # Green should primarily stimulate M cones (medium wavelength)
      assert lms.medium.to_f > 0.5
      assert lms.long.to_f > 0
      assert lms.short.to_f > 0
    end

    def test_blue_lms_cone_response
      lms = @blue.to_lms
      # Blue should primarily stimulate S cones (short wavelength)
      assert lms.short.to_f > 0
      assert lms.long.to_f >= 0
      assert lms.medium.to_f >= 0
    end

    def test_lms_component_accessors_convert_from_srgb
      # Test that component accessors work on sRGB colors
      assert_instance_of Abachrome::AbcDecimal, @red.long
      assert_instance_of Abachrome::AbcDecimal, @red.medium
      assert_instance_of Abachrome::AbcDecimal, @red.short
    end

    def test_lms_component_accessors_on_lms_color
      lms = @red.to_lms
      # Accessing components on LMS color should not re-convert
      long_val = lms.long
      assert_equal lms.coordinates[0], long_val
    end

    def test_to_lms_from_different_color_spaces
      # Test conversion from OKLAB
      oklab = Abachrome::Color.from_oklab(0.5, 0.1, -0.1)
      lms = oklab.to_lms
      assert_equal :lms, lms.color_space.name

      # Test conversion from OKLCH
      oklch = Abachrome::Color.from_oklch(0.5, 0.1, 180)
      lms2 = oklch.to_lms
      assert_equal :lms, lms2.color_space.name

      # Test conversion from LRGB
      lrgb = Abachrome::Color.from_lrgb(0.5, 0.3, 0.2)
      lms3 = lrgb.to_lms
      assert_equal :lms, lms3.color_space.name

      # Test conversion from XYZ
      xyz = Abachrome::Color.from_xyz(0.5, 0.3, 0.2)
      lms4 = xyz.to_lms
      assert_equal :lms, lms4.color_space.name
    end

    def test_lms_values_precision
      lms = @red.to_lms
      values = lms.lms_values

      # Check that we maintain high precision
      values.each do |v|
        refute_nil v
        assert v.is_a?(Abachrome::AbcDecimal)
      end
    end

    def test_multiple_conversions_maintain_consistency
      # Convert multiple times and ensure consistency
      lms1 = @red.to_lms
      lms2 = @red.to_lms

      lms1.coordinates.zip(lms2.coordinates).each do |v1, v2|
        assert_equal v1, v2
      end
    end

    def test_lms_with_fractional_rgb_values
      color = Abachrome::Color.from_rgb(0.25, 0.75, 0.5)
      lms = color.to_lms

      assert_equal :lms, lms.color_space.name
      assert lms.long.to_f > 0
      assert lms.medium.to_f > 0
      assert lms.short.to_f > 0
    end

    def test_lms_component_order
      lms = @red.to_lms
      values = lms.lms_values

      assert_equal lms.long, values[0]
      assert_equal lms.medium, values[1]
      assert_equal lms.short, values[2]
    end

    def test_lms_as_intermediate_to_oklab
      # LMS is used as an intermediate space for OKLAB conversion
      # Verify the conversion path works
      srgb = @red
      lms = srgb.to_lms
      oklab = lms.to_oklab

      assert_equal :oklab, oklab.color_space.name
      assert oklab.l.to_f > 0
    end

    def test_lms_from_xyz_conversion
      xyz = Abachrome::Color.from_xyz(0.5, 0.3, 0.2)
      lms = xyz.to_lms

      assert_equal :lms, lms.color_space.name
      assert lms.long.to_f > 0
      assert lms.medium.to_f > 0
      assert lms.short.to_f > 0
    end

    def test_lms_to_xyz_conversion
      lms = Abachrome::Color.from_lms(0.5, 0.3, 0.2)
      xyz = lms.to_xyz

      assert_equal :xyz, xyz.color_space.name
      assert xyz.x.to_f > 0
      assert xyz.y.to_f > 0
      assert xyz.z.to_f > 0
    end

    def test_lms_values_are_non_negative_for_valid_colors
      colors = [@red, @green, @blue, @white, @gray]

      colors.each do |color|
        lms = color.to_lms
        assert lms.long.to_f >= 0, "Long cone response should be non-negative"
        assert lms.medium.to_f >= 0, "Medium cone response should be non-negative"
        assert lms.short.to_f >= 0, "Short cone response should be non-negative"
      end
    end

    def test_lms_reflects_human_cone_sensitivity
      # Red light primarily stimulates L cones
      red_lms = @red.to_lms
      assert red_lms.long.to_f > red_lms.short.to_f, "Red should stimulate L more than S"

      # Green light primarily stimulates M cones
      green_lms = @green.to_lms
      assert green_lms.medium.to_f > green_lms.short.to_f, "Green should stimulate M more than S"
    end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
