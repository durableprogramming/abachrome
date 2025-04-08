# frozen_string_literal: true

module Abachrome
  module Converters
    class SrgbToOklab
      # Converts a color from sRGB color space to Oklab color space.
      # The conversion happens in two steps:
      # 1. sRGB is first converted to linear RGB
      # 2. Linear RGB is then converted to Oklab
      # 
      # @param srgb_color [Abachrome::Color] The color in sRGB color space to convert
      # @return [Abachrome::Color] The converted color in Oklab color space
      def self.convert(srgb_color)
        # First convert sRGB to linear RGB
        lrgb_color = SrgbToLrgb.convert(srgb_color)

        # Then convert linear RGB to Oklab
        LrgbToOklab.convert(lrgb_color)
      end
    end
  end
end