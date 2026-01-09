# Abachrome::PaletteMixins::Interpolate - Color palette interpolation functionality
#
# This mixin provides methods for interpolating between adjacent colors in a palette to create
# smooth color transitions and gradients. The interpolation process inserts new colors between
# existing palette colors by blending them at calculated intervals, creating smoother color
# progressions ideal for gradients, color ramps, and visual transitions.
#
# Key features:
# - Insert specified number of interpolated colors between each adjacent color pair
# - Both non-destructive (interpolate) and destructive (interpolate!) variants
# - Uses color blending in the current color space for smooth transitions
# - Maintains original colors as anchor points in the interpolated result
# - High-precision decimal arithmetic for accurate color calculations
# - Preserves alpha values during interpolation process
#
# The mixin includes both immutable methods that return new palette instances and mutable
# methods that modify the current palette object in place, providing flexibility for
# different use cases and performance requirements. Interpolation is essential for creating
# smooth color gradients and ensuring adequate color resolution in palette-based applications.

module Abachrome
  module PaletteMixins
    module Interpolate
      def interpolate(count_between = 1)
        return self if count_between < 1 || size < 2

        new_colors = []
        @colors.each_cons(2) do |color1, color2|
          new_colors << color1
          step = AbcDecimal("1.0") / AbcDecimal(count_between + 1)

          (1..count_between).each do |i|
            amount = step * i
            new_colors << color1.blend(color2, amount)
          end
        end
        new_colors << last

        self.class.new(new_colors)
      end

      def interpolate!(count_between = 1)
        interpolated = interpolate(count_between)
        @colors = interpolated.colors
        self
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.