# frozen_string_literal: true

module Abachrome
  class Palette
    attr_reader :colors

    def initialize(colors = [])
      @colors = colors.map { |c| c.is_a?(Color) ? c : Color.from_hex(c.to_s) }
    end

    def add(color)
      color = Color.from_hex(color.to_s) unless color.is_a?(Color)
      @colors << color
      self
    end

    alias << add

    def remove(color)
      @colors.delete(color)
      self
    end

    def clear
      @colors.clear
      self
    end

    def size
      @colors.size
    end

    def empty?
      @colors.empty?
    end

    def each(&block)
      @colors.each(&block)
    end
    def each_with_index(&block)
      @colors.each_with_index(&block)
    end

    def map(&block)
      self.class.new(@colors.map(&block))
    end

    def to_a
      @colors.dup
    end

    def [](index)
      @colors[index]
    end

    def slice(start, length = nil)
      new_colors = length ? @colors[start, length] : @colors[start]
      self.class.new(new_colors)
    end

    def first
      @colors.first
    end

    def last
      @colors.last
    end

    def sort_by_lightness
      self.class.new(@colors.sort_by(&:lightness))
    end

    def sort_by_saturation
      self.class.new(@colors.sort_by { |c| c.to_oklab.coordinates[1] })
    end

    def blend_all(amount = 0.5)
      return nil if empty?

      result = first
      @colors[1..].each do |color|
        result = result.blend(color, amount)
      end
      result
    end

    def average
      return nil if empty?

      oklab_coords = @colors.map(&:to_oklab).map(&:coordinates)
      avg_coords = oklab_coords.reduce([0, 0, 0]) do |sum, coords|
        [sum[0] + coords[0], sum[1] + coords[1], sum[2] + coords[2]]
      end
      avg_coords.map! { |c| c / size }

      Color.new(
        ColorSpace.find(:oklab),
        avg_coords,
        @colors.map(&:alpha).sum / size
      )
    end

    def to_css(format: :hex)
      to_a.map do |color|
        case format
        when :hex
          Outputs::CSS.format_hex(color)
        when :rgb
          Outputs::CSS.format_rgb(color)
        when :oklab
          Outputs::CSS.format_oklab(color)
        else
          Outputs::CSS.format(color)
        end
      end
    end

    def inspect
      "#<#{self.class} colors=#{@colors.map(&:to_s)}>"
    end

    mixins_path = File.join(__dir__, "palette_mixins", "*.rb")
    Dir[mixins_path].each do |file|
      require file
      mixin_name = File.basename(file, ".rb")
      inflector = Dry::Inflector.new
      mixin_module = Abachrome::PaletteMixins.const_get(inflector.camelize(mixin_name))
      include mixin_module
    end
  end
end
