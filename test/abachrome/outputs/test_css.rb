# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "../../../lib/abachrome/outputs/css"
require_relative "../../../lib/abachrome/color"
require_relative "../../../lib/abachrome/gamut/srgb"

module Abachrome
  module Outputs
    class TestCSS < Minitest::Test
      def setup
        @black = Color.from_rgb(0, 0, 0)
        @white = Color.from_rgb(1, 1, 1)
        @red = Color.from_rgb(1, 0, 0)
        @transparent = Color.from_rgb(1, 1, 1, 0.5)
        @srgb_gamut = Gamut::SRGB.new
      end

      def test_format_outputs_hex_for_opaque_colors
        assert_equal "#000000", CSS.format(@black)
        assert_equal "#ffffff", CSS.format(@white)
        assert_equal "#ff0000", CSS.format(@red)
      end

      def test_format_outputs_rgba_for_transparent_colors
        assert_equal "rgba(255, 255, 255, 0.500)", CSS.format(@transparent)
      end

      def test_format_hex_always_outputs_hex
        assert_equal "#000000", CSS.format_hex(@black)
        assert_equal "#ffffff", CSS.format_hex(@white)
        assert_equal "#ff0000", CSS.format_hex(@red)
        assert_equal "#ffffff80", CSS.format_hex(@transparent)
      end

      def test_format_rgb_always_outputs_rgb
        assert_equal "rgb(0, 0, 0)", CSS.format_rgb(@black)
        assert_equal "rgb(255, 255, 255)", CSS.format_rgb(@white)
        assert_equal "rgb(255, 0, 0)", CSS.format_rgb(@red)
        assert_equal "rgba(255, 255, 255, 0.500)", CSS.format_rgb(@transparent)
      end

      def test_format_with_gamut_mapping
        out_of_gamut = Color.from_rgb(1.2, -0.1, 1.5)
        assert_equal "#ff00ff", CSS.format(out_of_gamut, gamut: @srgb_gamut)
      end

      def test_shorthand_hex_for_grayscale
        gray = Color.from_rgb(0.5, 0.5, 0.5)
        assert_equal "#808080", CSS.format(gray)
      end

      def test_format_oklab_outputs_oklab_format
        # Test with default precision of 3
        assert_match(/oklab\(0\.\d{3} 0\.\d{3} 0\.\d{3}\)/, CSS.format_oklab(@black))
        assert_match(/oklab\(1\.\d{3} 0\.\d{3} 0\.\d{3}\)/, CSS.format_oklab(@white))
        assert_match(/oklab\(0\.\d{3} 0\.\d{3} 0\.\d{3}\)/, CSS.format_oklab(@red))
      end

      def test_format_oklab_with_transparency
        assert_match(%r{oklab\(1\.\d{3} 0\.\d{3} 0\.\d{3} / 0\.500\)}, CSS.format_oklab(@transparent))
      end

      def test_format_oklab_with_precision
        # Test with custom precision
        result = CSS.format_oklab(@white, precision: 5)
        assert_match(/oklab\(1\.\d{5} 0\.\d{5} 0\.\d{5}\)/, result)
      end

      def test_format_oklab_with_gamut_mapping
        out_of_gamut = Color.from_rgb(1.2, -0.1, 1.5)
        mapped_color = CSS.format_oklab(out_of_gamut, gamut: @srgb_gamut)
        # Just verifying format is correct, not checking specific values
        assert_match(/oklab\([\d.-]+ [\d.-]+ [\d.-]+\)/, mapped_color)
      end
    end
  end
end
