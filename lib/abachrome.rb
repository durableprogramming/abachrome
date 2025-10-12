# Abachrome - A Ruby color manipulation library
#
# This is the main entry point for the Abachrome library, providing color creation,
# conversion, and manipulation capabilities across multiple color spaces including
# sRGB, OKLAB, OKLCH, and linear RGB.
#
# Key features:
# - Create colors from RGB, OKLAB, OKLCH values or hex strings
# - Convert between different color spaces
# - Parse colors from hex codes and CSS color names
# - Register custom color spaces and converters
# - High-precision decimal arithmetic for accurate color calculations
#
# The library uses autoloading for efficient memory usage and provides both
# functional and object-oriented APIs for color operations.

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

  # Creates a new color in the specified color space with given coordinates and alpha value.
  # 
  # @param space_name [Symbol, String] The name of the color space (e.g., :srgb, :oklch)
  # @param coordinates [Array<Numeric>] The color coordinates in the specified color space
  # @param alpha [Float] The alpha (opacity) value of the color, defaults to 1.0 (fully opaque)
  # @return [Abachrome::Color] A new Color object in the specified color space with the given coordinates
  def create_color(space_name, *coordinates, alpha: 1.0)
    space = ColorSpace.find(space_name)
    Color.new(space, coordinates, alpha)
  end

  # Creates a color object from RGB values.
  # 
  # @param r [Numeric] The red component value (typically 0-255 or 0.0-1.0)
  # @param g [Numeric] The green component value (typically 0-255 or 0.0-1.0)
  # @param b [Numeric] The blue component value (typically 0-255 or 0.0-1.0)
  # @param alpha [Float] The alpha (opacity) component value (0.0-1.0), defaults to 1.0 (fully opaque)
  # @return [Abachrome::Color] A new Color object initialized with the specified RGB values
  def from_rgb(r, g, b, alpha = 1.0)
    Color.from_rgb(r, g, b, alpha)
  end

  # Creates a color in the OKLAB color space.
  # 
  # @param l [Numeric] The lightness component (L) in the OKLAB color space, typically in range 0 to 1
  # @param a [Numeric] The green-red component (a) in the OKLAB color space
  # @param b [Numeric] The blue-yellow component (b) in the OKLAB color space
  # @param alpha [Float] The alpha (opacity) value, ranging from 0.0 (transparent) to 1.0 (opaque), defaults to 1.0
  # @return [Abachrome::Color] A new Color object in the OKLAB color space
  def from_oklab(l, a, b, alpha = 1.0)
    Color.from_oklab(l, a, b, alpha)
  end

  # Creates a new color from OKLCH color space values.
  # 
  # @param l [Numeric] The lightness value, typically in range 0-1
  # @param a [Numeric] The chroma (colorfulness) value
  # @param b [Numeric] The hue angle value in degrees (0-360)
  # @param alpha [Numeric] The alpha (opacity) value, between 0-1 (default: 1.0)
  # @return [Abachrome::Color] A new color object initialized with the given OKLCH values
  def from_oklch(l, a, b, alpha = 1.0)
    Color.from_oklch(l, a, b, alpha)
  end

  # Creates a color object from a hexadecimal color code string.
  # 
  # @param hex_str [String] The hexadecimal color code string to parse. Can be in formats like
  # "#RGB", "#RRGGBB", "RGB", or "RRGGBB", with or without the leading "#" character.
  # @return [Abachrome::Color] A new Color object representing the parsed hexadecimal color.
  # @example
  # Abachrome.from_hex("#ff0000") # => returns a red Color object
  # Abachrome.from_hex("00ff00")  # => returns a green Color object
  # @see Abachrome::Parsers::Hex.parse
  def from_hex(hex_str)
    Parsers::Hex.parse(hex_str)
  end

  # Creates a color object from a CSS color name.
  # 
  # @param color_name [String] The CSS color name (e.g., 'red', 'blue', 'cornflowerblue').
  # Case-insensitive.
  # @return [Abachrome::Color, nil] A color object in the RGB color space if the name is valid,
  # nil if the color name is not recognized.
  def from_name(color_name)
    rgb_values = Named::CSS::ColorNames[color_name.downcase]
    return nil unless rgb_values

    from_rgb(*rgb_values.map { |v| v / 255.0 })
  end

  # Convert a color from its current color space to another color space.
  # 
  # @param color [Abachrome::Color] The color object to convert
  # @param to_space [Symbol, String] The destination color space identifier (e.g. :srgb, :oklch)
  # @return [Abachrome::Color] A new color object in the specified color space
  def convert(color, to_space)
    Converter.convert(color, to_space)
  end

  # Register a new color space with the Abachrome library.
  # 
  # @param name [Symbol, String] The identifier for the color space being registered
  # @param block [Proc] A block that defines the color space properties and conversion rules
  # @return [Abachrome::ColorSpace] The newly registered color space object
  def register_color_space(name, &block)
    ColorSpace.register(name, &block)
  end

  # Register a new color space converter in the Abachrome system.
  # 
  # This method allows registering custom converters between color spaces.
  # Converters are used to transform color representations from one color
  # space to another.
  # 
  # @param from_space [Symbol, String] The source color space identifier
  # @param to_space [Symbol, String] The destination color space identifier
  # @param converter [#call] An object responding to #call that performs the conversion
  # @return [void]
  def register_converter(from_space, to_space, converter)
    Converter.register(from_space, to_space, converter)
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.