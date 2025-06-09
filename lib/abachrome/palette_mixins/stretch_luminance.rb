#

module Abachrome
  module PaletteMixins
    module StretchLuminance
      def stretch_luminance(new_min: 0.0, new_max: 1.0)
        return self if empty?

        new_min = AbcDecimal(new_min)
        new_max = AbcDecimal(new_max)

        oklab_colors = @colors.map(&:to_oklab)
        current_min = oklab_colors.map { |c| c.coordinates[0] }.min
        current_max = oklab_colors.map { |c| c.coordinates[0] }.max

        range = current_max - current_min
        new_range = new_max - new_min

        self.class.new(
          oklab_colors.map do |color|
            l, a, b = color.coordinates
            scaled_l = if range.zero?
                         new_min
                       else
                         new_min + ((l - current_min) * new_range / range)
                       end

            Color.new(
              ColorSpace.find(:oklab),
              [scaled_l, a, b],
              color.alpha
            )
          end
        )
      end

      def stretch_luminance!(new_min: 0.0, new_max: 1.0)
        stretched = stretch_luminance(new_min: new_min, new_max: new_max)
        @colors = stretched.colors
        self
      end

      def normalize_luminance
        stretch_luminance(new_min: 0.0, new_max: 1.0)
      end

      def normalize_luminance!
        stretch_luminance!(new_min: 0.0, new_max: 1.0)
      end

      def compress_luminance(amount = 0.5)
        amount = AbcDecimal(amount)
        mid_point = AbcDecimal("0.5")
        stretch_luminance(
          new_min: mid_point - (mid_point * amount),
          new_max: mid_point + (mid_point * amount)
        )
      end

      def compress_luminance!(amount = 0.5)
        amount = AbcDecimal(amount)
        mid_point = AbcDecimal("0.5")
        stretch_luminance!(
          new_min: mid_point - (mid_point * amount),
          new_max: mid_point + (mid_point * amount)
        )
      end
    end
  end
end