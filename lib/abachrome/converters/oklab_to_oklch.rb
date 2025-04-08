# frozen_string_literal: true

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