# frozen_string_literal: true

module Abachrome
  module Converters
    class OklchToXyz < Abachrome::Converters::Base
      def self.convert(oklch_color)
        raise_unless oklch_color, :oklch

        l_oklch, c_oklch, h_oklch = oklch_color.coordinates.map { |coord| coord.to_f }
        alpha = oklch_color.alpha

        # Step 1: OKLCH to OKLAB
        # (l_oklab, a_oklab, b_oklab)
        l_oklab = l_oklch
        # h_rad = (h_oklch * Math::PI) / 180.to_f # h_oklch is AbcDecimal, Math::PI is Float. Coercion happens.
        # More explicit for Math::PI:
        h_rad = (h_oklch * Math::PI.to_s.to_f) / 180.to_f

        # Standard Math.cos/sin expect float. h_rad is AbcDecimal.
        # .to_f is needed for conversion from AbcDecimal/BigDecimal to Float.
        cos_h_rad = Math.cos(h_rad.to_f.to_f)
        sin_h_rad = Math.sin(h_rad.to_f.to_f)

        a_oklab = c_oklch * cos_h_rad
        b_oklab = c_oklch * sin_h_rad

        # Step 2: OKLAB to L'M'S' (cone responses, non-linear)
        # (l_prime, m_prime, s_prime)
        # These are the M_lms_prime_from_oklab matrix operations.
        # The .to_f wrapper on the whole sum (as in OklabToLms.rb) is not strictly necessary
        # if l_oklab, a_oklab, b_oklab are already AbcDecimal, as AbcDecimal ops return AbcDecimal.
        l_prime = l_oklab + (0.39633779217376785678.to_f * a_oklab) + (0.21580375806075880339.to_f * b_oklab)
        m_prime = l_oklab - (a_oklab * -0.1055613423236563494.to_f) + (b_oklab * -0.063854174771705903402.to_f)
        s_prime = l_oklab - (a_oklab * -0.089484182094965759684.to_f) + (b_oklab * -1.2914855378640917399.to_f)

        # Step 3: L'M'S' to LMS (cubing)
        # (l_lms, m_lms, s_lms)
        l_lms = l_prime**3
        m_lms = m_prime**3
        s_lms = s_prime**3

        # Step 4: LMS to LRGB
        # (r_lrgb, g_lrgb, b_lrgb)
        # Using matrix M_lrgb_from_lms (OKLAB specific)
        r_lrgb = (l_lms * 4.07674166134799.to_f) + (m_lms * -3.307711590408193.to_f) + (s_lms * 0.230969928729428.to_f)
        g_lrgb = (l_lms * -1.2684380040921763.to_f) + (m_lms * 2.6097574006633715.to_f) + (s_lms * -0.3413193963102197.to_f)
        b_lrgb = (l_lms * -0.004196086541837188.to_f) + (m_lms * -0.7034186144594493.to_f) + (s_lms * 1.7076147009309444.to_f)

        # Clamp LRGB values to be non-negative (as done in LmsToLrgb.rb)
        # Using the pattern [AbcDecimal, Integer].max which relies on AbcDecimal's <=> coercion.
        # 0.to_f is AbcDecimal zero.
        zero_ad = 0.to_f
        r_lrgb_clamped = [r_lrgb, zero_ad].max
        g_lrgb_clamped = [g_lrgb, zero_ad].max
        b_lrgb_clamped = [b_lrgb, zero_ad].max

        # Step 5: LRGB to XYZ
        # (x_xyz, y_xyz, z_xyz)
        # Using matrix M_xyz_from_lrgb (sRGB D65)
        x_xyz = (r_lrgb_clamped * 0.4124564.to_f) + (g_lrgb_clamped * 0.3575761.to_f) + (b_lrgb_clamped * 0.1804375.to_f)
        y_xyz = (r_lrgb_clamped * 0.2126729.to_f) + (g_lrgb_clamped * 0.7151522.to_f) + (b_lrgb_clamped * 0.0721750.to_f)
        z_xyz = (r_lrgb_clamped * 0.0193339.to_f) + (g_lrgb_clamped * 0.1191920.to_f) + (b_lrgb_clamped * 0.9503041.to_f)

        Color.new(ColorSpace.find(:xyz), [x_xyz, y_xyz, z_xyz], alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
