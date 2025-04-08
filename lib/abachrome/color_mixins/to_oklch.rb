# frozen_string_literal: true

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