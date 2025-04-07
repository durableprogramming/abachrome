# frozen_string_literal: true

require_relative "oklch_to_oklab"
require_relative "oklab_to_srgb"

module Abachrome
  module Converters
    class OklchToSrgb < Abachrome::Converters::Base
      def self.convert(oklch_color)
        # Convert OKLCh to OKLab first
        oklab_color = OklchToOklab.convert(oklch_color)
        
        # Then convert OKLab to sRGB 
        OklabToSrgb.convert(oklab_color)
      end
    end
  end
end
