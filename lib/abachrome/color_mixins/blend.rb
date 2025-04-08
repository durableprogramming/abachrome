# frozen_string_literal: true

module Abachrome
  module ColorMixins
    module Blend
      # @method blend
      # Interpolates between two colors, creating a new color that is a blend of the two.
      # The blend happens in the specified color space or the current color space if none is provided.
      # #
      # @param [Abachrome::Color] other The color to blend with
      # @param [Float, Integer, #to_d] amount The blend amount between 0 and 1, where 0 returns the original color and 1 returns the other color. Defaults to 0.5 (midpoint)
      # @param [Symbol, nil] target_color_space The color space to perform the blend in (optional)
      # @return [Abachrome::Color] A new color representing the blend of the two colors
      # @example Blend two colors equally
      #   red.blend(blue, 0.5)
      # @example Blend with 25% of another color
      #   red.blend(blue, 0.25)
      # @example Blend in a specific color space
      #   red.blend(blue, 0.5, target_color_space: :oklab)
      def blend(other, amount = 0.5, target_color_space: nil)
        amount = AbcDecimal(amount)

        source = target_color_space ? to_color_space(target_color_space) : self
        other = other.to_color_space(source.color_space)

        l1, a1, b1 = coordinates.map { |_| AbcDecimal(_) }
        l2, a2, b2 = other.coordinates.map { |_| AbcDecimal(_) }

        blended_l = (AbcDecimal(1 - amount) * l1)     + (AbcDecimal(amount) * l2)
        blended_a = (AbcDecimal(1 - amount) * a1)     + (AbcDecimal(amount) * a2)
        blended_b = (AbcDecimal(1 - amount) * b1)     + (AbcDecimal(amount) * b2)

        blended_alpha = alpha + ((other.alpha - alpha) * amount)

        Color.new(
          color_space,
          [blended_l, blended_a, blended_b],
          blended_alpha
        )
      end

      # Blends this color with another color by the specified amount.
      # This is a destructive version of the blend method, modifying the current
      # color in place.
      # 
      # @param other [Abachrome::Color] The color to blend with
      # @param amount [Float] The blend amount, between 0.0 and 1.0, where 0.0 is
      # this color and 1.0 is the other color (default: 0.5)
      # @return [Abachrome::Color] Returns self after modification
      def blend!(other, amount = 0.5)
        blended = blend(other, amount)
        @color_space = blended.color_space
        @coordinates = blended.coordinates
        @alpha = blended.alpha
        self
      end

      # Alias for the blend method that mixes two colors together.
      # 
      # @param other [Abachrome::Color] The color to mix with
      # @param amount [Float] The amount to mix, between 0.0 and 1.0, where 0.0 returns the original color and 1.0 returns the other color (default: 0.5)
      # @return [Abachrome::Color] A new color resulting from the mix of the two colors
      def mix(other, amount = 0.5)
        blend(other, amount)
      end

      # Mix the current color with another color.
      # 
      # This method is an alias for blend!. It combines the current color with
      # the provided color at the specified amount.
      # 
      # @param other [Abachrome::Color] The color to mix with the current color
      # @param amount [Numeric] The amount of the other color to mix in, from 0 to 1 (default: 0.5)
      # @return [self] Returns the modified color object
      def mix!(other, amount = 0.5)
        blend!(other, amount)
      end
    end
  end
end
