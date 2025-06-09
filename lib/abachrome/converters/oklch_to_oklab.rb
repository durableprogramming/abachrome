# Abachrome::Converters::OklchToOklab - OKLCH to OKLAB color space converter
#
# This converter transforms colors from the OKLCH color space to the OKLAB color space
# using cylindrical to rectangular coordinate conversion. The transformation converts the
# cylindrical coordinates (L, C, h) to rectangular coordinates (L, a, b) where lightness
# remains unchanged, and the a and b components are calculated from chroma and hue using
# trigonometric functions (cosine and sine respectively).
#
# Key features:
# - Converts OKLCH cylindrical coordinates to OKLAB rectangular coordinates
# - Preserves lightness component unchanged during conversion
# - Calculates a component as chroma × cos(hue) for green-red axis positioning
# - Calculates b component as chroma × sin(hue) for blue-yellow axis positioning
# - Converts hue angle from degrees to radians for trigonometric calculations
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper OKLCH source data
#
# The OKLAB color space provides the foundation for further conversions to other color
# spaces and serves as an intermediate step in the color transformation pipeline when
# working with OKLCH color manipulations that need to be converted to display-ready formats.

module Abachrome
  module Converters
    class OklchToOklab < Abachrome::Converters::Base
      # Converts a color from OKLCH color space to OKLAB color space.
      # 
      # @param oklch_color [Abachrome::Color] The color in OKLCH format to convert
      # @return [Abachrome::Color] The converted color in OKLAB format
      # @raise [StandardError] If the provided color is not in OKLCH color space
      def self.convert(oklch_color)
        raise_unless oklch_color, :oklch

        l, c, h = oklch_color.coordinates.map { |_| AbcDecimal(_) }

        h_rad = h * Rational(Math::PI, 180)
        a = c * Math.cos(h_rad.value)
        b = c * Math.sin(h_rad.value)

        Color.new(
          ColorSpace.find(:oklab),
          [l, a, b],
          oklch_color.alpha
        )
      end
    end
  end
end