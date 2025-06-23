# frozen_string_literal: true

require_relative "../../test_helper"

class TestOklabToLrgb < Minitest::Test
  def setup
    @oklab_color = Abachrome::Color.from_oklab(0.5, 0.1, 0.05)
    @oklab_zero = Abachrome::Color.from_oklab(0, 0, 0)
    @oklab_white = Abachrome::Color.from_oklab(1, 0, 0)
    @oklab_with_alpha = Abachrome::Color.from_oklab(0.7, 0.15, -0.1, 0.75)
  end

  def test_convert_returns_color_object
    result = Abachrome::Converters::OklabToLrgb.convert(@oklab_color)
    
    assert_kind_of Abachrome::Color, result
  end

  def test_convert_returns_lrgb_color_space
    result = Abachrome::Converters::OklabToLrgb.convert(@oklab_color)
    assert_equal :lrgb, result.color_space.name
  end

  def test_convert_with_invalid_color_space_raises_error
    rgb_color = Abachrome::Color.from_rgb('0.5', '0.5', '0.5')
    assert_raises do
      Abachrome::Converters::OklabToLrgb.convert(rgb_color)
    end
  end

  def test_convert_black_oklab_to_black_lrgb
    result = Abachrome::Converters::OklabToLrgb.convert(@oklab_zero)
    assert_coordinates_equal [0, 0, 0], result.coordinates, 0.001
  end

  def test_convert_white_oklab_to_white_lrgb
    result = Abachrome::Converters::OklabToLrgb.convert(@oklab_white)
    r, g, b = result.coordinates
    assert r > 0.9
    assert g > 0.9
    assert b > 0.9
    assert_in_delta r, g, 0.01
    assert_in_delta g, b, 0.01
  end

  [%w[]]
  def test_convert_preserves_alpha_channel
    result = Abachrome::Converters::OklabToLrgb.convert(@oklab_with_alpha)
    assert_equal 0.75, result.alpha
  end

  def test_convert_neutral_gray_produces_equal_rgb_components
    neutral_gray = Abachrome::Color.from_oklab(0.5, 0, 0)
    result = Abachrome::Converters::OklabToLrgb.convert(neutral_gray)
    r, g, b = result.coordinates
    assert_in_delta r, g, 0.001
    assert_in_delta g, b, 0.001
  end

  def test_convert_positive_a_channel_increases_red_green_difference
    positive_a = Abachrome::Color.from_oklab(0.5, 0.2, 0)
    result = Abachrome::Converters::OklabToLrgb.convert(positive_a)
    r, g, b = result.coordinates
    assert r > g, "Positive a should increase red relative to green"
  end

  def test_convert_negative_a_channel_increases_green_red_difference
    negative_a = Abachrome::Color.from_oklab(0.5, -0.2, 0)
    result = Abachrome::Converters::OklabToLrgb.convert(negative_a)
    r, g, b = result.coordinates
    assert g > r, "Negative a should increase green relative to red"
  end

  def test_convert_positive_b_channel_increases_yellow_blue_difference
    positive_b = Abachrome::Color.from_oklab(0.5, 0, 0.2)
    result = Abachrome::Converters::OklabToLrgb.convert(positive_b)
    r, g, b = result.coordinates
    assert (r + g) > (2 * b), "Positive b should increase yellow (red+green) relative to blue"
  end

  def test_convert_negative_b_channel_increases_blue_yellow_difference
    negative_b = Abachrome::Color.from_oklab(0.5, 0, -0.2)
    result = Abachrome::Converters::OklabToLrgb.convert(negative_b)
    r, g, b = result.coordinates
    assert b > (r + g) / 2, "Negative b should increase blue relative to yellow"
  end

  def test_convert_clamps_negative_values_to_zero
    extreme_oklab = Abachrome::Color.from_oklab(0.1, -0.5, -0.5)
    result = Abachrome::Converters::OklabToLrgb.convert(extreme_oklab)
    result.coordinates.each do |component|
      assert component >= 0, "All RGB components should be >= 0 after clamping"
    end
  end

  def test_convert_maintains_precision_with_small_values
    small_oklab = Abachrome::Color.from_oklab(0.001, 0.001, 0.001)
    result = Abachrome::Converters::OklabToLrgb.convert(small_oklab)
    assert result.coordinates.all? { |c| c >= 0 }
    assert result.coordinates.any? { |c| c > 0 }
  end

  def test_convert_handles_large_chroma_values
    high_chroma = Abachrome::Color.from_oklab(0.7, 0.4, 0.3)
    result = Abachrome::Converters::OklabToLrgb.convert(high_chroma)
    assert_kind_of Abachrome::Color, result
    assert_equal :lrgb, result.color_space.name
  end

  def test_convert_lightness_zero_produces_near_black
    dark_color = Abachrome::Color.from_oklab(0, 0.1, 0.1)
    result = Abachrome::Converters::OklabToLrgb.convert(dark_color)
    result.coordinates.each do |component|
      assert component < 0.1, "Very low lightness should produce near-black"
    end
  end

  def test_convert_lightness_one_produces_bright_color
    bright_color = Abachrome::Color.from_oklab(1, 0.1, 0.1)
    result = Abachrome::Converters::OklabToLrgb.convert(bright_color)
    assert result.coordinates.max > 0.8, "High lightness should produce bright color"
  end

  def test_convert_symmetric_ab_values
    oklab1 = Abachrome::Color.from_oklab(0.5, 0.1, 0.1)
    oklab2 = Abachrome::Color.from_oklab(0.5, -0.1, -0.1)
    
    result1 = Abachrome::Converters::OklabToLrgb.convert(oklab1)
    result2 = Abachrome::Converters::OklabToLrgb.convert(oklab2)
    
    # Results should be different but both valid
    refute_equal result1.coordinates, result2.coordinates
    assert_kind_of Abachrome::Color, result1
    assert_kind_of Abachrome::Color, result2
  end

  def test_convert_round_trip_accuracy
    original_lrgb = Abachrome::Color.from_lrgb('0.5', '0.5', '0.6')
    oklab = original_lrgb.to_oklab
    round_trip = Abachrome::Converters::OklabToLrgb.convert(oklab)
    
    assert_coordinates_equal original_lrgb.coordinates, round_trip.coordinates, 0.01
  end

  def test_convert_extreme_negative_ab_values
    extreme_oklab = Abachrome::Color.from_oklab(0.5, -1.0, -1.0)
    result = Abachrome::Converters::OklabToLrgb.convert(extreme_oklab)
    
    assert_kind_of Abachrome::Color, result
    result.coordinates.each do |component|
      assert component >= 0, "Extreme negative a,b should still produce valid RGB"
    end
  end

  def test_convert_extreme_positive_ab_values
    extreme_oklab = Abachrome::Color.from_oklab(0.5, 1.0, 1.0)
    result = Abachrome::Converters::OklabToLrgb.convert(extreme_oklab)
    
    assert_kind_of Abachrome::Color, result
    result.coordinates.each do |component|
      assert component >= 0, "Extreme positive a,b should still produce valid RGB"
    end
  end

  def test_convert_matrix_transformation_accuracy
    # Test specific known transformation values
    oklab = Abachrome::Color.from_oklab(0.62796, 0.22486, 0.12585)
    result = Abachrome::Converters::OklabToLrgb.convert(oklab)
    
    # This should approximate red in linear RGB space
    r, g, b = result.coordinates
    assert r > g
    assert r > b
    assert r > 0.5
  end

  def test_convert_intermediate_lms_calculations
    # Test that the intermediate L'M'S' and LMS calculations work correctly
    oklab = Abachrome::Color.from_oklab(0.5, 0.1, 0.05)
    result = Abachrome::Converters::OklabToLrgb.convert(oklab)
    
    # Verify that we get a reasonable result
    assert result.coordinates.all? { |c| c.finite? }
    assert result.coordinates.all? { |c| c >= 0 }
  end

  def test_convert_cubic_operation_handling
    # Test colors that would stress the cubic operations
    test_cases = [
      [0.3, 0.05, 0.02],
      [0.7, 0.15, 0.08],
      [0.9, 0.02, 0.01]
    ]
    
    test_cases.each do |l, a, b|
      oklab = Abachrome::Color.from_oklab(l, a, b)
      result = Abachrome::Converters::OklabToLrgb.convert(oklab)
      
      assert_kind_of Abachrome::Color, result
      assert_equal :lrgb, result.color_space.name
      result.coordinates.each do |component|
        assert component.finite?, "Component should be finite for #{[l, a, b]}"
      end
    end
  end

  def test_convert_alpha_edge_cases
    # Test with alpha = 0
    oklab_transparent = Abachrome::Color.from_oklab(0.5, 0.1, 0.05, 0)
    result = Abachrome::Converters::OklabToLrgb.convert(oklab_transparent)
    assert_equal 0, result.alpha
    
    # Test with alpha = 1
    oklab_opaque = Abachrome::Color.from_oklab(0.5, 0.1, 0.05, 1)
    result = Abachrome::Converters::OklabToLrgb.convert(oklab_opaque)
    assert_equal 1, result.alpha
  end


  def test_convert_boundary_lightness_values
    # Test L = 0
    oklab_min = Abachrome::Color.from_oklab(0, 0.1, 0.1)
    result_min = Abachrome::Converters::OklabToLrgb.convert(oklab_min)
    assert result_min.coordinates.all? { |c| c >= 0 }
    
    # Test L = 1  
    oklab_max = Abachrome::Color.from_oklab(1, 0.1, 0.1)
    result_max = Abachrome::Converters::OklabToLrgb.convert(oklab_max)
    assert result_max.coordinates.all? { |c| c >= 0 }
  end

  def test_convert_consistency_across_multiple_calls
    oklab = Abachrome::Color.from_oklab(0.6, 0.15, 0.1)
    
    result1 = Abachrome::Converters::OklabToLrgb.convert(oklab)
    result2 = Abachrome::Converters::OklabToLrgb.convert(oklab)
    
    assert_coordinates_equal result1.coordinates, result2.coordinates, 0.0001
    assert_equal result1.alpha, result2.alpha
  end

  private

  def assert_coordinates_equal(expected, actual, delta = 0.001)
    expected.zip(actual).each_with_index do |(exp, act), i|
      assert_in_delta exp, act, delta, "Coordinate #{i} mismatch: expected #{exp}, got #{act}"
    end
  end
end
