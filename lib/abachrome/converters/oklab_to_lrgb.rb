# frozen_string_literal: true

module Abachrome
  module Converters
    class OklabToLrgb < Abachrome::Converters::Base
      def self.convert(oklab_color)
        raise_unless oklab_color, :oklab

        l, a, b = oklab_color.coordinates.map { |_| AbcDecimal(_) }

        l_ = AbcDecimal((l * AD("0.99999999845051981432")) +
                        (AD("0.39633779217376785678") * a) +
                        (AD("0.21580375806075880339") * b))

        m_ = AbcDecimal((l * AD("1.0000000088817607767")) -
                        (a * AD("0.1055613423236563494")) -
                        (b * AD("0.063854174771705903402")))
        s_ = AbcDecimal((l * AD("1.000000054672410917")) -
                        (a * AD("0.089484182094965759684")) -
                        (b * AD("1.2914855378640917399")))

        l = AbcDecimal(l_)**3
        m = AbcDecimal(m_)**3
        s = AbcDecimal(s_)**3

        r =  (l * AD("4.07674166134799")) -
             (m * AD("3.307711590408193")) +
             (s * AD("0.230969928729428"))
        g =  (l * AD("-1.2684380040921763")) +
             (m * AD("2.6097574006633715")) -
             (s * AD("0.3413193963102197"))
        b =  (l * AD("-0.004196086541837188")) -
             (m * AD("0.7034186144594493")) +
             (s * AD("1.7076147009309444"))

        output_coords = [r, g, b].map { |it| [it, 0].max }

        Color.new(ColorSpace.find(:lrgb), output_coords, oklab_color.alpha)
      end
    end
  end
end
