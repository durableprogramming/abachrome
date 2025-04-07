# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/abachrome"

module Abachrome
  class TestPalette < Minitest::Test
    def setup
      @color1 = Abachrome.from_hex("#ff0000")
      @color2 = Abachrome.from_hex("#00ff00")
      @color3 = Abachrome.from_hex("#0000ff")
      @palette = Palette.new([@color1, @color2, @color3])
    end

    def test_initialize
      assert_equal 3, @palette.size
      assert_equal @color1, @palette[0]
      assert_equal @color2, @palette[1]
      assert_equal @color3, @palette[2]
    end

    def test_add
      color4 = Abachrome.from_hex("#ffffff")
      @palette.add(color4)
      assert_equal 4, @palette.size
      assert_equal color4, @palette.last
    end

    def test_remove
      @palette.remove(@color2)
      assert_equal 2, @palette.size
      assert_equal @color1, @palette[0]
      assert_equal @color3, @palette[1]
    end

    def test_clear
      @palette.clear
      assert_empty @palette
    end

    def test_empty?
      refute @palette.empty?
      @palette.clear
      assert @palette.empty?
    end

    def test_map
      new_palette = @palette.map { |color| color.lighten(0.1) }
      assert_instance_of Palette, new_palette
      assert_equal 3, new_palette.size
      refute_equal @color1, new_palette[0]
    end

    def test_slice
      sliced = @palette.slice(1, 2)
      assert_equal 2, sliced.size
      assert_equal @color2, sliced[0]
      assert_equal @color3, sliced[1]
    end

    def test_first_and_last
      assert_equal @color1, @palette.first
      assert_equal @color3, @palette.last
    end

    def test_sort_by_lightness
      sorted = @palette.sort_by_lightness
      assert_equal 3, sorted.size
      assert sorted[0].lightness <= sorted[1].lightness
      assert sorted[1].lightness <= sorted[2].lightness
    end

    def test_blend_all
      blended = @palette.blend_all(0.5)
      assert_instance_of Color, blended
    end

    def test_average
      avg = @palette.average
      assert_instance_of Color, avg
    end

    def test_to_css
      css_colors = @palette.to_css
      assert_equal 3, css_colors.size
      assert_equal "#ff0000", css_colors[0]
      assert_equal "#00ff00", css_colors[1]
      assert_equal "#0000ff", css_colors[2]
    end

    def test_interpolate
      interpolated = @palette.interpolate(1)
      assert_equal 5, interpolated.size
    end

    def test_resample
      resampled = @palette.resample(5)
      assert_equal 5, resampled.size
    end

    def test_stretch_luminance
      stretched = @palette.stretch_luminance(new_min: 0.2, new_max: 0.8)
      assert_equal 3, stretched.size
      stretched.each do |color|
        assert color.lightness >= 0.2
        assert color.lightness <= 0.8
      end
    end

    def test_normalize_luminance
      normalized = @palette.normalize_luminance
      assert_equal 3, normalized.size
      normalized.each do |color|
        assert color.lightness >= 0
        assert color.lightness <= 1
      end
    end

    def test_compress_luminance
      compressed = @palette.compress_luminance(0.5)
      assert_equal 3, compressed.size
      compressed.each do |color|
        assert color.lightness >= 0.25
        assert color.lightness <= 0.75
      end
    end
  end
end
