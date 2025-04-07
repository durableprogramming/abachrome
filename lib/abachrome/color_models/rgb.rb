# frozen_string_literal: true

module Abachrome
  module ColorModels
    class RGB
      class << self
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
