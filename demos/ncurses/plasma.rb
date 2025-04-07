require 'bundler/setup'

require "curses"
require "abachrome"

DELAY = 0.0016 
PLASMA_SCALE = 0.02
TIME_SCALE = 2.0

# Generate base hue for the palette
base_hue = rand(0..360)
base_color = Abachrome.from_oklch(0.5, 0.2, base_hue)

# Create 255 shades palette interpolating from black to base_color to white
black = Abachrome.from_rgb(0, 0, 0)
white = Abachrome.from_rgb(1, 1, 1)
palette = Abachrome::Palette.new([black, base_color, white])
palette = palette.interpolate(32)

def plasma(x, y, t)
  x_scaled = x * PLASMA_SCALE
  y_scaled = y * PLASMA_SCALE
  t_scaled = t * TIME_SCALE

  value = Math.sin(x_scaled) + Math.sin(y_scaled) +
          Math.sin(x_scaled + y_scaled + t_scaled) +
          Math.sin(Math.sqrt((x_scaled * x_scaled + y_scaled * y_scaled)) + t_scaled)

  # Normalize to 0..1 range
  (value + 4) / 8
end

def pick_color(value, palette)
  normalized = (value * (palette.size - 1))

  # Error diffusion dithering
  error = normalized - normalized.floor
  if rand < error
    normalized.ceil
  else
    normalized.floor
  end + 1
end

begin
  require 'curses'

  Curses.init_screen
  Curses.start_color
  Curses.curs_set(0)
  Curses.noecho
  Curses.cbreak
  Curses.stdscr.nodelay = 1

  total_colors = palette.size
  bar_width = 50

  Curses.setpos(Curses.lines / 2 - 1, (Curses.cols - 20) / 2)
  Curses.addstr("Initializing colors")

  Curses.use_default_colors
  palette.each_with_index do |color, i|
    progress = ((i + 1).to_f / total_colors * bar_width).to_i
    
    Curses.attron(Curses.color_pair(0)) {
      Curses.setpos(Curses.lines / 2, (Curses.cols - bar_width) / 2)
      Curses.addstr("[" + "#" * progress + " " * (bar_width - progress) + "]")
      
      Curses.setpos(Curses.lines / 2 + 1, (Curses.cols - 20) / 2)
      percentage = ((i + 1).to_f / total_colors * 100).to_i
      Curses.addstr("#{percentage}% complete")
    }
    
    Curses.refresh
    
    rgb = color.rgb_array.map { |_| ((_ * 1000)/255).to_i }
    Curses.init_color(i + 1, rgb[0], rgb[1], rgb[2])
    Curses.init_pair(i + 1, i + 1, i + 1)
    
  end

  Curses.setpos(Curses.lines / 2 + 2, (Curses.cols - 20) / 2)
  Curses.addstr("Done!")
  Curses.refresh

  height = Curses.lines
  width = Curses.cols
  start_time = Time.now
  frame_count = 0
  last_fps_update = start_time

  loop do

    t = Time.now - start_time
    frame_count += 1

    # Update FPS counter every second
    if Time.now - last_fps_update >= 1
      fps = frame_count / (Time.now - last_fps_update)
      frame_count = 0
      last_fps_update = Time.now
      fps_str = format("FPS: %.1f", fps.to_f)
      Curses.setpos(height - 1, width - fps_str.length)
      Curses.addstr(fps_str)
      Curses.setpos(height - 1, 0)
      Curses.addstr('Frame' +  frame_count.to_s)
    end

    height.times do |y|
      width.times do |x|
        value = plasma(x, y, t)
        color_index = pick_color(value, palette)
        Curses.setpos(y, x)
        Curses.attron(Curses.color_pair(color_index.to_i)) { Curses.addstr("X") }
      end
    end

    Curses.refresh
    sleep(DELAY)
  end

ensure
  Curses.close_screen
end
