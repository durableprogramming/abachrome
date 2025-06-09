#

lib
abachrome
gamut
rec2020.rb

module Abachrome
  module Gamut
    class Rec2020 < Base
      def initialize
        primaries = {
          red: [0.708, 0.292],
          green: [0.170, 0.797],
          blue: [0.131, 0.046]
        }
        super(:rec2020, primaries, :D65)
      end
    end

    register(Rec2020.new)
  end
end