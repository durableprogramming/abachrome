# Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Testing

Tests are run automatically in CI/CD pipelines for all pull requests and pushes to the main branch. The test suite includes:

- Unit tests for all color models and converters
- Integration tests for parsing and output functionality
- Performance benchmarks for critical operations

To run tests locally:
```bash
rake test
```

Tests must pass before any changes can be merged to the main branch.

## Testing Policy

- **All changes**: Must not break existing tests
- **New features**: Must include comprehensive unit tests
- **Bug fixes**: Must include regression tests
- **Major changes**: Require code review and may need additional integration tests
- **Performance changes**: Must include benchmark comparisons

All pull requests require tests to pass CI checks before merging.
