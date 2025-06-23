module Abachrome
  module Converters
    class LmsToXyz < Abachrome::Converters::Base
      # Converts a color from LMS color space to XYZ color space.
      # 
      # This method implements the LMS to XYZ transformation using the standard
      # transformation matrix. The LMS color space represents the response of
      # the three types of cone cells in the human eye (Long, Medium, Short),
      # while XYZ is the CIE 1931 color space that forms the basis for most
      # other color space definitions.
      # 
      # @param lms_color [Abachrome::Color] The color in LMS color space
      # @raise [ArgumentError] If the input color is not in LMS color space
      # @return [Abachrome::Color] The resulting color in XYZ color space with
      # the same alpha as the input color
      def self.convert(lms_color)
        raise_unless lms_color, :lms

        l, m, s = lms_color.coordinates.map { |_| AbcDecimal(_) }

        # LMS to XYZ transformation matrix
        x = (l * AD("1.86006661")) - (m * AD("1.12948190")) + (s * AD("0.21989740"))
        y = (l * AD("0.36122292")) + (m * AD("0.63881308")) - (s * AD("0.00000000"))
        z = (l * AD("0.00000000")) - (m * AD("0.00000000")) + (s * AD("1.08906362"))

        Color.new(ColorSpace.find(:xyz), [x, y, z], lms_color.alpha)
      end
    end
  end
end
