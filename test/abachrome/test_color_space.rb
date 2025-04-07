# frozen_string_literal: true

require_relative "../test_helper"
module Abachrome
  class ColorSpaceTest < Minitest::Test
    def test_register_and_find_color_space
      name = :test_space
      ColorSpace.register(name) do |s|
        s.coordinates = %i[x y z]
        s.white_point = :D65
      end

      space = ColorSpace.find(name)
      assert_equal name, space.name
      assert_equal %i[x y z], space.coordinates
      assert_equal :D65, space.white_point
    end

    def test_unknown_color_space_raises_error
      assert_raises(ArgumentError) do
        ColorSpace.find(:nonexistent)
      end
    end

    def test_equality
      space1 = ColorSpace.find(:rgb)
      space2 = ColorSpace.find(:rgb)
      space3 = ColorSpace.find(:oklab)

      assert_equal space1, space2
      refute_equal space1, space3
    end

    def test_rgb_color_space_exists
      space = ColorSpace.find(:rgb)
      assert_equal :srgb, space.name
      assert_equal %i[red green blue], space.coordinates
      assert_equal :D65, space.white_point
    end

    def test_oklab_color_space_exists
      space = ColorSpace.find(:oklab)
      assert_equal :oklab, space.name
      assert_equal %i[lightness a b], space.coordinates
      assert_equal :D65, space.white_point
    end

    def test_lab_color_space_exists
      space = ColorSpace.find(:lab)
      assert_equal :lab, space.name
      assert_equal %i[lightness a b], space.coordinates
      assert_equal :D65, space.white_point
    end

    def test_hsl_color_space_exists
      space = ColorSpace.find(:hsl)
      assert_equal :hsl, space.name
      assert_equal %i[hue saturation lightness], space.coordinates
      assert_equal :D65, space.white_point
    end

    def test_lch_color_space_exists
      space = ColorSpace.find(:oklch)
      assert_equal :oklch, space.name
      assert_equal %i[lightness chroma hue], space.coordinates
      assert_equal :D65, space.white_point
    end

    def test_hash_equality
      space1 = ColorSpace.find(:rgb)
      space2 = ColorSpace.find(:rgb)
      assert_equal space1.hash, space2.hash
    end

    def test_eql_operator
      space1 = ColorSpace.find(:rgb)
      space2 = ColorSpace.find(:rgb)
      assert space1.eql?(space2)
    end

    def test_color_space_hash_as_key
      hash = {}
      space1 = ColorSpace.find(:rgb)
      space2 = ColorSpace.find(:rgb)

      hash[space1] = "test"
      assert_equal "test", hash[space2]
    end
  end
end
