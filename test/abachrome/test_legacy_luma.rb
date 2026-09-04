# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/abachrome"

# Test suite for legacy luma conversion methods (Rec. 601 and Rec. 709)
# These tests verify the correct implementation of grayscale conversion
# using historically accurate coefficients for different broadcast standards.
class TestLegacyLuma < Minitest::Test
  def test_luma_601_coefficients
    # Verify Rec. 601 uses correct coefficients: 0.299R + 0.587G + 0.114B
    # Test each primary color individually
    red = Abachrome::Color.from_rgb(1, 0, 0)
    green = Abachrome::Color.from_rgb(0, 1, 0)
    blue = Abachrome::Color.from_rgb(0, 0, 1)

    assert_in_delta 0.299, red.luma_601.to_f, 0.001
    assert_in_delta 0.587, green.luma_601.to_f, 0.001
    assert_in_delta 0.114, blue.luma_601.to_f, 0.001
  end

  def test_luma_709_coefficients
    # Verify Rec. 709 uses correct coefficients: 0.2126R + 0.7152G + 0.0722B
    # Test each primary color individually
    red = Abachrome::Color.from_rgb(1, 0, 0)
    green = Abachrome::Color.from_rgb(0, 1, 0)
    blue = Abachrome::Color.from_rgb(0, 0, 1)

    assert_in_delta 0.2126, red.luma_709.to_f, 0.001
    assert_in_delta 0.7152, green.luma_709.to_f, 0.001
    assert_in_delta 0.0722, blue.luma_709.to_f, 0.001
  end

  def test_luma_601_vs_709_difference
    # Verify that 601 and 709 produce different results for non-gray colors
    test_colors = [
      Abachrome::Color.from_rgb(1, 0, 0),    # Red
      Abachrome::Color.from_rgb(0, 1, 0),    # Green
      Abachrome::Color.from_rgb(0, 0, 1),    # Blue
      Abachrome::Color.from_rgb(1, 1, 0),    # Yellow
      Abachrome::Color.from_rgb(1, 0, 1),    # Magenta
      Abachrome::Color.from_rgb(0, 1, 1),    # Cyan
      Abachrome::Color.from_rgb(0.5, 0.3, 0.7) # Purple
    ]

    test_colors.each do |color|
      luma_601 = color.luma_601.to_f
      luma_709 = color.luma_709.to_f

      # The standards should produce different results for colored inputs
      # (but may be the same for pure grays)
      unless color.coordinates[0] == color.coordinates[1] && color.coordinates[1] == color.coordinates[2]
        refute_in_delta luma_601, luma_709, 0.001, "601 and 709 should differ for #{color.inspect}"
      end
    end
  end

  def test_luma_601_vs_709_same_for_gray
    # Verify that both standards produce the same result for pure gray
    grays = [
      Abachrome::Color.from_rgb(0, 0, 0),
      Abachrome::Color.from_rgb(0.25, 0.25, 0.25),
      Abachrome::Color.from_rgb(0.5, 0.5, 0.5),
      Abachrome::Color.from_rgb(0.75, 0.75, 0.75),
      Abachrome::Color.from_rgb(1, 1, 1)
    ]

    grays.each do |gray|
      luma_601 = gray.luma_601.to_f
      luma_709 = gray.luma_709.to_f
      expected = gray.coordinates[0].to_f

      assert_in_delta expected, luma_601, 0.0001
      assert_in_delta expected, luma_709, 0.0001
      assert_in_delta luma_601, luma_709, 0.0001
    end
  end

  def test_to_grayscale_601_creates_achromatic_color
    # Verify grayscale conversion creates colors with R=G=B
    test_colors = [
      Abachrome::Color.from_rgb(1, 0, 0),
      Abachrome::Color.from_rgb(0, 1, 0),
      Abachrome::Color.from_rgb(0, 0, 1),
      Abachrome::Color.from_rgb(0.3, 0.7, 0.2)
    ]

    test_colors.each do |color|
      gray = color.to_grayscale_601
      r, g, b = gray.coordinates.map(&:to_f)

      assert_in_delta r, g, 0.0001
      assert_in_delta g, b, 0.0001
      assert_equal :srgb, gray.color_space.name
    end
  end

  def test_to_grayscale_709_creates_achromatic_color
    # Verify grayscale conversion creates colors with R=G=B
    test_colors = [
      Abachrome::Color.from_rgb(1, 0, 0),
      Abachrome::Color.from_rgb(0, 1, 0),
      Abachrome::Color.from_rgb(0, 0, 1),
      Abachrome::Color.from_rgb(0.3, 0.7, 0.2)
    ]

    test_colors.each do |color|
      gray = color.to_grayscale_709
      r, g, b = gray.coordinates.map(&:to_f)

      assert_in_delta r, g, 0.0001
      assert_in_delta g, b, 0.0001
      assert_equal :srgb, gray.color_space.name
    end
  end

  def test_grayscale_601_matches_luma_601
    # Verify that to_grayscale_601 produces a color with luma_601 value
    colors = [
      Abachrome::Color.from_rgb(1, 0, 0),
      Abachrome::Color.from_rgb(0.2, 0.4, 0.6),
      Abachrome::Color.from_rgb(0.8, 0.1, 0.3)
    ]

    colors.each do |color|
      expected_luma = color.luma_601.to_f
      gray = color.to_grayscale_601

      assert_in_delta expected_luma, gray.coordinates[0].to_f, 0.0001
      assert_in_delta expected_luma, gray.coordinates[1].to_f, 0.0001
      assert_in_delta expected_luma, gray.coordinates[2].to_f, 0.0001
    end
  end

  def test_grayscale_709_matches_luma_709
    # Verify that to_grayscale_709 produces a color with luma_709 value
    colors = [
      Abachrome::Color.from_rgb(1, 0, 0),
      Abachrome::Color.from_rgb(0.2, 0.4, 0.6),
      Abachrome::Color.from_rgb(0.8, 0.1, 0.3)
    ]

    colors.each do |color|
      expected_luma = color.luma_709.to_f
      gray = color.to_grayscale_709

      assert_in_delta expected_luma, gray.coordinates[0].to_f, 0.0001
      assert_in_delta expected_luma, gray.coordinates[1].to_f, 0.0001
      assert_in_delta expected_luma, gray.coordinates[2].to_f, 0.0001
    end
  end

  def test_luma_preserves_brightness_order
    # Verify that luma calculations preserve perceptual brightness order
    # Green should be brightest, red middle, blue darkest for primaries
    red = Abachrome::Color.from_rgb(1, 0, 0)
    green = Abachrome::Color.from_rgb(0, 1, 0)
    blue = Abachrome::Color.from_rgb(0, 0, 1)

    # Test with 601
    assert green.luma_601.to_f > red.luma_601.to_f
    assert red.luma_601.to_f > blue.luma_601.to_f

    # Test with 709
    assert green.luma_709.to_f > red.luma_709.to_f
    assert red.luma_709.to_f > blue.luma_709.to_f
  end

  def test_luma_default_alias
    # Verify that luma() is an alias for luma_601()
    colors = [
      Abachrome::Color.from_rgb(1, 0, 0),
      Abachrome::Color.from_rgb(0, 1, 0),
      Abachrome::Color.from_rgb(0.5, 0.3, 0.7)
    ]

    colors.each do |color|
      assert_in_delta color.luma_601.to_f, color.luma.to_f, 0.0001
    end
  end

  def test_to_grayscale_default_alias
    # Verify that to_grayscale() is an alias for to_grayscale_601()
    colors = [
      Abachrome::Color.from_rgb(1, 0, 0),
      Abachrome::Color.from_rgb(0, 1, 0),
      Abachrome::Color.from_rgb(0.5, 0.3, 0.7)
    ]

    colors.each do |color|
      gray_default = color.to_grayscale
      gray_601 = color.to_grayscale_601

      assert_in_delta gray_601.coordinates[0].to_f, gray_default.coordinates[0].to_f, 0.0001
      assert_in_delta gray_601.coordinates[1].to_f, gray_default.coordinates[1].to_f, 0.0001
      assert_in_delta gray_601.coordinates[2].to_f, gray_default.coordinates[2].to_f, 0.0001
    end
  end

  def test_grayscale_preserves_alpha
    # Test that alpha channel is preserved during grayscale conversion
    color_with_alpha = Abachrome::Color.from_rgb(0.5, 0.3, 0.7, 0.8)

    gray_601 = color_with_alpha.to_grayscale_601
    gray_709 = color_with_alpha.to_grayscale_709

    assert_in_delta 0.8, gray_601.alpha.to_f, 0.0001
    assert_in_delta 0.8, gray_709.alpha.to_f, 0.0001
  end

  def test_luma_bounds
    # Verify luma values are always in [0, 1] range
    test_colors = [
      Abachrome::Color.from_rgb(0, 0, 0),
      Abachrome::Color.from_rgb(1, 1, 1),
      Abachrome::Color.from_rgb(1, 0, 0),
      Abachrome::Color.from_rgb(0, 1, 0),
      Abachrome::Color.from_rgb(0, 0, 1),
      Abachrome::Color.from_rgb(0.2, 0.4, 0.6)
    ]

    test_colors.each do |color|
      luma_601 = color.luma_601.to_f
      luma_709 = color.luma_709.to_f

      assert luma_601 >= 0.0, "Luma 601 should be >= 0"
      assert luma_601 <= 1.0, "Luma 601 should be <= 1"
      assert luma_709 >= 0.0, "Luma 709 should be >= 0"
      assert luma_709 <= 1.0, "Luma 709 should be <= 1"
    end
  end

  def test_grayscale_idempotent
    # Verify that converting to grayscale twice produces the same result
    color = Abachrome::Color.from_rgb(0.5, 0.3, 0.7)

    gray_601_once = color.to_grayscale_601
    gray_601_twice = gray_601_once.to_grayscale_601

    assert_in_delta gray_601_once.coordinates[0].to_f, gray_601_twice.coordinates[0].to_f, 0.0001
    assert_in_delta gray_601_once.coordinates[1].to_f, gray_601_twice.coordinates[1].to_f, 0.0001
    assert_in_delta gray_601_once.coordinates[2].to_f, gray_601_twice.coordinates[2].to_f, 0.0001

    gray_709_once = color.to_grayscale_709
    gray_709_twice = gray_709_once.to_grayscale_709

    assert_in_delta gray_709_once.coordinates[0].to_f, gray_709_twice.coordinates[0].to_f, 0.0001
    assert_in_delta gray_709_once.coordinates[1].to_f, gray_709_twice.coordinates[1].to_f, 0.0001
    assert_in_delta gray_709_once.coordinates[2].to_f, gray_709_twice.coordinates[2].to_f, 0.0001
  end

  def test_yiq_y_matches_luma_601
    # Verify that YIQ's Y component matches Rec. 601 luma
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"

    colors = [
      Abachrome::Color.from_rgb(1, 0, 0),
      Abachrome::Color.from_rgb(0, 1, 0),
      Abachrome::Color.from_rgb(0, 0, 1),
      Abachrome::Color.from_rgb(0.5, 0.3, 0.7)
    ]

    colors.each do |color|
      luma_601 = color.luma_601.to_f
      yiq = Abachrome::Converters::SrgbToYiq.convert(color)
      y_component = yiq.coordinates[0].to_f

      assert_in_delta luma_601, y_component, 0.0001
    end
  end

  def test_luma_linearity
    # Verify that luma calculation is linear
    # luma(c1) + luma(c2) should equal luma(c1+c2) for additive RGB
    r1 = 0.2
    g1 = 0.3
    b1 = 0.4
    r2 = 0.3
    g2 = 0.2
    b2 = 0.1

    color1 = Abachrome::Color.from_rgb(r1, g1, b1)
    color2 = Abachrome::Color.from_rgb(r2, g2, b2)
    color_sum = Abachrome::Color.from_rgb(
      [r1 + r2, 1.0].min,
      [g1 + g2, 1.0].min,
      [b1 + b2, 1.0].min
    )

    # 601 linearity
    luma_sum_601 = color1.luma_601.to_f + color2.luma_601.to_f
    expected_601 = color_sum.luma_601.to_f
    assert_in_delta expected_601, luma_sum_601, 0.001

    # 709 linearity
    luma_sum_709 = color1.luma_709.to_f + color2.luma_709.to_f
    expected_709 = color_sum.luma_709.to_f
    assert_in_delta expected_709, luma_sum_709, 0.001
  end

  def test_grayscale_from_non_srgb_space
    # Test that grayscale conversion works from other color spaces
    require_relative "../../lib/abachrome/converters/srgb_to_oklab"

    # Start with a color in oklab space
    srgb_color = Abachrome::Color.from_rgb(0.5, 0.3, 0.7)
    oklab_color = Abachrome::Converters::SrgbToOklab.convert(srgb_color)

    # Convert to grayscale (should work via sRGB conversion)
    gray_601 = oklab_color.to_grayscale_601
    gray_709 = oklab_color.to_grayscale_709

    # Should produce same result as converting sRGB directly
    expected_601 = srgb_color.to_grayscale_601
    expected_709 = srgb_color.to_grayscale_709

    assert_in_delta expected_601.coordinates[0].to_f, gray_601.coordinates[0].to_f, 0.001
    assert_in_delta expected_709.coordinates[0].to_f, gray_709.coordinates[0].to_f, 0.001
  end

  def test_coefficients_sum_to_one
    # Verify that Rec. 601 coefficients sum to 1.0
    sum_601 = 0.299 + 0.587 + 0.114
    assert_in_delta 1.0, sum_601, 0.001

    # Verify that Rec. 709 coefficients sum to 1.0
    sum_709 = 0.2126 + 0.7152 + 0.0722
    assert_in_delta 1.0, sum_709, 0.001
  end
end
