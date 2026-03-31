# frozen_string_literal: true

module Abachrome
  module Converters
    class XyzToSrgb < Abachrome::Converters::Base
      # Converts a color from XYZ color space to sRGB color space.
      #
      # This method first converts XYZ to linear RGB using the inverse transformation
      # matrix, then applies gamma correction to convert to sRGB. The XYZ color space
      # is the CIE 1931 color space that forms the basis for most other color space
      # definitions and serves as a device-independent reference.
      #
      # @param xyz_color [Abachrome::Color] The color in XYZ color space
      # @raise [ArgumentError] If the input color is not in XYZ color space
      # @return [Abachrome::Color] The resulting color in sRGB color space with
      # the same alpha as the input color
      def self.convert(xyz_color)
        raise_unless xyz_color, :xyz

        # Convert XYZ to linear RGB first
        lrgb_color = Converters::XyzToLrgb.convert(xyz_color)

        # Then convert linear RGB to sRGB
        Converters::LrgbToSrgb.convert(lrgb_color)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
