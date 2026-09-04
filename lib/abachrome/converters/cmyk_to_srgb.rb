# frozen_string_literal: true

# Abachrome::Converters::CmykToSrgb - CMYK to sRGB color space converter
#
# This converter transforms colors from the CMYK (Cyan, Magenta, Yellow, Key/Black)
# color space back to the standard RGB (sRGB) color space for display on screens.
#
# Key features:
# - Implements the standard CMYK to RGB conversion algorithm
# - Converts from subtractive (ink) to additive (light) color model
# - Maintains alpha channel transparency values during conversion
# - Uses BigDecimal arithmetic for precise color science calculations
# - Handles colors created with UCR/GCR correctly
#
# The conversion recombines the ink components (CMYK) back into light components (RGB)
# using the standard inverse transformation. Note that some CMYK colors may be
# out of gamut for sRGB displays.

module Abachrome
  module Converters
    class CmykToSrgb
      # Converts a color from CMYK color space to sRGB color space.
      # This method applies the standard CMYK to RGB transformation.
      #
      # @param cmyk_color [Abachrome::Color] A color object in the CMYK color space
      # @return [Abachrome::Color] A new color object in the sRGB color space
      # with the same alpha value as the input color
      def self.convert(cmyk_color)
        c, m, y, k = cmyk_color.coordinates.map { |component| AbcDecimal(component) }

        # Use the CMYK color model's conversion method
        r, g, b = ColorModels::CMYK.to_rgb(c, m, y, k)

        Color.new(
          ColorSpace.find(:srgb),
          [r, g, b],
          cmyk_color.alpha
        )
      end
    end
  end
end
