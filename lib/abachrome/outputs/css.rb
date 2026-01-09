#

require_relative "../color"
require_relative "../color_space"

module Abachrome
  module Outputs
    class CSS
      def self.format(color, gamut: nil, companding: nil)
        rgb_color = color.to_rgb
        r, g, b = rgb_color.coordinates
        a = rgb_color.alpha

        # Apply gamut mapping if provided
        r, g, b = gamut.map([r, g, b]) if gamut

        # Apply companding if provided
        if companding
          r = companding.call(r)
          g = companding.call(g)
          b = companding.call(b)
        end

        # Convert to 8-bit values
        r = (r * 255).round
        g = (g * 255).round
        b = (b * 255).round

        # Format based on alpha value
        return Kernel.format("rgba(%d, %d, %d, %.3f)", r, g, b, a) unless a == AbcDecimal.new("1.0")
        return Kernel.format("#%02x%02x%02x", r, g, b) unless r == g && g == b

        # Use shortened hex format for grayscale
        hex = Kernel.format("%02x", r)
        "##{hex}#{hex}#{hex}"
      end

      def self.format_hex(color, gamut: nil, companding: nil)
        rgb_color = color.to_rgb
        r, g, b = rgb_color.coordinates
        a = rgb_color.alpha

        # Apply gamut mapping if provided
        r, g, b = gamut.map([r, g, b]) if gamut

        # Apply companding if provided
        if companding
          r = companding.call(r)
          g = companding.call(g)
          b = companding.call(b)
        end

        r = (r * 255).round
        g = (g * 255).round
        b = (b * 255).round

        if a == AbcDecimal.new("1.0")
          Kernel.format("#%02x%02x%02x", r, g, b)
        else
          a = (a * 255).round
          Kernel.format("#%02x%02x%02x%02x", r, g, b, a)
        end
      end

      def self.format_rgb(color, gamut: nil, companding: nil)
        rgb_color = color.to_rgb
        r, g, b = rgb_color.coordinates
        a = rgb_color.alpha

        # Apply gamut mapping if provided
        r, g, b = gamut.map([r, g, b]) if gamut

        # Apply companding if provided
        if companding
          r = companding.call(r)
          g = companding.call(g)
          b = companding.call(b)
        end

        r = (r * 255).round
        g = (g * 255).round
        b = (b * 255).round

        if a == AbcDecimal.new("1.0")
          Kernel.format("rgb(%d, %d, %d)", r, g, b)
        else
          Kernel.format("rgba(%d, %d, %d, %.3f)", r, g, b, a)
        end
      end

      def self.format_oklab(color, gamut: nil, companding: nil, precision: 3)
        oklab_color = color.to_oklab
        l, a, b = oklab_color.coordinates
        alpha = oklab_color.alpha

        # Apply gamut mapping if provided
        l, a, b = gamut.map([l, a, b]) if gamut

        # Apply companding if provided
        if companding
          l = companding.call(l)
          a = companding.call(a)
          b = companding.call(b)
        end

        # Format with appropriate precision
        format_string = "%.#{precision}f %.#{precision}f %.#{precision}f"

        if alpha == AbcDecimal.new("1.0")
          Kernel.format("oklab(#{format_string})", l, a, b)
        else
          Kernel.format("oklab(#{format_string} / %.#{precision}f)", l, a, b, alpha)
        end
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.