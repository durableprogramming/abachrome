# frozen_string_literal: true

# Abachrome::ColorMixins::ToXyz - XYZ color space conversion functionality
#
# This mixin provides methods for converting colors to the XYZ color space, which is the
# CIE 1931 color space that forms the basis for most other color space definitions and
# serves as a device-independent reference color space. XYZ represents colors using
# tristimulus values that correspond to the response of the human visual system to light.
#
# Key features:
# - Convert colors to XYZ with automatic converter lookup
# - Both non-destructive (to_xyz) and destructive (to_xyz!) conversion methods
# - Direct access to XYZ components (x, y, z)
# - Utility methods for XYZ array and value extraction
# - Optimized to return the same object when no conversion is needed
# - High-precision decimal arithmetic for accurate color science calculations
#
# The XYZ color space uses three components: X, Y, and Z tristimulus values, providing
# a device-independent representation of colors that serves as the foundation for defining
# other color spaces, making it essential for accurate color transformations.

require_relative "../converter"

module Abachrome
  module ColorMixins
    module ToXyz
      # Converts the current color to the XYZ color space.
      #
      # If the color is already in XYZ, it returns the color unchanged.
      # Otherwise, it uses the Converter to transform the color to XYZ.
      #
      # @return [Abachrome::Color] A new Color object in the XYZ color space
      def to_xyz
        return self if color_space.name == :xyz

        Converter.convert(self, :xyz)
      end

      # Converts the color to the XYZ color space in place.
      # This method transforms the current color into XYZ space,
      # modifying the original object by updating its color space
      # and coordinates if not already in XYZ.
      #
      # @example
      # color = Abachrome::Color.from_hex("#ff5500")
      # color.to_xyz!  # Color now uses XYZ color space
      #
      # @return [Abachrome::Color] self, with updated color space and coordinates
      def to_xyz!
        unless color_space.name == :xyz
          xyz_color = to_xyz
          @color_space = xyz_color.color_space
          @coordinates = xyz_color.coordinates
        end
        self
      end

      # Returns the X component from the XYZ color space.
      #
      # The X component represents the mix of cone response curves chosen to be
      # nonnegative and represents a scale of the CIE RGB red primary.
      #
      # @return [AbcDecimal] The X tristimulus value from the XYZ color space
      def x
        to_xyz.coordinates[0]
      end

      # Returns the Y component from the XYZ color space.
      #
      # The Y component represents luminance, which closely matches human perception
      # of brightness. It corresponds to the CIE RGB green primary.
      #
      # @return [AbcDecimal] The Y tristimulus value from the XYZ color space
      def y
        to_xyz.coordinates[1]
      end

      # Returns the Z component from the XYZ color space.
      #
      # The Z component represents the CIE RGB blue primary and is roughly equal
      # to blue stimulation.
      #
      # @return [AbcDecimal] The Z tristimulus value from the XYZ color space
      def z
        to_xyz.coordinates[2]
      end

      # Returns the XYZ color space coordinates for this color.
      #
      # @return [Array<AbcDecimal>] An array of XYZ coordinates [X, Y, Z] representing the color in XYZ color space
      def xyz_values
        to_xyz.coordinates
      end

      # Returns an array representation of the color's coordinates in the XYZ color space.
      #
      # @return [Array<AbcDecimal>] An array containing the coordinates of the color
      # in the XYZ color space in the order [X, Y, Z]
      def xyz_array
        to_xyz.coordinates
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
