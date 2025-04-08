# frozen_string_literal: true

module Abachrome
  class ColorSpace
    class << self
      # A registry of all registered color spaces.
      # 
      # @return [Hash] A memoized hash where keys are color space identifiers and values are the corresponding color space objects
      def registry
        @registry ||= {}
      end

      # Registers a new color space with the specified name.
      # 
      # @param name [String, Symbol] The identifier for the color space
      # @param block [Proc] A block that configures the color space properties
      # @return [Abachrome::ColorSpace] The newly created color space instance added to the registry
      def register(name, &block)
        registry[name.to_sym] = new(name, &block)
      end

      # Aliases a color space name to an existing registered color space.
      # 
      # This method creates an alias for an existing color space in the registry,
      # allowing the same color space to be accessed through multiple names.
      # 
      # @param name [Symbol, String] The existing color space name already registered
      # @param aliased_name [Symbol, String] The new alias name to register
      # @return [void]
      def alias(name, aliased_name)
        registry[aliased_name.to_sym] = registry[name.to_sym]
      end

      # @param name [String, Symbol] The name of the color space to find
      # @return [Abachrome::ColorSpace] The color space with the given name
      # @raise [ArgumentError] If no color space with the given name exists in the registry
      def find(name)
        registry[name.to_sym] or raise ArgumentError, "Unknown color space: #{name}"
      end
    end

    attr_reader :name, :coordinates, :white_point, :color_model

    # Initialize a new ColorSpace instance.
    # 
    # @param name [String, Symbol] The name of the color space, which will be converted to a symbol
    # @return [Abachrome::ColorSpace] A new instance of ColorSpace
    # @yield [self] Yields self to the block for configuration if a block is given
    def initialize(name)
      @name = name.to_sym
      yield self if block_given?
    end

    # Sets the color coordinates for the current color space.
    # 
    # @param [Array] coords The coordinate values that define a color in this color space.
    # Multiple arguments or a single flat array can be provided.
    # @return [Array] The flattened array of coordinates.
    def coordinates=(*coords)
      @coordinates = coords.flatten
    end

    # Sets the white point reference used by the color space.
    # 
    # The white point is a reference that defines what is considered "white" in a color space.
    # Common values include :D50, :D65, etc.
    # 
    # @param point [Symbol, String] The white point reference to use (will be converted to Symbol)
    # @return [Symbol] The newly set white point
    def white_point=(point)
      @white_point = point.to_sym
    end

    # Sets the color model for the color space.
    # 
    # @param model [String, Symbol] The new color model to set for this color space
    # @return [Symbol] The color model as a symbolized value
    def color_model=(model)
      @color_model = model.to_sym
    end

    # Compares this ColorSpace instance with another to check for equality.
    # 
    # Two ColorSpace objects are considered equal if they have the same name.
    # 
    # @param other [Object] The object to compare against
    # @return [Boolean] true if other is a ColorSpace with the same name, false otherwise
    def ==(other)
      return false unless other.is_a?(ColorSpace)

      name == other.name
    end

    # Checks if two color spaces are equal.
    # 
    # @param other [Abachrome::ColorSpace] The color space to compare with
    # @return [Boolean] true if the color spaces are equal, false otherwise
    def eql?(other)
      self == other
    end

    # Returns a hash value for the color space based on its name.
    # 
    # @return [Integer] A hash value computed from the color space name that can be
    # used for equality comparison and as a hash key.
    def hash
      name.hash
    end

    # Returns the identifier for the color space, which is currently the same as its name.
    # @return [String, Symbol] the identifier of the color space
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