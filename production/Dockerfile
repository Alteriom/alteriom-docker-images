# Optimized Production builder image for Alteriom
# Minimal image with PlatformIO for ESP32/ESP8266 builds
# Platforms are installed at runtime for smaller base image
# Size: ~400-500MB (optimized from ~800MB+ in non-optimized versions)

# Base image: Python 3.11 slim variant for minimal footprint
FROM python:3.11-slim

# Add version labels for tracking and container registry metadata
ARG VERSION=1.4.0
LABEL org.opencontainers.image.title="Alteriom Production Builder"
LABEL org.opencontainers.image.description="Minimal PlatformIO builder for ESP32/ESP8266 development"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.vendor="Alteriom"
LABEL org.opencontainers.image.source="https://github.com/Alteriom/alteriom-docker-images"
LABEL org.opencontainers.image.licenses="MIT"
LABEL maintainer="Alteriom <contact@alteriom.org>"

# Disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential dependencies only, removing build tools after PlatformIO install
# This multi-stage approach significantly reduces final image size (~20-30% reduction)
# Package list:
#   git: Required for PlatformIO package management and cloning
#   ca-certificates: Required for SSL/TLS support for secure package downloads
#   gcc, g++, make: Build-only tools for compilation (removed after install)
#   libffi-dev, libssl-dev: Build-only libraries (removed after install)
#   gosu: Lightweight tool for dropping privileges (kept for entrypoint)
# Python packages:
#   setuptools>=70.0.0: Pinned for security patch CVE-2024-6345
#   platformio==6.1.16: Upgraded from 6.1.13 to fix SCons 4.5.2 bug with Python 3.11
#     - SCons upgraded to 4.8.1 which fixes UnboundLocalError with Python 3.11
#     - Resolves: "cannot access local variable 'node' where it is not associated with a value"
#   starlette>=0.40.0: Security patch for CVE-2024-47874
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    gcc \
    g++ \
    make \
    libffi-dev \
    libssl-dev \
    gosu \
    && pip3 install --no-cache-dir -U pip \
    && pip3 install --no-cache-dir -U "setuptools>=70.0.0" \
    && pip3 install --no-cache-dir "platformio==6.1.16" \
    && pip3 install --no-cache-dir -U "starlette>=0.40.0" \
    && apt-get remove -y gcc g++ make libffi-dev libssl-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user and workspace directory for safer builds
# Security: Running as non-root (UID 1000) prevents privilege escalation
# Note: Container starts as root but entrypoint drops to builder user after fixing permissions
RUN useradd --create-home --shell /bin/bash builder \
    && mkdir -p /workspace \
    && chown -R builder:builder /workspace

# Copy entrypoint script that handles permission fixes for persistent volumes
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set working directory for build operations
WORKDIR /workspace

# Set default user to non-root for security (satisfies DS002)
# Note: If persistent volumes need permission fixes, run with --user root
# The entrypoint script will detect root and drop privileges after fixing permissions
USER builder

# Add healthcheck to ensure PlatformIO is responding
# Enables container orchestration to detect unhealthy containers
# Runs as builder user (set above) for proper security
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/platformio --version || exit 1

# Custom entrypoint handles permission fixes, then runs platformio
# Default: Container runs as builder user (non-root)
# If persistent volumes need permission fixes, run with: docker run --user root ...
# Usage: docker run <image> run -e esp32dev
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh", "/usr/local/bin/platformio"]
CMD ["--help"]
