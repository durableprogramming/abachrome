# Abachrome::ColorModels::RGB - RGB color space model utilities
#
# This module provides utility methods for the RGB color model within the Abachrome
# color manipulation library. RGB represents colors using red, green, and blue
# components, which is the most common color model for digital displays and web
# applications.
#
# Key features:
# - Normalizes RGB component values to the [0, 1] range from various input formats
# - Handles percentage values (with % suffix) by dividing by 100
# - Handles 0-255 range values by dividing by 255
# - Handles 0-1 range values directly without conversion
# - Supports string and numeric input types for flexible color specification
# - Maintains high precision through AbcDecimal arithmetic for color calculations
#
# The RGB model serves as a foundation for sRGB and linear RGB color spaces,
# providing the basic coordinate normalization needed for accurate color
# representation and conversion between different RGB-based color spaces.

module Abachrome
  module ColorModels
    class RGB
      class << self
        # Normalizes RGB color component values to the [0,1] range.
        # 
        # @param r [String, Numeric] Red component. If string with % suffix, interpreted as percentage;
        # if string without suffix or numeric > 1, interpreted as 0-255 range value;
        # if numeric ≤ 1, used directly.
        # @param g [String, Numeric] Green component. Same interpretation as red component.
        # @param b [String, Numeric] Blue component. Same interpretation as red component.
        # @return [Array<AbcDecimal>] Array of three normalized components as AbcDecimal objects,
        # each in the range [0,1].
        def normalize(r, g, b)
          [r, g, b].map do |value|
            case value
            when String
              if value.end_with?("%")
                AbcDecimal(value.chomp("%")) / AbcDecimal(100)
              else
                AbcDecimal(value) / AbcDecimal(255)
              end
            when Numeric
              if value > 1
                AbcDecimal(value) / AbcDecimal(255)
              else
                AbcDecimal(value)
              end
            end
          end
        end
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.