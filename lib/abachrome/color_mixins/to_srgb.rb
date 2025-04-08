# frozen_string_literal: true

require_relative "../converter"

module Abachrome
  module ColorMixins
    module ToSrgb
      # Converts the current color to the sRGB color space.
      # 
      # If the color is already in the sRGB color space, returns the color instance
      # unchanged. Otherwise, performs a color space conversion from the current
      # color space to sRGB.
      # 
      # @return [Abachrome::Color] A new Color instance in the sRGB color space,
      # or self if already in sRGB
      def to_srgb
        return self if color_space.name == :srgb

        Converter.convert(self, :srgb)
      end

      # Alias for #to_srgb method.
      # 
      # @return [Abachrome::Color] The color converted to sRGB color space
      def to_rgb
        # assume they mean srgb
        to_srgb
      end

      # Converts the color to the sRGB color space, mutating the current object.
      # If the color is already in sRGB space, this method does nothing.
      # @return [Abachrome::Color] self for method chaining
      def to_srgb!
        unless color_space.name == :srgb
          srgb_color = to_srgb
          @color_space = srgb_color.color_space
          @coordinates = srgb_color.coordinates
        end
        self
      end

      # Converts the current color to sRGB color space in place.
      # This is an alias for {#to_srgb!} as RGB commonly refers to sRGB
      # in web and design contexts.
      # 
      # @return [self] Returns self after converting to sRGB
      def to_rgb!
        # assume they mean srgb
        to_srgb!
      end

      # Returns the red component of the color in the sRGB color space.
      # 
      # @return [AbcDecimal] The red component value in the sRGB color space,
      # normalized between 0 and 1.
      def red
        to_srgb.coordinates[0]
      end

      # Returns the green component of the color in sRGB space.
      # 
      # This method converts the current color to sRGB color space if needed,
      # then extracts the green component (second coordinate).
      # 
      # @return [AbcDecimal] The green component value in the sRGB color space, typically in the range 0-1
      def green
        to_srgb.coordinates[1]
      end

      # Returns the blue component of the color in sRGB color space.
      # 
      # This method converts the current color to sRGB if needed and
      # extracts the third coordinate value (blue).
      # 
      # @return [AbcDecimal] The blue component value in sRGB space, typically in range 0-1
      def blue
        to_srgb.coordinates[2]
      end

      # Returns the RGB color values in the sRGB color space.
      # 
      # @return [Array<AbcDecimal>] An array of three AbcDecimal values representing
      # the red, green, and blue color components in the sRGB color space.
      def srgb_values
        to_srgb.coordinates
      end

      # Returns the RGB values of the color as coordinates in the sRGB color space.
      # 
      # @return [Array<Abachrome::AbcDecimal>] The RGB coordinates (red, green, blue) in sRGB color space
      def rgb_values
        to_srgb.coordinates
      end

      # Returns an array of RGB values (0-255) for this color.
      # 
      # This method converts the color to sRGB, then scales the component values
      # from the 0-1 range to the 0-255 range commonly used in RGB color codes.
      # Values are rounded to the nearest integer and clamped between 0 and 255.
      # 
      # @return [Array<Integer>] An array of three integers representing the [R, G, B]
      # values in the 0-255 range
      def rgb_array
        to_srgb.coordinates.map { |c| (c * 255).round.clamp(0, 255) }
      end

      # Returns a hexadecimal representation of this color in sRGB color space.
      # Converts the color to sRGB, then formats it as a hexadecimal string.
      # 
      # @return [String] A string in the format "#RRGGBB" where RR, GG, and BB are
      # the hexadecimal representations of the red, green, and blue components,
      # each ranging from 00 to FF.
      # @example
      # color.rgb_hex #=> "#3a7bc8"
      def rgb_hex
        r, g, b = rgb_array
        format("#%02x%02x%02x", r, g, b)
      end
    end
  end
end