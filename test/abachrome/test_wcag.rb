# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/abachrome"

class TestWCAG < Minitest::Test
  # Test relative luminance calculation with known values
  def test_relative_luminance_black
    color = Abachrome.from_rgb(0, 0, 0)
    assert_in_delta 0.0, color.relative_luminance.to_f, 0.001
  end

  def test_relative_luminance_white
    color = Abachrome.from_rgb(1, 1, 1)
    assert_in_delta 1.0, color.relative_luminance.to_f, 0.001
  end

  def test_relative_luminance_red
    # Pure red (255, 0, 0) has relative luminance of approximately 0.2126
    color = Abachrome.from_rgb(1, 0, 0)
    assert_in_delta 0.2126, color.relative_luminance.to_f, 0.01
  end

  def test_relative_luminance_green
    # Pure green (0, 255, 0) has relative luminance of approximately 0.7152
    color = Abachrome.from_rgb(0, 1, 0)
    assert_in_delta 0.7152, color.relative_luminance.to_f, 0.01
  end

  def test_relative_luminance_blue
    # Pure blue (0, 0, 255) has relative luminance of approximately 0.0722
    color = Abachrome.from_rgb(0, 0, 1)
    assert_in_delta 0.0722, color.relative_luminance.to_f, 0.01
  end

  def test_relative_luminance_gray
    # 50% gray should have luminance around 0.2158 (not 0.5 due to gamma)
    color = Abachrome.from_rgb(0.5, 0.5, 0.5)
    assert_in_delta 0.2158, color.relative_luminance.to_f, 0.01
  end

  # Test contrast ratio calculation
  def test_contrast_ratio_black_white
    black = Abachrome.from_rgb(0, 0, 0)
    white = Abachrome.from_rgb(1, 1, 1)

    # Black on white should have maximum contrast ratio of 21:1
    ratio = black.contrast_ratio(white)
    assert_in_delta 21.0, ratio.to_f, 0.1
  end

  def test_contrast_ratio_symmetric
    color1 = Abachrome.from_rgb(0.2, 0.3, 0.4)
    color2 = Abachrome.from_rgb(0.7, 0.8, 0.9)

    # Contrast ratio should be symmetric
    ratio1 = color1.contrast_ratio(color2)
    ratio2 = color2.contrast_ratio(color1)
    assert_in_delta ratio1.to_f, ratio2.to_f, 0.001
  end

  def test_contrast_ratio_identical_colors
    color = Abachrome.from_rgb(0.5, 0.5, 0.5)

    # Identical colors should have 1:1 contrast
    ratio = color.contrast_ratio(color)
    assert_in_delta 1.0, ratio.to_f, 0.001
  end

  # Test WCAG AA compliance (normal text: 4.5:1, large text: 3:1)
  def test_meets_wcag_aa_normal_text_pass
    # Black text on white background (21:1) should pass
    black = Abachrome.from_rgb(0, 0, 0)
    white = Abachrome.from_rgb(1, 1, 1)
    assert black.meets_wcag_aa?(white, large_text: false)
  end

  def test_meets_wcag_aa_normal_text_fail
    # Very light gray on white should fail for normal text
    light_gray = Abachrome.from_rgb(0.9, 0.9, 0.9)
    white = Abachrome.from_rgb(1, 1, 1)
    refute light_gray.meets_wcag_aa?(white, large_text: false)
  end

  def test_meets_wcag_aa_large_text_pass
    # #767676 on white has a 4.54:1 contrast ratio
    # Should pass for large text (needs 3:1) but might be borderline for normal text
    gray = Abachrome.from_rgb(0x76 / 255.0, 0x76 / 255.0, 0x76 / 255.0)
    white = Abachrome.from_rgb(1, 1, 1)
    assert gray.meets_wcag_aa?(white, large_text: true)
  end

  def test_meets_wcag_aa_large_text_fail
    # Very light gray on white should fail even for large text
    light_gray = Abachrome.from_rgb(0.95, 0.95, 0.95)
    white = Abachrome.from_rgb(1, 1, 1)
    refute light_gray.meets_wcag_aa?(white, large_text: true)
  end

  # Test WCAG AAA compliance (normal text: 7:1, large text: 4.5:1)
  def test_meets_wcag_aaa_normal_text_pass
    # Black on white (21:1) should pass AAA for normal text
    black = Abachrome.from_rgb(0, 0, 0)
    white = Abachrome.from_rgb(1, 1, 1)
    assert black.meets_wcag_aaa?(white, large_text: false)
  end

  def test_meets_wcag_aaa_normal_text_fail
    # #595959 on white has approximately 7:1 contrast
    # Testing with slightly lighter gray to ensure it fails
    gray = Abachrome.from_rgb(0x65 / 255.0, 0x65 / 255.0, 0x65 / 255.0)
    white = Abachrome.from_rgb(1, 1, 1)
    refute gray.meets_wcag_aaa?(white, large_text: false)
  end

  def test_meets_wcag_aaa_large_text_pass
    # #767676 on white has 4.54:1 ratio, should pass AAA for large text
    gray = Abachrome.from_rgb(0x76 / 255.0, 0x76 / 255.0, 0x76 / 255.0)
    white = Abachrome.from_rgb(1, 1, 1)
    assert gray.meets_wcag_aaa?(white, large_text: true)
  end

  def test_meets_wcag_aaa_large_text_fail
    # Light gray should fail AAA for large text
    light_gray = Abachrome.from_rgb(0.85, 0.85, 0.85)
    white = Abachrome.from_rgb(1, 1, 1)
    refute light_gray.meets_wcag_aaa?(white, large_text: true)
  end

  # Test WCAG 2.1 non-text contrast (3:1 minimum)
  def test_meets_wcag_non_text_pass
    # Medium gray on white should pass 3:1 (need darker than 0.6)
    gray = Abachrome.from_rgb(0.55, 0.55, 0.55)
    white = Abachrome.from_rgb(1, 1, 1)
    assert gray.meets_wcag_non_text?(white)
  end

  def test_meets_wcag_non_text_fail
    # Very light gray on white should fail 3:1
    light_gray = Abachrome.from_rgb(0.93, 0.93, 0.93)
    white = Abachrome.from_rgb(1, 1, 1)
    refute light_gray.meets_wcag_non_text?(white)
  end

  # Test with actual color combinations
  def test_wcag_typical_dark_text_on_light_background
    # Typical body text: #333333 on #FFFFFF
    dark_gray = Abachrome.from_rgb(0x33 / 255.0, 0x33 / 255.0, 0x33 / 255.0)
    white = Abachrome.from_rgb(1, 1, 1)

    assert dark_gray.meets_wcag_aa?(white, large_text: false)
    assert dark_gray.meets_wcag_aaa?(white, large_text: false)
  end

  def test_wcag_link_blue_on_white
    # Typical link blue: #0000EE on white
    blue = Abachrome.from_rgb(0, 0, 0xEE / 255.0)
    white = Abachrome.from_rgb(1, 1, 1)

    # Should pass AA but might not pass AAA due to blue's low luminance
    assert blue.meets_wcag_aa?(white, large_text: false)
  end

  def test_wcag_colored_text_combinations
    # Red (#FF0000) on white
    red = Abachrome.from_rgb(1, 0, 0)
    white = Abachrome.from_rgb(1, 1, 1)

    # Pure red on white typically fails WCAG AA for normal text
    # (ratio is around 3.998:1, needs 4.5:1)
    refute red.meets_wcag_aa?(white, large_text: false)

    # But it should pass for large text and non-text
    assert red.meets_wcag_aa?(white, large_text: true)
    assert red.meets_wcag_non_text?(white)
  end

  # Test edge cases
  def test_wcag_with_different_color_spaces
    # Create colors in different color spaces and verify they work
    rgb_black = Abachrome.from_rgb(0, 0, 0)
    oklch_white = Abachrome.from_oklch(1, 0, 0)

    ratio = rgb_black.contrast_ratio(oklch_white)
    assert_in_delta 21.0, ratio.to_f, 0.1
  end

  def test_wcag_gray_scale_progression
    # Test that darker grays consistently have better contrast with white
    white = Abachrome.from_rgb(1, 1, 1)

    gray_10 = Abachrome.from_rgb(0.1, 0.1, 0.1)
    gray_30 = Abachrome.from_rgb(0.3, 0.3, 0.3)
    gray_50 = Abachrome.from_rgb(0.5, 0.5, 0.5)

    ratio_10 = gray_10.contrast_ratio(white).to_f
    ratio_30 = gray_30.contrast_ratio(white).to_f
    ratio_50 = gray_50.contrast_ratio(white).to_f

    # Darker colors should have higher contrast ratios
    assert ratio_10 > ratio_30
    assert ratio_30 > ratio_50
  end

  # Test linearization edge cases
  def test_linearization_threshold
    # Test colors around the 0.03928 threshold
    below = Abachrome.from_rgb(0.03, 0.03, 0.03)
    above = Abachrome.from_rgb(0.05, 0.05, 0.05)

    # Both should produce valid luminance values
    assert below.relative_luminance.to_f >= 0
    assert above.relative_luminance.to_f >= 0
    assert above.relative_luminance > below.relative_luminance
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
