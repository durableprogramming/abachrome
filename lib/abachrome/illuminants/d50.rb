#

module Abachrome
  module Illuminants
    class D50 < Base
      def self.x
        0.96422
      end

      def self.y
        1.0
      end

      def self.z
        0.82521
      end

      def self.temperature
        5003
      end

      def self.name
        "D50"
      end

      def self.description
        "CIE Standard Illuminant D50 (Horizon Light)"
      end
    end
  end
end