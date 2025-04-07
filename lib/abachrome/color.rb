# frozen_string_literal: true

require "dry-inflector"
require_relative "abc_decimal"
require_relative "color_space"

module Abachrome
  class Color
    attr_reader :color_space, :coordinates, :alpha

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

    def self.from_rgb(r, g, b, a = 1.0)
      space = ColorSpace.find(:srgb)
      new(space, [r, g, b], a)
    end

    def self.from_oklab(l, a, b, alpha = 1.0)
      space = ColorSpace.find(:oklab)
      new(space, [l, a, b], alpha)
    end

    def self.from_oklch(l, c, h, alpha = 1.0)
      space = ColorSpace.find(:oklch)
      new(space, [l, c, h], alpha)
    end

    def ==(other)
      return false unless other.is_a?(Color)

      color_space == other.color_space &&
        coordinates == other.coordinates &&
        alpha == other.alpha
    end

    def eql?(other)
      self == other
    end

    def hash
      [color_space, coordinates, alpha].map(&:to_s).hash
    end

    def to_s
      coord_str = coordinates.map { |c| c.to_f.round(3) }.join(", ")
      alpha_str = alpha == AbcDecimal.new("1.0") ? "" : ", #{alpha.to_f.round(3)}"
      "#{color_space.name}(#{coord_str}#{alpha_str})"
    end

    private

    def validate_coordinates!
      return if coordinates.size == color_space.coordinates.size

      raise ArgumentError,
            "Expected #{color_space.coordinates.size} coordinates for #{color_space.name}, got #{coordinates.size}"
    end
  end
end
