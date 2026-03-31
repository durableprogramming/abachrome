# frozen_string_literal: true

module Abachrome
  module Converters
    class XyzToLrgb < Abachrome::Converters::Base
      # Converts a color from XYZ color space to linear RGB color space.
      #
      # This method implements the XYZ to linear RGB transformation using the inverse
      # of the standard transformation matrix for the sRGB color space with D65 white point.
      # The XYZ color space is the CIE 1931 color space that serves as a device-independent
      # reference for color definitions.
      #
      # @param xyz_color [Abachrome::Color] The color in XYZ color space
      # @raise [ArgumentError] If the input color is not in XYZ color space
      # @return [Abachrome::Color] The resulting color in linear RGB color space with
      # the same alpha as the input color
      def self.convert(xyz_color)
        raise_unless xyz_color, :xyz

        x, y, z = xyz_color.coordinates.map { |_| AbcDecimal(_) }

        # XYZ to Linear RGB transformation matrix (inverse of sRGB/D65)
        r = (x * AD("3.2404542")) + (y * AD("-1.5371385")) + (z * AD("-0.4985314"))
        g = (x * AD("-0.9692660")) + (y * AD("1.8760108")) + (z * AD("0.0415560"))
        b = (x * AD("0.0556434")) + (y * AD("-0.2040259")) + (z * AD("1.0572252"))

        Color.new(ColorSpace.find(:lrgb), [r, g, b], xyz_color.alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
