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

      # Validates whether the coordinates are valid for the HSV color model.
      # Each component (hue, saturation, value) must be in the range [0, 1].
      # 
      # @param coordinates [Array<Numeric>] An array of three values representing
      # hue (h), saturation (s), and value (v) in the range [0, 1]
      # @return [Boolean] true if all coordinates are within valid ranges, false otherwise
      def valid_coordinates?(coordinates)
        h, s, v = coordinates
        h >= 0 && h <= 1.0 &&
          s >= 0 && s <= 1.0 &&
          v >= 0 && v <= 1.0
      end
    end
  end
end