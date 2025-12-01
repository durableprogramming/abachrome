# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "../../../lib/abachrome/color_space"
require_relative "../../../lib/abachrome/color"
require_relative "../../../lib/abachrome/named/tailwind"
require_relative "../../../lib/abachrome/parsers/tailwind"

class TestTailwindParser < Minitest::Test
  def test_parse_basic_color
    color = Abachrome::Parsers::Tailwind.parse("blue-500")

    assert_instance_of Abachrome::Color, color
    assert_equal :srgb, color.color_space.name

    # blue-500 is [59, 130, 246]
    expected = [59 / 255.0, 130 / 255.0, 246 / 255.0]
    assert_coordinates_equal expected, color.coordinates.map(&:to_f), 0.001
    assert_equal 1.0, color.alpha.to_f
  end

  def test_parse_color_with_opacity
    color = Abachrome::Parsers::Tailwind.parse("blue-500/50")

    assert_instance_of Abachrome::Color, color
    assert_equal :srgb, color.color_space.name

    # blue-500 is [59, 130, 246] with 50% opacity
    expected = [59 / 255.0, 130 / 255.0, 246 / 255.0]
    assert_coordinates_equal expected, color.coordinates.map(&:to_f), 0.001
    assert_in_delta 0.5, color.alpha.to_f, 0.001
  end

  def test_parse_color_with_decimal_opacity
    color = Abachrome::Parsers::Tailwind.parse("red-500/75.5")

    assert_instance_of Abachrome::Color, color
    assert_in_delta 0.755, color.alpha.to_f, 0.001
  end

  def test_parse_color_with_zero_opacity
    color = Abachrome::Parsers::Tailwind.parse("green-500/0")

    assert_instance_of Abachrome::Color, color
    assert_equal 0.0, color.alpha.to_f
  end

  def test_parse_color_with_full_opacity
    color = Abachrome::Parsers::Tailwind.parse("green-500/100")

    assert_instance_of Abachrome::Color, color
    assert_equal 1.0, color.alpha.to_f
  end

  def test_parse_all_shades
    shades = %w[50 100 200 300 400 500 600 700 800 900 950]

    shades.each do |shade|
      color = Abachrome::Parsers::Tailwind.parse("blue-#{shade}")

      assert_instance_of Abachrome::Color, color,
                         "Failed to parse blue-#{shade}"

      expected_rgb = Abachrome::Named::Tailwind::COLORS['blue'][shade]
      expected = expected_rgb.map { |v| v / 255.0 }

      assert_coordinates_equal expected, color.coordinates.map(&:to_f), 0.001
    end
  end

  def test_parse_all_color_families
    color_names = %w[
      slate gray zinc neutral stone red orange amber yellow lime
      green emerald teal cyan sky blue indigo violet purple fuchsia
      pink rose
    ]

    color_names.each do |color_name|
      color = Abachrome::Parsers::Tailwind.parse("#{color_name}-500")

      assert_instance_of Abachrome::Color, color,
                         "Failed to parse #{color_name}-500"

      expected_rgb = Abachrome::Named::Tailwind::COLORS[color_name]['500']
      expected = expected_rgb.map { |v| v / 255.0 }

      assert_coordinates_equal expected, color.coordinates.map(&:to_f), 0.001
    end
  end

  def test_parse_returns_nil_for_invalid_format
    invalid_inputs = [
      "blue",           # missing shade
      "blue-",          # missing shade number
      "blue500",        # missing dash
      "blue-500-600",   # extra shade
      "blue_500",       # wrong separator
      "BLUE-500",       # uppercase (pattern requires lowercase)
      "blue-50/",       # opacity without value
      "blue-50//20",    # double slash
      "blue-50/abc",    # non-numeric opacity
      "",               # empty string
      "500",            # just a number
      "-500",           # just dash and number
      "blue-1000",      # invalid shade
      "blue-5",         # invalid shade
    ]

    invalid_inputs.each do |input|
      color = Abachrome::Parsers::Tailwind.parse(input)
      assert_nil color, "Expected nil for invalid input '#{input}'"
    end
  end

  def test_parse_returns_nil_for_nonexistent_color
    color = Abachrome::Parsers::Tailwind.parse("notacolor-500")
    assert_nil color
  end

  def test_parse_returns_nil_for_nonexistent_shade
    # Valid color but invalid shade
    color = Abachrome::Parsers::Tailwind.parse("blue-250")
    assert_nil color
  end

  def test_parse_specific_colors
    # Test specific known color values
    test_cases = [
      {
        input: "slate-500",
        expected_rgb: [100, 116, 139],
        expected_alpha: 1.0
      },
      {
        input: "red-600",
        expected_rgb: [220, 38, 38],
        expected_alpha: 1.0
      },
      {
        input: "green-400",
        expected_rgb: [74, 222, 128],
        expected_alpha: 1.0
      },
      {
        input: "blue-900",
        expected_rgb: [30, 58, 138],
        expected_alpha: 1.0
      },
      {
        input: "purple-300",
        expected_rgb: [216, 180, 254],
        expected_alpha: 1.0
      }
    ]

    test_cases.each do |test_case|
      color = Abachrome::Parsers::Tailwind.parse(test_case[:input])

      assert_instance_of Abachrome::Color, color

      expected = test_case[:expected_rgb].map { |v| v / 255.0 }
      assert_coordinates_equal expected, color.coordinates.map(&:to_f), 0.001
      assert_equal test_case[:expected_alpha], color.alpha.to_f
    end
  end

  def test_parse_with_various_opacities
    opacities = [0, 10, 25, 50, 75, 90, 100]

    opacities.each do |opacity|
      color = Abachrome::Parsers::Tailwind.parse("blue-500/#{opacity}")

      assert_instance_of Abachrome::Color, color
      assert_in_delta opacity / 100.0, color.alpha.to_f, 0.001,
                      "Opacity #{opacity} not correctly parsed"
    end
  end

  def test_parse_gray_variants
    gray_variants = %w[slate gray zinc neutral stone]

    gray_variants.each do |variant|
      color = Abachrome::Parsers::Tailwind.parse("#{variant}-500")

      assert_instance_of Abachrome::Color, color,
                         "Failed to parse #{variant}-500"
    end
  end

  def test_parse_extreme_shades
    # Test the lightest and darkest shades
    color_50 = Abachrome::Parsers::Tailwind.parse("blue-50")
    color_950 = Abachrome::Parsers::Tailwind.parse("blue-950")

    assert_instance_of Abachrome::Color, color_50
    assert_instance_of Abachrome::Color, color_950

    # Shade 50 should be lighter (higher values) than 950
    avg_50 = color_50.coordinates.sum(&:to_f) / 3.0
    avg_950 = color_950.coordinates.sum(&:to_f) / 3.0

    assert avg_50 > avg_950, "Shade 50 should be lighter than 950"
  end

  def test_parse_color_conversions
    color = Abachrome::Parsers::Tailwind.parse("blue-500")

    # Test that parsed color can be converted to other color spaces
    oklab_color = color.to_oklab
    assert_instance_of Abachrome::Color, oklab_color
    assert_equal :oklab, oklab_color.color_space.name

    oklch_color = color.to_oklch
    assert_instance_of Abachrome::Color, oklch_color
    assert_equal :oklch, oklch_color.color_space.name

    lrgb_color = color.to_lrgb
    assert_instance_of Abachrome::Color, lrgb_color
    assert_equal :lrgb, lrgb_color.color_space.name
  end

  def test_parse_color_to_hex
    color = Abachrome::Parsers::Tailwind.parse("blue-500")
    hex = color.rgb_hex

    assert_match(/^#[0-9a-f]{6}$/i, hex)

    # blue-500 is [59, 130, 246] which is #3b82f6
    assert_equal "#3b82f6", hex.downcase
  end

  def test_parse_color_to_rgb_array
    color = Abachrome::Parsers::Tailwind.parse("red-500")
    rgb_array = color.rgb_array

    # red-500 is [239, 68, 68]
    assert_equal [239, 68, 68], rgb_array
  end

  def test_parse_with_opacity_preserves_color
    color_without = Abachrome::Parsers::Tailwind.parse("green-500")
    color_with = Abachrome::Parsers::Tailwind.parse("green-500/50")

    # RGB values should be the same, only alpha differs
    assert_coordinates_equal(
      color_without.coordinates.map(&:to_f),
      color_with.coordinates.map(&:to_f),
      0.001
    )

    assert_equal 1.0, color_without.alpha.to_f
    assert_equal 0.5, color_with.alpha.to_f
  end

  def test_pattern_constant_exists
    assert defined?(Abachrome::Parsers::Tailwind::TAILWIND_PATTERN)
  end

  def test_pattern_matches_valid_inputs
    pattern = Abachrome::Parsers::Tailwind::TAILWIND_PATTERN

    valid_inputs = [
      "blue-500",
      "red-50",
      "green-950",
      "slate-400",
      "blue-500/20",
      "red-500/50.5",
      "green-500/0",
      "amber-500/100"
    ]

    valid_inputs.each do |input|
      assert input.match?(pattern), "Pattern should match '#{input}'"
    end
  end

  def test_pattern_rejects_invalid_inputs
    pattern = Abachrome::Parsers::Tailwind::TAILWIND_PATTERN

    invalid_inputs = [
      "Blue-500",      # uppercase
      "blue-500-600",  # extra component
      "blue_500",      # wrong separator
      "blue",          # missing shade
      "500",           # missing color
    ]

    invalid_inputs.each do |input|
      refute input.match?(pattern), "Pattern should not match '#{input}'"
    end
  end

  def test_parse_edge_case_opacities
    # Test edge cases for opacity parsing
    edge_cases = [
      ["blue-500/0.5", 0.005],    # 0.5% opacity
      ["blue-500/1", 0.01],        # 1% opacity
      ["blue-500/99", 0.99],       # 99% opacity
      ["blue-500/99.9", 0.999]     # 99.9% opacity
    ]

    edge_cases.each do |input, expected_alpha|
      color = Abachrome::Parsers::Tailwind.parse(input)
      assert_instance_of Abachrome::Color, color
      assert_in_delta expected_alpha, color.alpha.to_f, 0.001,
                      "Failed for input #{input}"
    end
  end

  def test_parse_all_combinations
    # Test a sampling of all color/shade combinations
    sample_colors = %w[slate red blue green purple]
    sample_shades = %w[50 300 500 700 950]

    sample_colors.each do |color_name|
      sample_shades.each do |shade|
        input = "#{color_name}-#{shade}"
        color = Abachrome::Parsers::Tailwind.parse(input)

        assert_instance_of Abachrome::Color, color,
                           "Failed to parse #{input}"

        expected_rgb = Abachrome::Named::Tailwind::COLORS[color_name][shade]
        expected = expected_rgb.map { |v| v / 255.0 }

        assert_coordinates_equal expected, color.coordinates.map(&:to_f), 0.001
      end
    end
  end

  def test_parse_returns_different_objects
    color1 = Abachrome::Parsers::Tailwind.parse("blue-500")
    color2 = Abachrome::Parsers::Tailwind.parse("blue-500")

    # Should be equal but not the same object
    assert_equal color1, color2
    refute_same color1, color2
  end

  def test_parse_consistency
    # Parsing the same input multiple times should yield equal results
    input = "purple-600/75"

    colors = 5.times.map { Abachrome::Parsers::Tailwind.parse(input) }

    colors.each_cons(2) do |c1, c2|
      assert_equal c1, c2
      assert_coordinates_equal(
        c1.coordinates.map(&:to_f),
        c2.coordinates.map(&:to_f),
        0.001
      )
      assert_equal c1.alpha.to_f, c2.alpha.to_f
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
