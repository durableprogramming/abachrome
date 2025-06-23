#!/usr/bin/env ruby

require 'yaml'
require 'open3'

# Generate test color data by using pastel command line tool
class ColorGenerator
  def initialize
    @colors = {}
  end

  def generate
    color_names = get_color_names
    
    color_names.each do |color_name|
      puts "Processing #{color_name}..."
      color_data = process_color(color_name)
      @colors[color_name] = color_data if color_data
    end

    write_fixtures_file
  end

  private

  def get_color_names
    stdout, stderr, status = Open3.capture3('pastel list | shuf | head -25')
    
    unless status.success?
      puts "Error running 'pastel list': #{stderr}"
      exit 1
    end

    # Parse color names from pastel list output
    color_names = []
    stdout.each_line do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')
      
      # Extract color name (assumes format like "red" or "dark_red")
      if line.match(/^\w+$/)
        color_names << line
      end
    end

    color_names.sort.uniq
  end

  def process_color(color_name)
    formats = %w[rgb hex hsl lab oklab]
    color_data = {}

    formats.each do |format|
      stdout, stderr, status = Open3.capture3("pastel format #{format} #{color_name}")
      
      if status.success?
        result = stdout.strip
        color_data[format] = result unless result.empty?
      else
        puts "Warning: Could not get #{format} for #{color_name}: #{stderr}"
      end
    end

    # Only return color data if we got at least some formats
    color_data.empty? ? nil : color_data
  end

  def write_fixtures_file
    fixtures_dir = File.join(__dir__, 'fixtures')
    Dir.mkdir(fixtures_dir) unless Dir.exist?(fixtures_dir)
    
    fixtures_file = File.join(fixtures_dir, 'colors.yml')
    
    File.open(fixtures_file, 'w') do |file|
      file.write("# Generated test color data\n")
      file.write("# Created by test/generate_test_colors.rb\n")
      file.write("# Do not edit manually\n\n")
      file.write(@colors.to_yaml)
    end

    puts "Generated #{@colors.size} colors in #{fixtures_file}"
  end
end

if __FILE__ == $0
  generator = ColorGenerator.new
  generator.generate
end
