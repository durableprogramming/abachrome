# frozen_string_literal: true

# Abachrome::ColorModels::CMYK - CMYK color space model utilities
#
# This module provides utility methods for the CMYK (Cyan, Magenta, Yellow, Key/Black)
# color model within the Abachrome color manipulation library. CMYK represents colors
# using the subtractive color synthesis model used in printing and physical media.
#
# Key features:
# - Subtractive color model (ink on paper, not light)
# - Four channels: Cyan, Magenta, Yellow, and Key (Black)
# - Supports Undercolor Removal (UCR) for ink savings
# - Supports Gray Component Replacement (GCR) for richer blacks
# - High-precision BigDecimal arithmetic for exact ink percentages
# - Essential for print media, PDF generation, and pre-press workflows
#
# The CMYK model is fundamental for professional printing, where the fourth channel
# (Black/Key) is added to achieve crisp text and deep shadows that cannot be produced
# by combining cyan, magenta, and yellow inks alone.


module Abachrome
  module ColorModels
    class CMYK
      include Abachrome::ToAbcd

      class << self
        # Normalizes CMYK color component values to the [0,1] range.
        #
        # @param c [Numeric] Cyan component (0-1 or 0-100 for percentages)
        # @param m [Numeric] Magenta component (0-1 or 0-100 for percentages)
        # @param y [Numeric] Yellow component (0-1 or 0-100 for percentages)
        # @param k [Numeric] Key/Black component (0-1 or 0-100 for percentages)
        # @return [Array<AbcDecimal>] Array of four normalized components as AbcDecimal objects
        def normalize(c, m, y, k)
          [c, m, y, k].map do |value|
            case value
            when String
              if value.end_with?("%")
                value.chomp("%".to_f) / 100.to_f
              else
                value.to_f
              end
            when Numeric
              if value > 1
                value.to_f / 100.to_f
              else
                value.to_f
              end
            end
          end
        end

        # Converts RGB values to CMYK using the standard naive conversion.
        # This produces high ink coverage and is generally not recommended for production.
        #
        # @param r [Numeric] Red component (0-1)
        # @param g [Numeric] Green component (0-1)
        # @param b [Numeric] Blue component (0-1)
        # @return [Array<AbcDecimal>] Array of [c, m, y, k] values
        def from_rgb_naive(r, g, b)
          r = r.to_f
          g = g.to_f
          b = b.to_f

          # Simple complementary conversion
          c = 1.to_f - r
          m = 1.to_f - g
          y = 1.to_f - b
          k = 0.to_f

          [c, m, y, k]
        end

        # Converts RGB values to CMYK using Undercolor Removal (UCR).
        # This extracts the gray component to the black (K) channel, reducing ink usage.
        #
        # @param r [Numeric] Red component (0-1)
        # @param g [Numeric] Green component (0-1)
        # @param b [Numeric] Blue component (0-1)
        # @param gcr_amount [Numeric] Gray Component Replacement amount (0-1), default 1.0 for full UCR
        # @return [Array<AbcDecimal>] Array of [c, m, y, k] values
        def from_rgb_ucr(r, g, b, gcr_amount = 1.0)
          r = r.to_f
          g = g.to_f
          b = b.to_f
          gcr = gcr_amount.to_f

          # Calculate complementary CMY values
          c = 1.to_f - r
          m = 1.to_f - g
          y = 1.to_f - b

          # Find the minimum (gray component)
          k = [c, m, y].min * gcr

          # Remove the gray component from CMY if k > 0
          if k.positive?
            c -= k
            m -= k
            y -= k
          end

          [c, m, y, k]
        end

        # Alias for from_rgb_ucr with full GCR (the standard approach).
        # GCR is essentially the same as UCR but allows control over how much
        # of the gray component to extract.
        #
        # @param r [Numeric] Red component (0-1)
        # @param g [Numeric] Green component (0-1)
        # @param b [Numeric] Blue component (0-1)
        # @param amount [Numeric] Amount of GCR to apply (0-1), default 1.0
        # @return [Array<AbcDecimal>] Array of [c, m, y, k] values
        def from_rgb_gcr(r, g, b, amount = 1.0)
          from_rgb_ucr(r, g, b, amount)
        end

        # Converts CMYK values back to RGB.
        # This is a straightforward inverse of the naive RGB→CMY conversion
        # plus the addition of the black channel.
        #
        # @param c [Numeric] Cyan component (0-1)
        # @param m [Numeric] Magenta component (0-1)
        # @param y [Numeric] Yellow component (0-1)
        # @param k [Numeric] Key/Black component (0-1)
        # @return [Array<AbcDecimal>] Array of [r, g, b] values
        def to_rgb(c, m, y, k)
          c = c.to_f
          m = m.to_f
          y = y.to_f
          k = k.to_f

          # Standard CMYK to RGB conversion
          r = (1.to_f - c) * (1.to_f - k)
          g = (1.to_f - m) * (1.to_f - k)
          b = (1.to_f - y) * (1.to_f - k)

          [r, g, b]
        end

        # Calculates the Total Area Coverage (TAC) for CMYK values.
        # TAC is the sum of all four ink percentages and is critical in print workflows
        # to prevent excessive ink that can cause smearing or paper damage.
        #
        # @param c [Numeric] Cyan component (0-1)
        # @param m [Numeric] Magenta component (0-1)
        # @param y [Numeric] Yellow component (0-1)
        # @param k [Numeric] Key/Black component (0-1)
        # @return [AbcDecimal] Total ink coverage as a decimal (0-4, often expressed as 0-400%)
        def total_area_coverage(c, m, y, k)
          c.to_f + m.to_f + y.to_f + k.to_f
        end
      end
    end
  end
end
