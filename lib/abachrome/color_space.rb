# frozen_string_literal: true

module Abachrome
  class ColorSpace
    class << self
      def registry
        @registry ||= {}
      end

      def register(name, &block)
        registry[name.to_sym] = new(name, &block)
      end

      def alias(name, aliased_name)
        registry[aliased_name.to_sym] = registry[name.to_sym]
      end

      def find(name)
        registry[name.to_sym] or raise ArgumentError, "Unknown color space: #{name}"
      end
    end

    attr_reader :name, :coordinates, :white_point, :color_model

    def initialize(name)
      @name = name.to_sym
      yield self if block_given?
    end

    def coordinates=(*coords)
      @coordinates = coords.flatten
    end

    def white_point=(point)
      @white_point = point.to_sym
    end

    def color_model=(model)
      @color_model = model.to_sym
    end

    def ==(other)
      return false unless other.is_a?(ColorSpace)

      name == other.name
    end

    def eql?(other)
      self == other
    end

    def hash
      name.hash
    end

    def id
      name
    end
  end

  ColorSpace.register(:srgb) do |s|
    s.coordinates = %i[red green blue]
    s.white_point = :D65
    s.color_model = :srgb
  end
  ColorSpace.alias(:srgb, :rgb)

  ColorSpace.register(:lrgb) do |s|
    s.coordinates = %i[red green blue]
    s.white_point = :D65
    s.color_model = :lrgb
  end

  ColorSpace.register(:hsl) do |s|
    s.coordinates = %i[hue saturation lightness]
    s.white_point = :D65
    s.color_model = :hsl
  end

  ColorSpace.register(:lab) do |s|
    s.coordinates = %i[lightness a b]
    s.white_point = :D65
    s.color_model = :lab
  end

  ColorSpace.register(:oklab) do |s|
    s.coordinates = %i[lightness a b]
    s.white_point = :D65
    s.color_model = :oklab
  end

  ColorSpace.register(:oklch) do |s|
    s.coordinates = %i[lightness chroma hue]
    s.white_point = :D65
    s.color_model = :oklch
  end
end
