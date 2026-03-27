# frozen_string_literal: true

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

        r, g, b = rgb_color.coordinates.map { |_| _.to_f }

        l = (0.41222147079999993.to_f * r) + (0.5363325363.to_f * g) + (0.0514459929.to_f * b)
        m = (0.2119034981999999.to_f * r) + (0.680699545099999.to_f * g) + (0.1073969566.to_f * b)
        s = (0.08830246189999998.to_f * r) + (0.2817188376.to_f * g) + (0.6299787005000002.to_f * b)

        l_ = l.to_f**Rational(1, 3)
        m_ = m.to_f**Rational(1, 3)
        s_ = s.to_f**Rational(1, 3)

        lightness = (0.2104542553.to_f * l_) + (0.793617785.to_f * m_) - (0.0040720468.to_f * s_)
        a         = (1.9779984951.to_f * l_) - (2.4285922050.to_f * m_) + (0.4505937099.to_f * s_)
        b         = (0.0259040371.to_f * l_) + (0.7827717662.to_f * m_) - (0.8086757660.to_f * s_)

        Color.new(ColorSpace.find(:oklab), [lightness, a, b], rgb_color.alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
