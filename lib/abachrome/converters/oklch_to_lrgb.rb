# frozen_string_literal: true

# Abachrome::Converters::OklchToLrgb - OKLCH to Linear RGB color space converter
#
# This converter transforms colors from the OKLCH color space to the linear RGB (LRGB) color space.
# The conversion is performed by first transforming OKLCH's cylindrical coordinates (Lightness, Chroma, Hue)
# into OKLAB's rectangular coordinates (L, a, b).
# Then, these OKLAB coordinates are converted to LRGB. This second part involves transforming
# OKLAB to an intermediate non-linear cone response space (L'M'S'), then to a linear
# cone response space (LMS), and finally from LMS to LRGB using appropriate matrices.
# All these steps are combined into a single direct conversion method.
#
# Key features:
# - Direct conversion from OKLCH to LRGB.
# - Combines cylindrical to rectangular conversion (OKLCH to OKLAB)
#   with the OKLAB to LRGB transformation pipeline (OKLAB -> L'M'S' -> LMS -> LRGB).
# - Uses AbcDecimal arithmetic for precise color science calculations.
# - Maintains alpha channel transparency values during conversion.
# - Validates input color space to ensure proper OKLCH source data.

module Abachrome
  module Converters
    class OklchToLrgb < Abachrome::Converters::Base
      def self.convert(oklch_color)
        raise_unless oklch_color, :oklch

        l_oklch, c_oklch, h_oklch = oklch_color.coordinates.map { |_| _.to_f }
        alpha = oklch_color.alpha

        # Step 1: OKLCH to OKLAB
        # l_oklab is the same as l_oklch
        l_oklab = l_oklch

        # Convert hue from degrees to radians
        # h_oklch is AbcDecimal, Math::PI is Float. Math::PI.to_f makes it AbcDecimal.
        # Division by 180.to_f ensures AbcDecimal arithmetic.
        h_rad = (h_oklch * Math::PI.to_f) / 180.to_f

        # Calculate a_oklab and b_oklab
        # Math.cos/sin take a float; .value of AbcDecimal is BigDecimal.
        # Math.cos/sin(big_decimal_value.to_f) wraps the result back to AbcDecimal.
        a_oklab = c_oklch * Math.cos(h_rad.value.to_f)
        b_oklab = c_oklch * Math.sin(h_rad.value.to_f)

        # Step 2: OKLAB to L'M'S' (cone responses, non-linear)
        # Constants from the inverse of M2 matrix (OKLAB to L'M'S')
        # l_oklab, a_oklab, b_oklab are already AbcDecimal.
        l_prime = l_oklab + (0.39633779217376785678.to_f * a_oklab) + (0.21580375806075880339.to_f * b_oklab)
        m_prime = l_oklab - (0.1055613423236563494.to_f * a_oklab) - (0.063854174771705903402.to_f * b_oklab)
        s_prime = l_oklab - (0.089484182094965759684.to_f * a_oklab) - (1.2914855378640917399.to_f * b_oklab)

        # Step 3: L'M'S' to LMS (cubing to linearize cone responses)
        l_lms = l_prime**3
        m_lms = m_prime**3
        s_lms = s_prime**3

        # Step 4: LMS to LRGB
        # Using matrix M_lrgb_from_lms (OKLAB specific)
        r_lrgb = (l_lms * 4.07674166134799.to_f) + (m_lms * -3.307711590408193.to_f) + (s_lms * 0.230969928729428.to_f)
        g_lrgb = (l_lms * -1.2684380040921763.to_f) + (m_lms * 2.6097574006633715.to_f) + (s_lms * -0.3413193963102197.to_f)
        b_lrgb = (l_lms * -0.004196086541837188.to_f) + (m_lms * -0.7034186144594493.to_f) + (s_lms * 1.7076147009309444.to_f)

        # Clamp LRGB values to be non-negative.
        # LRGB values can be outside [0,1] but should be >= 0.
        # Further clamping to [0,1] typically occurs when converting to display-referred spaces like sRGB.
        zero_ad = 0.to_f
        output_coords = [
          [r_lrgb, zero_ad].max,
          [g_lrgb, zero_ad].max,
          [b_lrgb, zero_ad].max
        ]

        Color.new(ColorSpace.find(:lrgb), output_coords, alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
