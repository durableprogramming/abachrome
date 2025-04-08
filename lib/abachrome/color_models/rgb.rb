# frozen_string_literal: true

module Abachrome
  module ColorModels
    class RGB
      class << self
        # Normalizes RGB color component values to the [0,1] range.
        # 
        # @param r [String, Numeric] Red component. If string with % suffix, interpreted as percentage;
        # if string without suffix or numeric > 1, interpreted as 0-255 range value;
        # if numeric ≤ 1, used directly.
        # @param g [String, Numeric] Green component. Same interpretation as red component.
        # @param b [String, Numeric] Blue component. Same interpretation as red component.
        # @return [Array<AbcDecimal>] Array of three normalized components as AbcDecimal objects,
        # each in the range [0,1].
        def normalize(r, g, b)
          [r, g, b].map do |value|
            case value
            when String
              if value.end_with?("%")
                AbcDecimal(value.chomp("%")) / AbcDecimal(100)
              else
                AbcDecimal(value) / AbcDecimal(255)
              end
            when Numeric
              if value > 1
                AbcDecimal(value) / AbcDecimal(255)
              else
                AbcDecimal(value)
              end
            end
          end
        end
      end
    end
  end
end