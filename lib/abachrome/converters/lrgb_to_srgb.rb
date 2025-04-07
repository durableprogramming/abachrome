# frozen_string_literal: true

module Abachrome
  module Converters
    class LrgbToSrgb < Abachrome::Converters::Base
      def self.convert(lrgb_color)
        raise_unless lrgb_color, :lrgb
        r, g, b = lrgb_color.coordinates.map { |c| to_srgb(AbcDecimal(c)) }

        output_coords = [r, g, b]

        Color.new(
          ColorSpace.find(:srgb),
          output_coords,
          lrgb_color.alpha
        )
      end

      def self.to_srgb(v)
        v_abs = v.abs
        v_sign = v.negative? ? -1 : 1
        if v_abs <= AD("0.0031308")
          v * AD("12.92")
        else
          v_sign * ((AD("1.055") * (v_abs**Rational(1.0, 2.4))) - AD("0.055"))
        end
      end
    end
  end
end
