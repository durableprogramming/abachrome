# Abachrome::Converters::LrgbToSrgb - Linear RGB to sRGB color space converter
#
# This converter transforms colors from the linear RGB (LRGB) color space to the standard RGB (sRGB) color space by applying gamma correction. The conversion process applies the sRGB transfer function which uses different formulas for small and large values to match the non-linear response characteristics of typical display devices.
#
# Key features:
# - Implements the standard sRGB gamma correction algorithm with precise threshold handling
# - Converts linear RGB values to gamma-corrected sRGB values for proper display representation
# - Applies different transformation functions based on value magnitude (linear vs power function)
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper linear RGB source data
#
# The sRGB color space is the standard RGB color space for web content and most consumer displays, providing gamma correction that better matches human visual perception and display device characteristics compared to linear RGB values.

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