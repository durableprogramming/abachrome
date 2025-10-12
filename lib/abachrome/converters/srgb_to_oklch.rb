# Abachrome::Converters::SrgbToOklch - sRGB to OKLCH color space converter
#
# This converter transforms colors from the standard RGB (sRGB) color space to the OKLCH color space
# through a two-step conversion process. The transformation first converts sRGB gamma-corrected
# values to OKLAB rectangular coordinates as an intermediate step, then applies cylindrical coordinate
# conversion to produce the final OKLCH values with lightness, chroma, and hue components.
#
# Key features:
# - Two-stage conversion pipeline: sRGB → OKLAB → OKLCH
# - Leverages existing SrgbToOklab and OklabToOklch converters for modular transformation
# - Converts display-ready RGB values to perceptually uniform cylindrical coordinates
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper sRGB source data
#
# The OKLCH color space provides an intuitive interface for color manipulation through its
# cylindrical coordinate system, making it ideal for hue adjustments, saturation modifications,
# and other color operations that benefit from polar coordinates while maintaining perceptual
# uniformity for natural-looking color transformations.

require_relative "srgb_to_oklab"
require_relative "oklab_to_oklch"

module Abachrome
  module Converters
    class SrgbToOklch < Abachrome::Converters::Base
      # Converts an sRGB color to OKLCH color space
      # 
      # @param srgb_color [Abachrome::Color] The color in sRGB color space to convert
      # @return [Abachrome::Color] The converted color in OKLCH color space
      # @note This is a two-step conversion process: first from sRGB to OKLab, then from OKLab to OKLCH
      # @see SrgbToOklab
      # @see OklabToOklch
      def self.convert(srgb_color)
        # First convert sRGB to OKLab
        oklab_color = SrgbToOklab.convert(srgb_color)
        
        # Then convert OKLab to OKLCh
        OklabToOklch.convert(oklab_color)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.