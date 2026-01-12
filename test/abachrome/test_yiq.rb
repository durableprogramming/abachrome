# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/abachrome"

class TestYIQ < Minitest::Test
  def setup
    @yiq_space = Abachrome::ColorSpace.find(:yiq)
  end

  def test_yiq_color_space_exists
    refute_nil @yiq_space
    assert_equal :yiq, @yiq_space.name
    assert_equal [:y, :i, :q], @yiq_space.coordinates
  end

  def test_from_yiq
    color = Abachrome::Color.from_yiq(0.5, 0.1, -0.1)
    assert_equal :yiq, color.color_space.name
    assert_in_delta 0.5, color.coordinates[0].to_f, 0.0001
    assert_in_delta 0.1, color.coordinates[1].to_f, 0.0001
    assert_in_delta(-0.1, color.coordinates[2].to_f, 0.0001)
  end

  def test_rgb_to_yiq_white
    # White: RGB(1, 1, 1) should give Y=1, I=0, Q=0
    white = Abachrome::Color.from_rgb(1, 1, 1)
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    yiq = Abachrome::Converters::SrgbToYiq.convert(white)

    assert_in_delta 1.0, yiq.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, yiq.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, yiq.coordinates[2].to_f, 0.0001
  end

  def test_rgb_to_yiq_black
    # Black: RGB(0, 0, 0) should give Y=0, I=0, Q=0
    black = Abachrome::Color.from_rgb(0, 0, 0)
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    yiq = Abachrome::Converters::SrgbToYiq.convert(black)

    assert_in_delta 0.0, yiq.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, yiq.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, yiq.coordinates[2].to_f, 0.0001
  end

  def test_rgb_to_yiq_red
    # Red: RGB(1, 0, 0)
    # Y = 0.299*1 + 0.587*0 + 0.114*0 = 0.299
    # I = 0.5959*1 - 0.2746*0 - 0.3213*0 ≈ 0.5959
    # Q = 0.2115*1 - 0.5227*0 + 0.3112*0 ≈ 0.2115
    red = Abachrome::Color.from_rgb(1, 0, 0)
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    yiq = Abachrome::Converters::SrgbToYiq.convert(red)

    assert_in_delta 0.299, yiq.coordinates[0].to_f, 0.01
    assert_in_delta 0.5959, yiq.coordinates[1].to_f, 0.01
    assert_in_delta 0.2115, yiq.coordinates[2].to_f, 0.01
  end

  def test_yiq_to_rgb_roundtrip
    # Test that RGB -> YIQ -> RGB is reversible
    original = Abachrome::Color.from_rgb(0.5, 0.3, 0.7)
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    require_relative "../../lib/abachrome/converters/yiq_to_srgb"

    yiq = Abachrome::Converters::SrgbToYiq.convert(original)
    rgb = Abachrome::Converters::YiqToSrgb.convert(yiq)

    assert_in_delta 0.5, rgb.coordinates[0].to_f, 0.0001
    assert_in_delta 0.3, rgb.coordinates[1].to_f, 0.0001
    assert_in_delta 0.7, rgb.coordinates[2].to_f, 0.0001
  end

  def test_luma_601
    # Test grayscale conversion using Rec. 601 luma
    # For RGB(1, 0, 0): luma should be 0.299
    red = Abachrome::Color.from_rgb(1, 0, 0)
    assert_in_delta 0.299, red.luma_601.to_f, 0.001

    # For RGB(0, 1, 0): luma should be 0.587
    green = Abachrome::Color.from_rgb(0, 1, 0)
    assert_in_delta 0.587, green.luma_601.to_f, 0.001

    # For RGB(0, 0, 1): luma should be 0.114
    blue = Abachrome::Color.from_rgb(0, 0, 1)
    assert_in_delta 0.114, blue.luma_601.to_f, 0.001
  end

  def test_to_grayscale_601
    # Red should convert to a gray with value 0.299
    red = Abachrome::Color.from_rgb(1, 0, 0)
    gray = red.to_grayscale_601

    assert_equal :srgb, gray.color_space.name
    assert_in_delta 0.299, gray.coordinates[0].to_f, 0.001
    assert_in_delta 0.299, gray.coordinates[1].to_f, 0.001
    assert_in_delta 0.299, gray.coordinates[2].to_f, 0.001
  end

  def test_to_grayscale_709
    # Red using Rec. 709: luma should be 0.2126
    red = Abachrome::Color.from_rgb(1, 0, 0)
    gray = red.to_grayscale_709

    assert_equal :srgb, gray.color_space.name
    assert_in_delta 0.2126, gray.coordinates[0].to_f, 0.001
    assert_in_delta 0.2126, gray.coordinates[1].to_f, 0.001
    assert_in_delta 0.2126, gray.coordinates[2].to_f, 0.001
  end

  def test_yiq_alpha_preservation
    color = Abachrome::Color.from_yiq(0.5, 0.1, -0.1, 0.7)
    assert_in_delta 0.7, color.alpha.to_f, 0.0001
  end

  def test_rgb_to_yiq_green
    # Green: RGB(0, 1, 0)
    # Y = 0.299*0 + 0.587*1 + 0.114*0 = 0.587
    # I = 0.5959*0 - 0.2746*1 - 0.3213*0 ≈ -0.2746
    # Q = 0.2115*0 - 0.5227*1 + 0.3112*0 ≈ -0.5227
    green = Abachrome::Color.from_rgb(0, 1, 0)
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    yiq = Abachrome::Converters::SrgbToYiq.convert(green)

    assert_in_delta 0.587, yiq.coordinates[0].to_f, 0.01
    assert_in_delta(-0.2746, yiq.coordinates[1].to_f, 0.01)
    assert_in_delta(-0.5227, yiq.coordinates[2].to_f, 0.01)
  end

  def test_rgb_to_yiq_blue
    # Blue: RGB(0, 0, 1)
    # Y = 0.299*0 + 0.587*0 + 0.114*1 = 0.114
    # I = 0.5959*0 - 0.2746*0 - 0.3213*1 ≈ -0.3213
    # Q = 0.2115*0 - 0.5227*0 + 0.3112*1 ≈ 0.3112
    blue = Abachrome::Color.from_rgb(0, 0, 1)
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    yiq = Abachrome::Converters::SrgbToYiq.convert(blue)

    assert_in_delta 0.114, yiq.coordinates[0].to_f, 0.01
    assert_in_delta(-0.3213, yiq.coordinates[1].to_f, 0.01)
    assert_in_delta 0.3112, yiq.coordinates[2].to_f, 0.01
  end

  def test_rgb_to_yiq_gray
    # Gray: RGB(0.5, 0.5, 0.5) should give Y=0.5, I=0, Q=0
    gray = Abachrome::Color.from_rgb(0.5, 0.5, 0.5)
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    yiq = Abachrome::Converters::SrgbToYiq.convert(gray)

    assert_in_delta 0.5, yiq.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, yiq.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, yiq.coordinates[2].to_f, 0.0001
  end

  def test_yiq_to_rgb_primary_colors
    # Test converting YIQ back to primary colors
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    require_relative "../../lib/abachrome/converters/yiq_to_srgb"

    # Red
    red_yiq = Abachrome::Color.from_yiq(0.299, 0.5959, 0.2115)
    red_rgb = Abachrome::Converters::YiqToSrgb.convert(red_yiq)
    assert_in_delta 1.0, red_rgb.coordinates[0].to_f, 0.01
    assert_in_delta 0.0, red_rgb.coordinates[1].to_f, 0.01
    assert_in_delta 0.0, red_rgb.coordinates[2].to_f, 0.01

    # Green
    green_yiq = Abachrome::Color.from_yiq(0.587, -0.2746, -0.5227)
    green_rgb = Abachrome::Converters::YiqToSrgb.convert(green_yiq)
    assert_in_delta 0.0, green_rgb.coordinates[0].to_f, 0.01
    assert_in_delta 1.0, green_rgb.coordinates[1].to_f, 0.01
    assert_in_delta 0.0, green_rgb.coordinates[2].to_f, 0.01

    # Blue
    blue_yiq = Abachrome::Color.from_yiq(0.114, -0.3213, 0.3112)
    blue_rgb = Abachrome::Converters::YiqToSrgb.convert(blue_yiq)
    assert_in_delta 0.0, blue_rgb.coordinates[0].to_f, 0.01
    assert_in_delta 0.0, blue_rgb.coordinates[1].to_f, 0.01
    assert_in_delta 1.0, blue_rgb.coordinates[2].to_f, 0.01
  end

  def test_yiq_normalization
    # Test YIQ model normalization
    require_relative "../../lib/abachrome/color_models/yiq"
    y, i, q = Abachrome::ColorModels::YIQ.normalize(0.5, 0.25, -0.25)

    assert_in_delta 0.5, y.to_f, 0.0001
    assert_in_delta 0.25, i.to_f, 0.0001
    assert_in_delta(-0.25, q.to_f, 0.0001)
  end

  def test_luma_601_with_various_colors
    # Test Rec. 601 luma with various color values
    # Purple: RGB(0.5, 0.0, 0.5)
    purple = Abachrome::Color.from_rgb(0.5, 0.0, 0.5)
    expected_luma = 0.299 * 0.5 + 0.587 * 0.0 + 0.114 * 0.5
    assert_in_delta expected_luma, purple.luma_601.to_f, 0.001

    # Orange: RGB(1.0, 0.5, 0.0)
    orange = Abachrome::Color.from_rgb(1.0, 0.5, 0.0)
    expected_luma = 0.299 * 1.0 + 0.587 * 0.5 + 0.114 * 0.0
    assert_in_delta expected_luma, orange.luma_601.to_f, 0.001

    # Cyan: RGB(0, 1, 1)
    cyan = Abachrome::Color.from_rgb(0, 1, 1)
    expected_luma = 0.299 * 0.0 + 0.587 * 1.0 + 0.114 * 1.0
    assert_in_delta expected_luma, cyan.luma_601.to_f, 0.001
  end

  def test_luma_709_comparison
    # Verify that 709 uses different coefficients than 601
    red = Abachrome::Color.from_rgb(1, 0, 0)

    luma_601 = red.luma_601.to_f
    luma_709 = red.luma_709.to_f

    assert_in_delta 0.299, luma_601, 0.001
    assert_in_delta 0.2126, luma_709, 0.001
    refute_in_delta luma_601, luma_709, 0.01  # Should be different
  end

  def test_grayscale_601_preserves_brightness
    # Test that grayscale conversion maintains perceptual brightness
    colors = [
      Abachrome::Color.from_rgb(1, 0, 0),    # Red
      Abachrome::Color.from_rgb(0, 1, 0),    # Green
      Abachrome::Color.from_rgb(0, 0, 1),    # Blue
      Abachrome::Color.from_rgb(1, 1, 0),    # Yellow
      Abachrome::Color.from_rgb(1, 0, 1),    # Magenta
      Abachrome::Color.from_rgb(0, 1, 1)     # Cyan
    ]

    colors.each do |color|
      gray = color.to_grayscale_601
      expected_luma = color.luma_601.to_f

      # All RGB components should be equal to the luma value
      assert_in_delta expected_luma, gray.coordinates[0].to_f, 0.001
      assert_in_delta expected_luma, gray.coordinates[1].to_f, 0.001
      assert_in_delta expected_luma, gray.coordinates[2].to_f, 0.001
    end
  end

  def test_yiq_roundtrip_with_multiple_colors
    # Test roundtrip with a variety of colors
    test_colors = [
      [0.2, 0.4, 0.6],
      [0.8, 0.1, 0.3],
      [0.0, 0.0, 0.0],
      [1.0, 1.0, 1.0],
      [0.5, 0.5, 0.5]
    ]

    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    require_relative "../../lib/abachrome/converters/yiq_to_srgb"

    test_colors.each do |rgb_values|
      original = Abachrome::Color.from_rgb(*rgb_values)
      yiq = Abachrome::Converters::SrgbToYiq.convert(original)
      rgb = Abachrome::Converters::YiqToSrgb.convert(yiq)

      assert_in_delta rgb_values[0], rgb.coordinates[0].to_f, 0.001
      assert_in_delta rgb_values[1], rgb.coordinates[1].to_f, 0.001
      assert_in_delta rgb_values[2], rgb.coordinates[2].to_f, 0.001
    end
  end

  def test_yiq_alpha_roundtrip
    # Test that alpha is preserved through YIQ conversion
    require_relative "../../lib/abachrome/converters/srgb_to_yiq"
    require_relative "../../lib/abachrome/converters/yiq_to_srgb"

    original = Abachrome::Color.from_rgb(0.5, 0.3, 0.7, 0.6)
    yiq = Abachrome::Converters::SrgbToYiq.convert(original)
    rgb = Abachrome::Converters::YiqToSrgb.convert(yiq)

    assert_in_delta 0.6, yiq.alpha.to_f, 0.0001
    assert_in_delta 0.6, rgb.alpha.to_f, 0.0001
  end

  def test_luma_default_is_601
    # Verify that default luma uses 601
    color = Abachrome::Color.from_rgb(1, 0, 0)
    assert_in_delta color.luma_601.to_f, color.luma.to_f, 0.0001
  end

  def test_to_grayscale_default_is_601
    # Verify that default to_grayscale uses 601
    color = Abachrome::Color.from_rgb(1, 0, 0)
    gray_default = color.to_grayscale
    gray_601 = color.to_grayscale_601

    assert_in_delta gray_601.coordinates[0].to_f, gray_default.coordinates[0].to_f, 0.0001
    assert_in_delta gray_601.coordinates[1].to_f, gray_default.coordinates[1].to_f, 0.0001
    assert_in_delta gray_601.coordinates[2].to_f, gray_default.coordinates[2].to_f, 0.0001
  end
end
