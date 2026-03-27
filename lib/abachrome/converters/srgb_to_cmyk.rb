# frozen_string_literal: true

# Abachrome::Converters::SrgbToCmyk - sRGB to CMYK color space converter
#
# This converter transforms colors from the standard RGB (sRGB) color space to the CMYK
# (Cyan, Magenta, Yellow, Key/Black) color space using Gray Component Replacement (GCR)
# for optimal ink usage in print production.
#
# Key features:
# - Implements GCR/UCR for efficient ink usage and better print quality
# - Converts from additive (light) to subtractive (ink) color model
# - Configurable GCR amount for different printing requirements
# - Uses BigDecimal for precise ink percentage calculations
# - Maintains alpha channel transparency values during conversion
# - Produces professional-quality CMYK separations
#
# The conversion uses Gray Component Replacement by default, which extracts the neutral
# gray component from CMY inks and assigns it to the cheaper and more stable Black (K) ink.
# This reduces Total Area Coverage (TAC) and improves print quality.

module Abachrome
  module Converters
    class SrgbToCmyk
      # Converts a color from sRGB color space to CMYK color space.
      # Uses full GCR (Gray Component Replacement) by default for optimal ink usage.
      #
      # @param srgb_color [Abachrome::Color] A color object in the sRGB color space
      # @param gcr_amount [Numeric] The amount of GCR to apply (0.0 to 1.0), default 1.0 for full GCR
      # @return [Abachrome::Color] A new color object in the CMYK color space
      # with the same alpha value as the input color
      def self.convert(srgb_color, gcr_amount: 1.0)
        r, g, b = srgb_color.coordinates.map { |c| c.to_f }

        # Use GCR conversion from the CMYK color model
        c, m, y, k = ColorModels::CMYK.from_rgb_gcr(r, g, b, gcr_amount)

        Color.new(
          ColorSpace.find(:cmyk),
          [c, m, y, k],
          srgb_color.alpha
        )
      end

      # Converts a color from sRGB to CMYK using the naive method (no UCR/GCR).
      # This produces higher ink coverage but simpler conversion.
      # Generally not recommended for production printing.
      #
      # @param srgb_color [Abachrome::Color] A color object in the sRGB color space
      # @return [Abachrome::Color] A new color object in the CMYK color space
      def self.convert_naive(srgb_color)
        r, g, b = srgb_color.coordinates.map { |c| c.to_f }

        # Use naive conversion from the CMYK color model
        c, m, y, k = ColorModels::CMYK.from_rgb_naive(r, g, b)

        Color.new(
          ColorSpace.find(:cmyk),
          [c, m, y, k],
          srgb_color.alpha
        )
      end
    end
  end
end
