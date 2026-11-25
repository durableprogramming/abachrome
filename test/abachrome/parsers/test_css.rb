# frozen_string_literal: true

require_relative "../../test_helper"

class TestParsersCss < Minitest::Test
  def parse(css)
    Abachrome.parse(css)
  end

  def srgb(css)
    Abachrome::Converter.convert(parse(css), :srgb).coordinates
  end

  def test_named_and_hex_colors
    assert_coordinates_equal [1, 0, 0], srgb("red")
    assert_coordinates_equal [1, 0, 0], srgb("#ff0000")
    assert_coordinates_equal [0, 0, 1], srgb("#0000ff")
  end

  def test_rgb_functions
    assert_coordinates_equal [1, 0, 0], srgb("rgb(1, 0, 0)")
    assert_in_delta 0.5, parse("rgba(1, 0, 0, 0.5)").alpha, 0.001
  end

  def test_hsl_parses_into_the_hsl_color_space
    assert_equal :hsl, parse("hsl(120deg, 100%, 50%)").color_space.name
    assert_coordinates_equal [0, 1, 0], srgb("hsl(120deg, 100%, 50%)")
    assert_coordinates_equal [0.25, 0.25, 0.75], srgb("hsla(240deg, 50%, 50%, 0.5)")
  end

  def test_hwb_parses_into_the_hwb_color_space
    assert_equal :hwb, parse("hwb(0deg, 0%, 0%)").color_space.name
    assert_coordinates_equal [1, 0, 0], srgb("hwb(0deg, 0%, 0%)")
    assert_coordinates_equal [1, 0.5, 0.5], srgb("hwb(0deg, 50%, 0%)")
  end

  def test_lab_and_lch_parse_into_their_own_color_spaces
    assert_equal :lab, parse("lab(50 20 30)").color_space.name
    assert_equal :lch, parse("lch(50 30 120)").color_space.name
    assert_coordinates_equal [1, 0, 0], srgb("lab(53.2408 80.0925 67.2032)"), 0.01
    assert_coordinates_equal [1, 0, 0], srgb("lch(53.2408 104.5518 39.999)"), 0.01
  end

  def test_lab_lightness_percentage_is_on_a_0_to_100_scale
    # CSS says lab(50% ...) means L*=50, not L*=0.5.
    assert_in_delta 50, parse("lab(50% 20 30)").coordinates[0], 0.001
    assert_coordinates_equal srgb("lab(50 20 30)"), srgb("lab(50% 20 30)")
    assert_in_delta 50, parse("lch(50% 30 120)").coordinates[0], 0.001
    assert_coordinates_equal srgb("lch(50 30 120)"), srgb("lch(50% 30 120)")
    assert_coordinates_equal [1, 1, 1], srgb("lab(100% 0 0)")
  end

  def test_alpha_survives_conversion_out_of_the_parsed_space
    assert_in_delta 0.5, Abachrome::Converter.convert(parse("hsla(240deg, 50%, 50%, 0.5)"), :srgb).alpha, 0.001
  end

  def test_oklab_and_oklch
    assert_equal :oklab, parse("oklab(0.628 0.2249 0.1258)").color_space.name
    assert_equal :oklch, parse("oklch(0.628 0.2577 29.23)").color_space.name
  end

  def test_color_function
    assert_coordinates_equal [1, 0, 0], srgb("color(srgb 1, 0, 0)")
    assert_equal :lrgb, parse("color(srgb-linear 1, 0, 0)").color_space.name
  end

  def test_invalid_input_returns_nil
    assert_nil parse("not-a-color")
    assert_nil parse("rgb(1, 0)")
    assert_nil parse(nil)
  end
end
