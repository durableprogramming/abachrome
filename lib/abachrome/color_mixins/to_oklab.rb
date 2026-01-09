# Abachrome::ColorMixins::ToOklab - OKLAB color space conversion functionality
#
# This mixin provides methods for converting colors to the OKLAB color space, which is a
# perceptually uniform color space designed for better color manipulation and comparison.
# OKLAB provides more intuitive lightness adjustments and color blending compared to
# traditional RGB color spaces, making it ideal for color science applications.
#
# Key features:
# - Convert colors to OKLAB with automatic converter lookup
# - Both non-destructive (to_oklab) and destructive (to_oklab!) conversion methods
# - Direct access to OKLAB components (lightness, a, b)
# - Utility methods for OKLAB array and value extraction
# - Optimized to return the same object when no conversion is needed
# - High-precision decimal arithmetic for accurate color science calculations
#
# The OKLAB color space uses three components: L (lightness), a (green-red axis), and
# b (blue-yellow axis), providing a more perceptually uniform representation of colors
# that better matches human visual perception compared to traditional color spaces.

require_relative "../converter"

module Abachrome
  module ColorMixins
    module ToOklab
      # Converts the current color to the OKLAB color space.
      # 
      # If the color is already in OKLAB, it returns the color unchanged.
      # Otherwise, it uses the Converter to transform the color to OKLAB.
      # 
      # @return [Abachrome::Color] A new Color object in the OKLAB color space
      def to_oklab
        return self if color_space.name == :oklab

        Converter.convert(self, :oklab)
      end

      # Converts the color to the OKLAB color space in place.
      # This method transforms the current color into OKLAB space,
      # modifying the original object by updating its color space
      # and coordinates if not already in OKLAB.
      # 
      # @example
      # color = Abachrome::Color.from_hex("#ff5500")
      # color.to_oklab!  # Color now uses OKLAB color space
      # 
      # @return [Abachrome::Color] self, with updated color space and coordinates
      def to_oklab!
        unless color_space.name == :oklab
          oklab_color = to_oklab
          @color_space = oklab_color.color_space
          @coordinates = oklab_color.coordinates
        end
        self
      end

      # Returns the lightness component (L) of the color in the OKLAB color space.
      # The lightness value ranges from 0 (black) to 1 (white) and represents
      # the perceived lightness of the color.
      # 
      # @return [AbcDecimal] The lightness (L) value from the OKLAB color space
      def lightness
        to_oklab.coordinates[0]
      end

      # Returns the L (Lightness) component from the OKLAB color space.
      # 
      # The L value represents perceptual lightness in the OKLAB color space,
      # typically ranging from 0 (black) to 1 (white).
      # 
      # @return [AbcDecimal] The L (Lightness) component from the OKLAB color space
      def l
        to_oklab.coordinates[0]
      end

      # Returns the 'a' component from the OKLAB color space (green-red axis).
      # 
      # The 'a' component in OKLAB represents the position on the green-red axis,
      # with negative values being more green and positive values being more red.
      # 
      # @return [AbcDecimal] The 'a' component value from the OKLAB color space.
      # @see #to_oklab For the full conversion to OKLAB color space
      def a
        to_oklab.coordinates[1]
      end

      # Returns the B value of the color in OKLAB color space.
      # 
      # This method first converts the color to OKLAB color space if needed,
      # then extracts the B component (blue-yellow axis), which is the third
      # coordinate in the OKLAB model.
      # 
      # @return [AbcDecimal] The B component value in OKLAB color space
      def b
        to_oklab.coordinates[2]
      end

      # Returns the OKLAB color space coordinates for this color.
      # 
      # @return [Array] An array of OKLAB coordinates [L, a, b] representing the color in OKLAB color space
      def oklab_values
        to_oklab.coordinates
      end

      # Returns an array representation of the color's coordinates in the OKLAB color space.
      # 
      # @return [Array<AbcDecimal>] An array containing the coordinates of the color
      # in the OKLAB color space in the order [L, a, b]
      def oklab_array
        to_oklab.coordinates
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.