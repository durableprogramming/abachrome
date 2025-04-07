# frozen_string_literal: true

require_relative "base"

module Abachrome
  module Gamut
    class SRGB < Base
      def initialize
        primaries = {
          red: [0.6400, 0.3300],
          green: [0.3000, 0.6000],
          blue: [0.1500, 0.0600]
        }
        super(:srgb, primaries, :D65)
      end

      def contains?(coordinates)
        r, g, b = coordinates
        r >= 0 && r <= 1 &&
          g >= 0 && g <= 1 &&
          b >= 0 && b <= 1
      end
    end

    register(SRGB.new)
  end
end
