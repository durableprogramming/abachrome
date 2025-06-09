# Abachrome::Converters::OklchToSrgb - OKLCH to sRGB color space converter
#
# This converter transforms colors from the OKLCH color space to the standard RGB (sRGB) color space
# through a two-step conversion process. The transformation first converts OKLCH cylindrical
# coordinates to OKLAB rectangular coordinates, then applies the standard OKLAB to sRGB
# transformation pipeline to produce the final gamma-corrected sRGB values.
#
# Key features:
# - Two-stage conversion pipeline: OKLCH → OKLAB → sRGB
# - Leverages existing OklchToOklab and OklabToSrgb converters for modular transformation
# - Converts cylindrical coordinates (lightness, chroma, hue) to display-ready RGB values
# - Maintains alpha channel transparency values during conversion
# - Applies proper gamma correction for display on standard monitors and web applications
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper OKLCH source data
#
# The sRGB color space is the standard RGB color space for web content and most consumer
# displays, providing gamma-corrected values that properly represent colors on typical
# display devices while maintaining compatibility with web standards and digital media formats.

require_relative "oklch_to_oklab"
require_relative "oklab_to_srgb"

module Abachrome
  module Converters
    class OklchToSrgb < Abachrome::Converters::Base
      # Converts a color from OKLCH color space to sRGB color space.
      # This is done by first converting from OKLCH to OKLAB,
      # then from OKLAB to sRGB.
      # 
      # @param oklch_color [Abachrome::Color] Color in OKLCH color space
      # @return [Abachrome::Color] The converted color in sRGB color space
      def self.convert(oklch_color)
        # Convert OKLCh to OKLab first
        oklab_color = OklchToOklab.convert(oklch_color)
        
        # Then convert OKLab to sRGB 
        OklabToSrgb.convert(oklab_color)
      end
    end
  end
end