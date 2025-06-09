# Abachrome::Gamut::SRGB - sRGB color gamut definition and validation
#
# This module defines the sRGB color gamut within the Abachrome color manipulation library.
# The sRGB gamut represents the range of colors that can be displayed on standard monitors
# and is the default color space for web content and most consumer displays. It uses the
# D65 white point and specific primary color coordinates that define the boundaries of
# reproducible colors in the sRGB color space.
#
# Key features:
# - Defines sRGB primary color coordinates for red, green, and blue
# - Uses D65 illuminant as the white point reference for proper color reproduction
# - Provides gamut boundary validation to ensure colors fall within displayable ranges
# - Implements color containment checking for RGB coordinate validation
# - Automatically registers with the global gamut registry for system-wide access
# - Serves as the foundation for sRGB color space conversions and display output
#
# The sRGB gamut is essential for ensuring colors are properly represented on standard
# displays and provides the color boundary definitions needed for gamut mapping operations
# when converting between different color spaces or preparing colors for web and print output.

require_relative "base"

module Abachrome
  module Gamut
    class SRGB < Base
      def initialize
        primaries = {
          red: [0.6400, 0.3300],
          green: [0.3000, 0.6000],
          blue: [0.1500, 0.0600]
        }
        super(:srgb, primaries, :D65)
      end

      def contains?(coordinates)
        r, g, b = coordinates
        r >= 0 && r <= 1 &&
          g >= 0 && g <= 1 &&
          b >= 0 && b <= 1
      end
    end

    register(SRGB.new)
  end
end