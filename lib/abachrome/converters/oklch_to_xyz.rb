module Abachrome
  module Converters
    class OklchToXyz < Abachrome::Converters::Base
      def self.convert(oklch_color)
        raise_unless oklch_color, :oklch

        l_oklch, c_oklch, h_oklch = oklch_color.coordinates.map { |coord| AbcDecimal(coord) }
        alpha = oklch_color.alpha

        # Step 1: OKLCH to OKLAB
        # (l_oklab, a_oklab, b_oklab)
        l_oklab = l_oklch
        # h_rad = (h_oklch * Math::PI) / AD(180) # h_oklch is AbcDecimal, Math::PI is Float. Coercion happens.
        # More explicit for Math::PI:
        h_rad = (h_oklch * AD(Math::PI.to_s)) / AD(180)

        # Standard Math.cos/sin expect float. h_rad is AbcDecimal.
        # .to_f is needed for conversion from AbcDecimal/BigDecimal to Float.
        cos_h_rad = AD(Math.cos(h_rad.to_f))
        sin_h_rad = AD(Math.sin(h_rad.to_f))

        a_oklab = c_oklch * cos_h_rad
        b_oklab = c_oklch * sin_h_rad

        # Step 2: OKLAB to L'M'S' (cone responses, non-linear)
        # (l_prime, m_prime, s_prime)
        # These are the M_lms_prime_from_oklab matrix operations.
        # The AbcDecimal() wrapper on the whole sum (as in OklabToLms.rb) is not strictly necessary
        # if l_oklab, a_oklab, b_oklab are already AbcDecimal, as AbcDecimal ops return AbcDecimal.
        l_prime = l_oklab + (AD("0.39633779217376785678") * a_oklab) + (AD("0.21580375806075880339") * b_oklab)
        m_prime = l_oklab - (a_oklab * AD("-0.1055613423236563494")) + (b_oklab * AD("-0.063854174771705903402"))
        s_prime = l_oklab - (a_oklab * AD("-0.089484182094965759684")) + (b_oklab * AD("-1.2914855378640917399"))

        # Step 3: L'M'S' to LMS (cubing)
        # (l_lms, m_lms, s_lms)
        l_lms = l_prime**3
        m_lms = m_prime**3
        s_lms = s_prime**3

        # Step 4: LMS to LRGB
        # (r_lrgb, g_lrgb, b_lrgb)
        # Using matrix M_lrgb_from_lms (OKLAB specific)
        r_lrgb = (l_lms * AD("4.07674166134799"))   + (m_lms * AD("-3.307711590408193")) + (s_lms * AD("0.230969928729428"))
        g_lrgb = (l_lms * AD("-1.2684380040921763")) + (m_lms * AD("2.6097574006633715")) + (s_lms * AD("-0.3413193963102197"))
        b_lrgb = (l_lms * AD("-0.004196086541837188"))+ (m_lms * AD("-0.7034186144594493")) + (s_lms * AD("1.7076147009309444"))

        # Clamp LRGB values to be non-negative (as done in LmsToLrgb.rb)
        # Using the pattern [AbcDecimal, Integer].max which relies on AbcDecimal's <=> coercion.
        # AD(0) is AbcDecimal zero.
        zero_ad = AD(0)
        r_lrgb_clamped = [r_lrgb, zero_ad].max
        g_lrgb_clamped = [g_lrgb, zero_ad].max
        b_lrgb_clamped = [b_lrgb, zero_ad].max
        
        # Step 5: LRGB to XYZ
        # (x_xyz, y_xyz, z_xyz)
        # Using matrix M_xyz_from_lrgb (sRGB D65)
        x_xyz = (r_lrgb_clamped * AD("0.4124564")) + (g_lrgb_clamped * AD("0.3575761")) + (b_lrgb_clamped * AD("0.1804375"))
        y_xyz = (r_lrgb_clamped * AD("0.2126729")) + (g_lrgb_clamped * AD("0.7151522")) + (b_lrgb_clamped * AD("0.0721750"))
        z_xyz = (r_lrgb_clamped * AD("0.0193339")) + (g_lrgb_clamped * AD("0.1191920")) + (b_lrgb_clamped * AD("0.9503041"))

        Color.new(ColorSpace.find(:xyz), [x_xyz, y_xyz, z_xyz], alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.