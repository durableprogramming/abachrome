# frozen_string_literal: true

require_relative "../../test_helper"
require "abachrome/color_models/rgb"

module Abachrome
  module ColorModels
    class TestRGB < Minitest::Test
      def test_normalize_with_percentage_strings
        r, g, b = RGB.normalize("100%", "50%", "0%")
        assert_in_delta 1.0, r, 0.01
        assert_in_delta 0.5, g, 0.01
        assert_in_delta 0.0, b, 0.01
      end

      def test_normalize_with_numeric_strings
        r, g, b = RGB.normalize("255", "128", "0")
        assert_in_delta 1.0, r, 0.01
        assert_in_delta 0.5, g, 0.01
        assert_in_delta 0.0, b, 0.01
      end

      def test_normalize_with_decimals
        r, g, b = RGB.normalize(1.0, 0.5, 0.0)
        assert_in_delta 1.0, r, 0.01
        assert_in_delta 0.5, g, 0.01
        assert_in_delta 0.0, b, 0.01
      end

      def test_normalize_with_integers
        r, g, b = RGB.normalize(255, 128, 0)
        assert_in_delta 1.0, r, 0.01
        assert_in_delta 0.5, g, 0.01
        assert_in_delta 0.0, b, 0.01
      end

      def test_normalize_with_mixed_inputs
        r, g, b = RGB.normalize("100%", 128, 0.0)
        assert_in_delta 1.0, r, 0.01
        assert_in_delta 0.5, g, 0.01
        assert_in_delta 0.0, b, 0.01
      end
    end
  end
end
