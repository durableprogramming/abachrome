# Abachrome::ColorMixins::Lighten - Color lightness adjustment functionality
#
# This mixin provides methods for adjusting the lightness of colors by manipulating
# the L (lightness) component in the OKLAB color space. The OKLAB color space is used
# because it provides perceptually uniform lightness adjustments that appear more
# natural to the human eye compared to adjustments in other color spaces.
#
# Key features:
# - Lighten and darken colors with configurable amounts
# - Both non-destructive (lighten/darken) and destructive (lighten!/darken!) variants
# - Automatic clamping to valid lightness ranges [0, 1]
# - High-precision decimal arithmetic for accurate color calculations
# - Conversion to OKLAB color space for perceptually uniform adjustments
#
# The mixin includes both immutable methods that return new color instances and mutable
# methods that modify the current color object in place, providing flexibility for
# different use cases and performance requirements.

module Abachrome
  module ColorMixins
    module Lighten
      # Increases the lightness of a color by the specified amount in the OKLab color space.
      # This method works by extracting the L (lightness) component from the OKLab
      # representation of the color and increasing it by the given amount, ensuring
      # the result stays within the valid range of [0, 1].
      # 
      # @param amount [Numeric] The amount to increase the lightness by, as a decimal
      # value between 0 and 1. Defaults to 0.1 (10% increase).
      # @return [Abachrome::Color] A new Color instance with increased lightness.
      def lighten(amount = 0.1)
        amount = AbcDecimal(amount)
        oklab = to_oklab
        l, a, b = oklab.coordinates

        new_l = l + amount
        new_l = AbcDecimal("1.0") if new_l > 1
        new_l = AbcDecimal("0.0") if new_l.negative?

        Color.new(
          ColorSpace.find(:oklab),
          [new_l, a, b],
          alpha
        )
      end

      # Increases the lightness of the color by the specified amount and modifies the current color object.
      # This method changes the color in-place, mutating the current object. The color
      # is converted to a lightness-based color space if needed to perform the operation.
      # 
      # @param amount [Float] The amount to increase the lightness by, as a decimal value
      # between 0 and 1. Default is 0.1 (10% increase).
      # @return [Abachrome::Color] Returns self for method chaining.
      def lighten!(amount = 0.1)
        lightened = lighten(amount)
        @color_space = lightened.color_space
        @coordinates = lightened.coordinates
        @alpha = lightened.alpha
        self
      end

      # Darkens a color by decreasing its lightness value.
      # 
      # This method is effectively a convenience wrapper around the {#lighten} method,
      # passing a negative amount value to decrease the lightness instead of increasing it.
      # 
      # @param amount [Float] The amount to darken the color by, between 0 and 1.
      # Defaults to 0.1 (10% darker).
      # @return [Color] A new color instance with decreased lightness.
      # @see #lighten
      def darken(amount = 0.1)
        lighten(-amount)
      end

      # Decreases the lightness value of the color by the specified amount.
      # Modifies the color in place.
      # 
      # @param amount [Float] The amount to darken the color by, as a value between 0 and 1.
      # Defaults to 0.1 (10% darker).
      # @return [Abachrome::Color] Returns self with the modified lightness value.
      # @see #lighten!
      def darken!(amount = 0.1)
        lighten!(-amount)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.