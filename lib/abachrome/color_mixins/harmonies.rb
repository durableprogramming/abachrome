# frozen_string_literal: true

# Abachrome::ColorMixins::Harmonies - Color Harmony Generation Module
#
# This module provides methods for generating color harmonies based on color theory.
# Color harmonies are sets of colors that work well together according to established
# design principles. The module uses OKLCH color space for hue manipulation, which
# provides perceptually uniform results.
#
# Key features:
# - Analogous harmony: Colors adjacent on the color wheel (±30°)
# - Complementary harmony: Colors opposite on the color wheel (180°)
# - Triadic harmony: Three colors evenly spaced around the color wheel (120° intervals)
# - Tetradic/Square harmony: Four colors evenly spaced (90° intervals)
# - Split-complementary harmony: Base color plus two colors adjacent to its complement (150°, 210°)
# - Option to generate harmonies in different color spaces (HSL or OKLCH)
#
# All harmonies preserve the lightness and chroma of the base color while rotating
# the hue to create harmonious color combinations.
#
# References:
# - Color Theory: https://en.wikipedia.org/wiki/Color_theory
# - Color Harmony: https://en.wikipedia.org/wiki/Harmony_(color)

module Abachrome
  module ColorMixins
    module Harmonies
      # Generates an analogous color harmony.
      # Analogous colors are adjacent to each other on the color wheel,
      # typically within ±30 degrees. This creates a harmonious, cohesive palette.
      #
      # @param angle [Numeric] The hue angle offset in degrees (default: 30)
      # @param space [Symbol] The color space to use for hue manipulation (:hsl or :oklch, default: :oklch)
      # @return [Array<Abachrome::Color>] An array of three colors: [color at -angle, original, color at +angle]
      def analogous(angle: 30, space: :oklch)
        original_space = color_space

        # Convert to the specified space for hue manipulation
        color_in_space = space == color_space.id ? self : to_color_space(space)
        l, c, h = color_in_space.coordinates

        # Generate analogous colors by rotating hue
        color_minus = create_harmony_color(l, c, h - angle, space)
        color_plus = create_harmony_color(l, c, h + angle, space)

        # Convert back to original color space
        [
          color_minus.to_color_space(original_space.id),
          self,
          color_plus.to_color_space(original_space.id)
        ]
      end

      # Generates a complementary color harmony.
      # Complementary colors are opposite each other on the color wheel (180° apart).
      # They create maximum contrast and vibrant combinations.
      #
      # @param space [Symbol] The color space to use for hue manipulation (:hsl or :oklch, default: :oklch)
      # @return [Array<Abachrome::Color>] An array of two colors: [original, complement]
      def complementary(space: :oklch)
        original_space = color_space

        # Convert to the specified space for hue manipulation
        color_in_space = space == color_space.id ? self : to_color_space(space)
        l, c, h = color_in_space.coordinates

        # Generate complementary color by rotating hue 180°
        complement = create_harmony_color(l, c, h + 180, space)

        # Convert back to original color space
        [
          self,
          complement.to_color_space(original_space.id)
        ]
      end

      # Generates a triadic color harmony.
      # Triadic colors are evenly spaced around the color wheel at 120° intervals.
      # They create vibrant, balanced palettes with good contrast.
      #
      # @param space [Symbol] The color space to use for hue manipulation (:hsl or :oklch, default: :oklch)
      # @return [Array<Abachrome::Color>] An array of three colors evenly spaced around the color wheel
      def triadic(space: :oklch)
        original_space = color_space

        # Convert to the specified space for hue manipulation
        color_in_space = space == color_space.id ? self : to_color_space(space)
        l, c, h = color_in_space.coordinates

        # Generate triadic colors by rotating hue 120° and 240°
        color_1 = create_harmony_color(l, c, h + 120, space)
        color_2 = create_harmony_color(l, c, h + 240, space)

        # Convert back to original color space
        [
          self,
          color_1.to_color_space(original_space.id),
          color_2.to_color_space(original_space.id)
        ]
      end

      # Generates a tetradic (square) color harmony.
      # Tetradic colors are evenly spaced around the color wheel at 90° intervals.
      # They create rich, varied palettes with multiple complementary pairs.
      #
      # @param space [Symbol] The color space to use for hue manipulation (:hsl or :oklch, default: :oklch)
      # @return [Array<Abachrome::Color>] An array of four colors evenly spaced around the color wheel
      def tetradic(space: :oklch)
        original_space = color_space

        # Convert to the specified space for hue manipulation
        color_in_space = space == color_space.id ? self : to_color_space(space)
        l, c, h = color_in_space.coordinates

        # Generate tetradic colors by rotating hue 90°, 180°, and 270°
        color_1 = create_harmony_color(l, c, h + 90, space)
        color_2 = create_harmony_color(l, c, h + 180, space)
        color_3 = create_harmony_color(l, c, h + 270, space)

        # Convert back to original color space
        [
          self,
          color_1.to_color_space(original_space.id),
          color_2.to_color_space(original_space.id),
          color_3.to_color_space(original_space.id)
        ]
      end

      # Generates a split-complementary color harmony.
      # Split-complementary uses the base color plus two colors adjacent to its complement
      # (at 150° and 210° from the base). This creates strong visual contrast while being
      # more subtle than a pure complementary scheme.
      #
      # @param space [Symbol] The color space to use for hue manipulation (:hsl or :oklch, default: :oklch)
      # @return [Array<Abachrome::Color>] An array of three colors: [original, complement-30°, complement+30°]
      def split_complementary(space: :oklch)
        original_space = color_space

        # Convert to the specified space for hue manipulation
        color_in_space = space == color_space.id ? self : to_color_space(space)
        l, c, h = color_in_space.coordinates

        # Generate split-complementary colors at 150° and 210° (complement ± 30°)
        color_1 = create_harmony_color(l, c, h + 150, space)
        color_2 = create_harmony_color(l, c, h + 210, space)

        # Convert back to original color space
        [
          self,
          color_1.to_color_space(original_space.id),
          color_2.to_color_space(original_space.id)
        ]
      end

      private

      # Helper method to create a harmony color with normalized hue
      #
      # @param l [AbcDecimal] The lightness value
      # @param c [AbcDecimal] The chroma value
      # @param h [Numeric] The hue angle in degrees (will be normalized to 0-360)
      # @param space [Symbol] The color space (:hsl or :oklch)
      # @return [Abachrome::Color] A new color in the specified color space
      def create_harmony_color(l, c, h, space)
        # Normalize hue to 0-360 range
        normalized_hue = h % 360

        case space
        when :oklch
          Abachrome::Color.from_oklch(l, c, normalized_hue, alpha)
        when :hsl
          # For HSL, assuming coordinates are [h, s, l]
          # Note: HSL hue is first coordinate
          Abachrome::Color.new(
            Abachrome::ColorSpace.find(:hsl),
            [normalized_hue, c, l],
            alpha
          )
        else
          raise ArgumentError, "Unsupported color space for harmonies: #{space}. Use :oklch or :hsl"
        end
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
