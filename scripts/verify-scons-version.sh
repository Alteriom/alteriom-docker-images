#!/usr/bin/env bash
# Verification script for SCons version in Docker images
# This script verifies that the Docker images use the correct SCons version
# Expected: SCons 4.7.0 (tool-scons @ ~4.70700.0) for Python 3.11 compatibility

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCKER_REPO="${DOCKER_REPOSITORY:-ghcr.io/alteriom/alteriom-docker-images}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check PlatformIO version in an image
check_platformio_version() {
    local image_name="$1"
    
    print_status "Checking PlatformIO version in: $image_name"
    
    if ! docker image inspect "$image_name" >/dev/null 2>&1; then
        print_warning "Image not found locally, attempting to pull..."
        if ! docker pull "$image_name"; then
            print_error "Failed to pull image: $image_name"
            return 1
        fi
    fi
    
    local pio_version=$(docker run --rm "$image_name" --version 2>/dev/null | grep -oP "PlatformIO Core, version \K[0-9.]+")
    
    if [[ -z "$pio_version" ]]; then
        print_error "Failed to get PlatformIO version from $image_name"
        return 1
    fi
    
    print_status "PlatformIO version: $pio_version"
    
    # Check if version is 6.1.15 (correct) or 6.1.16+ (broken with Python 3.11)
    if [[ "$pio_version" == "6.1.15" ]]; then
        print_success "✓ Using PlatformIO 6.1.15 (includes SCons 4.7.0 - compatible with Python 3.11)"
        return 0
    elif [[ "$pio_version" == "6.1.16" ]] || [[ "$pio_version" > "6.1.16" ]]; then
        print_error "✗ Using PlatformIO $pio_version (includes SCons 4.8.1+ - BROKEN with Python 3.11)"
        print_error "  This will cause UnboundLocalError during builds!"
        return 1
    elif [[ "$pio_version" < "6.1.15" ]]; then
        print_warning "⚠ Using older PlatformIO $pio_version"
        print_warning "  May have other compatibility issues. Recommended: 6.1.15"
        return 2
    else
        print_warning "⚠ Unexpected PlatformIO version: $pio_version"
        return 2
    fi
}

# Function to check Python version
check_python_version() {
    local image_name="$1"
    
    print_status "Checking Python version in: $image_name"
    
    local python_version=$(docker run --rm --user root --entrypoint /bin/bash "$image_name" -c "python3 --version" 2>&1 | grep -oP "Python \K[0-9.]+")
    
    if [[ -z "$python_version" ]]; then
        print_error "Failed to get Python version from $image_name"
        return 1
    fi
    
    print_status "Python version: $python_version"
    
    if [[ "$python_version" =~ ^3\.11\. ]]; then
        print_success "✓ Using Python 3.11.x"
        return 0
    else
        print_warning "⚠ Using Python $python_version (expected 3.11.x)"
        return 2
    fi
}

# Main verification function
run_verification() {
    local test_images=("$@")
    local all_passed=true
    
    if [[ ${#test_images[@]} -eq 0 ]]; then
        test_images=("${DOCKER_REPO}/builder:latest" "${DOCKER_REPO}/dev:latest")
    fi
    
    print_status "Starting SCons/PlatformIO version verification"
    print_status "Testing images: ${test_images[*]}"
    echo ""
    
    for image in "${test_images[@]}"; do
        echo "========================================"
        print_status "Verifying Docker image: $image"
        echo "========================================"
        
        # Check Python version
        if ! check_python_version "$image"; then
            all_passed=false
        fi
        echo ""
        
        # Check PlatformIO version (which determines SCons version)
        if ! check_platformio_version "$image"; then
            all_passed=false
        fi
        echo ""
    done
    
    # Print summary
    echo "========================================"
    print_status "VERIFICATION SUMMARY"
    echo "========================================"
    
    if $all_passed; then
        print_success "All images use correct versions! ✅"
        print_success "PlatformIO 6.1.15 + Python 3.11 = SCons 4.7.0 (compatible)"
        echo ""
        print_status "Images are ready to build ESP32/ESP8266 firmware without SCons errors."
        return 0
    else
        print_error "Some images have version issues! ❌"
        echo ""
        print_error "Please rebuild images with PlatformIO 6.1.15 to fix SCons 4.8.x regression."
        return 1
    fi
}

# Show usage if help requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [docker-image...]"
    echo ""
    echo "Verify SCons/PlatformIO versions in Docker images."
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Arguments:"
    echo "  docker-image  Docker image(s) to verify (default: builder:latest and dev:latest)"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Verify default images"
    echo "  $0 builder:latest                     # Verify specific image"
    echo "  $0 builder:1.8.12 dev:1.8.12          # Verify specific versions"
    echo ""
    echo "Environment Variables:"
    echo "  DOCKER_REPOSITORY   Docker repository prefix (default: ghcr.io/Alteriom/alteriom-docker-images)"
    echo ""
    echo "Expected Versions (for Python 3.11 compatibility):"
    echo "  - PlatformIO: 6.1.15"
    echo "  - SCons: 4.7.0 (packaged as tool-scons @ ~4.70700.0)"
    echo "  - Python: 3.11.x"
    exit 0
fi

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    print_error "Docker is not available. Please install Docker to run verification."
    exit 1
fi

# Run the verification
run_verification "$@"
exit $?
