# Abachrome::Converters::SrgbToYiq - sRGB to YIQ color space converter
#
# This converter transforms colors from the standard RGB (sRGB) color space to the YIQ
# color space using the NTSC standard transformation matrix. The conversion applies the
# Rec. 601 luma coefficients to separate luminance (Y) from chrominance (I and Q).
#
# Key features:
# - Implements the standard NTSC RGB to YIQ conversion using matrix transformation
# - Separates brightness (Y) from color information (I, Q)
# - Uses Rec. 601 luma coefficients: Y = 0.299R + 0.587G + 0.114B
# - I axis represents orange-to-blue chrominance
# - Q axis represents purple-to-green chrominance
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
#
# The YIQ color space is historically significant for broadcast television and remains
# relevant for image processing tasks that require luminance/chrominance separation.

module Abachrome
  module Converters
    class SrgbToYiq
      # Converts a color from sRGB color space to YIQ color space.
      # This method applies the NTSC standard transformation matrix.
      #
      # @param srgb_color [Abachrome::Color] A color object in the sRGB color space
      # @return [Abachrome::Color] A new color object in the YIQ color space
      # with the same alpha value as the input color
      def self.convert(srgb_color)
        r, g, b = srgb_color.coordinates.map { |c| AbcDecimal(c) }

        # NTSC RGB to YIQ transformation matrix
        # Y = 0.299R + 0.587G + 0.114B  (Rec. 601 luma)
        # I = 0.596R - 0.275G - 0.321B  (In-phase: orange-blue)
        # Q = 0.212R - 0.523G + 0.311B  (Quadrature: purple-green)
        y = AD("0.299") * r + AD("0.587") * g + AD("0.114") * b
        i = AD("0.5959") * r - AD("0.2746") * g - AD("0.3213") * b
        q = AD("0.2115") * r - AD("0.5227") * g + AD("0.3112") * b

        Color.new(
          ColorSpace.find(:yiq),
          [y, i, q],
          srgb_color.alpha
        )
      end
    end
  end
end
