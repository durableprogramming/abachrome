# frozen_string_literal: true

require_relative "../test_helper"
require "yaml"
require "abachrome"

class ColorsTest < Minitest::Test
  def setup
    
    @colors_data = ColorsTest.colors_data
  end

  def self.colors_data
    YAML.load_file(File.join(__dir__, "..", "fixtures", "colors.yml"))
  end
  def test_all_colors_hex_parsing
    @colors_data.each do |color_name, data|
      hex = data["hex"]
      next unless hex

      color = Abachrome.from_hex(hex)
      assert_instance_of Abachrome::Color, color
      assert_equal :srgb, color.color_space.name
      assert_equal 3, color.coordinates.size
      assert_equal 1.0, color.alpha.to_f
    end
  end

  def test_all_colors_rgb_values
    @colors_data.each do |color_name, data|
      rgb_string = data["rgb"]
      next unless rgb_string

      # Parse RGB values from string like "rgb(240, 248, 255)"
      if rgb_string.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/)
        r, g, b = $1.to_i, $2.to_i, $3.to_i
        
        color = Abachrome.from_rgb(r / 255.0, g / 255.0, b / 255.0)
        assert_instance_of Abachrome::Color, color
        assert_equal :srgb, color.color_space.name
        
        # Check RGB values are within valid range
        color.coordinates.each do |coord|
          assert coord >= 0, "RGB coordinate should be >= 0"
          assert coord <= 1, "RGB coordinate should be <= 1"
        end
      end
    end
  end

  def test_all_colors_conversion_to_oklab
    @colors_data.each do |color_name, data|
      hex = data["hex"]
      next unless hex

      color = Abachrome.from_hex(hex)
      oklab_color = color.to_oklab
      
      assert_instance_of Abachrome::Color, oklab_color
      assert_equal :oklab, oklab_color.color_space.name
      assert_equal 3, oklab_color.coordinates.size
      
      # Check OKLAB lightness is within expected range
      lightness = oklab_color.coordinates[0]
      assert lightness >= 0, "OKLAB lightness should be >= 0 for #{color_name}"
      assert lightness <= 1, "OKLAB lightness should be <= 1 for #{color_name}"
    end
  end

  ColorsTest.colors_data.each do |color_name, data|

    define_method "test_#{color_name}_colors_conversion_to_oklch" do
        hex = data["hex"]
        next unless hex

        color = Abachrome.from_hex(hex)
        oklch_color = color.to_oklch
        
        assert_instance_of Abachrome::Color, oklch_color
        assert_equal :oklch, oklch_color.color_space.name
        assert_equal 3, oklch_color.coordinates.size
        
        # Check OKLCH values are within expected ranges
        l, c, h = oklch_color.coordinates
        assert l >= 0, "OKLCH lightness should be >= 0 for #{color_name}"
        assert l <= 1, "OKLCH lightness should be <= 1 for #{color_name}"
        assert c >= 0, "OKLCH chroma should be >= 0 for #{color_name}"
        assert h >= 0, "OKLCH hue should be >= 0 for #{color_name}"
        assert h < 360, "OKLCH hue should be < 360 for #{color_name}"
      end
  end

  def test_all_colors_conversion_to_lrgb
    @colors_data.each do |color_name, data|
      hex = data["hex"]
      next unless hex

      color = Abachrome.from_hex(hex)
      lrgb_color = color.to_lrgb
      
      assert_instance_of Abachrome::Color, lrgb_color
      assert_equal :lrgb, lrgb_color.color_space.name
      assert_equal 3, lrgb_color.coordinates.size
      
      # Check linear RGB values are non-negative
      lrgb_color.coordinates.each do |coord|
        assert coord >= 0, "Linear RGB coordinate should be >= 0 for #{color_name}"
      end
    end
  end

  def test_all_colors_roundtrip_conversion
    @colors_data.each do |color_name, data|
      hex = data["hex"]
      next unless hex

      original_color = Abachrome.from_hex(hex)
      
      # Test sRGB -> OKLAB -> sRGB roundtrip
      oklab_color = original_color.to_oklab
      roundtrip_color = oklab_color.to_srgb
      
      assert_coordinates_equal(
        original_color.coordinates.map(&:to_f),
        roundtrip_color.coordinates.map(&:to_f),
        0.01
      )
      
      # Test sRGB -> OKLCH -> sRGB roundtrip
      oklch_color = original_color.to_oklch
      roundtrip_color2 = oklch_color.to_srgb
      
      assert_coordinates_equal(
        original_color.coordinates.map(&:to_f),
        roundtrip_color2.coordinates.map(&:to_f),
        0.01
      )
    end
  end

  def test_all_colors_hex_output
    @colors_data.each do |color_name, data|
      hex = data["hex"]
      next unless hex

      color = Abachrome.from_hex(hex)
      output_hex = color.rgb_hex
      
      assert_match(/^#[0-9a-f]{6}$/i, output_hex)
      
      # Parse the hex back and compare
      reparsed_color = Abachrome.from_hex(output_hex)
      assert_coordinates_equal(
        color.coordinates.map(&:to_f),
        reparsed_color.coordinates.map(&:to_f),
        0.01
      )
    end
  end

  def test_all_colors_lightness_adjustment
    @colors_data.each do |color_name, data|
      hex = data["hex"]
      next unless hex

      color = Abachrome.from_hex(hex)
      original_lightness = color.lightness.to_f
      
      # Test lightening
      lightened = color.lighten(0.1)
      assert lightened.lightness.to_f >= original_lightness, "Lightened color should be lighter for #{color_name}"
      
      # Test darkening
      darkened = color.darken(0.1)
      assert darkened.lightness.to_f <= original_lightness, "Darkened color should be darker for #{color_name}"
    end
  end

  def test_all_colors_blending
    @colors_data.each do |color_name, data|
      hex = data["hex"]
      next unless hex

      color1 = Abachrome.from_hex(hex)
      color2 = Abachrome.from_hex("#ffffff") # White
      
      # Test blending at different amounts
      [0.0, 0.25, 0.5, 0.75, 1.0].each do |amount|
        blended = color1.blend(color2, amount)
        assert_instance_of Abachrome::Color, blended
        
        if amount == 0.0
          assert_coordinates_equal(
            color1.coordinates.map(&:to_f),
            blended.coordinates.map(&:to_f),
            0.001
          )
        elsif amount == 1.0
          assert_coordinates_equal(
            color2.coordinates.map(&:to_f),
            blended.coordinates.map(&:to_f),
            0.001
          )
        end
      end
    end
  end

  def test_all_colors_alpha_handling
    @colors_data.each do |color_name, data|
      hex = data["hex"]
      next unless hex

      color = Abachrome.from_hex(hex)
      
      # Test that alpha is preserved during conversions
      assert_equal 1.0, color.alpha.to_f
      assert_equal 1.0, color.to_oklab.alpha.to_f
      assert_equal 1.0, color.to_oklch.alpha.to_f
      assert_equal 1.0, color.to_lrgb.alpha.to_f
    end
  end

  def test_all_colors_component_access
    @colors_data.each do |color_name, data|
      hex = data["hex"]
      next unless hex

      color = Abachrome.from_hex(hex)
      
      # Test RGB component access
      assert_respond_to color, :red
      assert_respond_to color, :green
      assert_respond_to color, :blue
      
      # Test OKLAB component access
      assert_respond_to color, :lightness
      assert_respond_to color, :l
      assert_respond_to color, :a
      assert_respond_to color, :b
      
      # Test OKLCH component access
      assert_respond_to color, :chroma
      assert_respond_to color, :hue
      
      # Test linear RGB component access
      assert_respond_to color, :lred
      assert_respond_to color, :lgreen
      assert_respond_to color, :lblue
      
      # Verify component values are reasonable
      assert color.red.to_f >= 0 && color.red.to_f <= 1
      assert color.green.to_f >= 0 && color.green.to_f <= 1
      assert color.blue.to_f >= 0 && color.blue.to_f <= 1
      assert color.lightness.to_f >= 0 && color.lightness.to_f <= 1
      assert color.chroma.to_f >= 0
      assert color.hue.to_f >= 0 && color.hue.to_f < 360
    end
  end

  def test_all_colors_equality
    @colors_data.each do |color_name, data|
      hex = data["hex"]
      next unless hex

      color1 = Abachrome.from_hex(hex)
      color2 = Abachrome.from_hex(hex)
      
      assert_equal color1, color2
      assert color1.eql?(color2)
      assert_equal color1.hash, color2.hash
    end
  end

  def test_all_colors_string_representation
    @colors_data.each do |color_name, data|
      hex = data["hex"]
      next unless hex

      color = Abachrome.from_hex(hex)
      string_repr = color.to_s
      
      assert_instance_of String, string_repr
      assert string_repr.include?("srgb")
      assert string_repr.include?("(")
      assert string_repr.include?(")")
    end
  end

  def test_black_and_white_extremes
    # Test pure black
    black = Abachrome.from_hex("#000000")
    assert_in_delta 0.0, black.lightness.to_f, 0.001
    assert_equal [0, 0, 0], black.rgb_array
    
    # Test pure white
    white = Abachrome.from_hex("#ffffff")
    assert_in_delta 1.0, white.lightness.to_f, 0.001
    assert_equal [255, 255, 255], white.rgb_array
  end

  def test_primary_colors
    # Test pure red
    red = Abachrome.from_hex("#ff0000")
    assert_equal [255, 0, 0], red.rgb_array
    assert_in_delta 1.0, red.red.to_f, 0.001
    assert_in_delta 0.0, red.green.to_f, 0.001
    assert_in_delta 0.0, red.blue.to_f, 0.001
    
    # Test pure green
    green = Abachrome.from_hex("#00ff00")
    assert_equal [0, 255, 0], green.rgb_array
    assert_in_delta 0.0, green.red.to_f, 0.001
    assert_in_delta 1.0, green.green.to_f, 0.001
    assert_in_delta 0.0, green.blue.to_f, 0.001
    
    # Test pure blue
    blue = Abachrome.from_hex("#0000ff")
    assert_equal [0, 0, 255], blue.rgb_array
    assert_in_delta 0.0, blue.red.to_f, 0.001
    assert_in_delta 0.0, blue.green.to_f, 0.001
    assert_in_delta 1.0, blue.blue.to_f, 0.001
  end
end
