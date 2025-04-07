# frozen_string_literal: true

require "minitest"

require "simplecov"
SimpleCov.start

module Minitest
  class Test
    def assert_coordinates_equal(expected, actual, delta = 0.001)
      assert_equal expected.size, actual.size, "Coordinates arrays must have same size"
      expected.zip(actual).each_with_index do |(exp, act), i|
        assert_in_delta exp, act, delta, "Coordinate at index #{i} differs by more than #{delta}"
      end
    end
  end
end
