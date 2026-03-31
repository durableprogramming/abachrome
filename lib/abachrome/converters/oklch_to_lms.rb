# frozen_string_literal: true

module Abachrome
  module Converters
    class OklchToLms < Abachrome::Converters::Base
      # Converts a color from OKLCH color space to LMS color space.
      #
      # This method converts OKLCH to OKLAB first, then to LMS. The OKLCH color space
      # is a cylindrical representation of OKLAB using lightness, chroma, and hue.
      #
      # @param oklch_color [Abachrome::Color] The color in OKLCH color space
      # @raise [ArgumentError] If the input color is not in OKLCH color space
      # @return [Abachrome::Color] The resulting color in LMS color space with
      # the same alpha as the input color
      def self.convert(oklch_color)
        raise_unless oklch_color, :oklch

        # Convert OKLCH to OKLAB first
        oklab_color = Converters::OklchToOklab.convert(oklch_color)

        # Then convert OKLAB to LMS
        Converters::OklabToLms.convert(oklab_color)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
