# Abachrome::Converters::SrgbToOklab - sRGB to OKLAB color space converter
#
# This converter transforms colors from the standard RGB (sRGB) color space to the OKLAB color space
# through a two-step conversion process. The transformation first converts sRGB gamma-corrected
# values to linear RGB as an intermediate step, then applies the standard OKLAB transformation
# matrices to produce the final perceptually uniform OKLAB coordinates.
#
# Key features:
# - Two-stage conversion pipeline: sRGB → Linear RGB → OKLAB
# - Leverages existing SrgbToLrgb and LrgbToOklab converters for modular transformation
# - Removes gamma correction and applies perceptual uniformity transformations
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper sRGB source data
#
# The OKLAB color space provides better perceptual uniformity compared to traditional RGB spaces,
# making it ideal for color manipulation operations like blending, lightness adjustments, and
# gamut mapping where human visual perception accuracy is important. This converter enables
# seamless transformation from display-ready sRGB values to the scientifically accurate OKLAB
# representation for advanced color processing workflows.

module Abachrome
  module Converters
    class SrgbToOklab
      # Converts a color from sRGB color space to Oklab color space.
      # The conversion happens in two steps:
      # 1. sRGB is first converted to linear RGB
      # 2. Linear RGB is then converted to Oklab
      # 
      # @param srgb_color [Abachrome::Color] The color in sRGB color space to convert
      # @return [Abachrome::Color] The converted color in Oklab color space
      def self.convert(srgb_color)
        # First convert sRGB to linear RGB
        lrgb_color = SrgbToLrgb.convert(srgb_color)

        # Then convert linear RGB to Oklab
        LrgbToOklab.convert(lrgb_color)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.