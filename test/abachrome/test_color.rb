# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/abachrome/color_space"
require_relative "../../lib/abachrome/color"

class TestColor < Minitest::Test
  def setup
    @rgb_space = Abachrome::ColorSpace.find(:rgb)
    @oklab_space = Abachrome::ColorSpace.find(:oklab)
    @rgb_color = Abachrome::Color.new(@rgb_space, [0.5, 0.2, 0.8])
    @oklab_color = Abachrome::Color.new(@oklab_space, [0.6, 0.1, -0.2])
  end

  def test_initialize
    color = Abachrome::Color.new(@rgb_space, [0.5, 0.2, 0.8])
    assert_equal @rgb_space, color.color_space
    assert_coordinates_equal [0.5, 0.2, 0.8], color.coordinates
    assert_equal BigDecimal("1.0"), color.alpha
  end

  def test_initialize_with_alpha
    color = Abachrome::Color.new(@rgb_space, [0.5, 0.2, 0.8], 0.5)
    assert_equal BigDecimal("0.5"), color.alpha
  end

  def test_validate_coordinates
    assert_raises ArgumentError do
      Abachrome::Color.new(@rgb_space, [0.5, 0.2])
    end
  end

  def test_from_rgb
    color = Abachrome::Color.from_rgb(0.5, 0.2, 0.8)
    assert_equal :srgb, color.color_space.name
    assert_coordinates_equal [0.5, 0.2, 0.8], color.coordinates
  end

  def test_from_oklab
    color = Abachrome::Color.from_oklab(50, 20, -30)
    assert_equal :oklab, color.color_space.name
    assert_coordinates_equal [50, 20, -30], color.coordinates
  end

  def test_equality
    color1 = Abachrome::Color.new(@rgb_space, [0.5, 0.2, 0.8])
    color2 = Abachrome::Color.new(@rgb_space, [0.5, 0.2, 0.8])
    color3 = Abachrome::Color.new(@rgb_space, [0.5, 0.2, 0.7])

    assert_equal color1, color2
    refute_equal color1, color3
  end

  def test_color_conversion_methods
    color = @rgb_color

    assert_equal [0.5, 0.2, 0.8], color.rgb_values
    assert_equal [128, 51, 204], color.rgb_array
    assert_equal "#8033cc", color.rgb_hex
  end

  def test_rgb_component_getters
    color = @rgb_color

    assert_equal BigDecimal("0.5"), color.red
    assert_equal BigDecimal("0.2"), color.green
    assert_equal BigDecimal("0.8"), color.blue
  end

  def test_oklab_component_getters
    color = @oklab_color

    assert_equal BigDecimal("0.6"), color.lightness
    assert_equal BigDecimal("0.1"), color.a
    assert_equal BigDecimal("-0.2"), color.b
  end

  def test_to_s
    assert_match(/rgb\(0\.5, 0\.2, 0\.8\)/, @rgb_color.to_s)
    assert_match(/oklab\(0\.6, 0\.1, -0\.2\)/, @oklab_color.to_s)
  end

  def test_hash_equality
    color1 = Abachrome::Color.new(@rgb_space, [0.5, 0.2, 0.8])
    color2 = Abachrome::Color.new(@rgb_space, [0.5, 0.2, 0.8])
    assert_equal color1.hash, color2.hash
  end

  def test_color_as_hash_key
    color1 = Abachrome::Color.new(@rgb_space, [0.5, 0.2, 0.8])
    color2 = Abachrome::Color.new(@rgb_space, [0.5, 0.2, 0.8])
    hash = {}
    hash[color1] = "test"
    assert_equal "test", hash[color2]
  end

  def test_bang_conversion_methods
    color = @rgb_color.dup
    color.to_oklab!
    assert_equal :oklab, color.color_space.name

    color.to_rgb!
    assert_equal :srgb, color.color_space.name
  end
end
