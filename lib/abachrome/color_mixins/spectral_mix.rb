# Abachrome::ColorMixins::SpectralMix - Kubelka-Munk spectral color mixing
#
# This mixin adds spectral mixing capabilities to Color objects using the
# Kubelka-Munk theory for realistic paint-like color mixing.
#
# Unlike simple RGB blending or interpolation in perceptual color spaces,
# spectral mixing simulates how real pigments interact with light through
# absorption and scattering. This produces more realistic results, especially
# when mixing complementary colors.
#
# Key features:
# - Physics-based color mixing using Kubelka-Munk theory
# - Avoids muddy browns when mixing complementary colors
# - Supports tinting strength for different pigment concentrations
# - More realistic than linear RGB or LAB interpolation

module Abachrome
  module ColorMixins
    module SpectralMix
      # Mix this color with another color using Kubelka-Munk spectral mixing.
      #
      # This method produces more realistic color mixing than simple RGB or LAB
      # interpolation by simulating how real pigments absorb and scatter light.
      #
      # @param other [Abachrome::Color] The color to mix with
      # @param amount [Float] The mix ratio, between 0 and 1. 0.5 means equal mixing.
      #   Values closer to 0 favor this color, values closer to 1 favor the other color.
      # @param tinting_strength_self [Float] Tinting strength of this color (default: 1.0)
      #   Higher values mean stronger pigment concentration
      # @param tinting_strength_other [Float] Tinting strength of other color (default: 1.0)
      # @return [Abachrome::Color] A new color representing the spectral mix
      #
      # @example Mix red and blue equally
      #   red = Abachrome.from_rgb(1, 0, 0)
      #   blue = Abachrome.from_rgb(0, 0, 1)
      #   purple = red.spectral_mix(blue, 0.5)
      #
      # @example Mix with 25% of blue
      #   mostly_red = red.spectral_mix(blue, 0.25)
      #
      # @example Mix with different tinting strengths
      #   # Stronger blue pigment
      #   purple = red.spectral_mix(blue, 0.5, tinting_strength_other: 2.0)
      def spectral_mix(other, amount = 0.5, tinting_strength_self: 1.0, tinting_strength_other: 1.0)
        require_relative "../spectral"

        # Convert amount to weights
        # amount = 0 means 100% self, 0% other
        # amount = 0.5 means 50% self, 50% other
        # amount = 1 means 0% self, 100% other
        weight_self = 1.0 - amount.to_f
        weight_other = amount.to_f

        colors = [
          { color: self, weight: weight_self },
          { color: other, weight: weight_other }
        ]

        tinting_strengths = {
          self => tinting_strength_self.to_f,
          other => tinting_strength_other.to_f
        }

        Spectral.mix(colors, tinting_strengths: tinting_strengths)
      end
    end
  end
end
