#

module Abachrome
  module Gamut
    def self.register(gamut)
      @gamuts ||= {}
      @gamuts[gamut.name] = gamut
    end

    def self.find(name)
      @gamuts ||= {}
      @gamuts[name.to_sym] or raise ArgumentError, "Unknown gamut: #{name}"
    end

    def self.gamuts
      @gamuts ||= {}
    end

    class Base
      attr_reader :name, :primaries, :white_point

      def initialize(name, primaries, white_point)
        @name = name
        @primaries = primaries
        @white_point = white_point
      end

      # TODO: - make this work properly
      def contains?(coordinates)
        x, y, z = coordinates
        x >= 0 && x <= 1 &&
          y >= 0 && y <= 1 &&
          z >= 0 && z <= 1
      end

      def map(coordinates, method: :clip)
        case method
        when :clip
          clip(coordinates)
        when :scale
          scale(coordinates)
        else
          raise ArgumentError, "Unknown mapping method: #{method}"
        end
      end

      private

      def clip(coordinates)
        coordinates.map do |c|
          c.clamp(0, 1)
        end
      end

      def scale(coordinates, channels = nil, min = nil, max = nil)
        min ||= coordinates.min
        max ||= coordinates.max
        channels ||= (0..(coordinates.length - 1)).to_a

        scale_factor = if max > 1
                         1.0 / max
                       elsif min.negative?
                         1.0 / (1 - min)
                       else
                         1.0
                       end

        coordinates.each_with_index.map { |c, channel_index| channels.include?(channel_index) ? c * scale_factor : c }
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.