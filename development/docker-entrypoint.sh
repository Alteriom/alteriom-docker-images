#!/bin/bash
# Docker entrypoint script for Alteriom PlatformIO builder images
# Handles permission fixes for persistent volumes and toolchain executables
# This script runs as root initially to fix permissions, then drops to builder user

set -e

# Environment variables
PLATFORMIO_CORE_DIR="${PLATFORMIO_CORE_DIR:-/home/builder/.platformio}"
BUILDER_USER="builder"
BUILDER_UID=1000
BUILDER_GID=1000

# Color output for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[entrypoint]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[entrypoint]${NC} $*"
}

log_error() {
    echo -e "${RED}[entrypoint]${NC} $*"
}

# Function to fix directory ownership
fix_ownership() {
    local dir="$1"
    if [ -d "$dir" ]; then
        local current_owner
        current_owner=$(stat -c '%u:%g' "$dir" 2>/dev/null || echo "unknown")
        if [ "$current_owner" != "${BUILDER_UID}:${BUILDER_GID}" ]; then
            log_info "Fixing ownership of $dir (current: $current_owner, target: ${BUILDER_UID}:${BUILDER_GID})"
            chown -R ${BUILDER_UID}:${BUILDER_GID} "$dir" 2>/dev/null || {
                log_warn "Could not change ownership of $dir - this may cause permission issues"
            }
        fi
    fi
}

# Function to fix toolchain executable permissions
fix_toolchain_permissions() {
    local packages_dir="${PLATFORMIO_CORE_DIR}/packages"
    if [ -d "$packages_dir" ]; then
        log_info "Ensuring toolchain binaries have execute permissions..."
        # Find and fix common toolchain executables
        find "$packages_dir" -type f \( \
            -name '*-g++' -o \
            -name '*-gcc' -o \
            -name '*-ar' -o \
            -name '*-as' -o \
            -name '*-ld' -o \
            -name '*-objcopy' -o \
            -name '*-objdump' -o \
            -name '*-size' -o \
            -name 'esptool*' -o \
            -name 'espefuse*' -o \
            -name 'mkspiffs' -o \
            -name 'mklittlefs' \
        \) -exec chmod +x {} + 2>/dev/null || true
        
        # Also fix python scripts and shell scripts in bin directories
        find "$packages_dir" -type d -name 'bin' -exec chmod -R +x {}/* + 2>/dev/null || true
    fi
}

# Main permission fixing logic
if [ "$(id -u)" = "0" ]; then
    log_info "Running as root - fixing permissions for persistent volumes..."
    
    # Fix PlatformIO core directory if it exists
    if [ -d "$PLATFORMIO_CORE_DIR" ]; then
        fix_ownership "$PLATFORMIO_CORE_DIR"
        fix_toolchain_permissions
    fi
    
    # Fix workspace directory if it exists and needs fixing
    if [ -d "/workspace" ]; then
        fix_ownership "/workspace"
    fi
    
    # Drop to builder user and execute the command
    log_info "Dropping privileges to user '${BUILDER_USER}' (UID ${BUILDER_UID})"
    
    # Use gosu if available, otherwise fall back to su
    if command -v gosu >/dev/null 2>&1; then
        exec gosu ${BUILDER_UID}:${BUILDER_GID} "$@"
    else
        # Fall back to su with proper argument handling
        exec su -s /bin/sh ${BUILDER_USER} -c 'exec "$@"' -- "$@"
    fi
else
    # Already running as non-root user
    log_info "Running as non-root user (UID $(id -u))"
    
    # Check if we have permission issues and warn
    if [ -d "$PLATFORMIO_CORE_DIR" ] && [ ! -w "$PLATFORMIO_CORE_DIR" ]; then
        log_warn "PlatformIO directory exists but is not writable!"
        log_warn "You may need to run the container as root or fix permissions manually."
        log_warn "Consider using: docker run --user root ..."
    fi
    
    # Execute the command directly
    exec "$@"
fi
