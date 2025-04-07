# frozen_string_literal: true

require_relative "../converter"

module Abachrome
  module ColorMixins
    module ToSrgb
      def to_srgb
        return self if color_space.name == :srgb

        Converter.convert(self, :srgb)
      end

      def to_rgb
        # assume they mean srgb
        to_srgb
      end

      def to_srgb!
        unless color_space.name == :srgb
          srgb_color = to_srgb
          @color_space = srgb_color.color_space
          @coordinates = srgb_color.coordinates
        end
        self
      end

      def to_rgb!
        # assume they mean srgb
        to_srgb!
      end

      def red
        to_srgb.coordinates[0]
      end

      def green
        to_srgb.coordinates[1]
      end

      def blue
        to_srgb.coordinates[2]
      end

      def srgb_values
        to_srgb.coordinates
      end

      def rgb_values
        to_srgb.coordinates
      end

      def rgb_array
        to_srgb.coordinates.map { |c| (c * 255).round.clamp(0, 255) }
      end

      def rgb_hex
        r, g, b = rgb_array
        format("#%02x%02x%02x", r, g, b)
      end
    end
  end
end
