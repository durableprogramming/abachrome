# frozen_string_literal: true

require_relative "srgb_to_oklab"
require_relative "oklab_to_oklch"

module Abachrome
  module Converters
    class SrgbToOklch < Abachrome::Converters::Base
      def self.convert(srgb_color)
        # First convert sRGB to OKLab
        oklab_color = SrgbToOklab.convert(srgb_color)
        
        # Then convert OKLab to OKLCh
        OklabToOklch.convert(oklab_color)
      end
    end
  end
end
