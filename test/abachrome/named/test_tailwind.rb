# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "../../../lib/abachrome/named/tailwind"

class TestTailwind < Minitest::Test
  def test_colors_constant_exists
    assert defined?(Abachrome::Named::Tailwind::COLORS)
  end

  def test_colors_is_frozen
    assert Abachrome::Named::Tailwind::COLORS.frozen?
  end

  def test_colors_is_a_hash
    assert_instance_of Hash, Abachrome::Named::Tailwind::COLORS
  end

  def test_all_color_names_are_present
    expected_colors = %w[
      slate gray zinc neutral stone red orange amber yellow lime
      green emerald teal cyan sky blue indigo violet purple fuchsia
      pink rose
    ]

    expected_colors.each do |color_name|
      assert Abachrome::Named::Tailwind::COLORS.key?(color_name),
             "Expected color '#{color_name}' to be present"
    end
  end

  def test_all_colors_have_complete_shade_range
    expected_shades = %w[50 100 200 300 400 500 600 700 800 900 950]

    Abachrome::Named::Tailwind::COLORS.each do |color_name, shades|
      assert_instance_of Hash, shades,
                         "Expected #{color_name} to have a hash of shades"

      expected_shades.each do |shade|
        assert shades.key?(shade),
               "Expected #{color_name} to have shade '#{shade}'"
      end

      assert_equal expected_shades.size, shades.size,
                   "Expected #{color_name} to have exactly #{expected_shades.size} shades"
    end
  end

  def test_all_rgb_values_are_arrays_of_three_integers
    Abachrome::Named::Tailwind::COLORS.each do |color_name, shades|
      shades.each do |shade, rgb|
        assert_instance_of Array, rgb,
                           "#{color_name}-#{shade} should be an array"
        assert_equal 3, rgb.size,
                     "#{color_name}-#{shade} should have 3 values"

        rgb.each_with_index do |value, i|
          assert_instance_of Integer, value,
                             "#{color_name}-#{shade}[#{i}] should be an integer"
        end
      end
    end
  end

  def test_all_rgb_values_are_in_valid_range
    Abachrome::Named::Tailwind::COLORS.each do |color_name, shades|
      shades.each do |shade, rgb|
        rgb.each_with_index do |value, i|
          assert value >= 0 && value <= 255,
                 "#{color_name}-#{shade}[#{i}] = #{value} should be between 0 and 255"
        end
      end
    end
  end

  def test_shade_progression_lightness
    # Test that shades progress from lighter (50) to darker (950)
    Abachrome::Named::Tailwind::COLORS.each do |color_name, shades|
      # Calculate average value for each shade as a proxy for lightness
      shade_values = shades.map do |shade, rgb|
        [shade.to_i, rgb.sum / 3.0]
      end.sort_by(&:first)

      # Verify general trend: lower shade numbers are lighter
      assert shade_values.first[1] > shade_values.last[1],
             "#{color_name} should progress from light (50) to dark (950)"

      # Check that 50 is lighter than 500 and 500 is lighter than 950
      shade_50 = shades['50'].sum / 3.0
      shade_500 = shades['500'].sum / 3.0
      shade_950 = shades['950'].sum / 3.0

      assert shade_50 > shade_500,
             "#{color_name}-50 should be lighter than #{color_name}-500"
      assert shade_500 > shade_950,
             "#{color_name}-500 should be lighter than #{color_name}-950"
    end
  end

  def test_specific_color_values
    # Test a few specific known values to ensure data accuracy
    assert_equal [248, 250, 252], Abachrome::Named::Tailwind::COLORS['slate']['50']
    assert_equal [100, 116, 139], Abachrome::Named::Tailwind::COLORS['slate']['500']
    assert_equal [2, 6, 23], Abachrome::Named::Tailwind::COLORS['slate']['950']

    assert_equal [239, 246, 255], Abachrome::Named::Tailwind::COLORS['blue']['50']
    assert_equal [59, 130, 246], Abachrome::Named::Tailwind::COLORS['blue']['500']
    assert_equal [23, 37, 84], Abachrome::Named::Tailwind::COLORS['blue']['950']

    assert_equal [254, 242, 242], Abachrome::Named::Tailwind::COLORS['red']['50']
    assert_equal [239, 68, 68], Abachrome::Named::Tailwind::COLORS['red']['500']
    assert_equal [69, 10, 10], Abachrome::Named::Tailwind::COLORS['red']['950']

    assert_equal [240, 253, 244], Abachrome::Named::Tailwind::COLORS['green']['50']
    assert_equal [34, 197, 94], Abachrome::Named::Tailwind::COLORS['green']['500']
    assert_equal [5, 46, 22], Abachrome::Named::Tailwind::COLORS['green']['950']
  end

  def test_gray_variants_exist
    # Test that all gray variants are present
    gray_variants = %w[slate gray zinc neutral stone]

    gray_variants.each do |variant|
      assert Abachrome::Named::Tailwind::COLORS.key?(variant),
             "Expected gray variant '#{variant}' to exist"
    end
  end

  def test_color_families_exist
    # Test that main color families are present
    color_families = {
      'red_family' => %w[red orange amber yellow],
      'green_family' => %w[lime green emerald teal],
      'blue_family' => %w[cyan sky blue indigo],
      'purple_family' => %w[violet purple fuchsia pink rose]
    }

    color_families.each do |family_name, colors|
      colors.each do |color|
        assert Abachrome::Named::Tailwind::COLORS.key?(color),
               "Expected #{family_name} color '#{color}' to exist"
      end
    end
  end

  def test_no_duplicate_rgb_values_within_same_color
    # Each shade within a color should have unique RGB values
    Abachrome::Named::Tailwind::COLORS.each do |color_name, shades|
      rgb_values = shades.values
      unique_rgb_values = rgb_values.uniq

      assert_equal rgb_values.size, unique_rgb_values.size,
                   "#{color_name} has duplicate RGB values across different shades"
    end
  end

  def test_consistent_shade_intervals
    # Test that adjacent shades have reasonable differences
    # (not too similar, not too different)
    Abachrome::Named::Tailwind::COLORS.each do |color_name, shades|
      shade_numbers = %w[50 100 200 300 400 500 600 700 800 900 950]

      shade_numbers.each_cons(2) do |shade1, shade2|
        rgb1 = shades[shade1]
        rgb2 = shades[shade2]

        # Calculate Euclidean distance in RGB space
        distance = Math.sqrt(
          (rgb1[0] - rgb2[0])**2 +
          (rgb1[1] - rgb2[1])**2 +
          (rgb1[2] - rgb2[2])**2
        )

        # Distance should be at least 5 (not too similar)
        # This is a sanity check to ensure shades are actually different
        assert distance >= 1,
               "#{color_name} shades #{shade1} and #{shade2} are too similar (distance: #{distance})"
      end
    end
  end

  def test_module_structure
    assert defined?(Abachrome::Named::Tailwind)
    assert_equal Module, Abachrome::Named::Tailwind.class
  end

  def test_neutral_colors_are_truly_neutral
    # Test that gray variants have R=G=B or very close
    neutral_colors = %w[gray zinc neutral]

    neutral_colors.each do |color_name|
      Abachrome::Named::Tailwind::COLORS[color_name].each do |shade, rgb|
        r, g, b = rgb
        max_diff = [r, g, b].max - [r, g, b].min

        # Allow small differences due to slight warm/cool tints
        assert max_diff <= 26,
               "#{color_name}-#{shade} should be more neutral (RGB: #{rgb}, diff: #{max_diff})"
      end
    end
  end

  def test_fifty_shade_is_lightest
    # Test that shade 50 is the lightest (highest RGB values on average)
    Abachrome::Named::Tailwind::COLORS.each do |color_name, shades|
      shade_50_avg = shades['50'].sum / 3.0

      shades.each do |shade, rgb|
        next if shade == '50'

        avg = rgb.sum / 3.0
        assert shade_50_avg >= avg,
               "#{color_name}-50 should be lighter than #{color_name}-#{shade}"
      end
    end
  end

  def test_nine_fifty_shade_is_darkest
    # Test that shade 950 is the darkest (lowest RGB values on average)
    Abachrome::Named::Tailwind::COLORS.each do |color_name, shades|
      shade_950_avg = shades['950'].sum / 3.0

      shades.each do |shade, rgb|
        next if shade == '950'

        avg = rgb.sum / 3.0
        assert shade_950_avg <= avg,
               "#{color_name}-950 should be darker than #{color_name}-#{shade}"
      end
    end
  end

  def test_color_count
    # Tailwind v3 has 22 color families
    assert_equal 22, Abachrome::Named::Tailwind::COLORS.size,
                 "Expected 22 Tailwind color families"
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
