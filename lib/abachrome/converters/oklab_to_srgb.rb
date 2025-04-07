# frozen_string_literal: true

module Abachrome
  module Converters
    class OklabToSrgb < Abachrome::Converters::Base
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
