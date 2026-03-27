# frozen_string_literal: true

module Abachrome
  module Converters
    class XyzToOklab < Abachrome::Converters::Base
      # Converts a color from XYZ color space to OKLAB color space.
      #
      # This method implements the XYZ to OKLAB transformation by first
      # converting XYZ coordinates to the intermediate LMS (Long, Medium, Short)
      # color space, then applying the LMS to OKLAB transformation matrix.
      #
      # @param xyz_color [Abachrome::Color] The color in XYZ color space
      # @raise [ArgumentError] If the input color is not in XYZ color space
      # @return [Abachrome::Color] The resulting color in OKLAB color space with
      # the same alpha as the input color
      def self.convert(xyz_color)
        raise_unless xyz_color, :xyz

        x, y, z = xyz_color.coordinates.map { |_| _.to_f }

        # XYZ to LMS transformation matrix
        l = (x * 0.8189330101.to_f) + (y * 0.3618667424.to_f) - (z * 0.1288597137.to_f)
        m = (x * 0.0329845436.to_f) + (y * 0.9293118715.to_f) + (z * 0.0361456387.to_f)
        s = (x * 0.0482003018.to_f) + (y * 0.2643662691.to_f) + (z * 0.6338517070.to_f)

        # Apply cube root transformation
        l_ = l.to_f**Rational(1, 3)
        m_ = m.to_f**Rational(1, 3)
        s_ = s.to_f**Rational(1, 3)

        # LMS to OKLAB transformation matrix
        lightness = (0.2104542553.to_f * l_) + (0.793617785.to_f * m_) - (0.0040720468.to_f * s_)
        a         = (1.9779984951.to_f * l_) - (2.4285922050.to_f * m_) + (0.4505937099.to_f * s_)
        b         = (0.0259040371.to_f * l_) + (0.7827717662.to_f * m_) - (0.8086757660.to_f * s_)

        Color.new(ColorSpace.find(:oklab), [lightness, a, b], xyz_color.alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
