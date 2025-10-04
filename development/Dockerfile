# Optimized Development builder image — extends production with dev tools
# Includes vim, htop, less, and twine for development workflows
# Size: ~600-800MB (includes debugging and troubleshooting tools)

# Base image: Python 3.11 slim variant
FROM python:3.11-slim

# Add version labels for tracking and container registry metadata
ARG VERSION=1.4.0
LABEL org.opencontainers.image.title="Alteriom Development Builder"
LABEL org.opencontainers.image.description="PlatformIO builder with development tools for ESP32/ESP8266 development"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.vendor="Alteriom"
LABEL org.opencontainers.image.source="https://github.com/Alteriom/alteriom-docker-images"
LABEL org.opencontainers.image.licenses="MIT"
LABEL maintainer="Alteriom <contact@alteriom.org>"

# Disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install all dependencies including dev tools, removing build-only packages after
# Development image includes debugging and troubleshooting tools
# Package list:
#   git, ca-certificates: Required for PlatformIO and secure connections
#   gcc, g++, make: Build-only tools (removed after install)
#   libffi-dev, libssl-dev: Build-only libraries (removed after install)
#   vim, less, htop: Development tools for debugging and monitoring
# Python packages:
#   setuptools>=70.0.0: Security patch CVE-2024-6345
#   platformio==6.1.13: Pinned for stability
#   twine: Package publishing tool
#   starlette>=0.40.0: Security patch CVE-2024-47874
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    gcc \
    g++ \
    make \
    libffi-dev \
    libssl-dev \
    vim \
    less \
    htop \
    && pip3 install --no-cache-dir -U pip \
    && pip3 install --no-cache-dir -U "setuptools>=70.0.0" \
    && pip3 install --no-cache-dir "platformio==6.1.13" twine \
    && pip3 install --no-cache-dir -U "starlette>=0.40.0" \
    && apt-get remove -y gcc g++ make libffi-dev libssl-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user and workspace directory for safer builds
# Security: Non-root execution (UID 1000) for development workflows
RUN useradd --create-home --shell /bin/false builder \
    && mkdir -p /workspace \
    && chown -R builder:builder /workspace

# Switch to non-root user for all development operations
USER builder

# Set working directory for development builds
WORKDIR /workspace

# Add healthcheck to ensure PlatformIO is responding
# Enables debugging of container health in development
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/platformio --version || exit 1

# Default entrypoint: run platformio with development tools available
# Additional tools (vim, htop, less) accessible via: docker exec -it <container> bash
ENTRYPOINT ["/usr/local/bin/platformio"]
CMD ["--help"]
