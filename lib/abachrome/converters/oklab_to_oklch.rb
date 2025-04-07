# frozen_string_literal: true

module Abachrome
  module Converters
    class OklabToOklch < Abachrome::Converters::Base
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
