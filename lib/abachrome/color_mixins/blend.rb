# frozen_string_literal: true

module Abachrome
  module ColorMixins
    module Blend
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

      def blend!(other, amount = 0.5)
        blended = blend(other, amount)
        @color_space = blended.color_space
        @coordinates = blended.coordinates
        @alpha = blended.alpha
        self
      end

      def mix(other, amount = 0.5)
        blend(other, amount)
      end

      def mix!(other, amount = 0.5)
        blend!(other, amount)
      end
    end
  end
end
