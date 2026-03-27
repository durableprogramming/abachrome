# frozen_string_literal: true

module Abachrome
  module Converters
    class OklabToLms < Abachrome::Converters::Base
      # Converts a color from OKLAB color space to LMS color space.
      #
      # This method implements the first part of the OKLAB to linear RGB transformation,
      # converting OKLAB coordinates to the intermediate LMS (Long, Medium, Short) color space
      # which represents the response of the three types of cone cells in the human eye.
      #
      # @param oklab_color [Abachrome::Color] The color in OKLAB color space
      # @raise [ArgumentError] If the input color is not in OKLAB color space
      # @return [Abachrome::Color] The resulting color in LMS color space with
      # the same alpha as the input color
      def self.convert(oklab_color)
        raise_unless oklab_color, :oklab

        l, a, b = oklab_color.coordinates.map { |_| _.to_f }

        l_ = AbcDecimal(l +
                        (0.39633779217376785678.to_f * a) +
                        (0.21580375806075880339.to_f * b))

        m_ = AbcDecimal(l -
                        (a * -0.1055613423236563494.to_f) +
                        (b * -0.063854174771705903402.to_f))

        s_ = AbcDecimal(l -
                        (a * -0.089484182094965759684.to_f) +
                        (b * -1.2914855378640917399.to_f))

        # Apply cubic operation to convert from L'M'S' to LMS
        l_lms = l_.to_f**3
        m_lms = m_.to_f**3
        s_lms = s_.to_f**3

        Color.new(ColorSpace.find(:lms), [l_lms, m_lms, s_lms], oklab_color.alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
