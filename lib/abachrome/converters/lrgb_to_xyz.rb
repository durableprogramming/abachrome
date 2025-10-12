module Abachrome
  module Converters
    class LrgbToXyz < Abachrome::Converters::Base
      # Converts a color from linear RGB color space to XYZ color space.
      # 
      # This method implements the linear RGB to XYZ transformation using the standard
      # transformation matrix for the sRGB color space with D65 white point. The XYZ
      # color space is the CIE 1931 color space that forms the basis for most other
      # color space definitions and serves as a device-independent reference.
      # 
      # @param lrgb_color [Abachrome::Color] The color in linear RGB color space
      # @raise [ArgumentError] If the input color is not in linear RGB color space
      # @return [Abachrome::Color] The resulting color in XYZ color space with
      # the same alpha as the input color
      def self.convert(lrgb_color)
        raise_unless lrgb_color, :lrgb

        r, g, b = lrgb_color.coordinates.map { |_| AbcDecimal(_) }

        # Linear RGB to XYZ transformation matrix (sRGB/D65)
        x = (r * AD("0.4124564")) + (g * AD("0.3575761")) + (b * AD("0.1804375"))
        y = (r * AD("0.2126729")) + (g * AD("0.7151522")) + (b * AD("0.0721750"))
        z = (r * AD("0.0193339")) + (g * AD("0.1191920")) + (b * AD("0.9503041"))

        Color.new(ColorSpace.find(:xyz), [x, y, z], lrgb_color.alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.