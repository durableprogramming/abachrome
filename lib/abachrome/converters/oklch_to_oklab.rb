# frozen_string_literal: true

module Abachrome
  module Converters
    class OklchToOklab < Abachrome::Converters::Base
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
