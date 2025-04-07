# Abachrome

Abachrome is a Ruby gem for parsing, manipulating, and managing colors. It provides a robust set of tools for working with various color formats including hex, RGB, HSL, and named colors.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'abachrome'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install abachrome
```

## Usage

### Basic Color Creation

```ruby
# Create colors in different ways
color = Abachrome.from_rgb(1.0, 0.0, 0.0)           # Red using RGB values
color = Abachrome.from_hex('#FF0000')               # Red using hex
color = Abachrome.from_name('red')                  # Red using CSS color name

# Create color with alpha
color = Abachrome.from_rgb(1.0, 0.0, 0.0, 0.5)     # Semi-transparent red
```

### Color Space Conversion

```ruby
# Convert between color spaces
rgb_color = Abachrome.from_rgb(1.0, 0.0, 0.0)
oklab_color = rgb_color.to_oklab                    # Convert to Oklab
rgb_again = oklab_color.to_rgb                      # Convert back to RGB
```

### Color Output Formats

```ruby
color = Abachrome.from_rgb(1.0, 0.0, 0.0)

# Different output formats
color.rgb_hex                                       # => "#ff0000"
Abachrome::Outputs::CSS.format(color)              # => "#ff0000"
Abachrome::Outputs::CSS.format_rgb(color)          # => "rgb(255, 0, 0)"
```

### Working with Color Gamuts

```ruby
# Check if color is within gamut
srgb_gamut = Abachrome::Gamut::SRGB.new
color = Abachrome.from_rgb(1.2, -0.1, 0.5)
mapped_color = srgb_gamut.map(color.coordinates)    # Map color to gamut
```

## Features

- Support for multiple color spaces (RGB, HSL, Lab, Oklab)
- Color space conversion
- Gamut mapping
- CSS color parsing and formatting
- Support for CSS named colors
- High-precision color calculations using BigDecimal
- Alpha channel support

## Requirements

- Ruby >= 3.0.0

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/durableprogramming/abachrome.

# Acknowledgement

We'd like to thank the excellent Color.js and culori color libraries, which helped inspire this project and
inform its design.
