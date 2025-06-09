# Abachrome::Converters::Base - Abstract base class for color space converters
#
# This class provides the foundation for implementing color space conversion functionality
# within the Abachrome library. It defines the interface that all converter classes must
# implement and provides common validation and utility methods for color transformations.
#
# Key features:
# - Abstract conversion interface requiring subclasses to implement #convert method
# - Color model validation to ensure proper conversion compatibility
# - Converter registration and lookup system for managing conversion mappings
# - Source and target color space compatibility checking
# - Base functionality for building specific converter implementations
#
# All converter classes in the Abachrome system inherit from this base class and implement
# the specific mathematical transformations needed to convert colors between different
# color spaces such as sRGB, OKLAB, OKLCH, and linear RGB. The class follows a naming
# convention pattern (FromSpaceToSpace) for automatic registration and discovery.

module Abachrome
  module Converters
    class Base
      attr_reader :from_space, :to_space

      # Initialize a new converter between two color spaces.
      # 
      # @param from_space [Abachrome::ColorSpace] The source color space to convert from
      # @param to_space [Abachrome::ColorSpace] The target color space to convert to
      # @return [Abachrome::Converters::Base] A new converter instance
      def initialize(from_space, to_space)
        @from_space = from_space
        @to_space = to_space
      end

      # Converts a color from one color space to another.
      # 
      # @abstract This is an abstract method that must be implemented by subclasses.
      # @param color [Abachrome::Color] The color to convert
      # @return [Abachrome::Color] The converted color
      # @raise [NotImplementedError] If the subclass doesn't implement this method
      def convert(color)
        raise NotImplementedError, "Subclasses must implement #convert"
      end

      # Validates that a color uses the expected color model.
      # 
      # @param color [Abachrome::Color] The color object to check
      # @param model [Symbol, String] The expected color model
      # @raise [RuntimeError] If the color's model doesn't match the expected model
      # @return [nil] If the color's model matches the expected model
      def self.raise_unless(color, model)
        return if color.color_space.color_model == model

        raise "#{color} is #{color.color_space.color_model}), expecting #{model}"
      end

      # Determines if the converter can handle the given color.
      # 
      # This method checks if the color's current color space matches
      # the converter's source color space.
      # 
      # @param color [Abachrome::Color] The color to check
      # @return [Boolean] true if the converter can convert from the color's current color space,
      # false otherwise
      def can_convert?(color)
        color.color_space == from_space
      end

      # Register a converter class for transforming colors between two specific color spaces.
      # 
      # @param from_space_id [Symbol] The identifier of the source color space
      # @param to_space_id [Symbol] The identifier of the destination color space
      # @param converter_class [Class] The converter class that handles the transformation
      # @return [void]
      def self.register(from_space_id, to_space_id, converter_class)
        @converters ||= {}
        @converters[[from_space_id, to_space_id]] = converter_class
      end

      # Find a converter for converting between color spaces.
      # 
      # @param from_space_id [Symbol, String] The identifier of the source color space
      # @param to_space_id [Symbol, String] The identifier of the destination color space
      # @return [Converter, nil] The converter instance for the specified color spaces, or nil if no converter is found
      def self.find_converter(from_space_id, to_space_id)
        @converters ||= {}
        @converters[[from_space_id, to_space_id]]
      end

      # Converts a color from its current color space to a target color space.
      # 
      # This method finds the appropriate converter class for the given source and
      # target color spaces and performs the conversion.
      # 
      # @param color [Abachrome::Color] The color to convert
      # @param to_space [Abachrome::ColorSpace] The target color space to convert to
      # @return [Abachrome::Color] The converted color in the target color space
      # @raise [ConversionError] If no converter is found for the given color spaces
      def self.convert(color, to_space)
        converter_class = find_converter(color.color_space.id, to_space.id)
        unless converter_class
          raise ConversionError,
                "No converter found from #{color.color_space.name} to #{to_space.name}"
        end

        converter = converter_class.new(color.color_space, to_space)
        converter.convert(color)
      end

      private

      # Validates if a color can be converted from its current color space.
      # Raises an ArgumentError if the color's space doesn't match the expected source space.
      # 
      # @param color [Abachrome::Color] The color object to validate
      # @raise [ArgumentError] If the color cannot be converted from its current color space
      # @return [nil] Returns nil if the color is valid for conversion
      def validate_color!(color)
        return if can_convert?(color)

        raise ArgumentError, "Cannot convert color from #{color.color_space.name} (expected #{from_space.name})"
      end
    end
  end
end