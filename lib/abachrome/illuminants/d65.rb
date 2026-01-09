#

module Abachrome
  module Illuminants
    class D65 < Base
      def self.x
        95.047
      end

      def self.y
        100.000
      end

      def self.z
        108.883
      end

      def self.white_point
        [x, y, z]
      end

      def self.temperature
        6504
      end

      def self.name
        "D65"
      end

      def self.description
        "CIE Standard Illuminant D65 - represents average daylight with a correlated color temperature of 6504K"
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.