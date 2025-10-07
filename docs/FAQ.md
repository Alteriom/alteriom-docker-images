# Frequently Asked Questions (FAQ)

## General Questions

### Q: What are these Docker images for?

**A:** These are pre-built PlatformIO development environments for building ESP32/ESP8266 firmware. Instead of installing PlatformIO and all its dependencies on your computer, you can use these Docker images to build firmware in an isolated, reproducible environment.

### Q: Do I need to know Docker to use these images?

**A:** Basic Docker knowledge helps, but you only need to know a few commands:
- `docker pull` - to download the image
- `docker run` - to build your firmware

See our [User Installation Guide](guides/USER_INSTALLATION_GUIDE.md) for step-by-step instructions.

### Q: Are these images free to use?

**A:** Yes! The images are open source and publicly available at no cost. You can use them for personal or commercial projects.

## Installation Questions

### Q: How do I get the images on my PC?

**A:** Follow these steps:

1. Install Docker Desktop on your computer ([download here](https://www.docker.com/products/docker-desktop/))
2. Pull the image:
   ```bash
   docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest
   ```
3. Use it to build your firmware:
   ```bash
   docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev
   ```

See the [User Installation Guide](guides/USER_INSTALLATION_GUIDE.md) for complete details.

### Q: Do the images work on Windows, Mac, and Linux?

**A:** Yes! Docker images are cross-platform. The images support both amd64 (Intel/AMD) and arm64 (Apple Silicon) architectures.

### Q: How much disk space do I need?

**A:** 
- Docker Desktop: ~1-2 GB
- Production builder image: ~400-500 MB
- Development image: ~600-800 MB
- ESP platform toolchains (downloaded on first use): ~200-500 MB

Total: Plan for about 3-4 GB of free disk space.

## Image Availability Questions

### Q: Are the images public or do I need authentication?

**A:** The images are **publicly available** once published. No GitHub account or authentication required to pull and use them.

### Q: I get "manifest unknown" error when pulling. What's wrong?

**A:** This means the images haven't been published yet. This can happen if:

1. **First-time setup needed**: An administrator needs to trigger the initial build and make packages public
2. **Build in progress**: Check https://github.com/Alteriom/alteriom-docker-images/actions for build status
3. **Package not public**: Package visibility needs to be set to "Public" in GitHub settings

**Solution for administrators:**
- Follow the [Publishing Requirements](guides/USER_INSTALLATION_GUIDE.md#-for-administrators-publishing-requirements) section

### Q: How do I know if the images are available?

**A:** Check the package registry:
- Production builder: https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fbuilder
- Development image: https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fdev

If the page shows packages with version tags, they're available. If it says "Package not found", they need to be published.

### Q: How do I publish the images? (Administrators)

**A:** Follow these steps:

1. **Trigger build:**
   - Go to: https://github.com/Alteriom/alteriom-docker-images/actions
   - Click "Build and Publish Docker Images"
   - Click "Run workflow" → select `main` → "Run workflow"
   - Wait ~15-30 minutes

2. **Make public:**
   - Visit the package pages (links above)
   - Click "Package settings" → "Change visibility" → "Public"
   - Confirm the change

3. **Verify:**
   ```bash
   docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest
   ```

See complete documentation: [User Installation Guide - Admin Section](guides/USER_INSTALLATION_GUIDE.md#-for-administrators-publishing-requirements)

## Usage Questions

### Q: Which image should I use?

**A:** 
- **Production builder** (`builder:latest`) - Recommended for most users. Minimal size, all essential tools.
- **Development image** (`dev:latest`) - Includes extra debugging tools (git, vim, htop, etc). Useful for troubleshooting.

For firmware builds, use the production builder.

### Q: How do I build for ESP32-C3?

**A:** Use the appropriate environment name from your `platformio.ini`:

```bash
docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32-c3-devkitm-1
```

Replace `esp32-c3-devkitm-1` with your specific environment name.

### Q: Can I upload firmware to my device using Docker?

**A:** 
- **Linux/Mac**: Yes, with USB device passthrough
  ```bash
  docker run --rm -v ${PWD}:/workspace --device=/dev/ttyUSB0 \
    ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev -t upload
  ```
- **Windows**: USB passthrough is complex in Docker Desktop. Recommended approach:
  1. Use Docker to build the firmware
  2. Use esptool or PlatformIO installed locally to upload

### Q: Why is my first build so slow?

**A:** The first time you build for a platform (ESP32, ESP8266, etc.), PlatformIO downloads the platform toolchains (~100-500 MB). This is a one-time download per platform. Subsequent builds are much faster.

You can pre-download platforms:
```bash
docker run --rm ghcr.io/alteriom/alteriom-docker-images/builder:latest pio platform install espressif32
docker run --rm ghcr.io/alteriom/alteriom-docker-images/builder:latest pio platform install espressif8266
```

### Q: Can I use these images in CI/CD pipelines?

**A:** Absolutely! That's one of their primary use cases. Example GitHub Actions workflow:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build firmware
        run: |
          docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest
          docker run --rm -v ${PWD}:/workspace \
            ghcr.io/alteriom/alteriom-docker-images/builder:latest \
            pio run -e esp32dev
```

## Troubleshooting Questions

### Q: I get "permission denied" errors on Linux

**A:** Add your user to the docker group:

```bash
sudo usermod -aG docker $USER
```

Then log out and back in.

### Q: Docker says "drive not shared" on Windows

**A:** 
1. Open Docker Desktop
2. Go to Settings → Resources → File Sharing
3. Add your project drive (e.g., C:)
4. Click "Apply & Restart"

### Q: Builds fail with SSL certificate errors

**A:** Your corporate firewall may be blocking required domains. See the [Firewall Configuration Guide](guides/FIREWALL_CONFIGURATION.md) for a complete list of required domains to allowlist:

- `ghcr.io`
- `pypi.org`
- `dl.espressif.com`
- `github.com`

### Q: How do I get an interactive shell in the container?

**A:** Use the development image with `-it` flags:

```bash
docker run -it --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/dev:latest bash
```

Inside, you can run commands directly:
```bash
pio run -e esp32dev
pio test
ls -la
```

Type `exit` to leave the container.

### Q: Can I customize the images?

**A:** Yes! The Dockerfiles are available in the repository:
- `production/Dockerfile` - Production builder
- `development/Dockerfile` - Development image

You can:
1. Fork the repository
2. Modify the Dockerfiles
3. Build your own images locally or in your own CI/CD

## Technical Questions

### Q: What PlatformIO version is included?

**A:** Version 6.1.13 (pinned for stability). This version is well-tested and reliable for ESP32/ESP8266 development.

### Q: What ESP platforms are supported?

**A:** All Espressif platforms:
- ESP32 (espressif32)
- ESP32-S2
- ESP32-S3
- ESP32-C3
- ESP32-C6
- ESP8266 (espressif8266)

Platforms are installed at runtime when you first build for them.

### Q: What's the base image?

**A:** Python 3.11-slim (Debian-based). This provides a minimal, secure foundation with Python for PlatformIO.

### Q: Are the images multi-platform?

**A:** Yes! The images support:
- `linux/amd64` - Intel/AMD processors
- `linux/arm64` - ARM processors (Apple Silicon, Raspberry Pi, etc.)

Docker automatically pulls the correct architecture for your system.

### Q: How often are the images updated?

**A:** 
- **Development image**: Daily at 02:00 UTC
- **Production image**: When PRs are merged to main
- **Manual**: Can be triggered anytime via GitHub Actions

### Q: Do the images include any security scanning?

**A:** Yes! Each build includes:
- Trivy vulnerability scanning
- Hadolint Dockerfile linting
- Python dependency security checks
- SARIF report generation for GitHub Security tab

## Getting More Help

### Q: Where can I find more documentation?

**A:** 
- [User Installation Guide](guides/USER_INSTALLATION_GUIDE.md) - Complete installation and usage
- [Main README](../README.md) - Project overview
- [Firewall Configuration](guides/FIREWALL_CONFIGURATION.md) - Network requirements
- [Optimization Guide](guides/OPTIMIZATION_GUIDE.md) - Performance tips
- [Documentation Index](index.md) - All documentation

### Q: How do I report a bug or request a feature?

**A:** 
1. Check [existing issues](https://github.com/Alteriom/alteriom-docker-images/issues)
2. Create a new issue with:
   - Your operating system
   - Docker version (`docker --version`)
   - Error message
   - Steps to reproduce

### Q: Can I contribute to the project?

**A:** Yes! Contributions are welcome:
1. Read [CONTRIBUTING.md](../CONTRIBUTING.md)
2. Fork the repository
3. Create a feature branch
4. Submit a pull request

---

**Still have questions?** Open an issue: https://github.com/Alteriom/alteriom-docker-images/issues/new

*Last updated: 2025-10-07*
