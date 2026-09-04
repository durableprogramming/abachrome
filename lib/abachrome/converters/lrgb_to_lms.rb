# frozen_string_literal: true

module Abachrome
  module Converters
    class LrgbToLms < Abachrome::Converters::Base
      # Converts a color from linear RGB color space to LMS color space.
      #
      # This method converts linear RGB to XYZ first, then to LMS cone response space.
      # The LMS color space represents the response of the three types of cone cells
      # in the human eye (Long, Medium, Short wavelength sensitivity).
      #
      # @param lrgb_color [Abachrome::Color] The color in linear RGB color space
      # @raise [ArgumentError] If the input color is not in linear RGB color space
      # @return [Abachrome::Color] The resulting color in LMS color space with
      # the same alpha as the input color
      def self.convert(lrgb_color)
        raise_unless lrgb_color, :lrgb

        # Convert linear RGB to XYZ first
        xyz_color = Converters::LrgbToXyz.convert(lrgb_color)

        # Then convert XYZ to LMS
        Converters::XyzToLms.convert(xyz_color)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
