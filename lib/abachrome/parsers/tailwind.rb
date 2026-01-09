#

module Abachrome
  module Parsers
    class Tailwind
      # Matches Tailwind color patterns like:
      # - gray-400
      # - blue-900/20 (with opacity)
      # - slate-50
      TAILWIND_PATTERN = /^([a-z]+)-(\d+)(?:\/(\d+(?:\.\d+)?))?$/

      def self.parse(input)
        match = input.match(TAILWIND_PATTERN)
        return nil unless match

        color_name = match[1]
        shade = match[2]
        opacity = match[3]

        # Look up the color in the Tailwind color palette
        color_shades = Named::Tailwind::COLORS[color_name]
        return nil unless color_shades

        rgb_values = color_shades[shade]
        return nil unless rgb_values

        # Convert RGB values to 0-1 range
        r, g, b = rgb_values.map { |v| v / 255.0 }

        # Calculate alpha from opacity percentage if provided
        alpha = if opacity
          opacity_value = opacity.to_f
          # Opacity in Tailwind is a percentage (0-100)
          opacity_value / 100.0
        else
          1.0
        end

        Color.from_rgb(r, g, b, alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
