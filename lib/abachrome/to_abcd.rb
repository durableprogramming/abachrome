# frozen_string_literal: true

module Abachrome
  module ToAbcd
    def to_abcd
      AbcDecimal.new(self)
    end
  end
end

[Numeric, String, Rational].each do |klass|
  klass.include(Abachrome::ToAbcd)
end
