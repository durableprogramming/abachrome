# frozen_string_literal: true

require_relative "../../test_helper"

class InterpolateTest < Minitest::Test
  def setup
    @color1 = Abachrome::Color.from_rgb(1, 0, 0)  # Red
    @color2 = Abachrome::Color.from_rgb(0, 0, 1)  # Blue
    @palette = Abachrome::Palette.new([@color1, @color2])
  end

  def test_interpolate_with_one_color_between
    interpolated = @palette.interpolate(1)
    assert_equal 3, interpolated.size
    assert_equal @color1, interpolated.first
    assert_equal @color2, interpolated.last

    middle_color = interpolated[1].to_rgb

    assert_in_delta 0.5, middle_color.red
    assert_in_delta 0.0, middle_color.green
    assert_in_delta 0.5, middle_color.blue
  end

  def test_interpolate_with_multiple_colors_between
    interpolated = @palette.interpolate(2)
    assert_equal 4, interpolated.size
    assert_equal @color1, interpolated.first
    assert_equal @color2, interpolated.last

    # Test first interpolated color (1/3 of the way)
    assert_in_delta 0.666, interpolated[1].red, 0.001
    assert_in_delta 0.0, interpolated[1].green
    assert_in_delta 0.333, interpolated[1].blue, 0.001

    # Test second interpolated color (2/3 of the way)
    assert_in_delta 0.333, interpolated[2].red, 0.001
    assert_in_delta 0.0, interpolated[2].green
    assert_in_delta 0.666, interpolated[2].blue, 0.001
  end

  def test_interpolate_with_zero_colors_between
    interpolated = @palette.interpolate(0)
    assert_equal @palette.size, interpolated.size
    assert_equal @palette.to_a, interpolated.to_a
  end

  def test_interpolate_with_single_color_palette
    single_palette = Abachrome::Palette.new([@color1])
    interpolated = single_palette.interpolate(1)
    assert_equal 1, interpolated.size
    assert_equal @color1, interpolated.first
  end

  def test_interpolate_with_empty_palette
    empty_palette = Abachrome::Palette.new([])
    interpolated = empty_palette.interpolate(1)
    assert_empty interpolated.to_a
  end

  def test_interpolate_bang_modifies_original
    original_colors = @palette.to_a.dup
    @palette.interpolate!(1)

    refute_equal original_colors, @palette.to_a
    assert_equal 3, @palette.size

    middle_color = @palette[1]
    assert_in_delta 0.5, middle_color.red
    assert_in_delta 0.0, middle_color.green
    assert_in_delta 0.5, middle_color.blue
  end

  def test_interpolate_preserves_alpha
    color1 = Abachrome::Color.from_rgb(1, 0, 0, 1.0)
    color2 = Abachrome::Color.from_rgb(0, 0, 1, 0.5)
    palette = Abachrome::Palette.new([color1, color2])

    interpolated = palette.interpolate(1)
    assert_equal 3, interpolated.size
    assert_in_delta 0.75, interpolated[1].alpha
  end
end
