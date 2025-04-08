# frozen_string_literal: true

require_relative "../converter"

module Abachrome
  module ColorMixins
    module ToLrgb
      # Converts this color to the Linear RGB (LRGB) color space.
      # This method transforms the current color to the linear RGB color space,
      # which uses a linear relationship between the stored numeric value and
      # the actual light intensity. If the color is already in the LRGB space,
      # it returns the current object without conversion.
      # 
      # @return [Abachrome::Color] A new color object in the LRGB color space,
      # or the original object if already in LRGB space
      def to_lrgb
        return self if color_space.name == :lrgb

        Converter.convert(self, :lrgb)
      end

      # Converts the current color to the linear RGB (LRGB) color space and updates
      # the receiver's state. If the color is already in LRGB space, this is a no-op.
      # 
      # Unlike #to_lrgb which returns a new color instance, this method modifies the
      # current object by changing its color space and coordinates to the LRGB equivalent.
      # 
      # @return [Abachrome::Color] the receiver itself, now in LRGB color space
      def to_lrgb!
        unless color_space.name == :lrgb
          lrgb_color = to_lrgb
          @color_space = lrgb_color.color_space
          @coordinates = lrgb_color.coordinates
        end
        self
      end

      # Returns the linear red component value of the color.
      # 
      # This method accesses the first coordinate from the color in linear RGB space.
      # Linear RGB values differ from standard RGB by using a non-gamma-corrected
      # linear representation of luminance.
      # 
      # @return [AbcDecimal] The linear red component value, typically in range [0, 1]
      def lred
        to_lrgb.coordinates[0]
      end

      # Retrieves the linear green (lgreen) coordinate from a color by converting it to
      # linear RGB color space first. Linear RGB uses a different scale than standard
      # sRGB, with values representing linear light energy rather than gamma-corrected
      # values.
      # 
      # @return [AbcDecimal] The linear green component value from the color's linear
      # RGB representation
      def lgreen
        to_lrgb.coordinates[1]
      end

      # Returns the linear blue channel value of this color after conversion to linear RGB color space.
      # 
      # This method converts the current color to the linear RGB color space and extracts the blue
      # component (the third coordinate).
      # 
      # @return [AbcDecimal] The linear blue component value, typically in the range [0, 1]
      def lblue
        to_lrgb.coordinates[2]
      end

      # Returns the coordinates of the color in the linear RGB color space.
      # 
      # @return [Array<AbcDecimal>] An array of three AbcDecimal values representing
      # the red, green, and blue components in linear RGB color space.
      def lrgb_values
        to_lrgb.coordinates
      end

      # Returns an array of sRGB values as integers in the 0-255 range.
      # This method converts the color to RGB, scales the values to the 0-255 range,
      # rounds to integers, and ensures they are clamped within the valid range.
      # 
      # @return [Array<Integer>] An array of three RGB integer values between 0-255
      def rgb_array
        to_rgb.coordinates.map { |c| (c * 255).round.clamp(0, 255) }
      end

      # Returns a hexadecimal string representation of the color in RGB format.
      # 
      # @return [String] A hexadecimal color code in the format '#RRGGBB' where RR, GG, and BB
      # are two-digit hexadecimal values for the red, green, and blue components respectively.
      # @example
      # color.rgb_hex  # => "#1a2b3c"
      def rgb_hex
        r, g, b = rgb_array
        format("#%02x%02x%02x", r, g, b)
      end
    end
  end
end