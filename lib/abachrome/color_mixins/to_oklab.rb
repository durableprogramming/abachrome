# frozen_string_literal: true

require_relative "../converter"

module Abachrome
  module ColorMixins
    module ToOklab
      def to_oklab
        return self if color_space.name == :oklab

        Converter.convert(self, :oklab)
      end

      def to_oklab!
        unless color_space.name == :oklab
          oklab_color = to_oklab
          @color_space = oklab_color.color_space
          @coordinates = oklab_color.coordinates
        end
        self
      end

      def lightness
        to_oklab.coordinates[0]
      end

      def l
        to_oklab.coordinates[0]
      end

      def a
        to_oklab.coordinates[1]
      end

      def b
        to_oklab.coordinates[2]
      end

      def oklab_values
        to_oklab.coordinates
      end

      def oklab_array
        to_oklab.coordinates
      end
    end
  end
end
