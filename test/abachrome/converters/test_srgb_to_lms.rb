# frozen_string_literal: true

require_relative "../../test_helper"
require "abachrome"

class TestSrgbToLms < Minitest::Test
  def test_converts_red_to_lms
    red = Abachrome::Color.from_rgb(1, 0, 0)
    lms = Abachrome::Converters::SrgbToLms.convert(red)

    assert_equal :lms, lms.color_space.name
    # Red should have high L cone response
    assert lms.coordinates[0].to_f > 0.3
  end

  def test_converts_green_to_lms
    green = Abachrome::Color.from_rgb(0, 1, 0)
    lms = Abachrome::Converters::SrgbToLms.convert(green)

    assert_equal :lms, lms.color_space.name
    # Green should have high M cone response
    assert lms.coordinates[1].to_f > 0.5
  end

  def test_converts_blue_to_lms
    blue = Abachrome::Color.from_rgb(0, 0, 1)
    lms = Abachrome::Converters::SrgbToLms.convert(blue)

    assert_equal :lms, lms.color_space.name
    # Blue should have high S cone response
    assert lms.coordinates[2].to_f > 0.3
  end

  def test_converts_white_to_lms
    white = Abachrome::Color.from_rgb(1, 1, 1)
    lms = Abachrome::Converters::SrgbToLms.convert(white)

    assert_equal :lms, lms.color_space.name
    # White should stimulate all cones equally (roughly)
    assert lms.coordinates[0].to_f > 0.7
    assert lms.coordinates[1].to_f > 0.7
    assert lms.coordinates[2].to_f > 0.7
  end

  def test_converts_black_to_lms
    black = Abachrome::Color.from_rgb(0, 0, 0)
    lms = Abachrome::Converters::SrgbToLms.convert(black)

    assert_equal :lms, lms.color_space.name
    assert_in_delta 0.0, lms.coordinates[0].to_f, 0.001
    assert_in_delta 0.0, lms.coordinates[1].to_f, 0.001
    assert_in_delta 0.0, lms.coordinates[2].to_f, 0.001
  end

  def test_preserves_alpha
    color = Abachrome::Color.from_rgb(0.5, 0.5, 0.5, 0.4)
    lms = Abachrome::Converters::SrgbToLms.convert(color)

    assert_equal BigDecimal("0.4"), lms.alpha
  end

  def test_raises_error_for_non_srgb_input
    lrgb = Abachrome::Color.from_lrgb(0.5, 0.5, 0.5)
    assert_raises(RuntimeError) do
      Abachrome::Converters::SrgbToLms.convert(lrgb)
    end
  end

  def test_cone_response_ratios_for_red
    red = Abachrome::Color.from_rgb(1, 0, 0)
    lms = Abachrome::Converters::SrgbToLms.convert(red)

    # L cones should be most responsive to red
    assert lms.coordinates[0].to_f > lms.coordinates[2].to_f
  end

  def test_cone_response_ratios_for_green
    green = Abachrome::Color.from_rgb(0, 1, 0)
    lms = Abachrome::Converters::SrgbToLms.convert(green)

    # M cones should be most responsive to green
    assert lms.coordinates[1].to_f > lms.coordinates[2].to_f
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
