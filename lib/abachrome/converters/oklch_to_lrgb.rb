# frozen_string_literal: true

require_relative "oklab_to_lrgb"
require_relative "oklch_to_oklab"

module Abachrome
  module Converters
    class OklchToLrgb < Abachrome::Converters::Base
      def self.convert(oklch_color)
        oklab_color = OklchToOklab.convert(oklch_color)
        OklabToLrgb.convert(oklab_color)
      end
    end
  end
end
