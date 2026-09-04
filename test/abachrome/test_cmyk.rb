# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/abachrome"

class TestCMYK < Minitest::Test
  def setup
    @cmyk_space = Abachrome::ColorSpace.find(:cmyk)
  end

  def test_cmyk_color_space_exists
    refute_nil @cmyk_space
    assert_equal :cmyk, @cmyk_space.name
    assert_equal %i[cyan magenta yellow key], @cmyk_space.coordinates
  end

  def test_from_cmyk
    color = Abachrome::Color.from_cmyk(0.5, 0.3, 0.7, 0.1)
    assert_equal :cmyk, color.color_space.name
    assert_in_delta 0.5, color.coordinates[0].to_f, 0.0001
    assert_in_delta 0.3, color.coordinates[1].to_f, 0.0001
    assert_in_delta 0.7, color.coordinates[2].to_f, 0.0001
    assert_in_delta 0.1, color.coordinates[3].to_f, 0.0001
  end

  def test_rgb_to_cmyk_white
    # White: RGB(1, 1, 1) should give CMYK(0, 0, 0, 0)
    white = Abachrome::Color.from_rgb(1, 1, 1)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(white)

    assert_in_delta 0.0, cmyk.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[2].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[3].to_f, 0.0001
  end

  def test_rgb_to_cmyk_black
    # Black: RGB(0, 0, 0) should give CMYK(0, 0, 0, 1) with GCR
    black = Abachrome::Color.from_rgb(0, 0, 0)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(black)

    assert_in_delta 0.0, cmyk.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[2].to_f, 0.0001
    assert_in_delta 1.0, cmyk.coordinates[3].to_f, 0.0001
  end

  def test_rgb_to_cmyk_red_with_gcr
    # Red: RGB(1, 0, 0)
    # Naive CMY: C=0, M=1, Y=1
    # With GCR: min(C,M,Y) = 0, so K=0
    # Result: CMYK(0, 1, 1, 0)
    red = Abachrome::Color.from_rgb(1, 0, 0)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(red)

    assert_in_delta 0.0, cmyk.coordinates[0].to_f, 0.0001
    assert_in_delta 1.0, cmyk.coordinates[1].to_f, 0.0001
    assert_in_delta 1.0, cmyk.coordinates[2].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[3].to_f, 0.0001
  end

  def test_rgb_to_cmyk_gray_with_gcr
    # Gray: RGB(0.5, 0.5, 0.5)
    # Naive CMY: C=0.5, M=0.5, Y=0.5
    # With GCR: min(C,M,Y) = 0.5, so K=0.5
    # Result: CMYK(0, 0, 0, 0.5)
    gray = Abachrome::Color.from_rgb(0.5, 0.5, 0.5)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(gray)

    assert_in_delta 0.0, cmyk.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[2].to_f, 0.0001
    assert_in_delta 0.5, cmyk.coordinates[3].to_f, 0.0001
  end

  def test_rgb_to_cmyk_with_partial_gcr
    # Test with 50% GCR
    gray = Abachrome::Color.from_rgb(0.5, 0.5, 0.5)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(gray, gcr_amount: 0.5)

    # With 50% GCR: K = 0.5 * 0.5 = 0.25
    # CMY = 0.5 - 0.25 = 0.25 each
    assert_in_delta 0.25, cmyk.coordinates[0].to_f, 0.0001
    assert_in_delta 0.25, cmyk.coordinates[1].to_f, 0.0001
    assert_in_delta 0.25, cmyk.coordinates[2].to_f, 0.0001
    assert_in_delta 0.25, cmyk.coordinates[3].to_f, 0.0001
  end

  def test_cmyk_to_rgb_white
    # CMYK(0, 0, 0, 0) should give RGB(1, 1, 1)
    white = Abachrome::Color.from_cmyk(0, 0, 0, 0)
    require_relative "../../lib/abachrome/converters/cmyk_to_srgb"
    rgb = Abachrome::Converters::CmykToSrgb.convert(white)

    assert_in_delta 1.0, rgb.coordinates[0].to_f, 0.0001
    assert_in_delta 1.0, rgb.coordinates[1].to_f, 0.0001
    assert_in_delta 1.0, rgb.coordinates[2].to_f, 0.0001
  end

  def test_cmyk_to_rgb_black
    # CMYK(0, 0, 0, 1) should give RGB(0, 0, 0)
    black = Abachrome::Color.from_cmyk(0, 0, 0, 1)
    require_relative "../../lib/abachrome/converters/cmyk_to_srgb"
    rgb = Abachrome::Converters::CmykToSrgb.convert(black)

    assert_in_delta 0.0, rgb.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, rgb.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, rgb.coordinates[2].to_f, 0.0001
  end

  def test_cmyk_roundtrip
    # Test that RGB -> CMYK (with GCR) -> RGB preserves the general color
    # Note: GCR may change representation but preserves visual appearance
    original = Abachrome::Color.from_rgb(1.0, 0.5, 0.0)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    require_relative "../../lib/abachrome/converters/cmyk_to_srgb"

    cmyk = Abachrome::Converters::SrgbToCmyk.convert(original)
    rgb = Abachrome::Converters::CmykToSrgb.convert(cmyk)

    # Orange color should roundtrip accurately
    assert_in_delta 1.0, rgb.coordinates[0].to_f, 0.0001
    assert_in_delta 0.5, rgb.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, rgb.coordinates[2].to_f, 0.0001
  end

  def test_total_area_coverage
    # Test TAC calculation
    require_relative "../../lib/abachrome/color_models/cmyk"
    tac = Abachrome::ColorModels::CMYK.total_area_coverage(0.5, 0.3, 0.7, 0.1)
    assert_in_delta 1.6, tac.to_f, 0.0001
  end

  def test_cmyk_alpha_preservation
    color = Abachrome::Color.from_cmyk(0.5, 0.3, 0.7, 0.1, 0.8)
    assert_in_delta 0.8, color.alpha.to_f, 0.0001

    require_relative "../../lib/abachrome/converters/cmyk_to_srgb"
    rgb = Abachrome::Converters::CmykToSrgb.convert(color)
    assert_in_delta 0.8, rgb.alpha.to_f, 0.0001
  end

  def test_rgb_to_cmyk_naive
    # Test naive conversion (no GCR)
    # RGB(0.5, 0.5, 0.5) -> naive CMYK(0.5, 0.5, 0.5, 0)
    gray = Abachrome::Color.from_rgb(0.5, 0.5, 0.5)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    cmyk = Abachrome::Converters::SrgbToCmyk.convert_naive(gray)

    assert_in_delta 0.5, cmyk.coordinates[0].to_f, 0.0001
    assert_in_delta 0.5, cmyk.coordinates[1].to_f, 0.0001
    assert_in_delta 0.5, cmyk.coordinates[2].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[3].to_f, 0.0001
  end

  def test_cmyk_color_model_normalize
    # Test normalization of CMYK values
    require_relative "../../lib/abachrome/color_models/cmyk"
    c, m, y, k = Abachrome::ColorModels::CMYK.normalize(50, 30, 70, 10)

    # Values > 1 should be treated as percentages
    assert_in_delta 0.5, c.to_f, 0.0001
    assert_in_delta 0.3, m.to_f, 0.0001
    assert_in_delta 0.7, y.to_f, 0.0001
    assert_in_delta 0.1, k.to_f, 0.0001
  end

  def test_rgb_to_cmyk_cyan_primary
    # Cyan: RGB(0, 1, 1)
    # Naive CMY: C=1, M=0, Y=0
    # With GCR: min(C,M,Y) = 0, so K=0
    # Result: CMYK(1, 0, 0, 0)
    cyan = Abachrome::Color.from_rgb(0, 1, 1)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(cyan)

    assert_in_delta 1.0, cmyk.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[2].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[3].to_f, 0.0001
  end

  def test_rgb_to_cmyk_magenta_primary
    # Magenta: RGB(1, 0, 1)
    # Naive CMY: C=0, M=1, Y=0
    # With GCR: min(C,M,Y) = 0, so K=0
    # Result: CMYK(0, 1, 0, 0)
    magenta = Abachrome::Color.from_rgb(1, 0, 1)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(magenta)

    assert_in_delta 0.0, cmyk.coordinates[0].to_f, 0.0001
    assert_in_delta 1.0, cmyk.coordinates[1].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[2].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[3].to_f, 0.0001
  end

  def test_rgb_to_cmyk_yellow_primary
    # Yellow: RGB(1, 1, 0)
    # Naive CMY: C=0, M=0, Y=1
    # With GCR: min(C,M,Y) = 0, so K=0
    # Result: CMYK(0, 0, 1, 0)
    yellow = Abachrome::Color.from_rgb(1, 1, 0)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(yellow)

    assert_in_delta 0.0, cmyk.coordinates[0].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[1].to_f, 0.0001
    assert_in_delta 1.0, cmyk.coordinates[2].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[3].to_f, 0.0001
  end

  def test_rgb_to_cmyk_with_zero_gcr
    # Test with 0% GCR (no black separation, pure CMY)
    gray = Abachrome::Color.from_rgb(0.5, 0.5, 0.5)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(gray, gcr_amount: 0)

    # With 0% GCR: K = 0, CMY = 0.5 each (naive conversion)
    assert_in_delta 0.5, cmyk.coordinates[0].to_f, 0.0001
    assert_in_delta 0.5, cmyk.coordinates[1].to_f, 0.0001
    assert_in_delta 0.5, cmyk.coordinates[2].to_f, 0.0001
    assert_in_delta 0.0, cmyk.coordinates[3].to_f, 0.0001
  end

  def test_rgb_to_cmyk_with_75_percent_gcr
    # Test with 75% GCR
    gray = Abachrome::Color.from_rgb(0.4, 0.4, 0.4)
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(gray, gcr_amount: 0.75)

    # Naive CMY: 0.6, 0.6, 0.6
    # Min: 0.6
    # With 75% GCR: K = 0.6 * 0.75 = 0.45
    # CMY = 0.6 - 0.45 = 0.15 each
    assert_in_delta 0.15, cmyk.coordinates[0].to_f, 0.0001
    assert_in_delta 0.15, cmyk.coordinates[1].to_f, 0.0001
    assert_in_delta 0.15, cmyk.coordinates[2].to_f, 0.0001
    assert_in_delta 0.45, cmyk.coordinates[3].to_f, 0.0001
  end

  def test_ucr_vs_gcr_equivalence
    # Verify that UCR and GCR with same amount produce same results
    require_relative "../../lib/abachrome/color_models/cmyk"

    r = 0.3
    g = 0.5
    b = 0.7
    gcr_amount = 0.6

    ucr_result = Abachrome::ColorModels::CMYK.from_rgb_ucr(r, g, b, gcr_amount)
    gcr_result = Abachrome::ColorModels::CMYK.from_rgb_gcr(r, g, b, gcr_amount)

    assert_in_delta ucr_result[0].to_f, gcr_result[0].to_f, 0.0001
    assert_in_delta ucr_result[1].to_f, gcr_result[1].to_f, 0.0001
    assert_in_delta ucr_result[2].to_f, gcr_result[2].to_f, 0.0001
    assert_in_delta ucr_result[3].to_f, gcr_result[3].to_f, 0.0001
  end

  def test_naive_vs_gcr_conversion
    # Verify that naive conversion is same as GCR with 0% amount
    require_relative "../../lib/abachrome/color_models/cmyk"

    r = 0.6
    g = 0.4
    b = 0.2

    naive_result = Abachrome::ColorModels::CMYK.from_rgb_naive(r, g, b)
    gcr_zero_result = Abachrome::ColorModels::CMYK.from_rgb_gcr(r, g, b, 0.0)

    assert_in_delta naive_result[0].to_f, gcr_zero_result[0].to_f, 0.0001
    assert_in_delta naive_result[1].to_f, gcr_zero_result[1].to_f, 0.0001
    assert_in_delta naive_result[2].to_f, gcr_zero_result[2].to_f, 0.0001
    assert_in_delta naive_result[3].to_f, gcr_zero_result[3].to_f, 0.0001
  end

  def test_tac_limits
    # Test TAC (Total Area Coverage) for various scenarios
    require_relative "../../lib/abachrome/color_models/cmyk"

    # Pure black should have TAC = 1.0
    tac_black = Abachrome::ColorModels::CMYK.total_area_coverage(0, 0, 0, 1)
    assert_in_delta 1.0, tac_black.to_f, 0.0001

    # Pure white should have TAC = 0.0
    tac_white = Abachrome::ColorModels::CMYK.total_area_coverage(0, 0, 0, 0)
    assert_in_delta 0.0, tac_white.to_f, 0.0001

    # Maximum TAC (all channels at 100%) = 4.0
    tac_max = Abachrome::ColorModels::CMYK.total_area_coverage(1, 1, 1, 1)
    assert_in_delta 4.0, tac_max.to_f, 0.0001

    # Typical print limit is around 300% (3.0), test a value near that
    tac_print = Abachrome::ColorModels::CMYK.total_area_coverage(0.8, 0.8, 0.8, 0.6)
    assert_in_delta 3.0, tac_print.to_f, 0.0001
  end

  def test_gcr_reduces_tac
    # Verify that GCR reduces total ink coverage compared to naive
    require_relative "../../lib/abachrome/color_models/cmyk"

    r = 0.5
    g = 0.5
    b = 0.5

    naive = Abachrome::ColorModels::CMYK.from_rgb_naive(r, g, b)
    gcr_full = Abachrome::ColorModels::CMYK.from_rgb_gcr(r, g, b, 1.0)

    tac_naive = Abachrome::ColorModels::CMYK.total_area_coverage(*naive)
    tac_gcr = Abachrome::ColorModels::CMYK.total_area_coverage(*gcr_full)

    # GCR should result in lower or equal TAC
    assert tac_gcr.to_f <= tac_naive.to_f
  end

  def test_cmyk_roundtrip_with_various_colors
    # Test that various colors roundtrip accurately through CMYK using naive conversion
    test_colors = [
      [0.2, 0.4, 0.6],
      [0.8, 0.1, 0.3],
      [0.0, 0.5, 1.0],
      [0.9, 0.9, 0.1]
    ]

    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    require_relative "../../lib/abachrome/converters/cmyk_to_srgb"

    test_colors.each do |rgb_values|
      original = Abachrome::Color.from_rgb(*rgb_values)
      # Use naive conversion (GCR=0) for perfect roundtrip
      cmyk = Abachrome::Converters::SrgbToCmyk.convert(original, gcr_amount: 0.0)
      rgb = Abachrome::Converters::CmykToSrgb.convert(cmyk)

      # Naive conversion should roundtrip exactly
      assert_in_delta rgb_values[0], rgb.coordinates[0].to_f, 0.0001
      assert_in_delta rgb_values[1], rgb.coordinates[1].to_f, 0.0001
      assert_in_delta rgb_values[2], rgb.coordinates[2].to_f, 0.0001
    end
  end

  def test_cmyk_roundtrip_with_different_gcr
    # Test roundtrip with different GCR amounts
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"
    require_relative "../../lib/abachrome/converters/cmyk_to_srgb"

    # Test with GCR amounts 0.0 and 1.0 which are mathematically exact
    original = Abachrome::Color.from_rgb(0.5, 0.5, 0.5)

    # Test with no GCR (naive)
    cmyk_0 = Abachrome::Converters::SrgbToCmyk.convert(original, gcr_amount: 0.0)
    rgb_0 = Abachrome::Converters::CmykToSrgb.convert(cmyk_0)
    assert_in_delta 0.5, rgb_0.coordinates[0].to_f, 0.0001
    assert_in_delta 0.5, rgb_0.coordinates[1].to_f, 0.0001
    assert_in_delta 0.5, rgb_0.coordinates[2].to_f, 0.0001

    # Test with full GCR
    cmyk_1 = Abachrome::Converters::SrgbToCmyk.convert(original, gcr_amount: 1.0)
    rgb_1 = Abachrome::Converters::CmykToSrgb.convert(cmyk_1)
    assert_in_delta 0.5, rgb_1.coordinates[0].to_f, 0.0001
    assert_in_delta 0.5, rgb_1.coordinates[1].to_f, 0.0001
    assert_in_delta 0.5, rgb_1.coordinates[2].to_f, 0.0001
  end

  def test_cmyk_normalization_with_percentages
    # Test normalization of percentage values
    require_relative "../../lib/abachrome/color_models/cmyk"

    # Test with strings ending in %
    c, m, y, k = Abachrome::ColorModels::CMYK.normalize("50%", "25%", "75%", "10%")
    assert_in_delta 0.5, c.to_f, 0.0001
    assert_in_delta 0.25, m.to_f, 0.0001
    assert_in_delta 0.75, y.to_f, 0.0001
    assert_in_delta 0.1, k.to_f, 0.0001

    # Test with numeric values in 0-1 range
    c, m, y, k = Abachrome::ColorModels::CMYK.normalize(0.5, 0.25, 0.75, 0.1)
    assert_in_delta 0.5, c.to_f, 0.0001
    assert_in_delta 0.25, m.to_f, 0.0001
    assert_in_delta 0.75, y.to_f, 0.0001
    assert_in_delta 0.1, k.to_f, 0.0001
  end

  def test_cmyk_edge_case_all_equal_rgb
    # When RGB values are all equal, GCR should maximize K and minimize CMY
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"

    equal_rgb_colors = [
      [0.0, 0.0, 0.0],
      [0.25, 0.25, 0.25],
      [0.5, 0.5, 0.5],
      [0.75, 0.75, 0.75],
      [1.0, 1.0, 1.0]
    ]

    equal_rgb_colors.each do |rgb_values|
      color = Abachrome::Color.from_rgb(*rgb_values)
      cmyk = Abachrome::Converters::SrgbToCmyk.convert(color)

      # With full GCR, gray colors should have C=M=Y=0
      assert_in_delta 0.0, cmyk.coordinates[0].to_f, 0.0001
      assert_in_delta 0.0, cmyk.coordinates[1].to_f, 0.0001
      assert_in_delta 0.0, cmyk.coordinates[2].to_f, 0.0001
    end
  end

  def test_cmyk_rich_black
    # Test "rich black" - using CMY with K for deeper blacks
    # RGB(0, 0, 0) with partial GCR should give some CMY + K
    require_relative "../../lib/abachrome/converters/srgb_to_cmyk"

    black = Abachrome::Color.from_rgb(0, 0, 0)

    # With 80% GCR
    cmyk = Abachrome::Converters::SrgbToCmyk.convert(black, gcr_amount: 0.8)

    # Should have K=0.8, CMY=0.2 each
    assert_in_delta 0.2, cmyk.coordinates[0].to_f, 0.0001
    assert_in_delta 0.2, cmyk.coordinates[1].to_f, 0.0001
    assert_in_delta 0.2, cmyk.coordinates[2].to_f, 0.0001
    assert_in_delta 0.8, cmyk.coordinates[3].to_f, 0.0001
  end

  def test_cmyk_from_rgb_direct_model_usage
    # Test calling ColorModels::CMYK methods directly
    require_relative "../../lib/abachrome/color_models/cmyk"

    r = 0.4
    g = 0.6
    b = 0.8

    # Test naive
    c, m, y, k = Abachrome::ColorModels::CMYK.from_rgb_naive(r, g, b)
    assert_in_delta 0.6, c.to_f, 0.0001
    assert_in_delta 0.4, m.to_f, 0.0001
    assert_in_delta 0.2, y.to_f, 0.0001
    assert_in_delta 0.0, k.to_f, 0.0001

    # Test UCR with full GCR
    c, m, y, k = Abachrome::ColorModels::CMYK.from_rgb_ucr(r, g, b, 1.0)
    assert_in_delta 0.4, c.to_f, 0.0001  # 0.6 - 0.2
    assert_in_delta 0.2, m.to_f, 0.0001  # 0.4 - 0.2
    assert_in_delta 0.0, y.to_f, 0.0001  # 0.2 - 0.2
    assert_in_delta 0.2, k.to_f, 0.0001  # min(0.6, 0.4, 0.2)
  end

  def test_cmyk_to_rgb_direct_model_usage
    # Test calling ColorModels::CMYK.to_rgb directly
    require_relative "../../lib/abachrome/color_models/cmyk"

    c = 0.2
    m = 0.4
    y = 0.6
    k = 0.1

    r, g, b = Abachrome::ColorModels::CMYK.to_rgb(c, m, y, k)

    # R = (1 - 0.2) * (1 - 0.1) = 0.8 * 0.9 = 0.72
    # G = (1 - 0.4) * (1 - 0.1) = 0.6 * 0.9 = 0.54
    # B = (1 - 0.6) * (1 - 0.1) = 0.4 * 0.9 = 0.36
    assert_in_delta 0.72, r.to_f, 0.0001
    assert_in_delta 0.54, g.to_f, 0.0001
    assert_in_delta 0.36, b.to_f, 0.0001
  end
end
