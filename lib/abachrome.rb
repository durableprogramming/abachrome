# frozen_string_literal: true

require_relative "abachrome/to_abcd"

module Abachrome
  module_function

  autoload :AbcDecimal, "abachrome/abc_decimal"
  autoload :Color, "abachrome/color"
  autoload :Palette, "abachrome/palette"
  autoload :ColorSpace, "abachrome/color_space"
  autoload :Converter, "abachrome/converter"
  autoload :Gamut, "abachrome/gamut/base"
  autoload :ToAbcd, "abachrome/to_abcd"
  autoload :VERSION, "abachrome/version"

  module ColorModels
    autoload :HSV, "abachrome/color_models/hsv"
    autoload :Oklab, "abachrome/color_models/oklab"
    autoload :RGB, "abachrome/color_models/rgb"
  end

  module ColorMixins
    autoload :ToLrgb, "abachrome/color_mixins/to_lrgb"
    autoload :ToOklab, "abachrome/color_mixins/to_oklab"
  end

  module Converters
    autoload :Base, "abachrome/converters/base"
    autoload :LrgbToOklab, "abachrome/converters/lrgb_to_oklab"
    autoload :OklabToLrgb, "abachrome/converters/oklab_to_lrgb"
  end

  module Gamut
    autoload :P3, "abachrome/gamut/p3"
    autoload :Rec2020, "abachrome/gamut/rec2020"
    autoload :SRGB, "abachrome/gamut/srgb"
  end

  module Illuminants
    autoload :Base, "abachrome/illuminants/base"
    autoload :D50, "abachrome/illuminants/d50"
    autoload :D55, "abachrome/illuminants/d55"
    autoload :D65, "abachrome/illuminants/d65"
    autoload :D75, "abachrome/illuminants/d75"
  end

  module Named
    autoload :CSS, "abachrome/named/css"
  end

  module Outputs
    autoload :CSS, "abachrome/outputs/css"
  end

  module Parsers
    autoload :Hex, "abachrome/parsers/hex"
  end

  def create_color(space_name, *coordinates, alpha: 1.0)
    space = ColorSpace.find(space_name)
    Color.new(space, coordinates, alpha)
  end

  def from_rgb(r, g, b, alpha = 1.0)
    Color.from_rgb(r, g, b, alpha)
  end

  def from_oklab(l, a, b, alpha = 1.0)
    Color.from_oklab(l, a, b, alpha)
  end

  def from_oklch(l, a, b, alpha = 1.0)
    Color.from_oklch(l, a, b, alpha)
  end

  def from_hex(hex_str)
    Parsers::Hex.parse(hex_str)
  end

  def from_name(color_name)
    rgb_values = Named::CSS::ColorNames[color_name.downcase]
    return nil unless rgb_values

    from_rgb(*rgb_values.map { |v| v / 255.0 })
  end

  def convert(color, to_space)
    Converter.convert(color, to_space)
  end

  def register_color_space(name, &block)
    ColorSpace.register(name, &block)
  end

  def register_converter(from_space, to_space, converter)
    Converter.register(from_space, to_space, converter)
  end
end
