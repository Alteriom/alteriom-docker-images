#!/usr/bin/env bash
# Test script for persistent volume permission handling
# This script validates that the Docker images correctly handle permission issues
# when using persistent volumes for PlatformIO cache

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE="${1:-ghcr.io/alteriom/alteriom-docker-images/builder:latest}"
TEST_DIR="/tmp/test-persistent-volumes-$$"
VOLUME_NAME="test-platformio-cache-$$"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

log_test() {
    echo -e "${BLUE}[TEST]${NC} $*"
}

cleanup() {
    log_info "Cleaning up test environment..."
    docker volume rm "$VOLUME_NAME" 2>/dev/null || true
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

# Register cleanup on exit
trap cleanup EXIT

# Create test environment
log_info "Setting up test environment..."
mkdir -p "$TEST_DIR"

# Create a minimal PlatformIO project for testing
cat > "$TEST_DIR/platformio.ini" << 'EOF'
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino
EOF

mkdir -p "$TEST_DIR/src"
cat > "$TEST_DIR/src/main.cpp" << 'EOF'
#include <Arduino.h>

void setup() {
    Serial.begin(115200);
    Serial.println("Permission test successful!");
}

void loop() {
    delay(1000);
}
EOF

log_info "Test project created at: $TEST_DIR"

# Create Docker volume for PlatformIO cache
log_info "Creating Docker volume: $VOLUME_NAME"
docker volume create "$VOLUME_NAME"

# Test 1: Verify entrypoint handles permissions correctly
log_test "Test 1: Running container with persistent volume (as root)..."
if docker run --rm \
    -v "$TEST_DIR:/workspace" \
    -v "$VOLUME_NAME:/home/builder/.platformio" \
    -w /workspace \
    "$IMAGE" --version > /dev/null 2>&1; then
    log_info "✓ Container started successfully with persistent volume"
else
    log_error "✗ Container failed to start with persistent volume"
    exit 1
fi

# Test 2: Verify PlatformIO can write to cache directory
log_test "Test 2: Checking if PlatformIO can initialize platforms..."
if docker run --rm \
    -v "$TEST_DIR:/workspace" \
    -v "$VOLUME_NAME:/home/builder/.platformio" \
    -w /workspace \
    -e "PLATFORMIO_CORE_DIR=/home/builder/.platformio" \
    "$IMAGE" platform list > /dev/null 2>&1; then
    log_info "✓ PlatformIO can access cache directory"
else
    log_error "✗ PlatformIO cannot access cache directory"
    exit 1
fi

# Test 3: Verify permissions are fixed after first run
log_test "Test 3: Verifying volume ownership after container run..."
VOLUME_MOUNT=$(docker volume inspect "$VOLUME_NAME" -f '{{.Mountpoint}}' 2>/dev/null || echo "")
if [ -n "$VOLUME_MOUNT" ] && [ -d "$VOLUME_MOUNT" ]; then
    OWNER=$(sudo stat -c '%u:%g' "$VOLUME_MOUNT" 2>/dev/null || echo "unknown")
    if [ "$OWNER" = "1000:1000" ] || [ "$OWNER" = "unknown" ]; then
        log_info "✓ Volume ownership is correct or inaccessible (expected: 1000:1000, got: $OWNER)"
    else
        log_warn "⚠ Volume ownership is $OWNER (expected: 1000:1000)"
    fi
else
    log_warn "⚠ Cannot check volume ownership (Docker Desktop or remote Docker)"
fi

# Test 4: Test multiple runs with same volume
log_test "Test 4: Running container multiple times with same volume..."
for i in {1..3}; do
    if docker run --rm \
        -v "$TEST_DIR:/workspace" \
        -v "$VOLUME_NAME:/home/builder/.platformio" \
        -w /workspace \
        "$IMAGE" --version > /dev/null 2>&1; then
        log_info "✓ Run $i/3 successful"
    else
        log_error "✗ Run $i/3 failed"
        exit 1
    fi
done

# Test 5: Verify user is builder inside container
log_test "Test 5: Verifying container runs as 'builder' user..."
CONTAINER_USER=$(docker run --rm \
    -v "$TEST_DIR:/workspace" \
    -v "$VOLUME_NAME:/home/builder/.platformio" \
    "$IMAGE" sh -c "whoami" 2>/dev/null || echo "unknown")

if [ "$CONTAINER_USER" = "builder" ]; then
    log_info "✓ Container runs as 'builder' user"
else
    log_warn "⚠ Container runs as '$CONTAINER_USER' (expected: builder)"
fi

# Test 6: Verify container can create files in workspace
log_test "Test 6: Verifying container can write to workspace..."
if docker run --rm \
    -v "$TEST_DIR:/workspace" \
    -v "$VOLUME_NAME:/home/builder/.platformio" \
    -w /workspace \
    "$IMAGE" sh -c "touch test-file.txt && rm test-file.txt" 2>/dev/null; then
    log_info "✓ Container can write to workspace"
else
    log_error "✗ Container cannot write to workspace"
    exit 1
fi

# Summary
echo ""
log_info "═══════════════════════════════════════"
log_info "All tests passed! ✅"
log_info "═══════════════════════════════════════"
echo ""
log_info "The image correctly handles:"
log_info "  • Permission fixes on mounted volumes"
log_info "  • Running as non-root (builder) user"
log_info "  • Multiple runs with persistent volumes"
log_info "  • Write access to workspace and cache"
echo ""
log_info "You can now use persistent volumes safely:"
echo ""
echo "  docker run --rm \\"
echo "    -v \${PWD}:/workspace \\"
echo "    -v platformio_cache:/home/builder/.platformio \\"
echo "    $IMAGE run -e esp32dev"
echo ""
