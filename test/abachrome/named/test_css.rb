# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "../../../lib/abachrome"

class TestNamedCSS < Minitest::Test
  def test_color_names_contains_all_css_colors
    assert_equal 147, Abachrome::Named::CSS::ColorNames.size
    assert_equal [255, 0, 0], Abachrome::Named::CSS::ColorNames["red"]
  end

  def test_methods_match_hash
    Abachrome::Named::CSS::ColorNames.each do |name, rgb|
      assert_equal rgb, Abachrome::Named::CSS.public_send(name), name
    end
  end

  def test_from_name
    assert_equal "#ff0000", Abachrome.from_name("red").to_hex
    assert_equal "#6495ed", Abachrome.from_name("CornflowerBlue").to_hex
    assert_nil Abachrome.from_name("nonsense")
  end

  def test_parse_named_color
    assert_equal "#ff0000", Abachrome.parse("red").to_hex
    assert_equal "#6495ed", Abachrome.parse("  CornflowerBlue ").to_hex
  end

  def test_transparent
    [Abachrome.parse("transparent"), Abachrome.from_name("Transparent")].each do |color|
      assert_equal [0, 0, 0], color.to_srgb.coordinates.map(&:to_f)
      assert_equal 0, color.alpha.to_f
    end
  end

  def test_parse_rejects_non_color_method_names
    %w[hash freeze name class nonsense].each do |input|
      assert_nil Abachrome.parse(input), input
      assert_nil Abachrome.from_name(input), input
    end
  end
end
