# Abachrome::Converters::LchToSrgb - CIELCH to sRGB color space converter
#
# This converter transforms colors from the CIELCH color space to the standard RGB (sRGB)
# color space by first converting the cylindrical CIELCH coordinates to rectangular CIELAB
# coordinates, then routing through the CIELAB to sRGB conversion path.
#
# Key features:
# - Composes the CIELCH to CIELAB and CIELAB to sRGB conversions
# - Maintains alpha channel transparency values through every stage of the conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
#
# CIELCH is the color model used by the CSS lch() function, and this converter provides the
# direct path to display-ready sRGB values that the parser and output layers need.

require_relative "lch_to_lab"
require_relative "lab_to_srgb"

module Abachrome
  module Converters
    class LchToSrgb < Abachrome::Converters::Base
      # Converts a color from CIELCH color space to sRGB color space.
      #
      # This is done by first converting from CIELCH to CIELAB, then from CIELAB to sRGB.
      #
      # @param lch_color [Abachrome::Color] Color in CIELCH color space
      # @return [Abachrome::Color] The converted color in sRGB color space
      def self.convert(lch_color)
        LabToSrgb.convert(LchToLab.convert(lch_color))
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
