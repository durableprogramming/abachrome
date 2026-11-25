# Usage

## Basic Color Creation

```ruby
# Create colors in different ways
color = Abachrome.from_rgb(1.0, 0.0, 0.0)           # Red using RGB values
color = Abachrome.from_hex('#FF0000')               # Red using hex
color = Abachrome.from_name('red')                  # Red using CSS color name

# Create color with alpha
color = Abachrome.from_rgb(1.0, 0.0, 0.0, 0.5)     # Semi-transparent red
```

## Color Space Conversion

```ruby
# Convert between color spaces
rgb_color = Abachrome.from_rgb(1.0, 0.0, 0.0)
oklab_color = rgb_color.to_oklab                    # Convert to Oklab
rgb_again = oklab_color.to_rgb                      # Convert back to RGB
```

## Color Output Formats

```ruby
color = Abachrome.from_rgb(1.0, 0.0, 0.0)

# Different output formats
color.rgb_hex                                       # => "#ff0000"
Abachrome::Outputs::CSS.format(color)              # => "#ff0000"
Abachrome::Outputs::CSS.format_rgb(color)          # => "rgb(255, 0, 0)"
```

## Working with Color Gamuts

```ruby
# Check if color is within gamut
srgb_gamut = Abachrome::Gamut::SRGB.new
color = Abachrome.from_rgb(1.2, -0.1, 0.5)
mapped_color = srgb_gamut.map(color.coordinates)    # Map color to gamut
```

## Parsing Colors

Abachrome supports parsing colors from various string formats using the CSS parser:

```ruby
# Hex colors
color = Abachrome::Parsers::CSS.parse('#ff0000')
color = Abachrome::Parsers::CSS.parse('#f00')     # Short hex

# RGB and HSL strings
color = Abachrome::Parsers::CSS.parse('rgb(255, 0, 0)')
color = Abachrome::Parsers::CSS.parse('rgba(255, 0, 0, 0.5)')
color = Abachrome::Parsers::CSS.parse('hsl(0, 100%, 50%)')

# Named colors
color = Abachrome::Parsers::CSS.parse('red')

# Advanced formats
color = Abachrome::Parsers::CSS.parse('oklab(0.5 0.2 -0.1)')
color = Abachrome::Parsers::CSS.parse('oklch(0.5 0.2 120)')
```

## Color Manipulation

Abachrome provides methods for blending and adjusting colors:

```ruby
color1 = Abachrome.from_rgb(1.0, 0.0, 0.0)
color2 = Abachrome.from_rgb(0.0, 1.0, 0.0)

# Blend two colors
blended = color1.blend(color2, 0.5)  # 50% blend

# Adjust lightness
lighter = color1.lighten(0.2)        # Lighten by 20%
```

## Working with Palettes

Create and manipulate color palettes:

```ruby
palette = Abachrome::Palette.new([color1, color2])

# Interpolate between colors
interpolated = palette.interpolate(steps: 5)  # Add 5 interpolated colors between each pair
```

## Advanced Gamut Mapping

Map colors to different color gamuts for accurate display:

```ruby
srgb_gamut = Abachrome::Gamut::SRGB.new
p3_gamut = Abachrome::Gamut::P3.new

out_of_gamut = Abachrome.from_rgb(1.2, -0.1, 0.5)
mapped_srgb = srgb_gamut.map(out_of_gamut.coordinates)
mapped_p3 = p3_gamut.map(out_of_gamut.coordinates)
```
