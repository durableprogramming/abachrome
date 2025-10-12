# Abachrome::Converters::OklabToOklch - OKLAB to OKLCH color space converter
#
# This converter transforms colors from the OKLAB color space to the OKLCH color space
# using cylindrical coordinate conversion. The transformation converts the rectangular
# coordinates (L, a, b) to cylindrical coordinates (L, C, h) where lightness remains
# unchanged, chroma is calculated as the Euclidean distance in the a-b plane, and hue
# is calculated as the angle in the a-b plane expressed in degrees.
#
# Key features:
# - Converts OKLAB rectangular coordinates to OKLCH cylindrical coordinates
# - Preserves lightness component unchanged during conversion
# - Calculates chroma as sqrt(a² + b²) for colorfulness representation
# - Computes hue angle using atan2 function and normalizes to 0-360 degree range
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper OKLAB source data
#
# The OKLCH color space provides an intuitive interface for color manipulation through
# its cylindrical coordinate system, making it ideal for hue adjustments, saturation
# modifications, and other color operations that benefit from polar coordinates.

module Abachrome
  module Converters
    class OklabToOklch < Abachrome::Converters::Base
      # Converts a color from OKLAB color space to OKLCH color space.
      # The method performs a mathematical transformation from the rectangular
      # coordinates (L, a, b) to cylindrical coordinates (L, C, h), where:
      # - L (lightness) remains the same
      # - C (chroma) is calculated as the Euclidean distance from the origin in the a-b plane
      # - h (hue) is calculated as the angle in the a-b plane
      # 
      # @param oklab_color [Abachrome::Color] A color in the OKLAB color space
      # @raise [ArgumentError] If the provided color is not in OKLAB color space
      # @return [Abachrome::Color] The equivalent color in OKLCH color space with the same alpha value
      def self.convert(oklab_color)
        raise_unless oklab_color, :oklab

        l, a, b = oklab_color.coordinates.map { |_| AbcDecimal(_) }

        c = ((a * a) + (b * b)).sqrt
        h = (AbcDecimal.atan2(b, a) * 180) / Math::PI
        h += 360 if h.negative?

        Color.new(
          ColorSpace.find(:oklch),
          [l, c, h],
          oklab_color.alpha
        )
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.