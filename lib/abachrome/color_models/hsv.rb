# frozen_string_literal: true

module Abachrome
  module ColorModels
    class HSV < Base
      #
      # Internally, we use 0..1.0 values for hsv, unlike the standard 0..360, 0..255, 0..255.
      #
      # Values can be converted for output.
      #

      register :hsv, "HSV", %w[hue saturation value]

      def valid_coordinates?(coordinates)
        h, s, v = coordinates
        h >= 0 && h <= 1.0 &&
          s >= 0 && s <= 1.0 &&
          v >= 0 && v <= 1.0
      end
    end
  end
end
