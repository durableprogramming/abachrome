#

module Abachrome
  module Illuminants
    class D75 < Base
      def x
        0.299
      end

      def y
        0.315
      end

      def z
        0.386
      end

      def temperature
        7500
      end

      def description
        "North sky daylight / CIE standard illuminant D75"
      end
    end
  end
end