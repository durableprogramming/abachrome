# frozen_string_literal: true

module Abachrome
  module PaletteMixins
    module Interpolate
      def interpolate(count_between = 1)
        return self if count_between < 1 || size < 2

        new_colors = []
        @colors.each_cons(2) do |color1, color2|
          new_colors << color1
          step = AbcDecimal("1.0") / AbcDecimal(count_between + 1)

          (1..count_between).each do |i|
            amount = step * i
            new_colors << color1.blend(color2, amount)
          end
        end
        new_colors << last

        self.class.new(new_colors)
      end

      def interpolate!(count_between = 1)
        interpolated = interpolate(count_between)
        @colors = interpolated.colors
        self
      end
    end
  end
end
