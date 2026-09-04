# Abachrome::Converters::HslToSrgb - HSL to sRGB color space converter
#
# This converter transforms colors from the HSL (hue, saturation, lightness) color space to
# the standard RGB (sRGB) color space using the chroma-based algorithm defined by the CSS
# Color specification. The hue angle selects one of six sectors of the color wheel, and the
# resulting base color is offset by a lightness match value to produce the final sRGB
# coordinates.
#
# Key features:
# - Implements the standard CSS HSL to sRGB conversion algorithm
# - Normalizes the hue angle into the 0-360 degree range before sector selection
# - Derives chroma from saturation and lightness for accurate color reproduction
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper HSL source data
#
# HSL is the color model used by the CSS hsl() and hsla() functions, expressing colors in
# terms that map closely to intuitive descriptions of hue, vividness, and brightness.

module Abachrome
  module Converters
    class HslToSrgb < Abachrome::Converters::Base
      # Converts a color from HSL color space to sRGB color space.
      #
      # @param hsl_color [Abachrome::Color] The color in HSL color space to convert
      # @return [Abachrome::Color] A new Color object in sRGB color space with the converted coordinates
      # @raise [RuntimeError] If the provided color is not in HSL color space
      def self.convert(hsl_color)
        raise_unless hsl_color, :hsl

        h, s, l = hsl_color.coordinates.map { |_| AbcDecimal(_) }

        Color.new(
          ColorSpace.find(:srgb),
          to_srgb(h, s, l),
          hsl_color.alpha
        )
      end

      # Converts hue, saturation, and lightness components into sRGB coordinates.
      #
      # The hue is normalized into the 0-360 degree range and divided into six 60-degree
      # sectors. Chroma is scaled by saturation and by the distance of lightness from the
      # extremes, and the intermediate component is interpolated within the active sector.
      #
      # @param h [AbcDecimal] The hue angle in degrees
      # @param s [AbcDecimal] The saturation component, in range 0..1
      # @param l [AbcDecimal] The lightness component, in range 0..1
      # @return [Array<AbcDecimal>] The red, green, and blue components, in range 0..1
      def self.to_srgb(h, s, l)
        h = h % AD(360)
        h_prime = h / AD(60)

        c = (AD(1) - (((AD(2) * l) - AD(1)).abs)) * s
        x = c * (AD(1) - ((h_prime % AD(2)) - AD(1)).abs)
        m = l - (c / AD(2))

        r, g, b = case h_prime.to_f
                  when 0...1 then [c, x, AD(0)]
                  when 1...2 then [x, c, AD(0)]
                  when 2...3 then [AD(0), c, x]
                  when 3...4 then [AD(0), x, c]
                  when 4...5 then [x, AD(0), c]
                  else [c, AD(0), x]
                  end

        [r + m, g + m, b + m]
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
