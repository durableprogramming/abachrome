# frozen_string_literal: true

module Abachrome
  module ColorMixins
    module Lighten
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

      def lighten!(amount = 0.1)
        lightened = lighten(amount)
        @color_space = lightened.color_space
        @coordinates = lightened.coordinates
        @alpha = lightened.alpha
        self
      end

      def darken(amount = 0.1)
        lighten(-amount)
      end

      def darken!(amount = 0.1)
        lighten!(-amount)
      end
    end
  end
end
