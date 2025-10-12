# Abachrome::ColorMixins::ToOklch - OKLCH color space conversion functionality
#
# This mixin provides methods for converting colors to the OKLCH color space, which is a
# cylindrical representation of the OKLAB color space using lightness, chroma, and hue
# coordinates. OKLCH offers intuitive color manipulation through its polar coordinate
# system where hue is represented as an angle and chroma represents colorfulness.
#
# Key features:
# - Convert colors to OKLCH with automatic converter lookup
# - Both non-destructive (to_oklch) and destructive (to_oklch!) conversion methods
# - Direct access to OKLCH components (lightness, chroma, hue)
# - Utility methods for OKLCH array and value extraction
# - Optimized to return the same object when no conversion is needed
# - High-precision decimal arithmetic for accurate color science calculations
#
# The OKLCH color space uses three components: L (lightness), C (chroma/colorfulness),
# and h (hue angle in degrees), providing an intuitive interface for color adjustments
# that better matches human perception compared to traditional RGB-based color spaces.

module Abachrome
  module ColorMixins
    module ToOklch
      # Converts the current color to the OKLCH color space.
      # 
      # This method transforms the color into the perceptually uniform OKLCH color space.
      # If the color is already in OKLCH, it returns itself unchanged. If the color is in
      # OKLAB, it directly converts from OKLAB to OKLCH. For all other color spaces, it
      # first converts to OKLAB as an intermediate step, then converts to OKLCH.
      # 
      # @return [Abachrome::Color] A new Color object in the OKLCH color space
      def to_oklch
        return self if color_space.name == :oklch

        if color_space.name == :oklab
          Converters::OklabToOklch.convert(self)
        else
          # For other color spaces, convert to OKLab first
          oklab_color = to_oklab
          Converters::OklabToOklch.convert(oklab_color)
        end
      end

      # Converts the color to OKLCH color space in-place.
      # This method transforms the current color to OKLCH color space, modifying
      # the original object instead of creating a new one. If the color is already
      # in OKLCH space, no conversion is performed.
      # 
      # @return [Abachrome::Color] self, allowing for method chaining
      def to_oklch!
        unless color_space.name == :oklch
          oklch_color = to_oklch
          @color_space = oklch_color.color_space
          @coordinates = oklch_color.coordinates
        end
        self
      end

      # Returns the lightness component of the color in the OKLCH color space.
      # This method provides direct access to the first coordinate of the OKLCH
      # representation of the color, which represents perceptual lightness.
      # 
      # @return [AbcDecimal] the lightness value in the OKLCH color space,
      # typically in the range of 0.0 to 1.0, where 0.0 is black and 1.0 is white
      def lightness
        to_oklch.coordinates[0]
      end

      # Returns the chroma value of the color by converting it to the OKLCH color space.
      # Chroma represents color intensity or saturation in the OKLCH color space.
      # 
      # @return [AbcDecimal] The chroma value (second coordinate) from the OKLCH color space
      def chroma
        to_oklch.coordinates[1]
      end

      # Returns the hue value of the color in the OKLCH color space.
      # 
      # @return [AbcDecimal] The hue component of the color in degrees (0-360)
      # from the OKLCH color space representation.
      def hue
        to_oklch.coordinates[2]
      end

      # Returns the OKLCH coordinates of the color.
      # 
      # @return [Array<AbcDecimal>] Array of OKLCH coordinates [lightness, chroma, hue] where:
      # - lightness: perceptual lightness component (0-1)
      # - chroma: colorfulness/saturation component
      # - hue: hue angle in degrees (0-360)
      def oklch_values
        to_oklch.coordinates
      end

      # Returns the OKLCH coordinates of the color as an array.
      # 
      # Converts the current color to OKLCH color space and returns its coordinates
      # as an array. The OKLCH color space represents colors using Lightness,
      # Chroma, and Hue components in a perceptually uniform way.
      # 
      # @return [Array<Numeric>] An array containing the OKLCH coordinates [lightness, chroma, hue]
      def oklch_array
        to_oklch.coordinates
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.