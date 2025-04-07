# frozen_string_literal: true

module Abachrome
  module PaletteMixins
    module Resample
      def resample(new_size)
        return self if new_size == size || empty?
        return self.class.new([@colors.first]) if new_size == 1

        step = (size - 1).to_f / (new_size - 1)

        self.class.new(
          (0...new_size).map do |i|
            index = i * step
            lower_index = index.floor
            upper_index = [lower_index + 1, size - 1].min

            if lower_index == upper_index
              @colors[lower_index]
            else
              fraction = index - lower_index
              @colors[lower_index].blend(@colors[upper_index], fraction)
            end
          end
        )
      end

      def resample!(new_size)
        resampled = resample(new_size)
        @colors = resampled.colors
        self
      end

      def expand(new_size)
        raise ArgumentError, "New size must be larger than current size" if new_size <= size

        resample(new_size)
      end

      def expand!(new_size)
        raise ArgumentError, "New size must be larger than current size" if new_size <= size

        resample!(new_size)
      end

      def reduce(new_size)
        raise ArgumentError, "New size must be smaller than current size" if new_size >= size

        resample(new_size)
      end

      def reduce!(new_size)
        raise ArgumentError, "New size must be smaller than current size" if new_size >= size

        resample!(new_size)
      end
    end
  end
end
