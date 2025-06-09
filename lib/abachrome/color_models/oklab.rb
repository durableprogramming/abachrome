# Abachrome::ColorModels::Oklab - OKLAB color space model definition
#
# This module defines the OKLAB color model within the Abachrome color manipulation library.
# OKLAB is a perceptually uniform color space designed for better color manipulation and
# comparison, providing more intuitive lightness adjustments and color blending compared
# to traditional RGB color spaces.
#
# Key features:
# - Registers the OKLAB color space with coordinate names [lightness, a, b]
# - Uses L (lightness) ranging from 0 (black) to 1 (white)
# - Uses a and b components representing green-red and blue-yellow axes respectively
# - Provides perceptually uniform color space for accurate color science calculations
# - Serves as an intermediate color space for conversions to OKLCH and other models
# - Maintains high precision through AbcDecimal arithmetic for color transformations
#
# The OKLAB model is particularly useful for color adjustments that need to appear natural
# to human perception, such as lightness modifications, color blending, and gamut mapping
# operations where perceptual uniformity is important.

module Abachrome
  module ColorModels
    class Oklab
    end
  end
end

ColorSpace.register(
  :oklab,
  "Oklab",
  %w[l a b],
  nil,
  ["ok-lab"]
)