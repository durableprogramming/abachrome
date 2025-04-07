# frozen_string_literal: true

module Abachrome
  module Converters
    class SrgbToOklab
      def self.convert(srgb_color)
        # First convert sRGB to linear RGB
        lrgb_color = SrgbToLrgb.convert(srgb_color)

        # Then convert linear RGB to Oklab
        LrgbToOklab.convert(lrgb_color)
      end
    end
  end
end
