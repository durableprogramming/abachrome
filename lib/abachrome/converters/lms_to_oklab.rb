# frozen_string_literal: true

module Abachrome
  module Converters
    class LmsToOklab < Abachrome::Converters::Base
      # Converts a color from LMS color space to OKLAB color space.
      #
      # This method converts LMS to LRGB first, then to OKLAB. The LMS color space
      # represents the response of the three types of cone cells in the human eye.
      #
      # @param lms_color [Abachrome::Color] The color in LMS color space
      # @raise [ArgumentError] If the input color is not in LMS color space
      # @return [Abachrome::Color] The resulting color in OKLAB color space with
      # the same alpha as the input color
      def self.convert(lms_color)
        raise_unless lms_color, :lms

        # Convert LMS to LRGB first
        lrgb_color = Converters::LmsToLrgb.convert(lms_color)

        # Then convert LRGB to OKLAB
        Converters::LrgbToOklab.convert(lrgb_color)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
