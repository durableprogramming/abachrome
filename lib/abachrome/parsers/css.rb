#
# Abachrome::Parsers::CSS - CSS color format parser
#
# This parser handles various CSS color formats including:
# - Named colors (red, blue, etc.)
# - Hex colors (#rgb, #rrggbb, #rgba, #rrggbbaa)
# - rgb() and rgba() functions
# - hsl() and hsla() functions
# - hwb() function
# - lab() and lch() functions
# - oklab() and oklch() functions
# - color() function
#

require_relative "hex"
require_relative "../named/css"
require_relative "../color"

module Abachrome
  module Parsers
    class CSS
      def self.parse(input)
        return nil unless input.is_a?(String)

        input = input.strip.downcase

        # Try named colors first
        named_color = parse_named_color(input)
        return named_color if named_color

        # Try hex colors
        hex_color = Hex.parse(input)
        return hex_color if hex_color

        # Try functional notation
        parse_functional_color(input)
      end

      private

      def self.parse_named_color(input)
        # Check if input matches a named color
        rgb_values = Named::CSS.method(input.to_sym)&.call
        return nil unless rgb_values

        # Convert 0-255 RGB values to 0-1 range
        r, g, b = rgb_values.map { |v| v / 255.0 }
        Color.from_rgb(r, g, b)
      rescue NameError
        nil
      end

      def self.parse_functional_color(input)
        case input
        when /^rgb\((.+)\)$/
          parse_rgb($1)
        when /^rgba\((.+)\)$/
          parse_rgba($1)
        when /^hsl\((.+)\)$/
          parse_hsl($1)
        when /^hsla\((.+)\)$/
          parse_hsla($1)
        when /^hwb\((.+)\)$/
          parse_hwb($1)
        when /^lab\((.+)\)$/
          parse_lab($1)
        when /^lch\((.+)\)$/
          parse_lch($1)
        when /^oklab\((.+)\)$/
          parse_oklab($1)
        when /^oklch\((.+)\)$/
          parse_oklch($1)
        when /^color\((.+)\)$/
          parse_color_function($1)
        else
          nil
        end
      end

      def self.parse_rgb(params)
        values = parse_color_values(params, 3)
        return nil unless values

        r, g, b = values
        Color.from_rgb(r, g, b)
      end

      def self.parse_rgba(params)
        values = parse_color_values(params, 4)
        return nil unless values

        r, g, b, a = values
        Color.from_rgb(r, g, b, a)
      end

      def self.parse_hsl(params)
        values = parse_hsl_values(params, 3)
        return nil unless values

        h, s, l = values
        rgb = hsl_to_rgb(h, s, l)
        Color.from_rgb(*rgb)
      end

      def self.parse_hsla(params)
        values = parse_hsl_values(params, 4)
        return nil unless values

        h, s, l, a = values
        rgb = hsl_to_rgb(h, s, l)
        Color.from_rgb(*rgb, a)
      end

      def self.parse_hwb(params)
        values = parse_hwb_values(params)
        return nil unless values

        h, w, b, a = values
        rgb = hwb_to_rgb(h, w, b)
        Color.from_rgb(*rgb, a)
      end

      def self.parse_lab(params)
        values = parse_lab_values(params, 3)
        return nil unless values

        l, a, b = values
        # Convert CIELAB to XYZ, then to sRGB
        xyz = lab_to_xyz(l, a, b)
        rgb = xyz_to_rgb(*xyz)
        Color.from_rgb(*rgb)
      end

      def self.parse_lch(params)
        values = parse_lch_values(params, 3)
        return nil unless values

        l, c, h = values
        # Convert CIELCH to CIELAB, then to XYZ, then to sRGB
        lab = lch_to_lab(l, c, h)
        xyz = lab_to_xyz(*lab)
        rgb = xyz_to_rgb(*xyz)
        Color.from_rgb(*rgb)
      end

      def self.parse_oklab(params)
        values = parse_oklab_values(params, 3)
        return nil unless values

        l, a, b = values
        Color.from_oklab(l, a, b)
      end

      def self.parse_oklch(params)
        values = parse_oklch_values(params, 3)
        return nil unless values

        l, c, h = values
        Color.from_oklch(l, c, h)
      end

      def self.parse_color_function(params)
        # Parse color(space values...)
        parts = params.split(/\s+/, 2)
        return nil unless parts.length == 2

        space = parts[0]
        values_str = parts[1]

        case space
        when "srgb"
          values = parse_color_values(values_str, 3)
          return nil unless values
          r, g, b = values
          Color.from_rgb(r, g, b)
        when "srgb-linear"
          values = parse_color_values(values_str, 3)
          return nil unless values
          r, g, b = values
          Color.from_lrgb(r, g, b)
        when "display-p3"
          # For now, approximate as sRGB
          values = parse_color_values(values_str, 3)
          return nil unless values
          r, g, b = values
          Color.from_rgb(r, g, b)
        when "a98-rgb"
          # For now, approximate as sRGB
          values = parse_color_values(values_str, 3)
          return nil unless values
          r, g, b = values
          Color.from_rgb(r, g, b)
        when "prophoto-rgb"
          # For now, approximate as sRGB
          values = parse_color_values(values_str, 3)
          return nil unless values
          r, g, b = values
          Color.from_rgb(r, g, b)
        when "rec2020"
          # For now, approximate as sRGB
          values = parse_color_values(values_str, 3)
          return nil unless values
          r, g, b = values
          Color.from_rgb(r, g, b)
        else
          nil
        end
      end

      # Helper methods for parsing values

      def self.parse_color_values(str, expected_count)
        values = str.split(/\s*,\s*/).map(&:strip)
        return nil unless values.length == expected_count

        values.map do |v|
          parse_numeric_value(v)
        end.compact
      end

      def self.parse_hsl_values(str, expected_count)
        values = str.split(/\s*,\s*/).map(&:strip)
        return nil unless values.length == expected_count

        parsed = []
        values.each_with_index do |v, i|
          if i == 0 # Hue
            val = parse_angle_value(v)
            return nil unless val
            parsed << val
          else # Saturation, Lightness, Alpha
            val = parse_percentage_or_number(v)
            return nil unless val
            parsed << val
          end
        end
        parsed
      end

      def self.parse_hwb_values(str)
        values = str.split(/\s*,\s*/).map(&:strip)
        return nil unless values.length >= 3

        h = parse_angle_value(values[0])
        w = parse_percentage_or_number(values[1])
        b = parse_percentage_or_number(values[2])
        a = values[3] ? parse_numeric_value(values[3]) : 1.0

        return nil unless h && w && b && a

        [h, w, b, a]
      end

      def self.parse_lab_values(str, expected_count)
        values = str.split(/\s+/, expected_count).map(&:strip)
        return nil unless values.length == expected_count

        l = parse_percentage_or_number(values[0])
        a = parse_numeric_value(values[1])
        b = parse_numeric_value(values[2])

        return nil unless l && a && b

        [l, a, b]
      end

      def self.parse_lch_values(str, expected_count)
        values = str.split(/\s+/, expected_count).map(&:strip)
        return nil unless values.length == expected_count

        l = parse_percentage_or_number(values[0])
        c = parse_numeric_value(values[1])
        h = parse_angle_value(values[2])

        return nil unless l && c && h

        [l, c, h]
      end

      def self.parse_oklab_values(str, expected_count)
        values = str.split(/\s+/, expected_count).map(&:strip)
        return nil unless values.length == expected_count

        l = parse_percentage_or_number(values[0])
        a = parse_numeric_value(values[1])
        b = parse_numeric_value(values[2])

        return nil unless l && a && b

        [l, a, b]
      end

      def self.parse_oklch_values(str, expected_count)
        values = str.split(/\s+/, expected_count).map(&:strip)
        return nil unless values.length == expected_count

        l = parse_percentage_or_number(values[0])
        c = parse_numeric_value(values[1])
        h = parse_angle_value(values[2])

        return nil unless l && c && h

        [l, c, h]
      end

      def self.parse_numeric_value(str)
        return nil unless str

        if str.end_with?('%')
          (str.chomp('%').to_f / 100.0)
        else
          str.to_f
        end
      rescue
        nil
      end

      def self.parse_percentage_or_number(str)
        return nil unless str

        if str.end_with?('%')
          str.chomp('%').to_f / 100.0
        else
          str.to_f
        end
      rescue
        nil
      end

      def self.parse_angle_value(str)
        return nil unless str

        if str.end_with?('deg')
          str.chomp('deg').to_f
        elsif str.end_with?('rad')
          str.chomp('rad').to_f * 180.0 / Math::PI
        elsif str.end_with?('grad')
          str.chomp('grad').to_f * 0.9
        elsif str.end_with?('turn')
          str.chomp('turn').to_f * 360.0
        else
          str.to_f # Assume degrees
        end
      rescue
        nil
      end

      # Color space conversion functions

      def self.hsl_to_rgb(h, s, l)
        h = h / 360.0 # Normalize hue to 0-1

        c = (1 - (2 * l - 1).abs) * s
        x = c * (1 - ((h * 6) % 2 - 1).abs)
        m = l - c / 2

        if h < 1.0/6
          r, g, b = c, x, 0
        elsif h < 2.0/6
          r, g, b = x, c, 0
        elsif h < 3.0/6
          r, g, b = 0, c, x
        elsif h < 4.0/6
          r, g, b = 0, x, c
        elsif h < 5.0/6
          r, g, b = x, 0, c
        else
          r, g, b = c, 0, x
        end

        [r + m, g + m, b + m]
      end

      def self.hwb_to_rgb(h, w, b)
        # Normalize values
        h = h / 360.0

        # Calculate RGB from HSL equivalent
        if w + b >= 1
          gray = w / (w + b)
          [gray, gray, gray]
        else
          rgb = hsl_to_rgb(h * 360, 1, 0.5)
          r, g, b_rgb = rgb

          # Apply whiteness and blackness
          r = r * (1 - w - b) + w
          g = g * (1 - w - b) + w
          b_rgb = b_rgb * (1 - w - b) + w

          [r, g, b_rgb]
        end
      end

      def self.lab_to_xyz(l, a, b)
        # CIELAB to XYZ conversion (D65 white point)
        y = (l + 16) / 116
        x = a / 500 + y
        z = y - b / 200

        x = x**3 > 0.008856 ? x**3 : (x - 16/116) / 7.787
        y = y**3 > 0.008856 ? y**3 : (y - 16/116) / 7.787
        z = z**3 > 0.008856 ? z**3 : (z - 16/116) / 7.787

        # D65 white point
        x *= 0.95047
        y *= 1.0
        z *= 1.08883

        [x, y, z]
      end

      def self.lch_to_lab(l, c, h)
        h_rad = h * Math::PI / 180.0
        a = c * Math.cos(h_rad)
        b = c * Math.sin(h_rad)
        [l, a, b]
      end

      def self.xyz_to_rgb(x, y, z)
        # XYZ to linear RGB
        r = x *  3.2406 + y * -1.5372 + z * -0.4986
        g = x * -0.9689 + y *  1.8758 + z *  0.0415
        b = x *  0.0557 + y * -0.2040 + z *  1.0570

        # Linear RGB to sRGB
        [r, g, b].map do |v|
          if v > 0.0031308
            1.055 * (v ** (1/2.4)) - 0.055
          else
            12.92 * v
          end
        end
      end
    end
  end
end