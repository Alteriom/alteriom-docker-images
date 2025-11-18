# Using Persistent Volumes with Alteriom Docker Images

This guide explains how to use persistent volumes with Alteriom Docker images to significantly speed up build times by caching PlatformIO packages and build artifacts.

## Table of Contents

- [Overview](#overview)
- [Benefits](#benefits)
- [Quick Start](#quick-start)
- [Understanding the Permission Fixes](#understanding-the-permission-fixes)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)
- [Technical Details](#technical-details)

## Overview

The Alteriom Docker images now support persistent volumes for PlatformIO's cache directory. This allows you to:

- Cache downloaded PlatformIO packages and platforms
- Persist build artifacts between container runs
- Reduce build times from ~5 minutes to ~30 seconds for incremental builds

### Version Information

This feature is available in:
- **Production image**: `ghcr.io/alteriom/alteriom-docker-images/builder:latest` (v1.8.10+)
- **Development image**: `ghcr.io/alteriom/alteriom-docker-images/dev:latest` (v1.8.10+)

## Benefits

| Scenario | Without Persistent Volumes | With Persistent Volumes |
|----------|----------------------------|-------------------------|
| First build | ~5 minutes | ~5 minutes |
| Subsequent builds | ~5 minutes | ~30 seconds |
| Platform downloads | Every build | Once (cached) |
| Toolchain setup | Every build | Once (cached) |

## Quick Start

### Using Docker Run

```bash
# Create a named volume for PlatformIO cache
docker volume create platformio_cache

# Run builds with persistent cache
# Note: Add --user root to fix permissions on first run with persistent volumes
docker run --rm --user root \
  -v ${PWD}:/workspace \
  -v platformio_cache:/home/builder/.platformio \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest run -e esp32dev
```

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  alteriom-dev:
    image: ghcr.io/alteriom/alteriom-docker-images/builder:latest
    container_name: alteriom-dev
    volumes:
      - .:/workspace
      - platformio_cache:/home/builder/.platformio
    working_dir: /workspace

volumes:
  platformio_cache:
    driver: local
```

Then run:

```bash
docker-compose run --rm alteriom-dev run -e esp32dev
```

See [docker-compose-persistent.yml](../examples/docker-compose-persistent.yml) for a complete example.

## Understanding the Permission Fixes

### The Problem

When using Docker volumes mounted at `/home/builder/.platformio`, permission conflicts can occur:

1. **Volume ownership issue**: Docker creates volumes with root ownership
2. **Non-root user conflict**: Container runs as `builder` user (UID 1000)
3. **PlatformIO write errors**: Cannot write to home directory
4. **Toolchain permission issues**: Extracted binaries lack execute permissions

### The Solution

The Docker images now include an intelligent entrypoint script (`docker-entrypoint.sh`) that handles two scenarios:

**Default behavior (non-root):**
1. **Starts as builder user** (UID 1000) - Secure by default
2. **Runs PlatformIO directly** - No privilege changes needed
3. **Works for most use cases** - No persistent volumes or fresh volumes

**With `--user root` option (for persistent volumes):**
1. **Starts as root** (when explicitly specified with `--user root`)
2. **Fixes volume ownership** on `/home/builder/.platformio` if it exists
3. **Ensures toolchain executables** have proper permissions
4. **Drops to builder user** using gosu before running PlatformIO

### How It Works

```bash
# Default entrypoint flow (non-root):
1. Container starts as builder user (USER directive in Dockerfile)
2. Script detects non-root execution
3. Executes PlatformIO command directly as builder user

# With --user root for persistent volumes:
1. Container starts as root (overridden with --user root)
2. Script checks if PlatformIO directory exists
3. If yes, fixes ownership: chown -R builder:builder /home/builder/.platformio
4. Fixes toolchain binary permissions (chmod +x)
5. Drops to builder user (UID 1000) using gosu
6. Executes PlatformIO command as builder user
```

This approach:
- ✅ Secure by default (runs as non-root)
- ✅ Fixes permission issues automatically when needed
- ✅ Flexible for different use cases
- ✅ Maintains backward compatibility

## Usage Examples

### Example 1: Basic Build with Cache

```bash
# First build (downloads packages, ~5 minutes)
# Use --user root to fix volume permissions
docker run --rm --user root \
  -v ${PWD}:/workspace \
  -v platformio_cache:/home/builder/.platformio \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest run -e esp32dev

# Second build (uses cache, ~30 seconds)
# Still use --user root with persistent volumes
docker run --rm --user root \
  -v ${PWD}:/workspace \
  -v platformio_cache:/home/builder/.platformio \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest run -e esp32dev
```

### Example 2: Multiple Environments

```bash
# Create a volume
docker volume create pio_cache

# Build for ESP32 (use --user root with persistent volumes)
docker run --rm --user root -v ${PWD}:/workspace -v pio_cache:/home/builder/.platformio \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest run -e esp32dev

# Build for ESP32-C3 (reuses ESP32 packages where possible)
docker run --rm --user root -v ${PWD}:/workspace -v pio_cache:/home/builder/.platformio \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest run -e esp32-c3-devkitm-1

# Build for ESP8266 (reuses shared dependencies)
docker run --rm --user root -v ${PWD}:/workspace -v pio_cache:/home/builder/.platformio \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest run -e nodemcuv2
```

### Example 3: Development Workflow

```bash
# Start development container in background
docker-compose up -d alteriom-dev

# Run builds (fast incremental builds)
docker-compose exec alteriom-dev platformio run -e esp32dev

# Clean build
docker-compose exec alteriom-dev platformio run -e esp32dev --target clean

# Open interactive shell
docker-compose exec alteriom-dev bash

# Stop container when done
docker-compose down
```

### Example 4: CI/CD Pipeline

```yaml
# GitHub Actions example
- name: Build firmware with cache
  run: |
    docker volume create pio_cache || true
    docker run --rm --user root \
      -v ${{ github.workspace }}:/workspace \
      -v pio_cache:/home/builder/.platformio \
      ghcr.io/alteriom/alteriom-docker-images/builder:latest \
      run -e esp32dev
```

### Example 5: Windows PowerShell

```powershell
# Create volume
docker volume create platformio_cache

# Build with cache (Windows PowerShell)
# Note: Use --user root with persistent volumes
docker run --rm --user root `
  -v "${PWD}:/workspace" `
  -v platformio_cache:/home/builder/.platformio `
  ghcr.io/alteriom/alteriom-docker-images/builder:latest run -e esp32dev
```

## Troubleshooting

### Issue: "Permission denied" errors

**Symptoms:**
```
PermissionError: [Errno 13] Permission denied: '/home/builder/.platformio/appstate.json.lock'
```

**Solution:**
The entrypoint script should fix this automatically. If you still see this error:

1. Ensure you're using the latest image:
   ```bash
   docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest
   ```

2. Remove and recreate the volume:
   ```bash
   docker volume rm platformio_cache
   docker volume create platformio_cache
   ```

3. Check that the container runs with proper permissions:
   ```bash
   # With --user root, the entrypoint drops to builder
   docker run --rm --user root -v platformio_cache:/home/builder/.platformio \
     ghcr.io/alteriom/alteriom-docker-images/builder:latest sh -c "whoami"
   # Should output: builder
   ```

### Issue: "sh: 1: xtensa-esp32-elf-g++: Permission denied"

**Symptoms:**
```
sh: 1: xtensa-esp32-elf-g++: Permission denied
*** [.pio/build/esp32dev/src/main.cpp.o] Error 126
```

**Solution:**
This is fixed automatically by the entrypoint script. If you still see this:

1. Ensure you're using the updated image
2. Clear the PlatformIO cache:
   ```bash
   docker run --rm --user root -v platformio_cache:/home/builder/.platformio \
     ghcr.io/alteriom/alteriom-docker-images/builder:latest \
     system prune
   ```

3. Rebuild with a fresh cache:
   ```bash
   docker volume rm platformio_cache
   docker volume create platformio_cache
   ```

### Issue: SCons build state corruption

**Symptoms:**
```
*** [.pio/build/esp32dev/src/main.cpp.o] AttributeError: 'str' object has no attribute 'filedir_lookup'
```

**Solution:**
Clean the build artifacts:
```bash
docker run --rm --user root \
  -v ${PWD}:/workspace \
  -v platformio_cache:/home/builder/.platformio \
  ghcr.io/alteriom/alteriom-docker-images/builder:latest \
  run -e esp32dev --target clean
```

### Issue: Volume not persisting between runs

**Symptoms:**
Packages are re-downloaded on every build.

**Solution:**
1. Verify volume was created:
   ```bash
   docker volume ls | grep platformio
   ```

2. Verify volume is being mounted:
   ```bash
   docker run --rm --user root \
     -v platformio_cache:/home/builder/.platformio \
     ghcr.io/alteriom/alteriom-docker-images/builder:latest \
     sh -c "ls -la /home/builder/.platformio"
   ```

3. Check volume mount in docker-compose.yml:
   ```yaml
   volumes:
     - platformio_cache:/home/builder/.platformio  # Correct
     # NOT: - ./platformio_cache:/home/builder/.platformio  # Wrong (bind mount)
   ```

## Technical Details

### Entrypoint Script Behavior

The `docker-entrypoint.sh` script performs the following operations:

```bash
# 1. Check if running as root
if [ "$(id -u)" = "0" ]; then
    # 2. Fix PlatformIO directory ownership
    if [ -d "/home/builder/.platformio" ]; then
        chown -R builder:builder /home/builder/.platformio
    fi
    
    # 3. Fix toolchain executable permissions
    find /home/builder/.platformio/packages -type f \
        \( -name '*-g++' -o -name '*-gcc' -o -name 'esptool*' \) \
        -exec chmod +x {} +
    
    # 4. Drop to builder user
    exec gosu builder:builder "$@"
else
    # Already running as non-root
    exec "$@"
fi
```

### Security Considerations

1. **Default non-root execution** - Container runs as builder user (UID 1000) by default
2. **Optional root for permissions** - Use `--user root` only when persistent volumes need permission fixes
3. **Automatic privilege dropping** - When started as root, entrypoint drops to builder user using gosu
4. **Uses gosu** - Proper privilege dropping (better than `su`)
5. **No persistent root access** - Root privileges only during initialization when explicitly requested

### Performance Impact

| Operation | Time Impact |
|-----------|-------------|
| Permission fixing | < 1 second |
| First build | No impact (same as stateless) |
| Subsequent builds | 90% faster (30s vs 5min) |
| Volume cleanup | < 1 second |

### Volume Management

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect platformio_cache

# Remove volume (clears cache)
docker volume rm platformio_cache

# Prune unused volumes
docker volume prune
```

### Compatibility

| Docker Version | Supported | Notes |
|----------------|-----------|-------|
| 20.10+ | ✅ Yes | Recommended |
| 19.03+ | ✅ Yes | Named volumes work |
| < 19.03 | ⚠️ Limited | May have volume permission issues |

| Platform | Supported | Notes |
|----------|-----------|-------|
| Linux | ✅ Yes | Native performance |
| Windows (Docker Desktop) | ✅ Yes | Uses WSL2 backend |
| macOS (Docker Desktop) | ✅ Yes | Uses virtualization |

## Additional Resources

- [Docker Volumes Documentation](https://docs.docker.com/storage/volumes/)
- [PlatformIO Core Directory](https://docs.platformio.org/en/latest/core/userguide/system/cmd_info.html)
- [Example docker-compose.yml](../examples/docker-compose-persistent.yml)
- [Test Script](../../scripts/test-persistent-volumes.sh)

## Feedback

If you encounter any issues with persistent volumes, please:

1. Check this troubleshooting guide
2. Review the [GitHub Issues](https://github.com/Alteriom/alteriom-docker-images/issues)
3. Open a new issue with:
   - Docker version: `docker --version`
   - Image version: `docker inspect <image> | grep version`
   - Error messages and logs
   - Steps to reproduce
