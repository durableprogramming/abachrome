# frozen_string_literal: true

require "dry-inflector"
require_relative "abc_decimal"
require_relative "color_space"

module Abachrome
  class Color
    attr_reader :color_space, :coordinates, :alpha

    # Initializes a new Color object with the specified color space, coordinates, and alpha value.
    # 
    # @param color_space [ColorSpace] The color space for this color instance
    # @param coordinates [Array<Numeric, String>] The color coordinates in the specified color space
    # @param alpha [Numeric, String] The alpha (opacity) value, between 0.0 and 1.0 (default: 1.0)
    # @raise [ArgumentError] If the coordinates are invalid for the specified color space
    # @return [Color] A new Color instance
    def initialize(color_space, coordinates, alpha = AbcDecimal("1.0"))
      @color_space = color_space
      @coordinates = coordinates.map { |c| AbcDecimal(c.to_s) }
      @alpha = AbcDecimal.new(alpha.to_s)

      validate_coordinates!
    end

    mixins_path = File.join(__dir__, "color_mixins", "*.rb")
    Dir[mixins_path].each do |file|
      require file
      mixin_name = File.basename(file, ".rb")
      inflector = Dry::Inflector.new
      mixin_module = Abachrome::ColorMixins.const_get(inflector.camelize(mixin_name))
      include mixin_module
    end

    # Creates a new Color instance from RGB values
    # 
    # @param r [Numeric] The red component value (typically 0-1)
    # @param g [Numeric] The green component value (typically 0-1)
    # @param b [Numeric] The blue component value (typically 0-1)
    # @param a [Numeric] The alpha (opacity) component value (0-1), defaults to 1.0 (fully opaque)
    # @return [Abachrome::Color] A new Color instance in the sRGB color space
    def self.from_rgb(r, g, b, a = 1.0)
      space = ColorSpace.find(:srgb)
      new(space, [r, g, b], a)
    end

    # Creates a new Color object with OKLAB values.
    # 
    # @param l [Float] The lightness component (L) of the OKLAB color space
    # @param a [Float] The green-red component (a) of the OKLAB color space
    # @param b [Float] The blue-yellow component (b) of the OKLAB color space
    # @param alpha [Float] The alpha (opacity) value, from 0.0 to 1.0
    # @return [Abachrome::Color] A new Color object in the OKLAB color space
    def self.from_oklab(l, a, b, alpha = 1.0)
      space = ColorSpace.find(:oklab)
      new(space, [l, a, b], alpha)
    end

    # Creates a new color instance in the OKLCH color space.
    # 
    # @param l [Numeric] The lightness component (L), typically in range 0..1
    # @param c [Numeric] The chroma component (C), typically starting from 0 with no upper bound
    # @param h [Numeric] The hue component (H) in degrees, typically in range 0..360
    # @param alpha [Float] The alpha (opacity) component, in range 0..1, defaults to 1.0 (fully opaque)
    # @return [Abachrome::Color] A new Color instance in the OKLCH color space
    def self.from_oklch(l, c, h, alpha = 1.0)
      space = ColorSpace.find(:oklch)
      new(space, [l, c, h], alpha)
    end

    # Compares this color instance with another for equality.
    # 
    # Two colors are considered equal if they have the same color space,
    # coordinates, and alpha value.
    # 
    # @param other [Object] The object to compare with
    # @return [Boolean] true if the colors are equal, false otherwise
    def ==(other)
      return false unless other.is_a?(Color)

      color_space == other.color_space &&
        coordinates == other.coordinates &&
        alpha == other.alpha
    end

    # Checks if this color is equal to another color object.
    # 
    # @param other [Object] The object to compare with
    # @return [Boolean] true if the two colors are equal, false otherwise
    # @see ==
    def eql?(other)
      self == other
    end

    # Generates a hash code for this color instance
    # based on its color space, coordinates, and alpha value.
    # The method first converts these components to strings,
    # then computes a hash of the resulting array.
    # 
    # @return [Integer] a hash code that can be used for equality comparison
    # and as a hash key in Hash objects
    def hash
      [color_space, coordinates, alpha].map(&:to_s).hash
    end

    # Returns a string representation of the color in the format "ColorSpaceName(coord1, coord2, coord3, alpha)"
    # 
    # @return [String] A human-readable string representation of the color showing its
    # color space name, coordinate values rounded to 3 decimal places, and alpha value
    # (if not 1.0)
    def to_s
      coord_str = coordinates.map { |c| c.to_f.round(3) }.join(", ")
      alpha_str = alpha == AbcDecimal.new("1.0") ? "" : ", #{alpha.to_f.round(3)}"
      "#{color_space.name}(#{coord_str}#{alpha_str})"
    end

    private

    # Validates that the number of coordinates matches the expected number for the color space.
    # Compares the size of the coordinates array with the number of coordinates
    # defined in the associated color space.
    # @raise [ArgumentError] when the number of coordinates doesn't match the color space definition
    # @return [nil] if validation passes
    def validate_coordinates!
      return if coordinates.size == color_space.coordinates.size

      raise ArgumentError,
            "Expected #{color_space.coordinates.size} coordinates for #{color_space.name}, got #{coordinates.size}"
    end
  end
end