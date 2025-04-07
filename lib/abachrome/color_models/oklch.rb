# frozen_string_literal: true

module Abachrome
  module ColorModels
    class Oklch
      def self.normalize(l, c, h)
        l = AbcDecimal(l)
        c = AbcDecimal(c)
        h = AbcDecimal(h)

        # Normalize hue to 0-360 range
        h -= 360 while h >= 360
        h += 360 while h.negative?

        # Normalize lightness and chroma to 0-1 range
        l = l.clamp(0, 1)
        c = c.clamp(0, 1)

        [l, c, h]
      end

      def self.to_oklab(l, c, h)
        # Convert OKLCH to OKLab
        h_rad = h * Math::PI / 180
        a = c * Math.cos(h_rad)
        b = c * Math.sin(h_rad)
        [l, a, b]
      end

      def self.from_oklab(l, a, b)
        # Convert OKLab to OKLCH
        c = Math.sqrt((a * a) + (b * b))
        h = Math.atan2(b, a) * 180 / Math::PI
        h += 360 if h.negative?
        [l, c, h]
      end
    end
  end
end

ColorSpace.register(
  :oklch,
  "OKLCh",
  %w[lightness chroma hue],
  nil,
  ["ok-lch"]
)
