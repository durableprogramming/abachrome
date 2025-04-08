# frozen_string_literal: true

module Abachrome
  module Converters
    class OklabToSrgb < Abachrome::Converters::Base
      # Converts a color from the Oklab color space to the sRGB color space.
      # This conversion is performed in two steps:
      # 1. First converts from Oklab to linear RGB
      # 2. Then converts from linear RGB to sRGB
      # 
      # @param oklab_color [Color] A color in the Oklab color space
      # @raise [ArgumentError] If the provided color is not in the Oklab color space
      # @return [Color] The converted color in the sRGB color space
      def self.convert(oklab_color)
        raise_unless oklab_color, :oklab

        # First convert Oklab to linear RGB
        lrgb_color = OklabToLrgb.convert(oklab_color)

        # Then use the LrgbToSrgb converter to go from linear RGB to sRGB
        LrgbToSrgb.convert(lrgb_color)
      end
    end
  end
end