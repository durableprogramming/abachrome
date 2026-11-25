# Abachrome::Converters::LabToSrgb - CIELAB to sRGB color space converter
#
# This converter transforms colors from the CIELAB color space to the standard RGB (sRGB)
# color space by routing through the intermediate XYZ and linear RGB color spaces. The
# CIELAB values are first converted to XYZ using the reference white point, then to linear
# RGB through the sRGB primaries matrix, and finally gamma corrected into sRGB.
#
# Key features:
# - Composes the CIELAB to XYZ, XYZ to linear RGB, and linear RGB to sRGB conversions
# - Reuses the shared gamma correction step rather than duplicating the transfer function
# - Maintains alpha channel transparency values through every stage of the conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
#
# CIELAB is the color model used by the CSS lab() function, and this converter provides the
# direct path to display-ready sRGB values that the parser and output layers need.

require_relative "lab_to_xyz"
require_relative "xyz_to_lrgb"
require_relative "lrgb_to_srgb"

module Abachrome
  module Converters
    class LabToSrgb < Abachrome::Converters::Base
      # Converts a color from CIELAB color space to sRGB color space.
      #
      # This is done by first converting from CIELAB to XYZ, then from XYZ to linear RGB,
      # and finally from linear RGB to sRGB.
      #
      # @param lab_color [Abachrome::Color] Color in CIELAB color space
      # @return [Abachrome::Color] The converted color in sRGB color space
      def self.convert(lab_color)
        LrgbToSrgb.convert(XyzToLrgb.convert(LabToXyz.convert(lab_color)))
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
