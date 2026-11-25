# frozen_string_literal: true

# Abachrome::Converters::XyzToLrgb - XYZ to linear RGB color space converter
#
# This converter transforms colors from the CIE 1931 XYZ color space to the linear RGB
# (LRGB) color space using the standard inverse transformation matrix for sRGB primaries
# with a D65 white point. The result is linear light, so it is the natural input to the
# existing linear RGB to sRGB gamma correction step.
#
# Key features:
# - Implements the inverse of the linear RGB to XYZ transformation matrix (sRGB/D65)
# - Produces linear light values suitable for subsequent gamma correction
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper XYZ source data
#
# This converter closes the loop with LrgbToXyz, allowing colors that arrive through the
# CIELAB and CIELCH conversion paths to reach sRGB through the same gamma correction used
# by every other conversion in the library.

module Abachrome
  module Converters
    class XyzToLrgb < Abachrome::Converters::Base
      # Converts a color from XYZ color space to linear RGB color space.
      #
      # @param xyz_color [Abachrome::Color] The color in XYZ color space to convert
      # @return [Abachrome::Color] A new Color object in linear RGB color space with the converted coordinates
      # @raise [RuntimeError] If the provided color is not in XYZ color space
      def self.convert(xyz_color)
        raise_unless xyz_color, :xyz

        x, y, z = xyz_color.coordinates.map { |_| AbcDecimal(_) }

        # XYZ to linear RGB transformation matrix (sRGB/D65), the inverse of the
        # matrix used by LrgbToXyz.
        r = (x * AD("3.2404542")) - (y * AD("1.5371385")) - (z * AD("0.4985314"))
        g = (x * AD("-0.9692660")) + (y * AD("1.8760108")) + (z * AD("0.0415560"))
        b = (x * AD("0.0556434")) - (y * AD("0.2040259")) + (z * AD("1.0572252"))

        Color.new(ColorSpace.find(:lrgb), [r, g, b], xyz_color.alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
