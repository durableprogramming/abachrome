# frozen_string_literal: true

module Abachrome
  module ColorMixins
    module ToColorspace
      def to_color_space(target_space)
        return self if color_space == target_space

        Converter.convert(self, target_space.name)
      end

      def to_color_space!(target_space)
        unless color_space == target_space
          converted = to_color_space(target_space)
          @color_space = converted.color_space
          @coordinates = converted.coordinates
        end
        self
      end

      def convert_to(space_name)
        to_color_space(ColorSpace.find(space_name))
      end

      def convert_to!(space_name)
        to_color_space!(ColorSpace.find(space_name))
      end

      def in_color_space(space_name)
        convert_to(space_name)
      end

      def in_color_space!(space_name)
        convert_to!(space_name)
      end
    end
  end
end
