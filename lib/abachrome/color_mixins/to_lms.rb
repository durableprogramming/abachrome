# frozen_string_literal: true

# Abachrome::ColorMixins::ToLms - LMS color space conversion functionality
#
# This mixin provides methods for converting colors to the LMS color space, which represents
# the response of the three types of cone cells in the human eye (Long, Medium, Short wavelength
# sensitivity). LMS serves as an intermediate color space in the OKLAB transformation pipeline
# and provides a foundation for perceptually uniform color representations.
#
# Key features:
# - Convert colors to LMS with automatic converter lookup
# - Both non-destructive (to_lms) and destructive (to_lms!) conversion methods
# - Direct access to LMS components (long, medium, short)
# - Utility methods for LMS array and value extraction
# - Optimized to return the same object when no conversion is needed
# - High-precision decimal arithmetic for accurate color science calculations
#
# The LMS color space uses three components: L (long wavelength), M (medium wavelength),
# and S (short wavelength), representing cone cell responses that bridge the gap between
# linear RGB and perceptually uniform color spaces like OKLAB.

require_relative "../converter"

module Abachrome
  module ColorMixins
    module ToLms
      # Converts the current color to the LMS color space.
      #
      # If the color is already in LMS, it returns the color unchanged.
      # Otherwise, it uses the Converter to transform the color to LMS.
      #
      # @return [Abachrome::Color] A new Color object in the LMS color space
      def to_lms
        return self if color_space.name == :lms

        Converter.convert(self, :lms)
      end

      # Converts the color to the LMS color space in place.
      # This method transforms the current color into LMS space,
      # modifying the original object by updating its color space
      # and coordinates if not already in LMS.
      #
      # @example
      # color = Abachrome::Color.from_hex("#ff5500")
      # color.to_lms!  # Color now uses LMS color space
      #
      # @return [Abachrome::Color] self, with updated color space and coordinates
      def to_lms!
        unless color_space.name == :lms
          lms_color = to_lms
          @color_space = lms_color.color_space
          @coordinates = lms_color.coordinates
        end
        self
      end

      # Returns the L component (long wavelength) from the LMS color space.
      #
      # The L component represents the response of long-wavelength sensitive cone cells
      # in the human eye, which are most sensitive to red light.
      #
      # @return [AbcDecimal] The L (long wavelength) value from the LMS color space
      def long
        to_lms.coordinates[0]
      end

      # Returns the M component (medium wavelength) from the LMS color space.
      #
      # The M component represents the response of medium-wavelength sensitive cone cells
      # in the human eye, which are most sensitive to green light.
      #
      # @return [AbcDecimal] The M (medium wavelength) value from the LMS color space
      def medium
        to_lms.coordinates[1]
      end

      # Returns the S component (short wavelength) from the LMS color space.
      #
      # The S component represents the response of short-wavelength sensitive cone cells
      # in the human eye, which are most sensitive to blue light.
      #
      # @return [AbcDecimal] The S (short wavelength) value from the LMS color space
      def short
        to_lms.coordinates[2]
      end

      # Returns the LMS color space coordinates for this color.
      #
      # @return [Array<AbcDecimal>] An array of LMS coordinates [L, M, S] representing the color in LMS color space
      def lms_values
        to_lms.coordinates
      end

      # Returns an array representation of the color's coordinates in the LMS color space.
      #
      # @return [Array<AbcDecimal>] An array containing the coordinates of the color
      # in the LMS color space in the order [L, M, S]
      def lms_array
        to_lms.coordinates
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
