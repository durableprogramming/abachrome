# frozen_string_literal: true

require_relative "lib/abachrome/version"

Gem::Specification.new do |spec|
  spec.name = "abachrome"
  spec.version = Abachrome::VERSION
  spec.authors = ["Durable Programming"]
  spec.email = ["commercial@durableprogramming.com"]

  spec.summary = "A Ruby gem for parsing, manipulating, and managing colors"
  spec.description = "Abachrome provides a robust set of tools for working with various color formats including hex, RGB, HSL, and named colors. Features support for multiple color spaces (RGB, HSL, Lab, Oklab), color space conversion, gamut mapping, CSS color parsing and formatting, and high-precision color calculations using BigDecimal."
  spec.homepage = "https://github.com/durableprogramming/abachrome"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/durableprogramming/abachrome"
  spec.metadata["changelog_uri"] = "https://github.com/durableprogramming/abachrome/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "dry-inflector", "~> 1.0"

end

