# frozen_string_literal: true

module Abachrome
  module ColorMixins
    module ToOklch
      def to_oklch
        return self if color_space.name == :oklch

        if color_space.name == :oklab
          Converters::OklabToOklch.convert(self)
        else
          # For other color spaces, convert to OKLab first
          oklab_color = to_oklab
          Converters::OklabToOklch.convert(oklab_color)
        end
      end

      def to_oklch!
        unless color_space.name == :oklch
          oklch_color = to_oklch
          @color_space = oklch_color.color_space
          @coordinates = oklch_color.coordinates
        end
        self
      end

      def lightness
        to_oklch.coordinates[0]
      end

      def chroma
        to_oklch.coordinates[1]
      end

      def hue
        to_oklch.coordinates[2]
      end

      def oklch_values
        to_oklch.coordinates
      end

      def oklch_array
        to_oklch.coordinates
      end
    end
  end
end
