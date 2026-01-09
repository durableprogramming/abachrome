#

module Abachrome
  module ToAbcd
    # Converts the receiver to an AbcDecimal object.
    # 
    # This method converts the receiver (typically a numeric value) to an AbcDecimal
    # instance, which provides high precision decimal arithmetic capabilities for
    # color space calculations.
    # 
    # @return [Abachrome::AbcDecimal] a new AbcDecimal instance representing the
    # same numeric value as the receiver
    def to_abcd
      AbcDecimal.new(self)
    end
  end
end

[Numeric, String, Rational].each do |klass|
  klass.include(Abachrome::ToAbcd)
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.