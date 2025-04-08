# frozen_string_literal: true

module Abachrome
  module ColorMixins
    module ToColorspace
      # Converts the current color to the specified target color space.
      # 
      # This method transforms the current color into an equivalent color in a different
      # color space. If the target space is the same as the current color space, no
      # conversion is performed and the current color is returned.
      # 
      # @param target_space [Abachrome::ColorSpace] The target color space to convert to
      # @return [Abachrome::Color] A new color object in the target color space, or self
      # if the target space is the same as the current color space
      def to_color_space(target_space)
        return self if color_space == target_space

        Converter.convert(self, target_space.name)
      end

      # Converts the color object to the specified target color space in-place.
      # This method modifies the current object by changing its color space and
      # coordinates to match the target color space.
      # 
      # @param target_space [Abachrome::ColorSpace] The color space to convert to
      # @return [Abachrome::Color] Returns self with modified color space and coordinates
      # @see #to_color_space The non-destructive version that returns a new color object
      def to_color_space!(target_space)
        unless color_space == target_space
          converted = to_color_space(target_space)
          @color_space = converted.color_space
          @coordinates = converted.coordinates
        end
        self
      end

      # Convert this color to a different color space.
      # 
      # @param space_name [String, Symbol] The name of the target color space to convert to.
      # @return [Abachrome::Color] A new Color object in the specified color space.
      # @example
      # # Convert a color from sRGB to OKLCH
      # rgb_color.convert_to(:oklch)
      # @see Abachrome::ColorSpace.find
      # @see #to_color_space
      def convert_to(space_name)
        to_color_space(ColorSpace.find(space_name))
      end

      # Converts this color to the specified color space in place.
      # 
      # @param space_name [String, Symbol] The name or identifier of the target color space to convert to.
      # @return [Abachrome::Color] Returns self with its values converted to the specified color space.
      # @raise [Abachrome::ColorSpaceNotFoundError] If the specified color space is not registered.
      # @see Abachrome::ColorSpace.find
      # @example
      # red = Abachrome::Color.new(1, 0, 0, color_space: :srgb)
      # red.convert_to!(:oklch) # Converts the red color to OKLCH space in place
      def convert_to!(space_name)
        to_color_space!(ColorSpace.find(space_name))
      end

      # Convert a color to a specified color space.
      # 
      # @param space_name [Symbol, String] The name of the color space to convert to.
      # @return [Abachrome::Color] A new Color instance in the specified color space.
      # @example
      # red_rgb = Abachrome::Color.new(:srgb, [1, 0, 0])
      # red_lch = red_rgb.in_color_space(:oklch)
      def in_color_space(space_name)
        convert_to(space_name)
      end

      # Converts the color to the specified color space and mutates the current object.
      # 
      # @param space_name [Symbol, String] The target color space to convert to (e.g., :oklch, :rgb, :lab)
      # @return [Abachrome::Color] Returns self after conversion
      # @see #convert_to!
      # @example
      # color = Abachrome::Color.new([255, 0, 0], :rgb)
      # color.in_color_space!(:oklch) # Color is now in OKLCH space
      def in_color_space!(space_name)
        convert_to!(space_name)
      end
    end
  end
end