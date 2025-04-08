# frozen_string_literal: true

require_relative "oklch_to_oklab"
require_relative "oklab_to_srgb"

module Abachrome
  module Converters
    class OklchToSrgb < Abachrome::Converters::Base
      # Converts a color from OKLCH color space to sRGB color space.
      # This is done by first converting from OKLCH to OKLAB,
      # then from OKLAB to sRGB.
      # 
      # @param oklch_color [Abachrome::Color] Color in OKLCH color space
      # @return [Abachrome::Color] The converted color in sRGB color space
      def self.convert(oklch_color)
        # Convert OKLCh to OKLab first
        oklab_color = OklchToOklab.convert(oklch_color)
        
        # Then convert OKLab to sRGB 
        OklabToSrgb.convert(oklab_color)
      end
    end
  end
end