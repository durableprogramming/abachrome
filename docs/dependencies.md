# Dependencies

Abachrome has minimal dependencies to maintain performance and compatibility:

## Runtime Dependencies
- **dry-inflector** (~> 1.0): Provides utilities for dynamic class loading and color space management

## Development Dependencies
- Testing framework (minitest)
- Code quality tools (rubocop)

## Dependency Management
Dependencies are specified in `abachrome.gemspec` and managed via Bundler.

To check for dependency updates:
```bash
bundle outdated
```

To update dependencies:
```bash
bundle update
```

All dependencies are selected based on:
- Active maintenance and community support
- Minimal footprint and performance impact
- Compatibility with Ruby 3.0+ requirements
