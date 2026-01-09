#

module Abachrome
  module Parsers
    class Hex
      HEX_PATTERN = /^#?([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{4}|[0-9A-Fa-f]{8})$/

      def self.parse(input)
        hex = input.gsub(/^#/, "")
        return nil unless hex.match?(HEX_PATTERN)

        case hex.length
        when 3
          parse_short_hex(hex)
        when 4
          parse_short_hex_with_alpha(hex)
        when 6
          parse_full_hex(hex)
        when 8
          parse_full_hex_with_alpha(hex)
        end
      end

      def self.parse_short_hex(hex)
        r, g, b = hex.chars.map { |c| (c + c).to_i(16) }
        Color.from_rgb(r / 255.0, g / 255.0, b / 255.0)
      end

      def self.parse_short_hex_with_alpha(hex)
        r, g, b, a = hex.chars.map { |c| (c + c).to_i(16) }
        Color.from_rgb(r / 255.0, g / 255.0, b / 255.0, a / 255.0)
      end

      def self.parse_full_hex(hex)
        r = hex[0, 2].to_i(16)
        g = hex[2, 2].to_i(16)
        b = hex[4, 2].to_i(16)
        Color.from_rgb(r / 255.0, g / 255.0, b / 255.0)
      end

      def self.parse_full_hex_with_alpha(hex)
        r = hex[0, 2].to_i(16)
        g = hex[2, 2].to_i(16)
        b = hex[4, 2].to_i(16)
        a = hex[6, 2].to_i(16)
        Color.from_rgb(r / 255.0, g / 255.0, b / 255.0, a / 255.0)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.