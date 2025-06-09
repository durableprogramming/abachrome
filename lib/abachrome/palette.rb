#

module Abachrome
  class Palette
    attr_reader :colors

    # Initializes a new color palette with the given colors.
    # Automatically converts non-Color objects to Color objects by parsing them as hex values.
    # 
    # @param colors [Array] An array of colors to include in the palette. Each element can be
    # either a Color object or a string-convertible object representing a hex color code.
    # @return [Abachrome::Palette] A new palette instance containing the provided colors.
    def initialize(colors = [])
      @colors = colors.map { |c| c.is_a?(Color) ? c : Color.from_hex(c.to_s) }
    end

    # Adds a color to the palette.
    # Accepts either an Abachrome::Color object or any object that can be
    # converted to a string and parsed as a hex color code.
    # 
    # @param color [Abachrome::Color, String, #to_s] The color to add to the palette.
    # If not already an Abachrome::Color object, it will be converted using Color.from_hex
    # @return [Abachrome::Palette] self, enabling method chaining
    def add(color)
      color = Color.from_hex(color.to_s) unless color.is_a?(Color)
      @colors << color
      self
    end

    alias << add

    # Removes the specified color from the palette.
    # 
    # @param color [Abachrome::Color, Object] The color to be removed from the palette
    # @return [Abachrome::Palette] Returns self for method chaining
    def remove(color)
      @colors.delete(color)
      self
    end

    # Clears all colors from the palette.
    # 
    # This method removes all stored colors in the palette. It provides a way to
    # reset the palette to an empty state while maintaining the same palette object.
    # 
    # @return [Abachrome::Palette] Returns self for method chaining
    def clear
      @colors.clear
      self
    end

    # Returns the number of colors in the palette.
    # 
    # @return [Integer] the number of colors in the palette
    def size
      @colors.size
    end

    # Returns whether the palette has no colors.
    # 
    # @return [Boolean] true if the palette contains no colors, false otherwise
    def empty?
      @colors.empty?
    end

    # Yields each color in the palette to the given block.
    # 
    # @param block [Proc] The block to be executed for each color in the palette.
    # @yield [Abachrome::Color] Each color in the palette.
    # @return [Enumerator] Returns an Enumerator if no block is given.
    # @see Enumerable#each
    def each(&block)
      @colors.each(&block)
    end
    # Calls the given block once for each color in the palette, passing the color and its index as parameters.
    # 
    # @example
    # palette.each_with_index { |color, index| puts "Color #{index}: #{color}" }
    # 
    # @param block [Proc] The block to be called for each color
    # @yield [color, index] Yields a color and its index
    # @yieldparam color [Abachrome::Color] The color at the current position
    # @yieldparam index [Integer] The index of the current color
    # @return [Enumerator] If no block is given, returns an Enumerator
    # @return [Array<Abachrome::Color>] Returns the array of colors if a block is given
    def each_with_index(&block)
      @colors.each_with_index(&block)
    end

    # Maps the palette by applying a block to each color.
    # 
    # @param block [Proc] A block that takes a color and returns a new color.
    # @return [Abachrome::Palette] A new palette with the mapped colors.
    # @example
    # # Convert all colors in palette to grayscale
    # palette.map { |color| color.grayscale }
    def map(&block)
      self.class.new(@colors.map(&block))
    end

    # Returns a duplicate of the internal colors array.
    # 
    # @return [Array<Abachrome::Color>] A duplicate of the palette's color array
    def to_a
      @colors.dup
    end

    # Access a color in the palette at the specified index.
    # 
    # @param index [Integer] The index of the color to retrieve from the palette
    # @return [Abachrome::Color, nil] The color at the specified index, or nil if the index is out of bounds
    def [](index)
      @colors[index]
    end

    # Slices the palette to create a new palette with a subset of colors.
    # 
    # @param start [Integer] The starting index (or range) from which to start the slice.
    # @param length [Integer, nil] The number of colors to include in the slice. If nil and start is an Integer,
    # returns a new palette containing the single color at that index. If start is a Range, length is ignored.
    # @return [Abachrome::Palette] A new palette containing the selected colors.
    def slice(start, length = nil)
      new_colors = length ? @colors[start, length] : @colors[start]
      self.class.new(new_colors)
    end

    # Returns the first color in the palette.
    # 
    # @return [Abachrome::Color, nil] The first color in the palette, or nil if the palette is empty.
    def first
      @colors.first
    end

    # Returns the last color in the palette.
    # 
    # @return [Abachrome::Color, nil] The last color in the palette or nil if palette is empty.
    def last
      @colors.last
    end

    # Returns a new palette with colors sorted by lightness.
    # This method creates a new palette instance containing the same colors as the current
    # palette but sorted in ascending order based on their lightness values.
    # 
    # @return [Abachrome::Palette] a new palette with the same colors sorted by lightness
    def sort_by_lightness
      self.class.new(@colors.sort_by(&:lightness))
    end

    # Returns a new palette with colors sorted by saturation from lowest to highest.
    # Saturation is determined by the second coordinate (a*) in the OKLAB color space.
    # Lower values represent less saturated colors, higher values represent more saturated colors.
    # 
    # @return [Abachrome::Palette] A new palette instance with the same colors sorted by saturation
    def sort_by_saturation
      self.class.new(@colors.sort_by { |c| c.to_oklab.coordinates[1] })
    end

    # Blends all colors in the palette together sequentially at the specified amount.
    # This method takes each color in the palette and blends it with the accumulated result
    # of previous blends. It starts with the first color and progressively blends each subsequent
    # color at the specified blend amount.
    # 
    # @param amount [Float] The blend amount to use between each color pair, between 0.0 and 1.0.
    # Defaults to 0.5 (equal blend).
    # @return [Abachrome::Color, nil] The final blended color result, or nil if the palette is empty.
    def blend_all(amount = 0.5)
      return nil if empty?

      result = first
      @colors[1..].each do |color|
        result = result.blend(color, amount)
      end
      result
    end

    # Calculates the average color of the palette by finding the centroid in OKLAB space.
    # This method converts each color in the palette to OKLAB coordinates,
    # calculates the arithmetic mean of these coordinates, and creates a new
    # color from the average values. Alpha values are also averaged.
    # 
    # @return [Abachrome::Color, nil] The average color of all colors in the palette,
    # or nil if the palette is empty
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

    # Converts the colors in the palette to CSS-formatted strings.
    # 
    # The format of the output can be specified with the format parameter.
    # 
    # @param format [Symbol] The format to use for the CSS color strings.
    # :hex - Outputs colors in hexadecimal format (e.g., "#RRGGBB")
    # :rgb - Outputs colors in rgb() function format
    # :oklab - Outputs colors in oklab() function format
    # When any other value is provided, a default format is used.
    # @return [Array<String>] An array of CSS-formatted color strings
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

    # Returns a string representation of the palette for inspection purposes.
    # 
    # @return [String] A string containing the class name and a list of colors in the palette
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