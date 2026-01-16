require "test_helper"
require "abachrome"

module Abachrome
  class TestSpectralMix < Minitest::Test
    def test_spectral_mix_red_and_blue
      red = Abachrome.from_rgb(1, 0, 0)
      blue = Abachrome.from_rgb(0, 0, 1)

      # Mix with equal weights using module function
      purple = Abachrome.spectral_mix([
        { color: red, weight: 1 },
        { color: blue, weight: 1 }
      ])

      assert_instance_of Abachrome::Color, purple
      assert_equal :srgb, purple.color_space.name

      # The result should be different from simple RGB average
      # RGB average would give [0.5, 0, 0.5]
      # Spectral mixing should produce a more realistic purple
      coords = purple.coordinates.map(&:to_f)
      refute_in_delta 0.5, coords[0], 0.1, "Red component should differ from RGB average"
    end

    def test_spectral_mix_using_color_method
      red = Abachrome.from_rgb(1, 0, 0)
      blue = Abachrome.from_rgb(0, 0, 1)

      # Mix using Color#spectral_mix method
      purple = red.spectral_mix(blue, 0.5)

      assert_instance_of Abachrome::Color, purple
      assert_equal :srgb, purple.color_space.name
    end

    def test_spectral_mix_different_amounts
      red = Abachrome.from_rgb(1, 0, 0)
      blue = Abachrome.from_rgb(0, 0, 1)

      # More red (amount closer to 0 means more of the first color)
      mostly_red = red.spectral_mix(blue, 0.25)
      # More blue (amount closer to 1 means more of the second color)
      mostly_blue = red.spectral_mix(blue, 0.75)

      red_coords = mostly_red.coordinates.map(&:to_f)
      blue_coords = mostly_blue.coordinates.map(&:to_f)

      # Mostly red should have more red component
      assert_operator red_coords[0], :>, blue_coords[0],
                      "Mostly red should have higher red component"
    end

    def test_spectral_mix_yellow_and_blue
      # This is a classic test case for spectral mixing
      # RGB mixing of yellow and blue gives gray/green
      # Spectral mixing should give a more natural green
      yellow = Abachrome.from_rgb(1, 1, 0)
      blue = Abachrome.from_rgb(0, 0, 1)

      green = yellow.spectral_mix(blue, 0.5)

      coords = green.coordinates.map(&:to_f)

      # Should produce a greenish color
      # Green component should be relatively high
      assert_operator coords[1], :>, 0.2, "Should have significant green component"
    end

    def test_spectral_mix_with_tinting_strengths
      red = Abachrome.from_rgb(1, 0, 0)
      blue = Abachrome.from_rgb(0, 0, 1)

      # Mix with stronger blue pigment
      result = red.spectral_mix(blue, 0.5,
                                tinting_strength_self: 1.0,
                                tinting_strength_other: 2.0)

      assert_instance_of Abachrome::Color, result
    end

    def test_spectral_mix_three_colors
      red = Abachrome.from_rgb(1, 0, 0)
      green = Abachrome.from_rgb(0, 1, 0)
      blue = Abachrome.from_rgb(0, 0, 1)

      mixed = Abachrome.spectral_mix([
        { color: red, weight: 1 },
        { color: green, weight: 1 },
        { color: blue, weight: 1 }
      ])

      assert_instance_of Abachrome::Color, mixed
      assert_equal :srgb, mixed.color_space.name
    end

    def test_spectral_mix_white_and_black
      white = Abachrome.from_rgb(1, 1, 1)
      black = Abachrome.from_rgb(0, 0, 0)

      gray = white.spectral_mix(black, 0.5)

      coords = gray.coordinates.map(&:to_f)

      # All components should be roughly equal (grayscale)
      assert_in_delta coords[0], coords[1], 0.1, "Should be grayish"
      assert_in_delta coords[1], coords[2], 0.1, "Should be grayish"
    end

    def test_spectral_module_functions
      # Test the internal functions
      red = Abachrome.from_rgb(1, 0, 0)
      lrgb_color = red.to_color_space(:lrgb)
      lrgb = lrgb_color.coordinates.map(&:to_f)

      # Test lrgb_to_reflectance
      reflectance = Spectral.lrgb_to_reflectance(lrgb)
      assert_equal Spectral::SIZE, reflectance.size
      assert reflectance.all? { |r| r >= 0 && r <= 1.1 },
             "Reflectance values should be in valid range"

      # Test reflectance_to_xyz
      xyz = Spectral.reflectance_to_xyz(reflectance)
      assert_equal 3, xyz.size

      # Test xyz_to_lrgb
      lrgb_back = Spectral.xyz_to_lrgb(xyz)
      assert_equal 3, lrgb_back.size
    end

    def test_spectral_mix_preserves_extremes
      # Mixing a color with itself should return approximately the same color
      red = Abachrome.from_rgb(1, 0, 0)

      same_red = red.spectral_mix(red, 0.5)

      red_coords = red.to_color_space(:srgb).coordinates.map(&:to_f)
      same_coords = same_red.coordinates.map(&:to_f)

      assert_in_delta red_coords[0], same_coords[0], 0.05,
                      "Red component should be preserved"
      assert_in_delta red_coords[1], same_coords[1], 0.05,
                      "Green component should be preserved"
      assert_in_delta red_coords[2], same_coords[2], 0.05,
                      "Blue component should be preserved"
    end

    def test_ks_and_reflectance_conversion
      # Test Kubelka-Munk conversion functions
      r = 0.5
      ks = Spectral.ks_from_reflectance(r)
      r_back = Spectral.reflectance_from_ks(ks)

      assert_in_delta r, r_back, 0.0001,
                      "Reflectance should round-trip through KS conversion"
    end
  end
end
