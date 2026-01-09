# Abachrome::Converters::OklabToSrgb - OKLAB to sRGB color space converter
#
# This converter transforms colors from the OKLAB color space to the standard RGB (sRGB) color space
# through a two-step conversion process. The transformation first converts OKLAB coordinates to
# linear RGB as an intermediate step, then applies gamma correction to produce the final sRGB
# values suitable for display on standard monitors and web applications.
#
# Key features:
# - Two-stage conversion pipeline: OKLAB → Linear RGB → sRGB
# - Leverages existing OklabToLrgb and LrgbToSrgb converters for modular transformation
# - Maintains alpha channel transparency values during conversion
# - Applies proper gamma correction for display-ready color values
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper OKLAB source data
#
# The sRGB color space is the standard RGB color space for web content and most consumer
# displays, providing gamma-corrected values that properly represent colors on typical
# display devices while maintaining compatibility with web standards and digital media formats.

module Abachrome
  module Converters
    class OklabToSrgb < Abachrome::Converters::Base
      # Converts a color from the Oklab color space to the sRGB color space.
      # This conversion is performed in two steps:
      # 1. First converts from Oklab to linear RGB
      # 2. Then converts from linear RGB to sRGB
      # 
      # @param oklab_color [Color] A color in the Oklab color space
      # @raise [ArgumentError] If the provided color is not in the Oklab color space
      # @return [Color] The converted color in the sRGB color space
      def self.convert(oklab_color)
        raise_unless oklab_color, :oklab

        # First convert Oklab to linear RGB
        lrgb_color = OklabToLrgb.convert(oklab_color)

        # Then use the LrgbToSrgb converter to go from linear RGB to sRGB
        LrgbToSrgb.convert(lrgb_color)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.