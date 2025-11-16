# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- **CRITICAL: SCons UnboundLocalError with Python 3.11** (Issue #[number])
  - Upgraded PlatformIO from 6.1.13 to 6.1.16
  - Resolves: `UnboundLocalError: cannot access local variable 'node' where it is not associated with a value`
  - Root cause: SCons 4.5.2 (bundled with PlatformIO 6.1.13) has variable scoping bug with Python 3.11
  - Solution: PlatformIO 6.1.16 includes SCons 4.8.1 with Python 3.11/3.13 compatibility fixes
  - Affects: ESP32/ESP8266 firmware compilation, specifically Arduino framework builds
  - Impact: Builds that previously failed at `esp32-hal-tinyusb.c.o` now complete successfully

### Added
- **Persistent volume support** with automatic permission fixing for PlatformIO cache
- `docker-entrypoint.sh` script that handles volume ownership and toolchain permissions
- `gosu` package for secure privilege dropping from root to builder user
- Comprehensive persistent volumes documentation guide
- Test script for validating persistent volume behavior (`scripts/test-persistent-volumes.sh`)
- **Regression test for SCons auto-clean functionality** (`scripts/test-auto-clean.sh`)
  - Validates that builds complete successfully with auto-clean enabled (default behavior)
  - Tests build → clean → rebuild cycle to prevent regression of UnboundLocalError
  - Eliminates need for `--disable-auto-clean` workaround
- Example docker-compose.yml for persistent volume usage
- CHANGELOG.md file for tracking project changes
- docs/ folder structure for better documentation organization
- CONTRIBUTING.md file with guidelines for Docker images project
- CODE_OF_CONDUCT.md file following Contributor Covenant

### Changed
- Container now starts as root and drops to builder user after fixing permissions
- Builder user shell changed from `/bin/false` to `/bin/bash` for better interactive use
- Healthcheck updated to use `gosu` for proper user context
- Enhanced compliance with Alteriom organization standards
- **PlatformIO upgraded from 6.1.13 to 6.1.16** for improved stability and Python 3.11 support

### Fixed (Previous)
- **Permission denied errors** when using persistent volumes for PlatformIO cache
- **Toolchain binary permission issues** (`xtensa-esp32-elf-g++: Permission denied`)
- **SCons build state corruption** when using mounted volumes
- Build times reduced from ~5 minutes to ~30 seconds for incremental builds with persistent volumes

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