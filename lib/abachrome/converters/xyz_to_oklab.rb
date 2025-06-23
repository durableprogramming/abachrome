module Abachrome
  module Converters
    class XyzToOklab < Abachrome::Converters::Base
      # Converts a color from XYZ color space to OKLAB color space.
      # 
      # This method implements the XYZ to OKLAB transformation by first
      # converting XYZ coordinates to the intermediate LMS (Long, Medium, Short)
      # color space, then applying the LMS to OKLAB transformation matrix.
      # 
      # @param xyz_color [Abachrome::Color] The color in XYZ color space
      # @raise [ArgumentError] If the input color is not in XYZ color space
      # @return [Abachrome::Color] The resulting color in OKLAB color space with
      # the same alpha as the input color
      def self.convert(xyz_color)
        raise_unless xyz_color, :xyz

        x, y, z = xyz_color.coordinates.map { |_| AbcDecimal(_) }

        # XYZ to LMS transformation matrix
        l = (x * AD("0.8189330101")) + (y * AD("0.3618667424")) - (z * AD("0.1288597137"))
        m = (x * AD("0.0329845436")) + (y * AD("0.9293118715")) + (z * AD("0.0361456387"))
        s = (x * AD("0.0482003018")) + (y * AD("0.2643662691")) + (z * AD("0.6338517070"))

        # Apply cube root transformation
        l_ = AbcDecimal(l)**Rational(1, 3)
        m_ = AbcDecimal(m)**Rational(1, 3)
        s_ = AbcDecimal(s)**Rational(1, 3)

        # LMS to OKLAB transformation matrix
        lightness = (AD("0.2104542553") * l_) + (AD("0.793617785") * m_) - (AD("0.0040720468") * s_)
        a         = (AD("1.9779984951") * l_) - (AD("2.4285922050") * m_) + (AD("0.4505937099") * s_)
        b         = (AD("0.0259040371") * l_) + (AD("0.7827717662") * m_) - (AD("0.8086757660") * s_)

        Color.new(ColorSpace.find(:oklab), [lightness, a, b], xyz_color.alpha)
      end
    end
  end
end
