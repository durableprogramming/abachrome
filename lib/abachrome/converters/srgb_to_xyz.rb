# frozen_string_literal: true

# Abachrome::Converters::SrgbToXyz - sRGB to XYZ color space converter
#
# This converter transforms colors from the standard RGB (sRGB) color space to the CIE 1931
# XYZ color space by routing through the intermediate linear RGB color space. The sRGB
# values are first linearized by removing the gamma correction, then transformed into XYZ
# through the sRGB primaries matrix with a D65 white point.
#
# Key features:
# - Composes the sRGB to linear RGB and linear RGB to XYZ conversions
# - Reuses the shared gamma decoding step rather than duplicating the transfer function
# - Maintains alpha channel transparency values through every stage of the conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
#
# XYZ is the device-independent reference space that connects sRGB to the CIELAB and CIELCH
# conversion paths, making this the entry point for converting display colors into those
# perceptually motivated spaces.

require_relative "srgb_to_lrgb"
require_relative "lrgb_to_xyz"

module Abachrome
  module Converters
    class SrgbToXyz < Abachrome::Converters::Base
      # Converts a color from sRGB color space to XYZ color space.
      #
      # This is done by first converting from sRGB to linear RGB by removing gamma
      # correction, then applying the linear RGB to XYZ transformation matrix.
      #
      # @param srgb_color [Abachrome::Color] Color in sRGB color space
      # @raise [RuntimeError] If the provided color is not in sRGB color space
      # @return [Abachrome::Color] The converted color in XYZ color space with the
      # same alpha as the input color
      def self.convert(srgb_color)
        raise_unless srgb_color, :srgb

        LrgbToXyz.convert(SrgbToLrgb.convert(srgb_color))
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
