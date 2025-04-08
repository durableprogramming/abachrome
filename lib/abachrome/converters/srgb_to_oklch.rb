# frozen_string_literal: true

require_relative "srgb_to_oklab"
require_relative "oklab_to_oklch"

module Abachrome
  module Converters
    class SrgbToOklch < Abachrome::Converters::Base
      # Converts an sRGB color to OKLCH color space
      # 
      # @param srgb_color [Abachrome::Color] The color in sRGB color space to convert
      # @return [Abachrome::Color] The converted color in OKLCH color space
      # @note This is a two-step conversion process: first from sRGB to OKLab, then from OKLab to OKLCH
      # @see SrgbToOklab
      # @see OklabToOklch
      def self.convert(srgb_color)
        # First convert sRGB to OKLab
        oklab_color = SrgbToOklab.convert(srgb_color)
        
        # Then convert OKLab to OKLCh
        OklabToOklch.convert(oklab_color)
      end
    end
  end
end