# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/abachrome"

class TestHarmonies < Minitest::Test
  def setup
    # A bright red color in OKLCH space for testing
    @red = Abachrome.from_oklch(0.628, 0.258, 29.2)

    # A blue color for additional testing
    @blue = Abachrome.from_oklch(0.452, 0.313, 264.1)
  end

  # Test analogous harmony
  def test_analogous_returns_three_colors
    harmony = @red.analogous
    assert_equal 3, harmony.length
  end

  def test_analogous_includes_original_color
    harmony = @red.analogous
    # Middle color should be similar to original
    assert_in_delta @red.to_oklch.coordinates[0].to_f, harmony[1].to_oklch.coordinates[0].to_f, 0.01
    assert_in_delta @red.to_oklch.coordinates[1].to_f, harmony[1].to_oklch.coordinates[1].to_f, 0.01
  end

  def test_analogous_with_custom_angle
    harmony = @red.analogous(angle: 45)
    oklch_red = @red.to_oklch
    base_hue = oklch_red.coordinates[2].to_f

    # Check that hues are approximately ±45° from base
    harmony_minus = harmony[0].to_oklch
    harmony_plus = harmony[2].to_oklch

    hue_minus = harmony_minus.coordinates[2].to_f
    hue_plus = harmony_plus.coordinates[2].to_f

    # Account for hue wrapping around 360
    diff_minus = ((hue_minus - (base_hue - 45)) % 360)
    diff_plus = ((hue_plus - (base_hue + 45)) % 360)

    assert_in_delta 0, diff_minus, 1, "Hue should be 45° less than base"
    assert_in_delta 0, diff_plus, 1, "Hue should be 45° more than base"
  end

  def test_analogous_preserves_lightness_and_chroma
    harmony = @red.analogous
    oklch_red = @red.to_oklch
    base_l = oklch_red.coordinates[0].to_f
    base_c = oklch_red.coordinates[1].to_f

    harmony.each do |color|
      oklch = color.to_oklch
      assert_in_delta base_l, oklch.coordinates[0].to_f, 0.01, "Lightness should be preserved"
      assert_in_delta base_c, oklch.coordinates[1].to_f, 0.01, "Chroma should be preserved"
    end
  end

  # Test complementary harmony
  def test_complementary_returns_two_colors
    harmony = @red.complementary
    assert_equal 2, harmony.length
  end

  def test_complementary_hue_difference
    harmony = @red.complementary
    oklch_red = @red.to_oklch
    oklch_complement = harmony[1].to_oklch

    base_hue = oklch_red.coordinates[2].to_f
    complement_hue = oklch_complement.coordinates[2].to_f

    # Complement should be 180° away
    hue_diff = (complement_hue - base_hue).abs
    hue_diff = 360 - hue_diff if hue_diff > 180

    assert_in_delta 180, hue_diff, 1
  end

  def test_complementary_preserves_lightness_and_chroma
    harmony = @red.complementary
    oklch_red = @red.to_oklch
    oklch_complement = harmony[1].to_oklch

    assert_in_delta oklch_red.coordinates[0].to_f, oklch_complement.coordinates[0].to_f, 0.01
    assert_in_delta oklch_red.coordinates[1].to_f, oklch_complement.coordinates[1].to_f, 0.01
  end

  # Test triadic harmony
  def test_triadic_returns_three_colors
    harmony = @red.triadic
    assert_equal 3, harmony.length
  end

  def test_triadic_hue_spacing
    harmony = @red.triadic
    oklch_base = @red.to_oklch
    base_hue = oklch_base.coordinates[2].to_f

    # Check that hues are approximately 120° and 240° from base
    hue_1 = harmony[1].to_oklch.coordinates[2].to_f
    hue_2 = harmony[2].to_oklch.coordinates[2].to_f

    diff_1 = ((hue_1 - (base_hue + 120)) % 360)
    diff_2 = ((hue_2 - (base_hue + 240)) % 360)

    assert_in_delta 0, diff_1, 1
    assert_in_delta 0, diff_2, 1
  end

  def test_triadic_preserves_lightness_and_chroma
    harmony = @red.triadic
    oklch_base = @red.to_oklch
    base_l = oklch_base.coordinates[0].to_f
    base_c = oklch_base.coordinates[1].to_f

    harmony.each do |color|
      oklch = color.to_oklch
      assert_in_delta base_l, oklch.coordinates[0].to_f, 0.01
      assert_in_delta base_c, oklch.coordinates[1].to_f, 0.01
    end
  end

  # Test tetradic harmony
  def test_tetradic_returns_four_colors
    harmony = @red.tetradic
    assert_equal 4, harmony.length
  end

  def test_tetradic_hue_spacing
    harmony = @red.tetradic
    oklch_base = @red.to_oklch
    base_hue = oklch_base.coordinates[2].to_f

    # Check that hues are approximately 90°, 180°, and 270° from base
    hue_1 = harmony[1].to_oklch.coordinates[2].to_f
    hue_2 = harmony[2].to_oklch.coordinates[2].to_f
    hue_3 = harmony[3].to_oklch.coordinates[2].to_f

    diff_1 = ((hue_1 - (base_hue + 90)) % 360)
    diff_2 = ((hue_2 - (base_hue + 180)) % 360)
    diff_3 = ((hue_3 - (base_hue + 270)) % 360)

    assert_in_delta 0, diff_1, 1
    assert_in_delta 0, diff_2, 1
    assert_in_delta 0, diff_3, 1
  end

  def test_tetradic_preserves_lightness_and_chroma
    harmony = @red.tetradic
    oklch_base = @red.to_oklch
    base_l = oklch_base.coordinates[0].to_f
    base_c = oklch_base.coordinates[1].to_f

    harmony.each do |color|
      oklch = color.to_oklch
      assert_in_delta base_l, oklch.coordinates[0].to_f, 0.01
      assert_in_delta base_c, oklch.coordinates[1].to_f, 0.01
    end
  end

  # Test split-complementary harmony
  def test_split_complementary_returns_three_colors
    harmony = @red.split_complementary
    assert_equal 3, harmony.length
  end

  def test_split_complementary_hue_spacing
    harmony = @red.split_complementary
    oklch_base = @red.to_oklch
    base_hue = oklch_base.coordinates[2].to_f

    # Check that hues are approximately 150° and 210° from base (complement ± 30°)
    hue_1 = harmony[1].to_oklch.coordinates[2].to_f
    hue_2 = harmony[2].to_oklch.coordinates[2].to_f

    diff_1 = ((hue_1 - (base_hue + 150)) % 360)
    diff_2 = ((hue_2 - (base_hue + 210)) % 360)

    assert_in_delta 0, diff_1, 1
    assert_in_delta 0, diff_2, 1
  end

  def test_split_complementary_preserves_lightness_and_chroma
    harmony = @red.split_complementary
    oklch_base = @red.to_oklch
    base_l = oklch_base.coordinates[0].to_f
    base_c = oklch_base.coordinates[1].to_f

    harmony.each do |color|
      oklch = color.to_oklch
      assert_in_delta base_l, oklch.coordinates[0].to_f, 0.01
      assert_in_delta base_c, oklch.coordinates[1].to_f, 0.01
    end
  end

  # Test with different color spaces
  def test_harmonies_with_rgb_input
    rgb_red = Abachrome.from_rgb(1, 0, 0)
    harmony = rgb_red.analogous

    # Should return colors in the same color space as input
    assert_equal 3, harmony.length
    harmony.each do |color|
      assert_equal :srgb, color.color_space.id
    end
  end

  def test_harmonies_preserve_alpha
    red_with_alpha = Abachrome.from_oklch(0.628, 0.258, 29.2, 0.5)
    harmony = red_with_alpha.analogous

    harmony.each do |color|
      assert_in_delta 0.5, color.alpha.to_f, 0.001
    end
  end

  # Test edge cases
  def test_harmonies_with_achromatic_color
    gray = Abachrome.from_oklch(0.5, 0, 0)
    harmony = gray.analogous

    # Achromatic colors (chroma = 0) should still generate harmony
    assert_equal 3, harmony.length

    # All colors should have same lightness and chroma (0)
    harmony.each do |color|
      oklch = color.to_oklch
      assert_in_delta 0.5, oklch.coordinates[0].to_f, 0.01
      assert_in_delta 0, oklch.coordinates[1].to_f, 0.01
    end
  end

  def test_harmonies_with_hue_wrapping
    # Test color with hue near 360° to ensure proper wrapping
    color = Abachrome.from_oklch(0.5, 0.2, 350)
    harmony = color.analogous(angle: 30)

    # Should handle wrapping around 0/360 boundary
    assert_equal 3, harmony.length

    # All should be valid colors
    harmony.each do |c|
      oklch = c.to_oklch
      hue = oklch.coordinates[2].to_f
      assert hue >= 0 && hue < 360, "Hue should be in 0-360 range, got #{hue}"
    end
  end

  # Test all harmony types with blue color
  def test_all_harmony_types_with_blue
    analogous = @blue.analogous
    complementary = @blue.complementary
    triadic = @blue.triadic
    tetradic = @blue.tetradic
    split_comp = @blue.split_complementary

    assert_equal 3, analogous.length
    assert_equal 2, complementary.length
    assert_equal 3, triadic.length
    assert_equal 4, tetradic.length
    assert_equal 3, split_comp.length
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
