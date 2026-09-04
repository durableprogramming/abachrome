# frozen_string_literal: true

# Abachrome::ColorMixins::Wcag - WCAG Accessibility Module
#
# This module provides methods for calculating color contrast ratios and checking
# WCAG 2.0/2.1 compliance for accessibility. It implements the relative luminance
# calculation with proper sRGB linearization according to WCAG specifications.
#
# Key features:
# - Calculate relative luminance using WCAG formula: Y = 0.2126R + 0.7152G + 0.0722B
# - Compute contrast ratio between two colors
# - Check WCAG 2.0 Level AA and AAA compliance for normal and large text
# - Check WCAG 2.1 non-text contrast compliance (3:1 minimum)
# - Predicate methods for easy accessibility checks
#
# References:
# - WCAG 2.0: https://www.w3.org/TR/WCAG20/
# - WCAG 2.1: https://www.w3.org/TR/WCAG21/
# - Relative luminance: https://www.w3.org/TR/WCAG20/#relativeluminancedef
# - Contrast ratio: https://www.w3.org/TR/WCAG20/#contrast-ratiodef

module Abachrome
  module ColorMixins
    module Wcag
      # Calculates the relative luminance of the color according to WCAG specifications.
      # Uses the formula: Y = 0.2126R + 0.7152G + 0.0722B
      # where R, G, B are linearized sRGB values.
      #
      # The linearization follows the sRGB specification:
      # - For values <= 0.03928: linear_value = value / 12.92
      # - For values > 0.03928: linear_value = ((value + 0.055) / 1.055) ^ 2.4
      #
      # @return [AbcDecimal] The relative luminance value between 0.0 (darkest) and 1.0 (lightest)
      def relative_luminance
        rgb = to_srgb
        r, g, b = rgb.coordinates

        # Linearize sRGB values
        r_linear = linearize_srgb_component(r)
        g_linear = linearize_srgb_component(g)
        b_linear = linearize_srgb_component(b)

        # Apply WCAG luminance coefficients (Rec. 709)
        AbcDecimal("0.2126") * r_linear +
          AbcDecimal("0.7152") * g_linear +
          AbcDecimal("0.0722") * b_linear
      end

      # Calculates the contrast ratio between this color and another color.
      # The contrast ratio is calculated according to WCAG:
      # (L1 + 0.05) / (L2 + 0.05)
      # where L1 is the relative luminance of the lighter color and
      # L2 is the relative luminance of the darker color.
      #
      # @param other [Abachrome::Color] The color to compare against
      # @return [AbcDecimal] The contrast ratio, ranging from 1:1 (no contrast) to 21:1 (maximum contrast)
      def contrast_ratio(other)
        l1 = relative_luminance
        l2 = other.relative_luminance

        # Ensure L1 is the lighter color
        l1, l2 = l2, l1 if l1 < l2

        (l1 + AbcDecimal("0.05")) / (l2 + AbcDecimal("0.05"))
      end

      # Checks if the contrast ratio with another color meets WCAG 2.0 Level AA standards.
      # AA requirements:
      # - Normal text (< 18pt or < 14pt bold): minimum 4.5:1 contrast ratio
      # - Large text (≥ 18pt or ≥ 14pt bold): minimum 3:1 contrast ratio
      #
      # @param other [Abachrome::Color] The color to compare against
      # @param large_text [Boolean] Whether the text is considered large (default: false)
      # @return [Boolean] true if the contrast meets AA standards
      def meets_wcag_aa?(other, large_text: false)
        ratio = contrast_ratio(other)
        minimum = large_text ? AbcDecimal("3.0") : AbcDecimal("4.5")
        ratio >= minimum
      end

      # Checks if the contrast ratio with another color meets WCAG 2.0 Level AAA standards.
      # AAA requirements:
      # - Normal text (< 18pt or < 14pt bold): minimum 7:1 contrast ratio
      # - Large text (≥ 18pt or ≥ 14pt bold): minimum 4.5:1 contrast ratio
      #
      # @param other [Abachrome::Color] The color to compare against
      # @param large_text [Boolean] Whether the text is considered large (default: false)
      # @return [Boolean] true if the contrast meets AAA standards
      def meets_wcag_aaa?(other, large_text: false)
        ratio = contrast_ratio(other)
        minimum = large_text ? AbcDecimal("4.5") : AbcDecimal("7.0")
        ratio >= minimum
      end

      # Checks if the contrast ratio with another color meets WCAG 2.1 non-text contrast requirements.
      # Non-text contrast applies to:
      # - Graphical objects (icons, graphs, infographics)
      # - User interface components (buttons, form inputs, focus indicators)
      # Requirement: minimum 3:1 contrast ratio
      #
      # @param other [Abachrome::Color] The color to compare against
      # @return [Boolean] true if the contrast meets the 3:1 minimum for non-text content
      def meets_wcag_non_text?(other)
        ratio = contrast_ratio(other)
        ratio >= AbcDecimal("3.0")
      end

      private

      # Linearizes a single sRGB component value according to the sRGB specification.
      # This is required before applying the luminance coefficients.
      #
      # @param component [AbcDecimal] The sRGB component value (0.0 to 1.0)
      # @return [AbcDecimal] The linearized component value
      def linearize_srgb_component(component)
        if component <= AbcDecimal("0.03928")
          component / AbcDecimal("12.92")
        else
          ((component + AbcDecimal("0.055")) / AbcDecimal("1.055"))**AbcDecimal("2.4")
        end
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
