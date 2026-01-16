# frozen_string_literal: true

# Abachrome::ColorMixins::ToGrayscale - Grayscale conversion mixin
#
# This mixin provides methods for converting colors to grayscale using various
# standard luma calculations. It supports both legacy Rec. 601 (SDTV) and modern
# Rec. 709 (HDTV) coefficients for accurate grayscale conversion based on human
# eye sensitivity.
#
# Key features:
# - Rec. 601 luma: Y = 0.299R + 0.587G + 0.114B (NTSC/SDTV standard)
# - Rec. 709 luma: Y = 0.2126R + 0.7152G + 0.0722B (HDTV standard)
# - Maintains alpha channel during conversion
# - Uses BigDecimal for precise calculations
#
# This is essential for image processing, accessibility checks, and any application
# that needs perceptually accurate grayscale conversion rather than simple averaging.

module Abachrome
  module ColorMixins
    module ToGrayscale
      # Converts the color to grayscale using Rec. 601 luma coefficients (legacy NTSC standard).
      # This is the same calculation used in the YIQ color space's Y component.
      #
      # @return [Abachrome::Color] A grayscale version of the color in sRGB space
      def to_grayscale_601
        rgb_color = to_srgb
        r, g, b = rgb_color.coordinates

        # Rec. 601 luma: Y = 0.299R + 0.587G + 0.114B
        luma = (AD("0.299") * r) + (AD("0.587") * g) + (AD("0.114") * b)

        Color.from_rgb(luma, luma, luma, alpha)
      end

      # Converts the color to grayscale using Rec. 709 luma coefficients (HDTV standard).
      #
      # @return [Abachrome::Color] A grayscale version of the color in sRGB space
      def to_grayscale_709
        rgb_color = to_srgb
        r, g, b = rgb_color.coordinates

        # Rec. 709 luma: Y = 0.2126R + 0.7152G + 0.0722B
        luma = (AD("0.2126") * r) + (AD("0.7152") * g) + (AD("0.0722") * b)

        Color.from_rgb(luma, luma, luma, alpha)
      end

      # Converts the color to grayscale using the default Rec. 601 standard.
      # This is an alias for to_grayscale_601 and matches the legacy behavior
      # expected by most image processing applications.
      #
      # @return [Abachrome::Color] A grayscale version of the color in sRGB space
      def to_grayscale
        to_grayscale_601
      end

      # Calculates the relative luminance (luma) value using Rec. 601 coefficients.
      # This returns just the Y component without creating a new color.
      #
      # @return [AbcDecimal] The luma value in range [0, 1]
      def luma_601
        rgb_color = to_srgb
        r, g, b = rgb_color.coordinates
        (AD("0.299") * r) + (AD("0.587") * g) + (AD("0.114") * b)
      end

      # Calculates the relative luminance (luma) value using Rec. 709 coefficients.
      # This returns just the Y component without creating a new color.
      #
      # @return [AbcDecimal] The luma value in range [0, 1]
      def luma_709
        rgb_color = to_srgb
        r, g, b = rgb_color.coordinates
        (AD("0.2126") * r) + (AD("0.7152") * g) + (AD("0.0722") * b)
      end

      # Calculates the relative luminance using the default Rec. 601 standard.
      # Alias for luma_601.
      #
      # @return [AbcDecimal] The luma value in range [0, 1]
      def luma
        luma_601
      end
    end
  end
end
