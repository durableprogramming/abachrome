# frozen_string_literal: true

module Abachrome
  class Converter
    class << self
      # Returns the registry hash used to store color space converters.
      # 
      # This method lazily initializes and returns the hash used internally to store
      # converter mappings between different color spaces. This registry is a central
      # repository that maps color space pairs to their appropriate conversion functions.
      # 
      # @return [Hash] The converter registry hash, mapping color space pairs to converter functions
      def registry
        @registry ||= {}
      end

      # Register a converter class for transforming colors between two specific color spaces.
      # 
      # @param from_space [Symbol, String] The source color space identifier
      # @param to_space [Symbol, String] The destination color space identifier
      # @param converter_class [Class] The converter class that implements the transformation
      # @return [Class] The registered converter class
      def register(from_space, to_space, converter_class)
        registry[[from_space.to_s, to_space.to_s]] = converter_class
      end

      # Converts a color from its current color space to the specified target color space.
      # 
      # @param color [Abachrome::Color] The color to convert
      # @param to_space_name [String, Symbol] The name of the target color space
      # @return [Abachrome::Color] The color converted to the target color space
      # @raise [RuntimeError] If no converter is found between the source and target color models
      def convert(color, to_space_name)
        to_space = ColorSpace.find(to_space_name)
        return color if color.color_space == to_space

        # convert model first
        to_model = to_space.color_model
        converter = find_converter(color.color_space.color_model, to_model.to_s)
        raise "No converter found from #{color.color_space.color_model} to #{to_model}" unless converter

        converter.convert(color)
      end

      # @api private
      # @since 0.1.0
      # @example
      # converter = Abachrome::Converter.new
      # converter.register_all_converters
      # 
      # Automatically registers all converter classes found in the Converters namespace.
      # The method iterates through constants in the Converters module, identifies classes
      # with naming pattern "FromSpaceToSpace" (e.g., LrgbToOklab), extracts the source
      # and destination color spaces from the class name, and registers the converter
      # class for the corresponding color space conversion.
      # 
      # @return [void]
      def register_all_converters
        Converters.constants.each do |const_name|
          const = Converters.const_get(const_name)
          next unless const.is_a?(Class)

          # Parse from_space and to_space from class name (e.g., LrgbToOklab)
          next unless const_name.to_s =~ /^(.+)To(.+)$/

          from_space = ::Regexp.last_match(1).downcase.to_sym
          to_space = ::Regexp.last_match(2).downcase.to_sym

          # Register the converter
          register(from_space, to_space, const)
        end
      end

      private

      # Retrieves a converter function between two color spaces from the registry.
      # 
      # @param from_space_name [String, Symbol] The source color space name
      # @param to_space_name [String, Symbol] The target color space name
      # @return [Proc, nil] The conversion function if registered, or nil if no converter exists for the specified color spaces
      def find_converter(from_space_name, to_space_name)
        registry[[from_space_name.to_s, to_space_name.to_s]]
      end
    end
  end

  # Load all converter files
  converters_path = File.join(__dir__, "converters", "*.rb")
  Dir[converters_path].each do |file|
    require file
  end

  # Auto-register all converters
  Converter.register_all_converters
end