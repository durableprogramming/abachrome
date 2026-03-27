# frozen_string_literal: true

# Abachrome::ColorModels::YIQ - YIQ color space model utilities
#
# This module provides utility methods for the YIQ color model within the Abachrome
# color manipulation library. YIQ is a color space historically used by the NTSC
# television standard, separating luminance (Y) from chrominance (I and Q).
#
# Key features:
# - Separates brightness (luma) from color information
# - Y (luma): Weighted sum of RGB based on human eye sensitivity
# - I (In-phase): Orange-to-blue axis
# - Q (Quadrature): Purple-to-green axis
# - Supports legacy broadcast standards and computer vision applications
# - Uses Rec. 601 coefficients for luma calculation
#
# The YIQ model is essential for image processing algorithms that need to separate
# luminance from chrominance, including JPEG compression, grayscale conversion, and
# edge detection in computer vision applications.

module Abachrome
  module ColorModels
    class YIQ
      class << self
        # Normalizes YIQ color component values to their standard ranges.
        #
        # @param y [Numeric] Luma component (brightness), typically in range [0,1]
        # @param i [Numeric] In-phase component (orange-blue), typically in range [-0.5957, 0.5957]
        # @param q [Numeric] Quadrature component (purple-green), typically in range [-0.5226, 0.5226]
        # @return [Array<AbcDecimal>] Array of three normalized components as AbcDecimal objects
        def normalize(y, i, q)
          [y, i, q].map { |value| value.to_f }
        end
      end
    end
  end
end
