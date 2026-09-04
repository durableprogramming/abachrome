# Abachrome::Converters::LabToXyz - CIELAB to XYZ color space converter
#
# This converter transforms colors from the CIELAB (L*a*b*) color space to the CIE 1931 XYZ
# color space by inverting the CIELAB transfer function and scaling the result by the
# reference white point. The inverse transfer function applies a cube for values above the
# CIE epsilon threshold and a linear segment below it, which keeps the transform well
# behaved near black.
#
# Key features:
# - Implements the standard CIELAB to XYZ transformation with the CIE epsilon threshold
# - Sources the D65 reference white point from the Illuminants registry
# - Applies the linear fallback segment for dark colors below the epsilon threshold
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper CIELAB source data
#
# CIELAB is a perceptually motivated color space used by the CSS lab() function, and XYZ is
# the device-independent reference space that connects it to the rest of the conversion
# pipeline.

module Abachrome
  module Converters
    class LabToXyz < Abachrome::Converters::Base
      # The CIE standard intent threshold, 216/24389, above which the cubic transfer
      # function is used.
      EPSILON = Rational(216, 24389)

      # The CIE standard slope constant, 24389/27, used by the linear segment of the
      # transfer function.
      KAPPA = Rational(24389, 27)

      # Converts a color from CIELAB color space to XYZ color space.
      #
      # @param lab_color [Abachrome::Color] The color in CIELAB color space to convert
      # @return [Abachrome::Color] A new Color object in XYZ color space with the converted coordinates
      # @raise [RuntimeError] If the provided color is not in CIELAB color space
      def self.convert(lab_color)
        raise_unless lab_color, :lab

        l, a, b = lab_color.coordinates.map { |_| AbcDecimal(_) }

        fy = (l + AD(16)) / AD(116)
        fx = (a / AD(500)) + fy
        fz = fy - (b / AD(200))

        wx, wy, wz = Illuminants::D65.white_point.map { |_| AD(_) / AD(100) }

        x = inverse_transfer(fx) * wx
        y = inverse_transfer(fy) * wy
        z = inverse_transfer(fz) * wz

        Color.new(ColorSpace.find(:xyz), [x, y, z], lab_color.alpha)
      end

      # Applies the inverse CIELAB transfer function to a single component.
      #
      # Values whose cube exceeds the CIE epsilon threshold are cubed directly. Values below
      # it fall back to the linear segment, which avoids the near-vertical slope the cubic
      # function has close to zero.
      #
      # @param f [AbcDecimal] The transformed component to invert
      # @return [AbcDecimal] The corresponding linear component, relative to the white point
      def self.inverse_transfer(f)
        cubed = f**3
        return cubed if cubed > AD(EPSILON)

        ((f * AD(116)) - AD(16)) / AD(KAPPA)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
