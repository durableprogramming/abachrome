# frozen_string_literal: true

require_relative "oklab_to_lrgb"
require_relative "oklch_to_oklab"

module Abachrome
  module Converters
    class OklchToLrgb < Abachrome::Converters::Base
      # Converts a color from OKLCH color space to linear RGB color space.
      # This is a two-step conversion process that first converts from OKLCH to OKLAB,
      # then from OKLAB to linear RGB.
      # 
      # @param oklch_color [Abachrome::Color] A color in the OKLCH color space
      # @return [Abachrome::Color] The resulting color in linear RGB color space
      def self.convert(oklch_color)
        oklab_color = OklchToOklab.convert(oklch_color)
        OklabToLrgb.convert(oklab_color)
      end
    end
  end
end