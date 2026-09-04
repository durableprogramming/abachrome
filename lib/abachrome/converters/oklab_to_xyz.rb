# frozen_string_literal: true

module Abachrome
  module Converters
    class OklabToXyz < Abachrome::Converters::Base
      # Converts a color from OKLAB color space to XYZ color space.
      #
      # This method converts OKLAB to LMS first, then to XYZ. The OKLAB color space
      # is a perceptually uniform color space, and XYZ is the CIE 1931 color space
      # that forms the basis for most other color space definitions.
      #
      # @param oklab_color [Abachrome::Color] The color in OKLAB color space
      # @raise [ArgumentError] If the input color is not in OKLAB color space
      # @return [Abachrome::Color] The resulting color in XYZ color space with
      # the same alpha as the input color
      def self.convert(oklab_color)
        raise_unless oklab_color, :oklab

        # Convert OKLAB to LMS first
        lms_color = Converters::OklabToLms.convert(oklab_color)

        # Then convert LMS to XYZ
        Converters::LmsToXyz.convert(lms_color)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
