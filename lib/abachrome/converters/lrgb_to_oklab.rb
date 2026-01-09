# Abachrome::Converters::LrgbToOklab - Linear RGB to OKLAB color space converter
#
# This converter transforms colors from the linear RGB (LRGB) color space to the OKLAB color space
# using the standard OKLAB transformation matrices. The conversion process applies a series of
# matrix transformations and non-linear operations to accurately map linear RGB coordinates to
# the perceptually uniform OKLAB color space.
#
# Key features:
# - Implements the official OKLAB transformation algorithm with high-precision matrices
# - Converts linear RGB values through intermediate LMS color space representation
# - Applies cube root transformation for perceptual uniformity in the OKLAB space
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper linear RGB source data
#
# The OKLAB color space provides better perceptual uniformity compared to traditional RGB spaces,
# making it ideal for color manipulation operations like blending, lightness adjustments, and
# gamut mapping where human visual perception accuracy is important.

module Abachrome
  module Converters
    class LrgbToOklab < Abachrome::Converters::Base
      # Converts a color from linear RGB (LRGB) color space to OKLAB color space.
      # 
      # This conversion applies a matrix transformation to the linear RGB values,
      # followed by a non-linear transformation, then another matrix transformation
      # to produce OKLAB coordinates.
      # 
      # @param rgb_color [Abachrome::Color] A color in linear RGB (LRGB) color space
      # @raise [ArgumentError] If the provided color is not in LRGB color space
      # @return [Abachrome::Color] The converted color in OKLAB color space with the same alpha value as the input
      def self.convert(rgb_color)
        raise_unless rgb_color, :lrgb

        r, g, b = rgb_color.coordinates.map { |_| AbcDecimal(_) }

        l = (AD("0.41222147079999993") * r) + (AD("0.5363325363") * g) + (AD("0.0514459929") * b)
        m = (AD("0.2119034981999999") * r) + (AD("0.680699545099999") * g) + (AD("0.1073969566") * b)
        s = (AD("0.08830246189999998") * r) + (AD("0.2817188376") * g) + (AD("0.6299787005000002") * b)

        l_ = AbcDecimal(l)**Rational(1, 3)
        m_ = AbcDecimal(m)**Rational(1, 3)
        s_ = AbcDecimal(s)**Rational(1, 3)

        lightness = (AD("0.2104542553") * l_) + (AD("0.793617785") * m_) - (AD("0.0040720468") * s_)
        a         = (AD("1.9779984951") * l_) - (AD("2.4285922050") * m_) + (AD("0.4505937099") * s_)
        b         = (AD("0.0259040371") * l_) + (AD("0.7827717662") * m_) - (AD("0.8086757660") * s_)

        Color.new(ColorSpace.find(:oklab), [lightness, a, b], rgb_color.alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.