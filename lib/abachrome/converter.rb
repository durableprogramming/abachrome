# frozen_string_literal: true

module Abachrome
  class Converter
    class << self
      def registry
        @registry ||= {}
      end

      def register(from_space, to_space, converter_class)
        registry[[from_space.to_s, to_space.to_s]] = converter_class
      end

      def convert(color, to_space_name)
        to_space = ColorSpace.find(to_space_name)
        return color if color.color_space == to_space

        # convert model first
        to_model = to_space.color_model
        converter = find_converter(color.color_space.color_model, to_model.to_s)
        raise "No converter found from #{color.color_space.color_model} to #{to_model}" unless converter

        converter.convert(color)
      end

      # Automatically register all converters in the Converters namespace
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
