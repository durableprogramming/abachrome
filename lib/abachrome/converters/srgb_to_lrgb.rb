# frozen_string_literal: true

module Abachrome
  module Converters
    class SrgbToLrgb
      # Converts a color from sRGB color space to linear RGB color space.
      # This method performs gamma correction by linearizing each sRGB coordinate.
      # 
      # @param srgb_color [Abachrome::Color] A color object in the sRGB color space
      # @return [Abachrome::Color] A new color object in the linear RGB (LRGB) color space
      # with the same alpha value as the input color
      def self.convert(srgb_color)
        r, g, b = srgb_color.coordinates.map { |c| to_linear(AbcDecimal(c)) }

        Color.new(
          ColorSpace.find(:lrgb),
          [r, g, b],
          srgb_color.alpha
        )
      end

      # Converts a sRGB component to its linear RGB equivalent.
      # This conversion applies the appropriate gamma correction to transform an sRGB value
      # into a linear RGB value.
      # 
      # @param v [AbcDecimal, Numeric] The sRGB component value to convert (typically in range 0-1)
      # @return [AbcDecimal] The corresponding linear RGB component value
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