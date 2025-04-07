# frozen_string_literal: true

module Abachrome
  module Converters
    class Base
      attr_reader :from_space, :to_space

      def initialize(from_space, to_space)
        @from_space = from_space
        @to_space = to_space
      end

      def convert(color)
        raise NotImplementedError, "Subclasses must implement #convert"
      end

      def self.raise_unless(color, model)
        return if color.color_space.color_model == model

        raise "#{color} is #{color.color_space.color_model}), expecting #{model}"
      end

      def can_convert?(color)
        color.color_space == from_space
      end

      def self.register(from_space_id, to_space_id, converter_class)
        @converters ||= {}
        @converters[[from_space_id, to_space_id]] = converter_class
      end

      def self.find_converter(from_space_id, to_space_id)
        @converters ||= {}
        @converters[[from_space_id, to_space_id]]
      end

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

      def validate_color!(color)
        return if can_convert?(color)

        raise ArgumentError, "Cannot convert color from #{color.color_space.name} (expected #{from_space.name})"
      end
    end
  end
end
