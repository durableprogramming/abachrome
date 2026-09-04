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

require_relative "../abc_decimal"

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
                value_without_percent = value.chomp("%")
                AbcDecimal(value_without_percent) / AbcDecimal(100)
              else
                AbcDecimal(value)
              end
            when Numeric
              if value > 1
                AbcDecimal(value) / AbcDecimal(100)
              else
                AbcDecimal(value)
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
          r = AbcDecimal(r)
          g = AbcDecimal(g)
          b = AbcDecimal(b)

          # Simple complementary conversion
          c = AbcDecimal(1) - r
          m = AbcDecimal(1) - g
          y = AbcDecimal(1) - b
          k = AbcDecimal(0)

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
          r = AbcDecimal(r)
          g = AbcDecimal(g)
          b = AbcDecimal(b)
          gcr = AbcDecimal(gcr_amount)

          # Calculate complementary CMY values
          c = AbcDecimal(1) - r
          m = AbcDecimal(1) - g
          y = AbcDecimal(1) - b

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
          c = AbcDecimal(c)
          m = AbcDecimal(m)
          y = AbcDecimal(y)
          k = AbcDecimal(k)

          # Standard CMYK to RGB conversion
          r = (AbcDecimal(1) - c) * (AbcDecimal(1) - k)
          g = (AbcDecimal(1) - m) * (AbcDecimal(1) - k)
          b = (AbcDecimal(1) - y) * (AbcDecimal(1) - k)

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
          AbcDecimal(c) + AbcDecimal(m) + AbcDecimal(y) + AbcDecimal(k)
        end
      end
    end
  end
end
