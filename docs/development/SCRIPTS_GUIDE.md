# Scripts Guide

Comprehensive guide to all scripts in the alteriom-docker-images repository.

## Quick Reference

| Script | Purpose | Time | Frequency |
|--------|---------|------|-----------|
| [status-check.sh](#status-checksh) | Quick health check | 10s | As needed |
| [verify-images.sh](#verify-imagessh) | Verify published images | 2s | After builds |
| [test-esp-builds.sh](#test-esp-buildssh) | Test ESP platform builds | 2.5min | Before release |
| [build-images.sh](#build-imagessh) | Build and push images | 15-45min | Admin only |
| [validate-workflows.sh](#validate-workflowssh) | Validate CI/CD config | 5s | Before commits |

## 📦 Core Build Scripts

### build-images.sh

**Purpose**: Build and optionally push Docker images to registry

**Usage**:
```bash
# Build locally without pushing
export DOCKER_REPOSITORY=ghcr.io/your_user/alteriom-docker-images
./scripts/build-images.sh

# Build and push both images
./scripts/build-images.sh push

# Build and push development image only (daily builds)
./scripts/build-images.sh dev-only
```

**Requirements**:
- Docker installed and running
- `DOCKER_REPOSITORY` environment variable set
- Network access to base image registries
- 15-45 minutes execution time (never cancel!)

**Options**:
- `push` - Build and push both production and development images
- `dev-only` - Build and push only development image (cost optimized)
- (no args) - Build locally without pushing

**Environment Variables**:
- `DOCKER_REPOSITORY` (required) - Target registry
- `PLATFORMS` (optional) - Build platforms (default: linux/amd64,linux/arm64)
- `AUDIT_RESULT` (optional) - Audit-driven build context
- `AUDIT_CHANGES` (optional) - Changes summary for build

**Exit Codes**:
- 0 - Success
- 1 - Build failure
- 2 - Missing DOCKER_REPOSITORY

**Examples**:
```bash
# Production build and push
export DOCKER_REPOSITORY=ghcr.io/Alteriom/alteriom-docker-images
./scripts/build-images.sh push

# Daily development build
./scripts/build-images.sh dev-only

# Local testing (no push)
./scripts/build-images.sh
```

### compare-image-optimizations.sh

**Purpose**: Compare image sizes before and after optimizations

**Usage**:
```bash
./scripts/compare-image-optimizations.sh
```

**Time**: ~30 seconds

**Output**: Side-by-side comparison of optimized vs non-optimized image sizes

## ✅ Validation Scripts

### status-check.sh

**Purpose**: Quick health check - "Did it work?"

**Usage**:
```bash
./scripts/status-check.sh
```

**Time**: ~10 seconds

**Checks**:
- Docker images published to GHCR
- GitHub Actions workflow status
- PlatformIO version in images
- Overall system health

**Output**: Color-coded status with ✓ or ✗ for each check

**Exit Codes**:
- 0 - All checks passed
- 1 - Some checks failed

### verify-images.sh

**Purpose**: Comprehensive image verification with GitHub Actions integration

**Usage**:
```bash
./scripts/verify-images.sh
```

**Time**: ~2 seconds

**Validates**:
- Docker images exist in registry
- Images are pullable
- PlatformIO version correctness
- GitHub Actions workflow status
- Latest build status

**Output**: Detailed status report with "ALL SYSTEMS GO!" or warnings

### test-esp-builds.sh

**Purpose**: Test ESP platform builds with Docker images

**Usage**:
```bash
# Test with default images (builder:latest and dev:latest)
./scripts/test-esp-builds.sh

# Test with specific image
./scripts/test-esp-builds.sh ghcr.io/Alteriom/alteriom-docker-images/builder:latest

# Show help
./scripts/test-esp-builds.sh --help
```

**Time**: ~2.5 minutes (first run may take longer)

**Tests**:
- ESP32 (esp32dev)
- ESP32-S3 (esp32-s3-devkitc-1)
- ESP32-C3 (esp32-c3-devkitm-1)
- ESP8266 (nodemcuv2)

**Requirements**:
- Docker installed
- Network access (for platform downloads)
- Test projects in `tests/` directory

**Exit Codes**:
- 0 - All tests passed
- 1 - One or more tests failed

### validate-workflows.sh

**Purpose**: Validate only ONE workflow exists (cost control)

**Usage**:
```bash
./scripts/validate-workflows.sh
```

**Time**: ~5 seconds

**Critical Check**: Ensures no duplicate workflows that would cause cost overruns

**Output**: "VALIDATION PASSED" or error if multiple workflows found

**Exit Codes**:
- 0 - Validation passed (one workflow)
- 1 - Validation failed (multiple workflows or issues)

### verify-admin-setup.sh

**Purpose**: Verify administrator setup and configuration

**Usage**:
```bash
./scripts/verify-admin-setup.sh
```

**Time**: ~10 seconds

**Validates**:
- Required environment variables
- GitHub credentials
- Docker configuration
- Repository access

## 🔒 Security Scripts

### comprehensive-security-scanner.sh

**Purpose**: Complete security scanning suite

**Usage**:
```bash
# Run comprehensive scan
./scripts/comprehensive-security-scanner.sh

# Advanced mode
ADVANCED_MODE=true ./scripts/comprehensive-security-scanner.sh
```

**Time**: 5-10 minutes

**Scans**:
- Filesystem vulnerabilities (Trivy)
- Container image security
- Dockerfile security (Hadolint)
- Python dependency vulnerabilities (Safety)
- Configuration security
- Malware detection (ClamAV, YARA)

**Output**: Security reports in multiple formats (JSON, SARIF, HTML)

**Requirements**:
- Trivy, Hadolint, ClamAV installed
- Network access for vulnerability databases

### enhanced-security-monitoring.sh

**Purpose**: Enhanced security monitoring with alerting

**Usage**:
```bash
./scripts/enhanced-security-monitoring.sh
```

**Time**: 3-5 minutes

**Features**:
- Continuous security monitoring
- Alert generation
- Trend analysis
- Integration with GitHub Security

### malware-scanner.sh

**Purpose**: Malware and threat detection

**Usage**:
```bash
./scripts/malware-scanner.sh [directory]
```

**Time**: 2-5 minutes depending on size

**Detects**:
- Known malware signatures
- Suspicious patterns
- Security threats

### security-remediation.sh

**Purpose**: Automated security remediation

**Usage**:
```bash
./scripts/security-remediation.sh
```

**Time**: Variable

**Actions**:
- Applies security patches
- Updates vulnerable dependencies
- Fixes security issues

### unified-security-reporter.sh

**Purpose**: Unified security reporting across all scans

**Usage**:
```bash
./scripts/unified-security-reporter.sh
```

**Time**: 1-2 minutes

**Output**: Consolidated security report with recommendations

### vulnerability-correlation-engine.sh

**Purpose**: Correlate vulnerabilities across different scans

**Usage**:
```bash
./scripts/vulnerability-correlation-engine.sh
```

**Time**: 30 seconds

**Features**:
- Cross-reference vulnerabilities
- Identify patterns
- Prioritize fixes

### sarif-aggregator.sh

**Purpose**: Aggregate SARIF security reports

**Usage**:
```bash
./scripts/sarif-aggregator.sh
```

**Time**: 10 seconds

**Output**: Combined SARIF report for GitHub Security integration

## 🧪 Testing Scripts

### test-build-enhancements.sh

**Purpose**: Test build system enhancements

**Usage**:
```bash
./scripts/test-build-enhancements.sh
```

**Time**: 5-10 minutes

**Tests**: Build optimization features and enhancements

### test-daily-build-logic.sh

**Purpose**: Test daily build workflow logic

**Usage**:
```bash
./scripts/test-daily-build-logic.sh
```

**Time**: 2-3 minutes

**Validates**: Daily build decision logic and conditions

### test-version-automation.sh

**Purpose**: Test automated versioning system

**Usage**:
```bash
./scripts/test-version-automation.sh
```

**Time**: 1-2 minutes

**Tests**: Version bumping and tagging logic

## 📊 Monitoring & Analytics Scripts

### service-monitoring.sh

**Purpose**: Complete service monitoring suite

**Usage**:
```bash
./scripts/service-monitoring.sh
```

**Time**: 1-2 minutes

**Monitors**:
- Image availability
- Build status
- Registry health
- API endpoints

### service-monitoring-simple.sh

**Purpose**: Simplified service monitoring

**Usage**:
```bash
./scripts/service-monitoring-simple.sh
```

**Time**: 30 seconds

**Monitors**: Basic service health checks

### cost-analysis.sh

**Purpose**: Analyze CI/CD costs and usage

**Usage**:
```bash
./scripts/cost-analysis.sh
```

**Time**: 10-15 seconds

**Reports**:
- Build costs
- Storage costs
- Optimization recommendations

## 🛠️ Utility Scripts

### audit-packages.sh

**Purpose**: Audit package dependencies for security issues

**Usage**:
```bash
./scripts/audit-packages.sh
```

**Time**: 30-60 seconds

**Checks**: Python package vulnerabilities and updates

### check-deprecated-commands.sh

**Purpose**: Check for deprecated Docker/PlatformIO commands

**Usage**:
```bash
./scripts/check-deprecated-commands.sh
```

**Time**: 5 seconds

**Output**: List of deprecated commands found

### generate-enhanced-release-notes.sh

**Purpose**: Generate comprehensive release notes

**Usage**:
```bash
./scripts/generate-enhanced-release-notes.sh [version]
```

**Time**: 10-20 seconds

**Output**: Formatted release notes with changes, contributors, and statistics

## 🎭 Demo Scripts

### comprehensive-security-demo.sh

**Purpose**: Demonstrate comprehensive security scanning

**Usage**:
```bash
./scripts/comprehensive-security-demo.sh
```

**Time**: 5-8 minutes

**Demonstrates**: Full security scanning capabilities

### security-demo.sh

**Purpose**: Basic security demonstration

**Usage**:
```bash
./scripts/security-demo.sh
```

**Time**: 2-3 minutes

**Shows**: Core security features

### security-scanner-demo.sh

**Purpose**: Security scanner demonstration

**Usage**:
```bash
./scripts/security-scanner-demo.sh
```

**Time**: 3-5 minutes

**Demonstrates**: Scanner capabilities and outputs

## 📋 Common Workflows

### Before Committing Changes

```bash
# 1. Validate workflows
./scripts/validate-workflows.sh

# 2. Run tests
./scripts/test-esp-builds.sh

# 3. Check status
./scripts/status-check.sh
```

### After Building Images

```bash
# 1. Verify images
./scripts/verify-images.sh

# 2. Test ESP builds
./scripts/test-esp-builds.sh

# 3. Run security scan
./scripts/comprehensive-security-scanner.sh
```

### Regular Maintenance

```bash
# Weekly: Security audit
./scripts/audit-packages.sh
./scripts/comprehensive-security-scanner.sh

# Monthly: Full validation
./scripts/verify-images.sh
./scripts/test-esp-builds.sh
./scripts/cost-analysis.sh
```

### Troubleshooting Build Issues

```bash
# 1. Check overall status
./scripts/status-check.sh

# 2. Verify images
./scripts/verify-images.sh

# 3. Test specific platform
./scripts/test-esp-builds.sh

# 4. Check for deprecated commands
./scripts/check-deprecated-commands.sh
```

## 🚨 Troubleshooting

### Common Issues

**Issue**: Script permissions denied
```bash
# Solution: Make scripts executable
chmod +x scripts/*.sh
```

**Issue**: Docker not running
```bash
# Solution: Start Docker
sudo systemctl start docker  # Linux
# or use Docker Desktop on Mac/Windows
```

**Issue**: DOCKER_REPOSITORY not set
```bash
# Solution: Export variable
export DOCKER_REPOSITORY=ghcr.io/your_user/alteriom-docker-images
```

**Issue**: Build timeout
```bash
# Solution: Increase timeout (builds take 15-45 minutes)
# Never cancel Docker builds!
```

**Issue**: Network blocked
```bash
# Solution: Check firewall settings
# See docs/guides/FIREWALL_CONFIGURATION.md
```

### Getting Help

1. Check script help: `./scripts/script-name.sh --help` (if available)
2. Review script source code (most have inline documentation)
3. Check related documentation in `docs/`
4. Review GitHub Actions logs for CI/CD issues
5. Create an issue with details and error messages

## 📚 Additional Resources

- [Admin Setup Guide](../admin/ADMIN_SETUP.md) - Administrator configuration
- [Firewall Configuration](../guides/FIREWALL_CONFIGURATION.md) - Network requirements
- [Security Guide](../security/SECURITY.md) - Security policies
- [Optimization Guide](../guides/OPTIMIZATION_GUIDE.md) - Performance tips

## 🔧 Script Development

### Adding New Scripts

When creating new scripts, include:
1. Shebang: `#!/usr/bin/env bash` or `#!/bin/bash`
2. Description comment block at top
3. Usage examples in comments
4. Error handling with `set -euo pipefail`
5. Exit code documentation
6. Make executable: `chmod +x scripts/new-script.sh`

### Script Template

```bash
#!/usr/bin/env bash
#
# Script: new-script.sh
# Purpose: Brief description of what the script does
#
# Usage:
#   ./scripts/new-script.sh [OPTIONS] [ARGUMENTS]
#
# Options:
#   -h, --help    Show help message
#
# Examples:
#   ./scripts/new-script.sh
#
# Exit Codes:
#   0 - Success
#   1 - Error
#

set -euo pipefail

# Script implementation here
```

---

**Last Updated**: October 2024  
**Total Scripts**: 26  
**Maintained By**: Alteriom Team

*This guide covers all scripts in the repository. For specific script details, refer to inline documentation in each script.*
