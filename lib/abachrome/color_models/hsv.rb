# Abachrome::ColorModels::HSV - HSV color space model definition
#
# This module defines the HSV (Hue, Saturation, Value) color model within the Abachrome
# color manipulation library. HSV provides an intuitive way to represent colors using
# cylindrical coordinates where hue represents the color type, saturation represents
# the intensity or purity of the color, and value represents the brightness.
#
# Key features:
# - Registers the HSV color space with coordinate names [hue, saturation, value]
# - Validates HSV coordinates to ensure all components are within the [0, 1] range
# - Uses normalized 0-1 values internally for consistency with other color models
# - Provides a more intuitive interface for color adjustments compared to RGB
# - Supports conversion to and from other color spaces through the converter system
#
# The HSV model is particularly useful for color picking interfaces and applications
# where users need to adjust color properties in a way that matches human perception
# of color relationships. All coordinate values are stored as AbcDecimal objects to
# maintain precision during color science calculations.

module Abachrome
  module ColorModels
    class HSV < Base
      #
      # Internally, we use 0..1.0 values for hsv, unlike the standard 0..360, 0..255, 0..255.
      #
      # Values can be converted for output.
      #

      register :hsv, "HSV", %w[hue saturation value]

      # Validates whether the coordinates are valid for the HSV color model.
      # Each component (hue, saturation, value) must be in the range [0, 1].
      # 
      # @param coordinates [Array<Numeric>] An array of three values representing
      # hue (h), saturation (s), and value (v) in the range [0, 1]
      # @return [Boolean] true if all coordinates are within valid ranges, false otherwise
      def valid_coordinates?(coordinates)
        h, s, v = coordinates
        h >= 0 && h <= 1.0 &&
          s >= 0 && s <= 1.0 &&
          v >= 0 && v <= 1.0
      end
    end
  end
end