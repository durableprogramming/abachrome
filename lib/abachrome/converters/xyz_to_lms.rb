module Abachrome
  module Converters
    class XyzToLms < Abachrome::Converters::Base
      # Converts a color from XYZ color space to LMS color space.
      # 
      # This method implements the XYZ to LMS transformation using the standard
      # transformation matrix. The LMS color space represents the response of
      # the three types of cone cells in the human eye (Long, Medium, Short),
      # while XYZ is the CIE 1931 color space that forms the basis for most
      # other color space definitions.
      # 
      # @param xyz_color [Abachrome::Color] The color in XYZ color space
      # @raise [ArgumentError] If the input color is not in XYZ color space
      # @return [Abachrome::Color] The resulting color in LMS color space with
      # the same alpha as the input color
      def self.convert(xyz_color)
        raise_unless xyz_color, :xyz

        x, y, z = xyz_color.coordinates.map { |_| AbcDecimal(_) }

        # XYZ to LMS transformation matrix
        l = (x * AD("0.8189330101")) + (y * AD("0.3618667424")) - (z * AD("0.1288597137"))
        m = (x * AD("0.0329845436")) + (y * AD("0.9293118715")) + (z * AD("0.0361456387"))
        s = (x * AD("0.0482003018")) + (y * AD("0.2643662691")) + (z * AD("0.6338517070"))

        Color.new(ColorSpace.find(:lms), [l, m, s], xyz_color.alpha)
      end
    end
  end
end
