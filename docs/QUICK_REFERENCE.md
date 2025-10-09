# Quick Reference Card - Alteriom Docker Images

## 📦 One-Time Setup

### 1. Install Docker
- **Windows/Mac**: Download [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **Linux**: `sudo apt-get install docker-ce docker-ce-cli containerd.io`

### 2. Pull Image (one-time, or when updates available)
```bash
docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest
```

## 🚀 Build Commands

### Basic Build
```bash
# Navigate to your project first
cd /path/to/your/platformio/project

# Build for ESP32
docker run --rm -v ${PWD}:/workspace \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest \
  pio run -e esp32dev
```

### Platform-Specific Builds

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
```bash
# Clean previous build
docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -t clean

# Rebuild
docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev
```

### Interactive Session
```bash
# Start interactive shell (dev image)
docker run -it --rm -v ${PWD}:/workspace \
  ghcr.io/alteriom/alteriom-docker-images/dev:latest bash

# Inside container, run commands:
pio run -e esp32dev
pio test
ls -la
exit  # to leave container
```

## 🔧 Platform-Specific Notes

### Windows PowerShell
Use `${PWD}` as shown in examples above.

### Windows Command Prompt
Replace `${PWD}` with `%cd%`:
```cmd
docker run --rm -v %cd%:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev
```

### macOS/Linux
Use `$(pwd)` or `${PWD}`:
```bash
docker run --rm -v $(pwd):/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e esp32dev
```

## 📝 Common Aliases (Optional Time-Savers)

Add to your shell profile (`.bashrc`, `.zshrc`, or PowerShell profile):

### Bash/Zsh (Linux/Mac)
```bash
# Add to ~/.bashrc or ~/.zshrc
alias pio-build='docker run --rm -v $(pwd):/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e'
alias pio-dev='docker run -it --rm -v $(pwd):/workspace ghcr.io/alteriom/alteriom-docker-images/dev:latest bash'

# Usage after reload:
pio-build esp32dev
pio-dev
```

### PowerShell (Windows)
```powershell
# Add to $PROFILE
function pio-build { 
    docker run --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/builder:latest pio run -e $args
}
function pio-dev { 
    docker run -it --rm -v ${PWD}:/workspace ghcr.io/alteriom/alteriom-docker-images/dev:latest bash
}

# Usage:
pio-build esp32dev
pio-dev
```

## ⚠️ Common Issues

### "denied: denied" or "access denied" when pulling
**Error:** `Error response from daemon: denied: denied`  
**Cause:** Images exist but package visibility is not set to "Public"  
**Solution:** Administrator needs to change package visibility to Public in GitHub settings  
**Details:** [User Installation Guide - Publishing](guides/USER_INSTALLATION_GUIDE.md#-for-administrators-publishing-requirements) or [FAQ - Access Denied](FAQ.md#q-i-get-denied-denied-or-access-denied-error-when-pulling-whats-wrong)

### "manifest unknown" or "not found"
**Cause:** Images not published yet  
**Solution:** Administrator needs to trigger build and make packages public  
**Details:** [User Installation Guide - Publishing](guides/USER_INSTALLATION_GUIDE.md#-for-administrators-publishing-requirements)

### "permission denied" (Linux)
**Cause:** User not in docker group  
**Solution:**
```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### Slow first build
**Cause:** Downloading ESP platform toolchains (normal, one-time)  
**Solution:** Wait 5-15 minutes. Subsequent builds are fast.

### SSL certificate errors
**Cause:** Corporate firewall  
**Solution:** Allowlist these domains:
- `ghcr.io`
- `pypi.org`
- `dl.espressif.com`
- `github.com`

## 🔗 More Information

- **Full Installation Guide**: [docs/guides/USER_INSTALLATION_GUIDE.md](guides/USER_INSTALLATION_GUIDE.md)
- **FAQ**: [docs/FAQ.md](FAQ.md)
- **Main README**: [README.md](../README.md)
- **Troubleshooting**: [USER_INSTALLATION_GUIDE.md#troubleshooting](guides/USER_INSTALLATION_GUIDE.md#-troubleshooting)
- **Issues**: https://github.com/Alteriom/alteriom-docker-images/issues

## 🎯 For Administrators Only

### Initial Publishing (One-Time)

1. **Trigger build:**
   - https://github.com/Alteriom/alteriom-docker-images/actions
   - Click "Build and Publish Docker Images" → "Run workflow" → `main` → "Run workflow"

2. **Make public:**
   - https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fbuilder
   - "Package settings" → "Change visibility" → "Public"
   - Repeat for `dev` package

3. **Verify:**
   ```bash
   docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest
   ```

## 💡 Tips

- **First-time users**: Plan 30-45 minutes for Docker installation + image pull + first build
- **Subsequent builds**: ~1-5 minutes depending on project size
- **Updates**: Run `docker pull` again to get latest image
- **Disk space**: Keep 3-4 GB free for Docker + images + toolchains
- **CI/CD**: These images work great in GitHub Actions, GitLab CI, Jenkins, etc.

---

**Print this page and keep it handy!** 📄

*Last updated: 2025-10-07*
