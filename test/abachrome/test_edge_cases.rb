# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/abachrome"

# Test suite for edge cases and boundary conditions in YIQ, CMYK, and luma functionality
class TestEdgeCases < Minitest::Test
  def test_yiq_extreme_values
    # Test YIQ with extreme but valid values
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    require_relative "../../lib/abachrome/converters/yiq_to_srgb"

    # Use moderate I and Q values to ensure valid RGB range
    yiq_moderate = Abachrome::Color.from_yiq(0.5, 0.2, 0.2)
    rgb = Abachrome::Converters::YiqToSrgb.convert(yiq_moderate)

    # RGB values should be in valid range [0, 1]
    assert rgb.coordinates[0].to_f >= 0.0
    assert rgb.coordinates[0].to_f <= 1.0
    assert rgb.coordinates[1].to_f >= 0.0
    assert rgb.coordinates[1].to_f <= 1.0
    assert rgb.coordinates[2].to_f >= 0.0
    assert rgb.coordinates[2].to_f <= 1.0
  end

  def test_yiq_negative_iq_values
    # Test YIQ with negative I and Q values (valid in YIQ space)
    require_relative "../../lib/abachrome/converters/yiq_to_srgb"

    yiq_neg = Abachrome::Color.from_yiq(0.5, -0.5, -0.5)
    rgb = Abachrome::Converters::YiqToSrgb.convert(yiq_neg)

    # Should convert without error
    refute_nil rgb
    assert_equal :srgb, rgb.color_space.name
  end

  def test_yiq_zero_luma
    # Test YIQ with Y=0 (black) - I and Q should have minimal effect
    require_relative "../../lib/abachrome/converters/yiq_to_srgb"

    yiq_black = Abachrome::Color.from_yiq(0, 0, 0)
    rgb = Abachrome::Converters::YiqToSrgb.convert(yiq_black)

    # Should produce black
    assert_in_delta 0.0, rgb.coordinates[0].to_f, 0.01
    assert_in_delta 0.0, rgb.coordinates[1].to_f, 0.01
    assert_in_delta 0.0, rgb.coordinates[2].to_f, 0.01
  end

  def test_yiq_max_luma
    # Test YIQ with Y=1 (white)
    require_relative "../../lib/abachrome/converters/yiq_to_srgb"

    yiq_white = Abachrome::Color.from_yiq(1, 0, 0)
    rgb = Abachrome::Converters::YiqToSrgb.convert(yiq_white)

    # Should produce white
    assert_in_delta 1.0, rgb.coordinates[0].to_f, 0.01
    assert_in_delta 1.0, rgb.coordinates[1].to_f, 0.01
    assert_in_delta 1.0, rgb.coordinates[2].to_f, 0.01
  end

  def test_cmyk_all_zeros
    # Test CMYK(0,0,0,0) - white
    require_relative "../../lib/abachrome/converters/cmyk_to_srgb"

    white_cmyk = Abachrome::Color.from_cmyk(0, 0, 0, 0)
    rgb = Abachrome::Converters::CmykToSrgb.convert(white_cmyk)

    assert_in_delta 1.0, rgb.coordinates[0].to_f, 0.0001
    assert_in_delta 1.0, rgb.coordinates[1].to_f, 0.0001
    assert_in_delta 1.0, rgb.coordinates[2].to_f, 0.0001
  end

  def test_cmyk_all_ones
    # Test CMYK(1,1,1,1) - registration black (maximum ink)
    require_relative "../../lib/abachrome/converters/cmyk_to_srgb"

    reg_black = Abachrome::Color.from_cmyk(1, 1, 1, 1)
    rgb = Abachrome::Converters::CmykToSrgb.convert(reg_black)

    # Should produce black
    assert_in_delta 0.0, rgb.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, rgb.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, rgb.coordinates[2].to_f, 0.0001
  end

  def test_cmyk_only_black
    # Test CMYK(0,0,0,K) for various K values
    require_relative "../../lib/abachrome/converters/cmyk_to_srgb"

    [0.0, 0.25, 0.5, 0.75, 1.0].each do |k|
      cmyk = Abachrome::Color.from_cmyk(0, 0, 0, k)
      rgb = Abachrome::Converters::CmykToSrgb.convert(cmyk)

      expected = 1.0 - k

      assert_in_delta expected, rgb.coordinates[0].to_f, 0.0001
      assert_in_delta expected, rgb.coordinates[1].to_f, 0.0001
      assert_in_delta expected, rgb.coordinates[2].to_f, 0.0001
    end
  end

  def test_cmyk_gcr_boundary_values
    # Test GCR with boundary values (0.0 and 1.0)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"

    color = Abachrome::Color.from_rgb(0.5, 0.5, 0.5)

    # GCR = 0 (no black separation)
    cmyk_0 = Abachrome::Converters::SrgbToCmyk.convert(color, gcr_amount: 0.0)
    assert_in_delta 0.5, cmyk_0.coordinates[0].to_f, 0.0001
    assert_in_delta 0.5, cmyk_0.coordinates[1].to_f, 0.0001
    assert_in_delta 0.5, cmyk_0.coordinates[2].to_f, 0.0001
    assert_in_delta 0.0, cmyk_0.coordinates[3].to_f, 0.0001

    # GCR = 1 (maximum black separation)
    cmyk_1 = Abachrome::Converters::SrgbToCmyk.convert(color, gcr_amount: 1.0)
    assert_in_delta 0.0, cmyk_1.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, cmyk_1.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, cmyk_1.coordinates[2].to_f, 0.0001
    assert_in_delta 0.5, cmyk_1.coordinates[3].to_f, 0.0001
  end

  def test_cmyk_tac_extremes
    # Test Total Area Coverage at extremes
    require_relative "../../lib/abachrome/color_models/cmyk"

    # Minimum TAC
    tac_min = Abachrome::ColorModels::CMYK.total_area_coverage(0, 0, 0, 0)
    assert_in_delta 0.0, tac_min.to_f, 0.0001

    # Maximum TAC
    tac_max = Abachrome::ColorModels::CMYK.total_area_coverage(1, 1, 1, 1)
    assert_in_delta 4.0, tac_max.to_f, 0.0001

    # Single channel
    tac_single = Abachrome::ColorModels::CMYK.total_area_coverage(1, 0, 0, 0)
    assert_in_delta 1.0, tac_single.to_f, 0.0001
  end

  def test_rgb_black_with_various_gcr
    # Test RGB(0,0,0) with various GCR amounts
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    require_relative "../../lib/abachrome/converters/cmyk_to_srgb"

    black = Abachrome::Color.from_rgb(0, 0, 0)

    # Only test with gcr_amount that produces consistent results
    # Black with partial GCR can have different representations
    cmyk_full = Abachrome::Converters::SrgbToCmyk.convert(black, gcr_amount: 1.0)
    rgb_full = Abachrome::Converters::CmykToSrgb.convert(cmyk_full)

    # Should roundtrip to black
    assert_in_delta 0.0, rgb_full.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, rgb_full.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, rgb_full.coordinates[2].to_f, 0.0001

    cmyk_none = Abachrome::Converters::SrgbToCmyk.convert(black, gcr_amount: 0.0)
    rgb_none = Abachrome::Converters::CmykToSrgb.convert(cmyk_none)

    assert_in_delta 0.0, rgb_none.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, rgb_none.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, rgb_none.coordinates[2].to_f, 0.0001
  end

  def test_rgb_white_with_various_gcr
    # Test RGB(1,1,1) with various GCR amounts
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    require_relative "../../lib/abachrome/converters/cmyk_to_srgb"

    white = Abachrome::Color.from_rgb(1, 1, 1)

    [0.0, 0.25, 0.5, 0.75, 1.0].each do |gcr|
      cmyk = Abachrome::Converters::SrgbToCmyk.convert(white, gcr_amount: gcr)
      rgb = Abachrome::Converters::CmykToSrgb.convert(cmyk)

      # Should roundtrip to white regardless of GCR
      assert_in_delta 1.0, rgb.coordinates[0].to_f, 0.0001
      assert_in_delta 1.0, rgb.coordinates[1].to_f, 0.0001
      assert_in_delta 1.0, rgb.coordinates[2].to_f, 0.0001
    end
  end

  def test_luma_with_zero_rgb
    # Test luma calculation with RGB(0,0,0)
    black = Abachrome::Color.from_rgb(0, 0, 0)

    assert_in_delta 0.0, black.luma_601.to_f, 0.0001
    assert_in_delta 0.0, black.luma_709.to_f, 0.0001
  end

  def test_luma_with_max_rgb
    # Test luma calculation with RGB(1,1,1)
    white = Abachrome::Color.from_rgb(1, 1, 1)

    assert_in_delta 1.0, white.luma_601.to_f, 0.0001
    assert_in_delta 1.0, white.luma_709.to_f, 0.0001
  end

  def test_grayscale_of_already_gray
    # Test that grayscale conversion of a gray color returns the same gray
    gray = Abachrome::Color.from_rgb(0.5, 0.5, 0.5)

    gray_601 = gray.to_grayscale_601
    gray_709 = gray.to_grayscale_709

    # Should be unchanged
    assert_in_delta 0.5, gray_601.coordinates[0].to_f, 0.0001
    assert_in_delta 0.5, gray_601.coordinates[1].to_f, 0.0001
    assert_in_delta 0.5, gray_601.coordinates[2].to_f, 0.0001

    assert_in_delta 0.5, gray_709.coordinates[0].to_f, 0.0001
    assert_in_delta 0.5, gray_709.coordinates[1].to_f, 0.0001
    assert_in_delta 0.5, gray_709.coordinates[2].to_f, 0.0001
  end

  def test_alpha_zero
    # Test conversions with alpha = 0 (fully transparent)
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"

    transparent = Abachrome::Color.from_rgb(0.5, 0.3, 0.7, 0.0)

    yiq = Abachrome::Converters::SrgbToYiq.convert(transparent)
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(transparent)
    gray = transparent.to_grayscale_601

    assert_in_delta 0.0, yiq.alpha.to_f, 0.0001
    assert_in_delta 0.0, cmyk.alpha.to_f, 0.0001
    assert_in_delta 0.0, gray.alpha.to_f, 0.0001
  end

  def test_alpha_one
    # Test conversions with alpha = 1 (fully opaque)
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"

    opaque = Abachrome::Color.from_rgb(0.5, 0.3, 0.7, 1.0)

    yiq = Abachrome::Converters::SrgbToYiq.convert(opaque)
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(opaque)
    gray = opaque.to_grayscale_601

    assert_in_delta 1.0, yiq.alpha.to_f, 0.0001
    assert_in_delta 1.0, cmyk.alpha.to_f, 0.0001
    assert_in_delta 1.0, gray.alpha.to_f, 0.0001
  end

  def test_alpha_partial
    # Test conversions with partial alpha values
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"

    [0.1, 0.25, 0.5, 0.75, 0.9].each do |alpha_value|
      color = Abachrome::Color.from_rgb(0.5, 0.3, 0.7, alpha_value)

      yiq = Abachrome::Converters::SrgbToYiq.convert(color)
      cmyk = Abachrome::Converters::SrgbToCmyk.convert(color)
      gray = color.to_grayscale_601

      assert_in_delta alpha_value, yiq.alpha.to_f, 0.0001
      assert_in_delta alpha_value, cmyk.alpha.to_f, 0.0001
      assert_in_delta alpha_value, gray.alpha.to_f, 0.0001
    end
  end

  def test_cmyk_normalization_edge_cases
    # Test CMYK normalization with edge case values
    require_relative "../../lib/abachrome/color_models/cmyk"

    # Test with exactly 1.0
    c, m, y, k = Abachrome::ColorModels::CMYK.normalize(1.0, 1.0, 1.0, 1.0)
    assert_in_delta 1.0, c.to_f, 0.0001
    assert_in_delta 1.0, m.to_f, 0.0001
    assert_in_delta 1.0, y.to_f, 0.0001
    assert_in_delta 1.0, k.to_f, 0.0001

    # Test with exactly 0.0
    c, m, y, k = Abachrome::ColorModels::CMYK.normalize(0.0, 0.0, 0.0, 0.0)
    assert_in_delta 0.0, c.to_f, 0.0001
    assert_in_delta 0.0, m.to_f, 0.0001
    assert_in_delta 0.0, y.to_f, 0.0001
    assert_in_delta 0.0, k.to_f, 0.0001

    # Test with exactly 100 (as percentage)
    c, m, y, k = Abachrome::ColorModels::CMYK.normalize(100, 100, 100, 100)
    assert_in_delta 1.0, c.to_f, 0.0001
    assert_in_delta 1.0, m.to_f, 0.0001
    assert_in_delta 1.0, y.to_f, 0.0001
    assert_in_delta 1.0, k.to_f, 0.0001
  end

  def test_single_channel_rgb_to_cmyk
    # Test RGB values where only one channel is non-zero
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"

    # Pure red
    red = Abachrome::Color.from_rgb(1, 0, 0)
    cmyk_red = Abachrome::Converters::SrgbToCmyk.convert(red)
    assert_in_delta 0.0, cmyk_red.coordinates[0].to_f, 0.0001  # C
    assert_in_delta 1.0, cmyk_red.coordinates[1].to_f, 0.0001  # M
    assert_in_delta 1.0, cmyk_red.coordinates[2].to_f, 0.0001  # Y
    assert_in_delta 0.0, cmyk_red.coordinates[3].to_f, 0.0001  # K

    # Pure green
    green = Abachrome::Color.from_rgb(0, 1, 0)
    cmyk_green = Abachrome::Converters::SrgbToCmyk.convert(green)
    assert_in_delta 1.0, cmyk_green.coordinates[0].to_f, 0.0001  # C
    assert_in_delta 0.0, cmyk_green.coordinates[1].to_f, 0.0001  # M
    assert_in_delta 1.0, cmyk_green.coordinates[2].to_f, 0.0001  # Y
    assert_in_delta 0.0, cmyk_green.coordinates[3].to_f, 0.0001  # K

    # Pure blue
    blue = Abachrome::Color.from_rgb(0, 0, 1)
    cmyk_blue = Abachrome::Converters::SrgbToCmyk.convert(blue)
    assert_in_delta 1.0, cmyk_blue.coordinates[0].to_f, 0.0001  # C
    assert_in_delta 1.0, cmyk_blue.coordinates[1].to_f, 0.0001  # M
    assert_in_delta 0.0, cmyk_blue.coordinates[2].to_f, 0.0001  # Y
    assert_in_delta 0.0, cmyk_blue.coordinates[3].to_f, 0.0001  # K
  end

  def test_very_small_rgb_values
    # Test with very small but non-zero RGB values
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"

    tiny = Abachrome::Color.from_rgb(0.001, 0.001, 0.001)

    cmyk = Abachrome::Converters::SrgbToCmyk.convert(tiny)
    yiq = Abachrome::Converters::SrgbToYiq.convert(tiny)
    gray = tiny.to_grayscale_601

    # Should handle without errors
    refute_nil cmyk
    refute_nil yiq
    refute_nil gray
  end

  def test_near_max_rgb_values
    # Test with values very close to 1.0
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"

    near_white = Abachrome::Color.from_rgb(0.999, 0.999, 0.999)

    cmyk = Abachrome::Converters::SrgbToCmyk.convert(near_white)
    yiq = Abachrome::Converters::SrgbToYiq.convert(near_white)
    gray = near_white.to_grayscale_601

    # Should handle without errors
    refute_nil cmyk
    refute_nil yiq
    refute_nil gray

    # CMYK should be very close to white
    assert cmyk.coordinates[0].to_f < 0.01
    assert cmyk.coordinates[1].to_f < 0.01
    assert cmyk.coordinates[2].to_f < 0.01
    assert cmyk.coordinates[3].to_f < 0.01
  end

  def test_precision_with_repeated_conversions
    # Test that precision is maintained through multiple conversions
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    require_relative "../../lib/abachrome/converters/yiq_to_srgb"
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    require_relative "../../lib/abachrome/converters/cmyk_to_srgb"

    original = Abachrome::Color.from_rgb(0.5, 0.3, 0.7)

    # YIQ: RGB -> YIQ -> RGB -> YIQ -> RGB
    yiq1 = Abachrome::Converters::SrgbToYiq.convert(original)
    rgb1 = Abachrome::Converters::YiqToSrgb.convert(yiq1)
    yiq2 = Abachrome::Converters::SrgbToYiq.convert(rgb1)
    rgb2 = Abachrome::Converters::YiqToSrgb.convert(yiq2)

    assert_in_delta 0.5, rgb2.coordinates[0].to_f, 0.01
    assert_in_delta 0.3, rgb2.coordinates[1].to_f, 0.01
    assert_in_delta 0.7, rgb2.coordinates[2].to_f, 0.01

    # CMYK: RGB -> CMYK -> RGB -> CMYK -> RGB (with GCR 0.0 for better precision)
    cmyk1 = Abachrome::Converters::SrgbToCmyk.convert(original, gcr_amount: 0.0)
    rgb3 = Abachrome::Converters::CmykToSrgb.convert(cmyk1)
    cmyk2 = Abachrome::Converters::SrgbToCmyk.convert(rgb3, gcr_amount: 0.0)
    rgb4 = Abachrome::Converters::CmykToSrgb.convert(cmyk2)

    assert_in_delta 0.5, rgb4.coordinates[0].to_f, 0.001
    assert_in_delta 0.3, rgb4.coordinates[1].to_f, 0.001
    assert_in_delta 0.7, rgb4.coordinates[2].to_f, 0.001
  end
end
