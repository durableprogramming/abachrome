# Abachrome::Converters::OklabToLrgb - OKLAB to Linear RGB color space converter
#
# This converter transforms colors from the OKLAB color space to the linear RGB (LRGB) color space
# using the standard OKLAB transformation matrices. The conversion process first transforms
# OKLAB coordinates to the intermediate LMS (Long, Medium, Short) color space, then applies
# another matrix transformation to convert LMS coordinates to linear RGB coordinates.
#
# Key features:
# - Implements the official OKLAB inverse transformation algorithm with high-precision matrices
# - Converts OKLAB coordinates through intermediate LMS color space representation
# - Applies cubic transformation for perceptual uniformity in the OKLAB space
# - Maintains alpha channel transparency values during conversion
# - Uses AbcDecimal arithmetic for precise color science calculations
# - Validates input color space to ensure proper OKLAB source data
#
# The linear RGB color space provides a linear relationship between stored numeric values and
# actual light intensity, making it essential for accurate color calculations and serving as
# an intermediate color space for many color transformations, particularly when converting
# between different color models or preparing colors for display on standard monitors.

module Abachrome
  module Converters
    class OklabToLrgb < Abachrome::Converters::Base
      # Converts a color from OKLAB color space to linear RGB (LRGB) color space.
      #
      # This method performs a two-step conversion:
      # 1. OKLAB to LMS (cone response space)
      # 2. LMS to LRGB (linear RGB)
      #
      # @param oklab_color [Abachrome::Color] The color in OKLAB color space
      # @raise [ArgumentError] If the input color is not in OKLAB color space
      # @return [Abachrome::Color] The resulting color in linear RGB color space with
      # the same alpha as the input color
      def self.convert(oklab_color)
        raise_unless oklab_color, :oklab

        l_ok, a_ok, b_ok = oklab_color.coordinates.map { |_| AbcDecimal(_) }

        # Step 1: OKLAB to L'M'S' (cone responses, non-linear)
        # These are the M_lms_prime_from_oklab matrix operations.
        l_prime = AbcDecimal(l_ok + (AD("0.39633779217376785678") * a_ok) + (AD("0.21580375806075880339") * b_ok))
        m_prime = AbcDecimal(l_ok - (a_ok * AD("0.1055613423236563494")) - (b_ok * AD("0.063854174771705903402"))) # Note: original OklabToLms had + (b * AD("-0.063..."))
        s_prime = AbcDecimal(l_ok - (a_ok * AD("0.089484182094965759684")) - (b_ok * AD("1.2914855378640917399"))) # Note: original OklabToLms had + (b * AD("-1.291..."))


        # Step 2: L'M'S' to LMS (cubing)
        l_lms = l_prime**3
        m_lms = m_prime**3
        s_lms = s_prime**3

        # Step 3: LMS to LRGB
        # Using matrix M_lrgb_from_lms (OKLAB specific)
        r_lrgb = (l_lms * AD("4.07674166134799"))   + (m_lms * AD("-3.307711590408193")) + (s_lms * AD("0.230969928729428"))
        g_lrgb = (l_lms * AD("-1.2684380040921763")) + (m_lms * AD("2.6097574006633715")) + (s_lms * AD("-0.3413193963102197"))
        b_lrgb = (l_lms * AD("-0.004196086541837188"))+ (m_lms * AD("-0.7034186144594493")) + (s_lms * AD("1.7076147009309444"))

        # Clamp LRGB values to be non-negative (as done in LmsToLrgb.rb)
        # It's also common to clamp to [0, 1] range after conversion from a wider gamut space
        # For LRGB, often just ensuring non-negative is done, and further clamping happens
        # when converting to sRGB or other display spaces.
        # Here, we'll ensure non-negative as per LmsToLrgb.
        output_coords = [r_lrgb, g_lrgb, b_lrgb].map { |it| [it, AD(0)].max }


        Color.new(ColorSpace.find(:lrgb), output_coords, oklab_color.alpha)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.