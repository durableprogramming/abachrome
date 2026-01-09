module Abachrome
  module Converters
    class LmsToSrgb < Abachrome::Converters::Base
      # Converts a color from LMS color space to sRGB color space.
      # 
      # This method implements a two-step conversion process:
      # 1. First converts from LMS to linear RGB using the standard transformation matrix
      # 2. Then converts from linear RGB to sRGB by applying gamma correction
      # 
      # @param lms_color [Abachrome::Color] The color in LMS color space
      # @raise [ArgumentError] If the input color is not in LMS color space
      # @return [Abachrome::Color] The resulting color in sRGB color space with
      # the same alpha as the input color
      def self.convert(lms_color)
        # First convert LMS to linear RGB
        lrgb_color = LmsToLrgb.convert(lms_color)
        
        # Then convert linear RGB to sRGB
        LrgbToSrgb.convert(lrgb_color)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.