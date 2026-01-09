module Abachrome
  module Converters
    class LmsToLrgb < Abachrome::Converters::Base
      # Converts a color from LMS color space to linear RGB color space.
      # 
      # This method implements the final part of the OKLAB to linear RGB transformation,
      # converting LMS (Long, Medium, Short) coordinates to linear RGB coordinates
      # using the standard transformation matrix. The LMS color space represents
      # the response of the three types of cone cells in the human eye.
      # 
      # @param lms_color [Abachrome::Color] The color in LMS color space
      # @raise [ArgumentError] If the input color is not in LMS color space
      # @return [Abachrome::Color] The resulting color in linear RGB color space with
      # the same alpha as the input color
      def self.convert(lms_color)
        raise_unless lms_color, :lms

        l, m, s = lms_color.coordinates.map { |_| AbcDecimal(_) }

        r = (l * AD("4.07674166134799")) +
            (m * AD("-3.307711590408193")) +
            (s * AD("0.230969928729428"))
        g = (l * AD("-1.2684380040921763")) +
            (m * AD("2.6097574006633715")) +
            (s * AD("-0.3413193963102197"))
        b = (l * AD("-0.004196086541837188")) +
            (m * AD("-0.7034186144594493")) +
            (s * AD("1.7076147009309444"))

        output_coords = [r, g, b].map { |it| [it, 0].max }

        Color.new(ColorSpace.find(:lrgb), output_coords, lms_color.alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.