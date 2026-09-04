# Abachrome::Converters::HwbToSrgb - HWB to sRGB color space converter
#
# This converter transforms colors from the HWB (hue, whiteness, blackness) color space to
# the standard RGB (sRGB) color space following the algorithm defined by the CSS Color
# specification. The hue component selects a fully saturated base color, which is then mixed
# with white and black according to the whiteness and blackness components.
#
# Key features:
# - Implements the standard CSS HWB to sRGB conversion algorithm
# - Normalizes whiteness and blackness proportionally when their sum exceeds one
# - Produces an achromatic gray when whiteness and blackness fully saturate the color
# - Derives the pure hue color through the HSL conversion at full saturation
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper HWB source data
#
# HWB is the color model used by the CSS hwb() function, describing colors in terms of how
# much white and black are mixed into a pure hue, which maps closely to how pigments are
# mixed in practice.

module Abachrome
  module Converters
    class HwbToSrgb < Abachrome::Converters::Base
      # Converts a color from HWB color space to sRGB color space.
      #
      # @param hwb_color [Abachrome::Color] The color in HWB color space to convert
      # @return [Abachrome::Color] A new Color object in sRGB color space with the converted coordinates
      # @raise [RuntimeError] If the provided color is not in HWB color space
      def self.convert(hwb_color)
        raise_unless hwb_color, :hwb

        h, w, b = hwb_color.coordinates.map { |_| AbcDecimal(_) }

        Color.new(
          ColorSpace.find(:srgb),
          to_srgb(h, w, b),
          hwb_color.alpha
        )
      end

      # Converts hue, whiteness, and blackness components into sRGB coordinates.
      #
      # When whiteness and blackness sum to one or more the result is achromatic, and the
      # gray level is the whiteness expressed as a proportion of the total. Otherwise the
      # fully saturated hue color is scaled into the range left between the two.
      #
      # @param h [AbcDecimal] The hue angle in degrees
      # @param w [AbcDecimal] The whiteness component, in range 0..1
      # @param b [AbcDecimal] The blackness component, in range 0..1
      # @return [Array<AbcDecimal>] The red, green, and blue components, in range 0..1
      def self.to_srgb(h, w, b)
        total = w + b

        if total >= AD(1)
          gray = w / total
          return [gray, gray, gray]
        end

        scale = AD(1) - total
        HslToSrgb.to_srgb(h, AD(1), AD("0.5")).map { |c| (c * scale) + w }
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
