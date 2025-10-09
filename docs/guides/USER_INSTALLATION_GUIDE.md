# User Installation Guide

## 🎯 Overview

This guide helps you install and use the Alteriom Docker images on your PC for building ESP32/ESP8266 firmware. No complicated setup required - just Docker and a few commands!

## 📋 Prerequisites

### Step 1: Install Docker

You need Docker Desktop installed on your computer. Choose your operating system:

#### Windows
1. Download [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
2. Run the installer
3. Follow the installation wizard
4. Restart your computer when prompted
5. Launch Docker Desktop and wait for it to start

**System Requirements:**
- Windows 10 64-bit: Pro, Enterprise, or Education (Build 19041 or higher)
- WSL 2 feature enabled
- 4GB RAM minimum

#### macOS
1. Download [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)
2. Double-click the `.dmg` file
3. Drag Docker to Applications folder
4. Launch Docker from Applications
5. Accept the service agreement

**System Requirements:**
- macOS 11 or newer
- 4GB RAM minimum

#### Linux
Install Docker Engine for your distribution:

**Ubuntu/Debian:**
```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
```

**Fedora/RHEL:**
```bash
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### Step 2: Verify Docker Installation

Open a terminal/command prompt and run:

```bash
docker --version
```

You should see output like: `Docker version 24.0.0, build...`

Test that Docker is working:

```bash
docker run hello-world
```

If you see a "Hello from Docker!" message, you're ready to proceed!

## 🚀 Using the Images

### Image Availability

The Alteriom Docker images are published to GitHub Container Registry (GHCR) and are **publicly available** - no authentication required!

Available images:
- **Production Builder** (recommended): `ghcr.io/alteriom/alteriom-docker-images/builder:latest`
- **Development Builder** (with debug tools): `ghcr.io/alteriom/alteriom-docker-images/dev:latest`

### Quick Start: Build Your Firmware

#### Step 1: Pull the Image

Open a terminal/command prompt and pull the production builder image:

```bash
docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest
```

This downloads the image to your computer (~400-500 MB). You only need to do this once (or when updates are available).

#### Step 2: Build Your Firmware

Navigate to your PlatformIO project directory:

```bash
cd /path/to/your/platformio/project
```

**On Windows (PowerShell):**
```powershell
docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev
```

**On Windows (Command Prompt):**
```cmd
docker run --rm -v %cd%:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev
```

**On macOS/Linux:**
```bash
docker run --rm -v $(pwd):/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev
```

Replace `esp32dev` with your target environment name from `platformio.ini`.

#### Step 3: Find Your Built Firmware

Your compiled firmware will be in the `.pio/build/<environment>/` directory of your project.

## 📚 Common Use Cases

### Building for Different ESP Platforms

**ESP32:**
```bash
docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev
```

**ESP32-C3:**
```bash
docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32-c3-devkitm-1
```

**ESP32-S3:**
```bash
docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32-s3-devkitc-1
```

**ESP8266:**
```bash
docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e nodemcuv2
```

### Clean Build

Remove previous build artifacts and rebuild:

```bash
docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev -t clean
docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev
```

### Upload Firmware to Device

To upload firmware, you need to pass through the USB device. This varies by platform:

**Linux:**
```bash
docker run --rm -v ${PWD}:/workspace --device=/dev/ttyUSB0 \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev -t upload
```

**macOS:**
```bash
docker run --rm -v ${PWD}:/workspace --device=/dev/cu.usbserial-* \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev -t upload
```

**Windows:**
Windows requires special handling for USB devices in Docker. Consider using the image for building only, then upload using PlatformIO CLI installed locally.

### Interactive Development Session

Use the development image for an interactive shell:

```bash
docker run -it --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/dev:latest bash
```

Inside the container, you can run PlatformIO commands directly:
```bash
pio run -e esp32dev
pio test
pio device list
```

Exit the container by typing `exit`.

## 🔧 Troubleshooting

### Access Denied When Pulling Image

**Error:** `Error response from daemon: Head "https://ghcr.io/v2/alteriom/alteriom-docker-images/builder/manifests/latest": denied: denied`

**What this means:** The Docker image package exists but is **not publicly accessible**. This is different from "manifest unknown" - the images have been built but the package visibility is set to "Private" instead of "Public".

**Solution (for administrators):**

1. **Change package visibility to Public:**
   - Visit the builder package: https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fbuilder
   - Click "Package settings" on the right side
   - Scroll down to "Danger Zone"
   - Click "Change visibility"
   - Select "Public"
   - Type the package name to confirm: `alteriom-docker-images/builder`
   - Click "I understand, change package visibility"

2. **Repeat for development image:**
   - Visit: https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fdev
   - Follow the same steps to change visibility to "Public"

3. **Verify public access:**
   ```bash
   docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest
   ```
   This should now work without requiring authentication.

**For users:** If you encounter this error, contact your repository administrator to make the packages public. See the [Publishing Requirements](#-for-administrators-publishing-requirements) section below for complete details.

### Image Not Found

**Error:** `Error response from daemon: manifest unknown`

**What this means:** The Docker images haven't been published yet, or the build is still in progress.

**Solutions:**

1. **Check if images are published:**
   - Visit: https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fbuilder
   - If you see "Package not found", the images haven't been built yet

2. **Trigger a build (for administrators):**
   - Go to: https://github.com/Alteriom/alteriom-docker-images/actions
   - Click "Build and Publish Docker Images"
   - Click "Run workflow"
   - Wait 15-30 minutes for completion

3. **Verify image is public:**
   - Images must be set to "Public" visibility in GitHub package settings
   - See [Publishing Requirements](#-for-administrators-publishing-requirements) below

### Permission Denied (Linux)

**Error:** `Permission denied while trying to connect to Docker daemon`

**Solution:** Add your user to the docker group:
```bash
sudo usermod -aG docker $USER
```

Log out and back in for changes to take effect.

### Volume Mount Issues (Windows)

**Error:** Issues mounting current directory

**Solution:** Ensure you're using PowerShell and the drive is shared in Docker Desktop settings:
1. Open Docker Desktop
2. Go to Settings → Resources → File Sharing
3. Add your project drive (e.g., C:)
4. Click "Apply & Restart"

### Platform Not Found

**Error:** `Error: Unknown platform 'espressif32'`

**Solution:** This happens on first run. The ESP platforms are downloaded automatically. Wait for the download to complete (5-15 minutes depending on your connection).

### Slow Builds (First Run)

The first build downloads ESP platform toolchains (~100-500 MB). Subsequent builds are much faster because the platforms are cached in the container.

**Tip:** Pre-download platforms by running:
```bash
docker run --rm ghcr.io/alteriom/alteriom-docker-images/builder:latest pio platform install espressif32
docker run --rm ghcr.io/alteriom/alteriom-docker-images/builder:latest pio platform install espressif8266
```

### Corporate Firewall Issues

If builds fail with SSL or connection errors, your corporate firewall may be blocking required domains.

**Required domains for Docker and PlatformIO:**
- `ghcr.io` - Docker image registry
- `pypi.org` - Python packages
- `dl.espressif.com` - ESP toolchains
- `github.com` - Source code and dependencies

See [Firewall Configuration Guide](FIREWALL_CONFIGURATION.md) for complete details.

## 📦 For Administrators: Publishing Requirements

If you're responsible for publishing the images, here's what you need to know:

### Initial Setup

1. **Ensure GitHub Actions is enabled** for the repository
2. **Trigger the first build:**
   - Navigate to: https://github.com/Alteriom/alteriom-docker-images/actions
   - Select "Build and Publish Docker Images"
   - Click "Run workflow" button
   - Select branch: `main`
   - Click "Run workflow"

3. **Wait for build completion** (~15-30 minutes)
   - Monitor progress in the Actions tab
   - Both `builder` and `dev` images will be created

### Making Images Public

After the first build, make the images publicly accessible:

1. **Navigate to packages:**
   - Builder: https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fbuilder
   - Dev: https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fdev

2. **For each package:**
   - Click "Package settings" (right side)
   - Scroll to "Danger Zone"
   - Click "Change visibility"
   - Select "Public"
   - Type the package name to confirm
   - Click "I understand, change package visibility"

3. **Verify public access:**
   ```bash
   docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest
   ```
   This should work without authentication.

### Automated Builds

The repository is configured for automatic builds:

- **Daily builds** at 02:00 UTC (development image only)
- **Production builds** when PRs are merged to main
- **Manual builds** via workflow dispatch

No additional configuration needed - the `GITHUB_TOKEN` is automatically provided by GitHub Actions.

### Verifying Published Images

Run the verification script:

```bash
./scripts/verify-images.sh
```

Expected output: "ALL SYSTEMS GO!" or similar success message.

## 🆘 Getting Help

If you're stuck:

1. **Check the documentation:**
   - [Main README](../../README.md) - Overview and quick start
   - [Firewall Configuration](FIREWALL_CONFIGURATION.md) - Network requirements
   - [Optimization Guide](OPTIMIZATION_GUIDE.md) - Performance tips

2. **Search existing issues:**
   - https://github.com/Alteriom/alteriom-docker-images/issues

3. **Create a new issue:**
   - Use the issue template
   - Include your operating system
   - Include the error message
   - Include the Docker version

4. **Check build status:**
   - https://github.com/Alteriom/alteriom-docker-images/actions

## 📝 Summary

**For users:**
1. Install Docker on your PC
2. Pull the image: `docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest`
3. Build firmware: `docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e <env>`

**For administrators:**
1. Trigger initial build via GitHub Actions
2. Make packages public in GitHub settings
3. Verify images are accessible

**That's it!** You now have a reproducible build environment without installing PlatformIO locally.

---

*Last updated: 2025-10-07*
