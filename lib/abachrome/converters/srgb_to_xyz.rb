# frozen_string_literal: true

module Abachrome
  module Converters
    class SrgbToXyz < Abachrome::Converters::Base
      # Converts a color from sRGB color space to XYZ color space.
      #
      # This method first converts sRGB to linear RGB by removing gamma correction,
      # then applies the linear RGB to XYZ transformation matrix. The XYZ color space
      # is the CIE 1931 color space that forms the basis for most other color space
      # definitions and serves as a device-independent reference.
      #
      # @param srgb_color [Abachrome::Color] The color in sRGB color space
      # @raise [ArgumentError] If the input color is not in sRGB color space
      # @return [Abachrome::Color] The resulting color in XYZ color space with
      # the same alpha as the input color
      def self.convert(srgb_color)
        raise_unless srgb_color, :srgb

        # Convert sRGB to linear RGB first
        lrgb_color = Converters::SrgbToLrgb.convert(srgb_color)

        # Then convert linear RGB to XYZ
        Converters::LrgbToXyz.convert(lrgb_color)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
