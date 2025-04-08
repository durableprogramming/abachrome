# frozen_string_literal: true

module Abachrome
  module Converters
    class LrgbToSrgb < Abachrome::Converters::Base
      # Converts a color from linear RGB to sRGB color space.
      # 
      # @param lrgb_color [Abachrome::Color] The color in linear RGB color space to convert
      # @return [Abachrome::Color] A new Color object in sRGB color space with the converted coordinates
      # @raise [TypeError] If the provided color is not in linear RGB color space
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

      # Converts a linear RGB value to standard RGB color space (sRGB) value.
      # 
      # This method implements the standard linearization function used in the sRGB color space.
      # For small values (≤ 0.0031308), a simple linear transformation is applied.
      # For larger values, a power function with gamma correction is used.
      # 
      # @param v [AbcDecimal] The linear RGB value to convert
      # @return [AbcDecimal] The corresponding sRGB value, preserving the sign of the input
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