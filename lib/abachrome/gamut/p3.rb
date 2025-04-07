# frozen_string_literal: true

module Abachrome
  module Gamut
    class P3 < Base
      def initialize
        primaries = {
          red: [0.680, 0.320],
          green: [0.265, 0.690],
          blue: [0.150, 0.060]
        }
        super(:p3, primaries, :D65)
      end

      def contains?(coordinates)
        r, g, b = coordinates
        r >= 0 && r <= 1 &&
          g >= 0 && g <= 1 &&
          b >= 0 && b <= 1
      end
    end

    register(P3.new)
  end
end
