# Abachrome::Converters::OklchToLrgb - OKLCH to Linear RGB color space converter
#
# This converter transforms colors from the OKLCH color space to the linear RGB (LRGB) color space
# through a two-step conversion process. The transformation first converts OKLCH cylindrical
# coordinates to OKLAB rectangular coordinates, then applies the standard OKLAB to linear RGB
# transformation matrices to produce the final linear RGB values.
#
# Key features:
# - Two-stage conversion pipeline: OKLCH → OKLAB → Linear RGB
# - Leverages existing OklchToOklab and OklabToLrgb converters for modular transformation
# - Converts cylindrical coordinates (lightness, chroma, hue) to linear light intensity values
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper OKLCH source data
#
# The linear RGB color space provides the foundation for further conversions to display-ready
# color spaces like sRGB, making this converter essential for the color transformation pipeline
# when working with OKLCH color manipulations that need to be rendered on standard displays.

require_relative "oklab_to_lrgb"
require_relative "oklch_to_oklab"

module Abachrome
  module Converters
    class OklchToLrgb < Abachrome::Converters::Base
      # Converts a color from OKLCH color space to linear RGB color space.
      # This is a two-step conversion process that first converts from OKLCH to OKLAB,
      # then from OKLAB to linear RGB.
      # 
      # @param oklch_color [Abachrome::Color] A color in the OKLCH color space
      # @return [Abachrome::Color] The resulting color in linear RGB color space
      def self.convert(oklch_color)
        oklab_color = OklchToOklab.convert(oklch_color)
        OklabToLrgb.convert(oklab_color)
      end
    end
  end
end