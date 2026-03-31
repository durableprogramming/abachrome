# frozen_string_literal: true

module Abachrome
  module Converters
    class SrgbToLms < Abachrome::Converters::Base
      # Converts a color from sRGB color space to LMS color space.
      #
      # This method converts sRGB to linear RGB first, then to LMS cone response space.
      # The LMS color space represents the response of the three types of cone cells
      # in the human eye (Long, Medium, Short wavelength sensitivity).
      #
      # @param srgb_color [Abachrome::Color] The color in sRGB color space
      # @raise [ArgumentError] If the input color is not in sRGB color space
      # @return [Abachrome::Color] The resulting color in LMS color space with
      # the same alpha as the input color
      def self.convert(srgb_color)
        raise_unless srgb_color, :srgb

        # Convert sRGB to linear RGB first
        lrgb_color = Converters::SrgbToLrgb.convert(srgb_color)

        # Then convert linear RGB to LMS
        Converters::LrgbToLms.convert(lrgb_color)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
