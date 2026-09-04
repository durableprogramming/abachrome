# Abachrome::Converters::LchToLab - CIELCH to CIELAB color space converter
#
# This converter transforms colors from the CIELCH color space to the CIELAB color space
# using cylindrical to rectangular coordinate conversion. The transformation converts the
# cylindrical coordinates (L, C, h) to rectangular coordinates (L, a, b) where lightness
# remains unchanged, and the a and b components are calculated from chroma and hue using
# trigonometric functions (cosine and sine respectively).
#
# Key features:
# - Converts CIELCH cylindrical coordinates to CIELAB rectangular coordinates
# - Preserves lightness component unchanged during conversion
# - Calculates a component as chroma × cos(hue) for green-red axis positioning
# - Calculates b component as chroma × sin(hue) for blue-yellow axis positioning
# - Converts hue angle from degrees to radians for trigonometric calculations
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper CIELCH source data
#
# CIELCH is the cylindrical form of CIELAB used by the CSS lch() function, expressing color
# in terms of chroma and hue angle rather than opponent axes, which makes hue rotations and
# saturation adjustments straightforward.

module Abachrome
  module Converters
    class LchToLab < Abachrome::Converters::Base
      # Converts a color from CIELCH color space to CIELAB color space.
      #
      # @param lch_color [Abachrome::Color] The color in CIELCH color space to convert
      # @return [Abachrome::Color] A new Color object in CIELAB color space with the converted coordinates
      # @raise [RuntimeError] If the provided color is not in CIELCH color space
      def self.convert(lch_color)
        raise_unless lch_color, :lch

        l, c, h = lch_color.coordinates.map { |_| AbcDecimal(_) }

        h_rad = (h * Math::PI) / AD(180)
        a = c * AD(Math.cos(h_rad.value))
        b = c * AD(Math.sin(h_rad.value))

        Color.new(
          ColorSpace.find(:lab),
          [l, a, b],
          lch_color.alpha
        )
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
