# frozen_string_literal: true

require_relative "../converter"

module Abachrome
  module ColorMixins
    module ToLrgb
      def to_lrgb
        return self if color_space.name == :lrgb

        Converter.convert(self, :lrgb)
      end

      def to_lrgb!
        unless color_space.name == :lrgb
          lrgb_color = to_lrgb
          @color_space = lrgb_color.color_space
          @coordinates = lrgb_color.coordinates
        end
        self
      end

      def lred
        to_lrgb.coordinates[0]
      end

      def lgreen
        to_lrgb.coordinates[1]
      end

      def lblue
        to_lrgb.coordinates[2]
      end

      def lrgb_values
        to_lrgb.coordinates
      end

      def rgb_array
        to_rgb.coordinates.map { |c| (c * 255).round.clamp(0, 255) }
      end

      def rgb_hex
        r, g, b = rgb_array
        format("#%02x%02x%02x", r, g, b)
      end
    end
  end
end
