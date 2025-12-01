# Security Policy

## Reporting Vulnerabilities

If you discover a security vulnerability in Abachrome, please report it to us as follows:

### Contact
Email: security@durableprogramming.com

### Response Time
We will acknowledge receipt of your report within 72 hours and provide a more detailed response within 7 days indicating our next steps.

### Disclosure
We ask that you do not publicly disclose the vulnerability until we have had a chance to address it. We will work with you to determine an appropriate disclosure timeline.

## Vulnerability Management

### Classification
Vulnerabilities are classified as:
- **Critical**: Immediate threat to user data or system security
- **High**: Significant security risk
- **Medium**: Moderate security concern
- **Low**: Minor security issue

### Remediation Timeline
- **Critical**: Within 48 hours
- **High**: Within 7 days
- **Medium**: Within 30 days
- **Low**: Within 90 days

### Process
1. Report received and acknowledged
2. Assessment and classification
3. Development of fix
4. Testing and validation
5. Release of patched version
6. Public disclosure (if applicable)

## Automated Security Scanning

### SCA (Software Composition Analysis)
- **Tool**: bundle-audit
- **Frequency**: Run on all CI builds and weekly scheduled scans
- **Threshold**: All vulnerabilities must be addressed before release
- **Policy**: Critical and High severity vulnerabilities must be fixed immediately. Medium severity within 30 days. Low severity tracked but may be accepted with risk assessment.

### SAST (Static Application Security Testing)
- **Tool**: Brakeman
- **Frequency**: Run on all CI builds
- **Threshold**: All warnings must be reviewed. High-confidence findings must be fixed. False positives documented.
- **Policy**: Security findings block releases. Code review required for waivers.

### Dependency Updates
- **Process**: Automated PRs for patch updates. Manual review for minor/major updates.
- **Testing**: Full test suite run on dependency updates.
- **Rollback**: Ability to rollback if issues discovered post-update.

## Security Updates
Security updates will be released as patch versions with descriptive changelogs. Subscribe to releases on GitHub to stay informed.

## Verifying Releases

To ensure the integrity and authenticity of Abachrome releases:

1. **Checksum Verification**: Each release includes SHA256 checksums for all assets. Download the checksum file and verify using:
   ```
   sha256sum -c abachrome-<version>.gem.sha256
   ```

2. **Signature Verification** (future): Releases will be signed with GPG. Verify using:
   ```
   gpg --verify abachrome-<version>.gem.asc abachrome-<version>.gem
   ```

3. **Source Verification**: Always build from the official GitHub repository source.

## Support and Maintenance

### Support Scope
Abachrome provides support for:
- Current stable Ruby versions (3.0+)
- Reported security vulnerabilities
- Critical bugs affecting core functionality

### Support Duration
- **Active Support**: Latest major version receives full support
- **Security Support**: Versions receive security updates for 1 year after release
- **End of Life**: Versions without security support are documented in release notes

### Security Update Policy
Security updates are provided for the current major version and the previous major version for up to 1 year after the new major version's release. Older versions may receive critical security fixes at our discretion.

## Current Known Vulnerabilities
None at this time.
