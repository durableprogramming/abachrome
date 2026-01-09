# Abachrome::Converters::YiqToSrgb - YIQ to sRGB color space converter
#
# This converter transforms colors from the YIQ color space back to the standard RGB
# (sRGB) color space using the inverse NTSC transformation matrix. The conversion
# recombines luminance (Y) and chrominance (I, Q) into RGB components.
#
# Key features:
# - Implements the inverse NTSC YIQ to RGB conversion using matrix transformation
# - Recombines brightness (Y) and color information (I, Q) into RGB
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - May produce RGB values outside [0,1] range for out-of-gamut YIQ values
#
# The inverse transformation allows colors manipulated in YIQ space (e.g., brightness
# adjustments on the Y channel) to be converted back to RGB for display.

module Abachrome
  module Converters
    class YiqToSrgb
      # Converts a color from YIQ color space to sRGB color space.
      # This method applies the inverse NTSC transformation matrix.
      #
      # @param yiq_color [Abachrome::Color] A color object in the YIQ color space
      # @return [Abachrome::Color] A new color object in the sRGB color space
      # with the same alpha value as the input color
      def self.convert(yiq_color)
        y, i, q = yiq_color.coordinates.map { |c| AbcDecimal(c) }

        # Inverse NTSC YIQ to RGB transformation matrix
        # R = Y + 0.956I + 0.619Q
        # G = Y - 0.272I - 0.647Q
        # B = Y - 1.106I + 1.703Q
        r = y + AD("0.9563") * i + AD("0.6210") * q
        g = y - AD("0.2721") * i - AD("0.6474") * q
        b = y - AD("1.1070") * i + AD("1.7046") * q

        Color.new(
          ColorSpace.find(:srgb),
          [r, g, b],
          yiq_color.alpha
        )
      end
    end
  end
end
