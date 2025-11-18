# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

_No unreleased changes yet._

## [1.8.11] - 2025-11-18

### ⚠️ BREAKING CHANGES

- **Containers now run as non-root user by default** (Security: Trivy DS002 compliance, PR #26)
  - Added `USER builder` directive to both Dockerfiles
  - Previous: images started as root (UID 0)
  - New: images start as `builder` (UID 1000); least-privilege by default
  - Impact: Workflows that rely on implicit root must add `--user root` (only needed when fixing permissions for persistent volumes)
  - Migration: See dedicated section "Migration from Root to Non-Root Default" below
  - Rationale: Eliminates HIGH severity DS002 finding; aligns with Docker security best practices

### Added

- Persistent volume support with automatic first-run permission fixing
- Intelligent `docker-entrypoint.sh` handling dual-mode (default non-root, optional root for permission repair)
- `gosu` for secure privilege dropping after root-based initialization
- Comprehensive persistent volumes guide & example `docker-compose-persistent.yml`
- Regression test script for SCons auto-clean (`scripts/test-auto-clean.sh`)
- Validation script for persistent volumes (`scripts/test-persistent-volumes.sh`)
- Documentation restructuring and governance artifacts (CONTRIBUTING.md, CODE_OF_CONDUCT.md)


### Changed

- Default execution user: root → builder (UID 1000)
- Healthchecks run directly as non-root (removed redundant gosu usage)
- Builder shell set to `/bin/bash` for improved interactive troubleshooting
- PlatformIO upgraded: 6.1.13 → 6.1.16 (includes SCons 4.8.1 for Python 3.11/3.13 compatibility)
- Examples and guides updated to show `--user root` only when persistent volumes are mounted


### Fixed

- SCons `UnboundLocalError` with Python 3.11 during ESP builds (resolved via PlatformIO upgrade)
- Permission denied/toolchain execution issues when using cached PlatformIO directories
- Volume ownership inconsistencies causing slow or repeated dependency downloads
- Incremental build performance: first build (~5 min) → subsequent (~30 sec) with persistent volume caching


### Security

- Trivy DS002 (missing USER directive) remediated
- Principle of least privilege enforced by default start as non-root
- Privilege dropping audited & consistent via `gosu`


### Performance

- Caching improvements drastically reduce incremental build time for ESP targets
- No image size regression (USER directive and entrypoint logic have negligible impact)


### Documentation

- Expanded persistent volume usage and troubleshooting
- Clear migration instructions for root → non-root change
- Updated examples (Docker CLI, Docker Compose, CI workflow snippets) to reflect new security model


### Notes

- Use `--user root` ONLY when mounting persistent volumes requiring first-run ownership fixes; runtime still executes as builder after drop
- Standard ephemeral builds (no cache volume) require no changes



## [1.8.3] - 2025-08-27

### Added

- Comprehensive security scanning and monitoring infrastructure
- Enhanced release notes generation system
- Automated versioning with semantic commit message support
- Cost reduction optimizations with intelligent build detection
- Security practices implementation guide for reusable workflows

### Fixed

- Docker tag generation issues
- Workflow syntax errors and duplicate build prevention
- Build optimization to reduce unnecessary CI/CD runs

## [1.8.0] - 2025-08-26

### Added

- Multi-layer security architecture with 20+ enterprise security tools
- Advanced vulnerability correlation engine
- Comprehensive security demo and validation scripts
- SARIF integration with GitHub Security tab
- Automated security scanning in CI/CD pipeline

### Enhanced

- Container security with Trivy and Hadolint integration
- Parallel security scanning without build time impact
- Documentation with security best practices guide

## [1.7.0] - 2025-08-25

### Added

- ESP32-C3 platform support and testing
- Enhanced ESP platform build testing with CI/CD integration
- Comprehensive Copilot instructions for AI-assisted development
- Enhanced release notes generation system

### Improved

- Testing infrastructure with automated ESP platform validation
- Documentation with 736+ lines of improvements
- Development workflow optimization

## [1.6.0] - 2025-08-24

### Added

- Automated versioning system with semantic commit analysis
- Development badge system with incremental build numbers
- Enhanced version tracking and release automation

### Changed

- Automated VERSION file management
- GitHub release creation with generated notes
- Docker image building and publishing automation

## [1.5.1] - 2025-08-23

### Added

- ESP32-C3 support to test suite and documentation
- Automated version bumping implementation

### Fixed

- VERSION file format issues
- Build automation reliability

## [1.5.0] - 2025-08-22

### Added

- Comprehensive ESP platform build testing
- CI/CD integration for automated testing
- Enhanced documentation and testing infrastructure

### Improved

- Docker image optimization and layer caching
- Build performance and reliability

## [1.4.0] - 2025-08-21

### Added

- Production and development Docker images for PlatformIO
- Multi-platform support (linux/amd64, linux/arm64)
- ESP32, ESP32-S3, ESP32-C3, and ESP8266 platform support
- Comprehensive build and verification scripts

### Features

- Optimized Docker images based on python:3.11-slim
- Non-root user execution (UID 1000)
- PlatformIO 6.1.13 (pinned for stability)
- GitHub Container Registry integration
- Automated CI/CD with GitHub Actions

### Documentation

- README with comprehensive usage instructions
- ADMIN_SETUP.md for deployment configuration
- OPTIMIZATION_GUIDE.md for image size optimization
- FIREWALL_CONFIGURATION.md for network requirements
- SECURITY.md for security policies and procedures

## [1.0.0] - 2025-08-20

### Added

- Initial project setup
- Basic Docker image structure
- PlatformIO integration
- ESP platform support foundation
- Core build scripts and documentation

### Security

- Initial security policies
- Container security best practices
- Vulnerability scanning integration

---

## Migration from Root to Non-Root Default

### Overview

Starting with version 1.8.10+, Docker images run as non-root user (`builder`, UID 1000) by default. This is a **breaking change** that improves security.

### Who Is Affected?

You are affected if you:
- Use persistent volumes for PlatformIO cache (`-v platformio_cache:/home/builder/.platformio`)
- Rely on root access within containers
- Have scripts or automation that assume root user

### Migration Steps

#### Scenario 1: Basic Builds (No Persistent Volumes)

**No changes needed!** Your existing commands will continue to work:

```bash
# This still works - runs as builder user by default
docker run --rm -v ${PWD}:/workspace \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest run -e esp32dev
```

#### Scenario 2: Builds with Persistent Volumes

**Action required:** Add `--user root` flag to your docker run commands:

```bash
# OLD (before v1.8.10):
docker run --rm \
  -v ${PWD}:/workspace \
  -v platformio_cache:/home/builder/.platformio \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest run -e esp32dev

# NEW (v1.8.10+): Add --user root flag
docker run --rm --user root \
  -v ${PWD}:/workspace \
  -v platformio_cache:/home/builder/.platformio \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest run -e esp32dev
```

**Why `--user root` is needed:**
- Persistent volumes need permission fixes on first use
- Entrypoint script runs as root to fix ownership
- Then automatically drops to builder user before running PlatformIO
- This maintains security while handling permissions correctly

#### Scenario 3: Docker Compose

Update your `docker-compose.yml` to add `user: root`:

```yaml
# OLD (before v1.8.10):
services:
  alteriom-builder:
    image: ghcr.io/alteriom/alteriom-docker-images/builder:latest
    volumes:
      - .:/workspace
      - platformio_cache:/home/builder/.platformio

# NEW (v1.8.10+): Add user: root
services:
  alteriom-builder:
    image: ghcr.io/alteriom/alteriom-docker-images/builder:latest
    user: root  # Required for persistent volumes
    volumes:
      - .:/workspace
      - platformio_cache:/home/builder/.platformio
```

#### Scenario 4: CI/CD Pipelines

Update your workflow files:

```yaml
# OLD:
- name: Build firmware
  run: |
    docker run --rm -v ${{ github.workspace }}:/workspace \
      -v pio_cache:/home/builder/.platformio \
      ghcr.io/alteriom/alteriom-docker-images/builder:latest run -e esp32dev

# NEW: Add --user root
- name: Build firmware
  run: |
    docker run --rm --user root -v ${{ github.workspace }}:/workspace \
      -v pio_cache:/home/builder/.platformio \
      ghcr.io/alteriom/alteriom-docker-images/builder:latest run -e esp32dev
```

### Benefits of This Change

1. **Improved Security**: Running as non-root by default prevents privilege escalation
2. **Docker Best Practice**: Follows industry-standard security guidelines
3. **Flexibility**: Can still use root when needed (with `--user root`)
4. **Automatic Privilege Dropping**: Entrypoint automatically drops to builder after permission fixes

### Need Help?

- See [Persistent Volumes Guide](docs/guides/PERSISTENT_VOLUMES.md) for detailed information
- Check [FAQ](docs/FAQ.md) for common questions
- Open an issue if you encounter problems: https://github.com/Alteriom/alteriom-docker-images/issues