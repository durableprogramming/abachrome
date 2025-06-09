# Abachrome::Converters::OklabToLrgb - OKLAB to Linear RGB color space converter
#
# This converter transforms colors from the OKLAB color space to the linear RGB (LRGB) color space
# using the standard OKLAB inverse transformation matrices. The conversion process applies a series of
# matrix transformations and cubic operations to accurately map OKLAB coordinates back to the
# linear RGB color space, which represents colors with a linear relationship to light intensity.
#
# Key features:
# - Implements the official OKLAB to linear RGB inverse transformation algorithm with high-precision matrices
# - Converts OKLAB values through intermediate L'M'S' and LMS color space representations
# - Applies cubic operations to reverse the perceptual uniformity transformations
# - Clamps negative RGB values to zero to ensure valid linear RGB output
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper OKLAB source data
#
# The linear RGB color space provides the foundation for further conversions to display-ready
# color spaces like sRGB, making this converter essential for the color transformation pipeline
# when working with perceptually uniform OKLAB color manipulations.

module Abachrome
  module Converters
    class OklabToLrgb < Abachrome::Converters::Base
      # Converts a color from OKLAB color space to linear RGB color space.
      # 
      # The method implements the OKLAB to linear RGB transformation matrix based on
      # standard color science algorithms. It first confirms the input is in OKLAB
      # space, then applies the transformation through several steps:
      # 1. Converts OKLAB coordinates to intermediate L'M'S' values
      # 2. Applies a cubic operation to get LMS values
      # 3. Transforms LMS to linear RGB
      # 4. Clamps negative values to zero
      # 
      # @param oklab_color [Abachrome::Color] The color in OKLAB color space
      # @raise [ArgumentError] If the input color is not in OKLAB color space
      # @return [Abachrome::Color] The resulting color in linear RGB color space with
      # the same alpha as the input color
      def self.convert(oklab_color)
        raise_unless oklab_color, :oklab

        l, a, b = oklab_color.coordinates.map { |_| AbcDecimal(_) }

        l_ = AbcDecimal((l * AD("0.99999999845051981432")) +
                        (AD("0.39633779217376785678") * a) +
                        (AD("0.21580375806075880339") * b))

        m_ = AbcDecimal((l * AD("1.0000000088817607767")) -
                        (a * AD("0.1055613423236563494")) -
                        (b * AD("0.063854174771705903402")))
        s_ = AbcDecimal((l * AD("1.000000054672410917")) -
                        (a * AD("0.089484182094965759684")) -
                        (b * AD("1.2914855378640917399")))

        l = AbcDecimal(l_)**3
        m = AbcDecimal(m_)**3
        s = AbcDecimal(s_)**3

        r =  (l * AD("4.07674166134799")) -
             (m * AD("3.307711590408193")) +
             (s * AD("0.230969928729428"))
        g =  (l * AD("-1.2684380040921763")) +
             (m * AD("2.6097574006633715")) -
             (s * AD("0.3413193963102197"))
        b =  (l * AD("-0.004196086541837188")) -
             (m * AD("0.7034186144594493")) +
             (s * AD("1.7076147009309444"))

        output_coords = [r, g, b].map { |it| [it, 0].max }

        Color.new(ColorSpace.find(:lrgb), output_coords, oklab_color.alpha)
      end
    end
  end
end