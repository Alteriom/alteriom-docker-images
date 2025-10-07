# alteriom-docker-images

[![Latest Release](https://img.shields.io/github/v/release/Alteriom/alteriom-docker-images?label=Production)](https://github.com/Alteriom/alteriom-docker-images/releases/latest)
[![Development Version](https://img.shields.io/badge/Development-1.8.7%2B%20(build%2018)-orange?logo=docker)](https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fdev)
[![Build Status](https://img.shields.io/github/actions/workflow/status/Alteriom/alteriom-docker-images/build-and-publish.yml?branch=main&label=Build%20Status)](https://github.com/Alteriom/alteriom-docker-images/actions/workflows/build-and-publish.yml)
[![License](https://img.shields.io/github/license/Alteriom/alteriom-docker-images)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/Alteriom/alteriom-docker-images)](https://github.com/Alteriom/alteriom-docker-images/commits/main)

[![Production Image](https://img.shields.io/badge/GHCR-production%20builder-blue?logo=github)](https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fbuilder)
[![Development Image](https://img.shields.io/badge/GHCR-development%20builder-blue?logo=github)](https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fdev)

Pre-built PlatformIO builder images for the Alteriom project (ESP32 / ESP32-C3 / ESP8266).

This repository contains optimized Dockerfiles and helper scripts to build and publish minimal PlatformIO images for ESP32/ESP32-C3/ESP8266 firmware builds. The images are optimized for size while maintaining full functionality.

> **📦 Image Availability Status**
> 
> **For Users:** Images are publicly available at `ghcr.io/alteriom/alteriom-docker-images/builder:latest`
> 
> **For Administrators:** If images are not yet available, see the [Publishing Images](#-for-administrators-publishing-images) section below for initial setup instructions.

## Version Tracking

The repository uses an automated badge system to show current version information:

- **Production Badge**: Shows the latest stable release version from GitHub releases
- **Development Badge**: Shows the current development version with incremental build numbers
  - Format: `1.6.1+ (build N)` where N is an incremental build number starting from 1
  - Updated automatically when development images are built
  - Build numbers increment with each development build
  - Links directly to the GHCR development package

Development images are tagged with both `:latest` and versioned tags (e.g., `:1.6.1-dev-build.N`) to provide flexibility in CI/CD pipelines.

## 🚀 Quick Start for Users

### Install Docker and Pull the Image

1. **Install Docker** on your PC ([Installation guide](docs/guides/USER_INSTALLATION_GUIDE.md#step-1-install-docker))
2. **Pull the production builder image:**

```bash
docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest
```

3. **Build your ESP firmware:**

```bash
# Navigate to your PlatformIO project directory
cd /path/to/your/project

# Build for ESP32
docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev

# Or for ESP8266
docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e nodemcuv2
```

**📖 Complete Installation Guide:** See [docs/guides/USER_INSTALLATION_GUIDE.md](docs/guides/USER_INSTALLATION_GUIDE.md) for detailed instructions, troubleshooting, and platform-specific guidance.

**Note:** Replace `${PWD}` with `%cd%` on Windows Command Prompt, or use `${PWD}` in PowerShell.

## 📦 Contents

- production/Dockerfile  — optimized minimal builder image with PlatformIO (ESP platforms installed at runtime)
- development/Dockerfile — development image with extra tools and debugging utilities  
- scripts/build-images.sh — build and push helper script
- scripts/verify-images.sh — verify published images are available and working
- **docs/guides/USER_INSTALLATION_GUIDE.md** — **complete user installation and usage guide**
- docs/guides/OPTIMIZATION_GUIDE.md — detailed guide on image size optimizations
- docs/guides/FIREWALL_CONFIGURATION.md — network access requirements and firewall allowlist

## 🔧 For Administrators: Publishing Images

### Initial Setup Required

Before users can access the images, you need to:

1. **Trigger the first build** (one-time setup):
   - Go to: https://github.com/Alteriom/alteriom-docker-images/actions
   - Click "Build and Publish Docker Images" workflow
   - Click "Run workflow" → Select `main` branch → Click "Run workflow"
   - Wait 15-30 minutes for build completion

2. **Make packages public** (one-time setup):
   - Visit: https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fbuilder
   - Click "Package settings" → Scroll to "Danger Zone"
   - Click "Change visibility" → Select "Public" → Confirm
   - Repeat for the `dev` package

3. **Verify images are accessible:**
   ```bash
   # Check if images are published and working
   ./scripts/verify-images.sh
   
   # Test ESP platform builds
   ./scripts/test-esp-builds.sh
   ```

### Automated Builds

After setup, builds run automatically:
- **Daily** at 02:00 UTC (development image)
- **On PR merge** to main (both images)
- **Manual** via workflow dispatch

See [docs/guides/USER_INSTALLATION_GUIDE.md](docs/guides/USER_INSTALLATION_GUIDE.md#-for-administrators-publishing-requirements) for complete admin documentation.

## Image Optimizations

The Docker images have been optimized for minimal size while maintaining full PlatformIO functionality:

**Key optimizations:**
- ESP32/ESP32-C3/ESP8266 platforms installed at runtime (smaller base image)
- Build tools removed after PlatformIO installation  
- Unnecessary packages eliminated
- Single-layer package installation for better caching

**Benefits:**
- Significantly smaller images for faster pulls
- Always get latest ESP platform versions
- Better Docker layer caching
- Same functionality and usage

See [docs/guides/OPTIMIZATION_GUIDE.md](docs/guides/OPTIMIZATION_GUIDE.md) for detailed information.

## Testing and Validation

The repository includes comprehensive tests to validate Docker image functionality:

### ESP Platform Build Tests

Automated tests verify that the Docker images can successfully build firmware for all supported ESP platforms:

- **ESP32** (esp32dev environment)
- **ESP32-S3** (esp32-s3-devkitc-1 environment)  
- **ESP32-C3** (esp32-c3-devkitm-1 environment)
- **ESP8266** (nodemcuv2 environment)

**Run tests manually:**

```bash
# Test with default images (builder:latest and dev:latest)
./scripts/test-esp-builds.sh

# Test with specific image
./scripts/test-esp-builds.sh ghcr.io/Alteriom/alteriom-docker-images/builder:latest

# Show help and options
./scripts/test-esp-builds.sh --help
```

**Test validation includes:**
- Docker image availability and accessibility
- PlatformIO functionality within containers
- ESP platform installation and compilation
- Arduino framework compatibility
- Successful firmware generation

The tests are automatically executed in the CI/CD pipeline after images are built, ensuring published images are fully functional.

### Security Testing and Scanning 🔒

The repository includes comprehensive security scanning to ensure safe and secure Docker images:

#### Automated Security Scans

**Multi-layer security scanning:**
- **Filesystem vulnerabilities**: Trivy scans for known CVEs in all files
- **Container image security**: Post-build vulnerability scanning of Docker images  
- **Dockerfile security**: Hadolint checks both production and development Dockerfiles
- **Python dependency scanning**: Safety checks for vulnerabilities in PlatformIO and dependencies
- **Configuration security**: Infrastructure-as-code security analysis
- **Malware detection**: ClamAV and YARA pattern-based malware scanning

**Run security scans manually:**

```bash
# Enhanced security monitoring (comprehensive)
./scripts/enhanced-security-monitoring.sh

# Malware scanning specifically  
./scripts/malware-scanner.sh

# Quick security status check
./scripts/verify-images.sh  # includes basic security validation
```

#### Security Features

**Container security:**
- ✅ Non-root user execution (UID 1000)
- ✅ Minimal base images (python:3.11-slim)
- ✅ No unnecessary packages or tools
- ✅ Read-only filesystem capability
- ✅ Security labels and metadata

**Build security:**
- ✅ Pinned dependency versions (PlatformIO 6.1.13)
- ✅ Build tools removed after compilation
- ✅ Package caches cleaned
- ✅ Multi-platform builds (amd64, arm64)

**Monitoring and compliance:**
- ✅ SARIF integration with GitHub Security
- ✅ 30-day scan result retention
- ✅ Automated vulnerability alerts
- ✅ Security policy enforcement

See [docs/security/SECURITY.md](docs/security/SECURITY.md) for detailed security policy and vulnerability reporting.

See [tests/README.md](tests/README.md) for detailed testing information.

## CI / Automated builds

This repository includes a GitHub Actions workflow (`.github/workflows/build-and-publish.yml`) that automatically builds and publishes Docker images with different strategies based on the trigger type.

**🌅 Daily Builds (Optimized):** 
- **Schedule**: Daily at 02:00 UTC, but **only builds the development image**
- **Development versions**: Tagged with format `1.6.1-dev-build.N` for incremental build tracking
- **Version badge**: Automatically updated to show current development version (e.g., "1.6.1+ (build 2)")
- **Cost optimization**: Reduces CI/CD resource usage by ~50% while maintaining development image freshness
- **Production unchanged**: Stable production images remain unchanged during daily builds

**🚀 Production Builds:**
- **PR merges**: Full builds of both production and development images with version increments
- **Manual dispatch**: Complete builds available via GitHub Actions interface
- **Automated versioning**: Semantic version bumping based on commit message conventions

**🧪 Automated testing:** After successful image builds, the workflow automatically runs ESP platform build tests to validate that the published images are fully functional for ESP32, ESP32-S3, ESP32-C3, and ESP8266 development. 

**🔒 Security scanning:** Comprehensive security scanning runs in parallel with builds, including:
- Vulnerability scanning (Trivy) for filesystem and containers
- Dockerfile security analysis (Hadolint)  
- Python dependency security checks (Safety)
- Configuration and infrastructure security scanning
- Results integrated with GitHub Security tab via SARIF

**Setup required:** The workflow is pre-configured to use GitHub Container Registry (GHCR) and requires no additional secrets setup. The workflow uses the built-in `GITHUB_TOKEN` for authentication.

**Versioning Guide:** See [docs/development/AUTOMATED_VERSIONING.md](docs/development/AUTOMATED_VERSIONING.md) for complete instructions on using the automated version management system.

**Admin Notes:** 
- Repository has been tested and builds are working as of August 2024
- Docker builds use Python 3.11-slim base image (compatible with current package repositories)
- Both production and development images build successfully with multi-platform support

**Optional configuration:** If you want to use a different container registry, set the following repository variables:

- `DOCKER_REPOSITORY` - target repository (e.g. `ghcr.io/<your_user>/alteriom-docker-images`) - optional, defaults to `ghcr.io/<owner>/alteriom-docker-images`

The workflow runs:
- **Daily builds** at 02:00 UTC (development image only - cost optimized)
- **Production builds** when PRs are merged to the main branch (both images)
- **Manual builds** via workflow dispatch in the Actions tab (both images)

Contribution and maintenance

If you'd like me to help maintain the CI and update images regularly, I can:

- Review and refine the Dockerfiles for size and reproducibility
- Add automated smoke tests that run a quick `pio run -e diag-esp32-c3` inside the image
- Keep the daily build workflow and perform periodic reviews when PlatformIO releases major changes

Repository structure

```
alteriom-docker-images/
├── production/
│   └── Dockerfile                   # Optimized minimal builder
├── development/
│   └── Dockerfile                   # Development tools + builder
├── scripts/
│   ├── build-images.sh             # Build and push helper
│   ├── verify-images.sh            # Image verification
│   ├── test-esp-builds.sh          # ESP platform build testing
│   └── compare-image-optimizations.sh  # Size comparison tool
├── tests/
│   ├── README.md                   # Testing documentation
│   ├── esp32-test/                 # ESP32 test project
│   ├── esp32s3-test/               # ESP32-S3 test project
│   ├── esp32c3-test/               # ESP32-C3 test project
│   └── esp8266-test/               # ESP8266 test project
├── docs/                           # All documentation (organized)
│   ├── README.md                   # Documentation index
│   ├── admin/                      # Administrative documentation
│   ├── security/                   # Security-related documentation
│   ├── guides/                     # User guides and tutorials
│   ├── development/                # Development documentation
│   └── migration/                  # Migration and implementation docs
└── README.md
```

License
This repository is licensed under the MIT License. See `LICENSE` for details.
