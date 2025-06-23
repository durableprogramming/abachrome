module Abachrome
  module Converters
    class OklabToLms < Abachrome::Converters::Base
      # Converts a color from OKLAB color space to LMS color space.
      # 
      # This method implements the first part of the OKLAB to linear RGB transformation,
      # converting OKLAB coordinates to the intermediate LMS (Long, Medium, Short) color space
      # which represents the response of the three types of cone cells in the human eye.
      # 
      # @param oklab_color [Abachrome::Color] The color in OKLAB color space
      # @raise [ArgumentError] If the input color is not in OKLAB color space
      # @return [Abachrome::Color] The resulting color in LMS color space with
      # the same alpha as the input color
      def self.convert(oklab_color)
        raise_unless oklab_color, :oklab

        l, a, b = oklab_color.coordinates.map { |_| AbcDecimal(_) }

        l_ = AbcDecimal((l ) +
                        (AD("0.39633779217376785678") * a) +
                        (AD("0.21580375806075880339") * b))

        m_ = AbcDecimal((l) -
                        (a * AD("-0.1055613423236563494")) +
                        (b * AD("-0.063854174771705903402")))
        
        s_ = AbcDecimal((l) -
                        (a * AD("-0.089484182094965759684")) +
                        (b * AD("-1.2914855378640917399")))

        # Apply cubic operation to convert from L'M'S' to LMS
        l_lms = AbcDecimal(l_)**3
        m_lms = AbcDecimal(m_)**3
        s_lms = AbcDecimal(s_)**3

        Color.new(ColorSpace.find(:lms), [l_lms, m_lms, s_lms], oklab_color.alpha)
      end
    end
  end
end

