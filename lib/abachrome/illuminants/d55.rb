#

module Abachrome
  module Illuminants
    class D55 < Base
      def x
        0.33243
      end

      def y
        0.34744
      end

      def z
        0.32013
      end

      def temperature
        5503
      end

      def description
        "D55 (mid-morning/mid-afternoon daylight)"
      end
    end
  end
end