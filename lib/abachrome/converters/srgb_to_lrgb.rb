# frozen_string_literal: true

module Abachrome
  module Converters
    class SrgbToLrgb
      def self.convert(srgb_color)
        r, g, b = srgb_color.coordinates.map { |c| to_linear(AbcDecimal(c)) }

        Color.new(
          ColorSpace.find(:lrgb),
          [r, g, b],
          srgb_color.alpha
        )
      end

      def self.to_linear(v)
        v_abs = v.abs
        v_sign = v.negative? ? -1 : 1
        if v_abs <= AD("0.04045")
          v / AD("12.92")
        else
          v_sign * (((v_abs + AD("0.055")) / AD("1.055"))**AD("2.4"))
        end
      end
    end
  end
end
