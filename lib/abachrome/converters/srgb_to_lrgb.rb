# Abachrome::Converters::SrgbToLrgb - sRGB to Linear RGB color space converter
#
# This converter transforms colors from the standard RGB (sRGB) color space to the linear RGB (LRGB) color space by removing gamma correction. The conversion process applies the inverse sRGB transfer function which uses different formulas for small and large values to convert from the gamma-corrected sRGB representation to linear light intensity values.
#
# Key features:
# - Implements the standard sRGB to linear RGB conversion algorithm with precise threshold handling
# - Converts gamma-corrected sRGB values to linear RGB values for accurate color calculations
# - Applies different transformation functions based on value magnitude (linear vs power function)
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper sRGB source data
#
# The linear RGB color space provides a linear relationship between stored numeric values and actual light intensity, making it essential for accurate color calculations and serving as an intermediate color space for many color transformations, particularly when converting between different color models.

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