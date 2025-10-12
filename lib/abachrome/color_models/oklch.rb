# Abachrome::ColorModels::Oklch - OKLCH color space model definition
#
# This module defines the OKLCH color model within the Abachrome color manipulation library.
# OKLCH is a cylindrical representation of the OKLAB color space using lightness, chroma, and hue
# coordinates. OKLCH offers intuitive color manipulation through its polar coordinate
# system where hue is represented as an angle and chroma represents colorfulness.
#
# Key features:
# - Registers the OKLCH color space with coordinate names [lightness, chroma, hue]
# - Provides conversion utilities between OKLCH and OKLAB color spaces
# - Uses L (lightness) ranging from 0 (black) to 1 (white)
# - Uses C (chroma) representing colorfulness intensity starting from 0
# - Uses h (hue) as an angle in degrees from 0 to 360
# - Includes normalization methods for proper coordinate ranges
# - Maintains high precision through AbcDecimal arithmetic for color transformations
#
# The OKLCH model is particularly useful for color adjustments that need to appear natural
# to human perception, such as hue shifts, saturation modifications, and lightness changes
# where the cylindrical coordinate system provides more intuitive control compared to
# rectangular color spaces.

module Abachrome
  module ColorModels
    class Oklch
      # Normalizes OKLCH color values to their standard ranges.
      # 
      # @param l [Numeric] The lightness component, will be clamped to range 0-1
      # @param c [Numeric] The chroma component, will be clamped to range 0-1
      # @param h [Numeric] The hue component in degrees, will be normalized to range 0-360
      # @return [Array<AbcDecimal>] Array containing the normalized [lightness, chroma, hue] values
      def self.normalize(l, c, h)
        l = AbcDecimal(l)
        c = AbcDecimal(c)
        h = AbcDecimal(h)

        # Normalize hue to 0-360 range
        h -= 360 while h >= 360
        h += 360 while h.negative?

        # Normalize lightness and chroma to 0-1 range
        l = l.clamp(0, 1)
        c = c.clamp(0, 1)

        [l, c, h]
      end

      # Converts OKLCH color coordinates to OKLab color coordinates.
      # 
      # @param l [Numeric] The lightness value in the OKLCH color space
      # @param c [Numeric] The chroma value in the OKLCH color space
      # @param h [Numeric] The hue value in degrees in the OKLCH color space
      # @return [Array<Numeric>] An array containing the OKLab coordinates [l, a, b]
      def self.to_oklab(l, c, h)
        # Convert OKLCH to OKLab
        h_rad = h * Math::PI / 180
        a = c * Math.cos(h_rad)
        b = c * Math.sin(h_rad)
        [l, a, b]
      end

      # Converts OKLab color coordinates to OKLCH color coordinates.
      # 
      # @param l [Numeric] The lightness component from OKLab.
      # @param a [Numeric] The green-red component from OKLab.
      # @param b [Numeric] The blue-yellow component from OKLab.
      # @return [Array<Numeric>] An array containing the OKLCH values [l, c, h] where:
      # - l is the lightness component (unchanged from OKLab)
      # - c is the chroma component (calculated from a and b)
      # - h is the hue angle in degrees (0-360)
      def self.from_oklab(l, a, b)
        # Convert OKLab to OKLCH
        c = Math.sqrt((a * a) + (b * b))
        h = Math.atan2(b, a) * 180 / Math::PI
        h += 360 if h.negative?
        [l, c, h]
      end
    end
  end
end

ColorSpace.register(
  :oklch,
  "OKLCh",
  %w[lightness chroma hue],
  nil,
  ["ok-lch"]
)

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.