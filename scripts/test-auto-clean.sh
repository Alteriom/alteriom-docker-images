#!/usr/bin/env bash
# Regression test for SCons auto-clean functionality
# Tests that builds complete successfully with auto-clean enabled (default behavior)
# This verifies the fix for UnboundLocalError that occurred with SCons 4.5.2 + Python 3.11

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

# Function to test auto-clean functionality with a specific image
test_auto_clean() {
    local image_name="$1"
    local test_project="$2"
    local environment="$3"
    local test_name="$4"
    
    print_status "==================================="
    print_status "Testing: $test_name"
    print_status "Image: $image_name"
    print_status "==================================="
    
    local test_path="${REPO_ROOT}/tests/${test_project}"
    
    if [[ ! -d "$test_path" ]]; then
        print_error "Test project directory not found: $test_path"
        return 1
    fi
    
    # Create temporary directory for PlatformIO cache
    local temp_platformio_dir=$(mktemp -d)
    
    print_status "Step 1: First build (with auto-clean enabled by default)"
    print_status "This tests that auto-clean doesn't trigger UnboundLocalError"
    
    if timeout 300 docker run --rm \
        --user "$(id -u):$(id -g)" \
        -e "PLATFORMIO_CORE_DIR=/tmp/platformio" \
        -v "$test_path:/workspace" \
        -v "$temp_platformio_dir:/tmp/platformio" \
        "$image_name" run -e "$environment"; then
        print_success "✓ First build completed successfully (auto-clean worked correctly)"
    else
        local exit_code=$?
        rm -rf "$temp_platformio_dir"
        print_error "✗ First build failed with exit code: $exit_code"
        print_error "This indicates the SCons auto-clean issue may still exist"
        return 1
    fi
    
    print_status ""
    print_status "Step 2: Clean build explicitly"
    print_status "Running: pio run --target clean"
    
    if timeout 120 docker run --rm \
        --user "$(id -u):$(id -g)" \
        -e "PLATFORMIO_CORE_DIR=/tmp/platformio" \
        -v "$test_path:/workspace" \
        -v "$temp_platformio_dir:/tmp/platformio" \
        "$image_name" run --target clean -e "$environment"; then
        print_success "✓ Explicit clean completed successfully"
    else
        local exit_code=$?
        rm -rf "$temp_platformio_dir"
        print_error "✗ Explicit clean failed with exit code: $exit_code"
        return 1
    fi
    
    print_status ""
    print_status "Step 3: Second build (incremental after clean)"
    print_status "This tests that build works correctly after explicit clean"
    
    if timeout 300 docker run --rm \
        --user "$(id -u):$(id -g)" \
        -e "PLATFORMIO_CORE_DIR=/tmp/platformio" \
        -v "$test_path:/workspace" \
        -v "$temp_platformio_dir:/tmp/platformio" \
        "$image_name" run -e "$environment"; then
        print_success "✓ Second build completed successfully"
    else
        local exit_code=$?
        rm -rf "$temp_platformio_dir"
        print_error "✗ Second build failed with exit code: $exit_code"
        return 1
    fi
    
    # Clean up
    rm -rf "$temp_platformio_dir"
    
    print_success ""
    print_success "✓✓✓ All auto-clean tests passed for $test_name"
    print_success ""
    return 0
}

# Function to check if Docker image exists and is accessible
check_image() {
    local image_name="$1"
    
    print_status "Checking if Docker image exists: $image_name"
    
    if docker image inspect "$image_name" >/dev/null 2>&1; then
        print_success "Image $image_name is available locally"
        return 0
    fi
    
    print_status "Image not found locally, attempting to pull: $image_name"
    
    if docker pull "$image_name"; then
        print_success "Successfully pulled image: $image_name"
        return 0
    else
        print_error "Failed to pull image: $image_name"
        return 1
    fi
}

# Test configurations
# Format: "project_dir:environment:test_name"
declare -A TEST_CONFIGS=(
    ["esp32"]="esp32-test:esp32dev:ESP32 Auto-Clean Test"
    ["esp32s3"]="esp32s3-test:esp32-s3-devkitc-1:ESP32-S3 Auto-Clean Test"
)

# Main test function
run_auto_clean_tests() {
    local test_images=("$@")
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    
    if [[ ${#test_images[@]} -eq 0 ]]; then
        test_images=("${DOCKER_REPO}/builder:latest")
    fi
    
    print_status "=================================="
    print_status "Auto-Clean Regression Test Suite"
    print_status "=================================="
    print_status ""
    print_status "This test verifies that the SCons UnboundLocalError"
    print_status "issue is fixed by running builds with auto-clean enabled"
    print_status ""
    print_status "Testing with images: ${test_images[*]}"
    print_status ""
    
    for image in "${test_images[@]}"; do
        echo ""
        echo "========================================"
        print_status "Testing Docker image: $image"
        echo "========================================"
        
        # Check if image is available
        if ! check_image "$image"; then
            print_error "Skipping tests for unavailable image: $image"
            continue
        fi
        
        # Test each configuration
        for platform in "${!TEST_CONFIGS[@]}"; do
            IFS=':' read -r project_dir environment test_name <<< "${TEST_CONFIGS[$platform]}"
            ((total_tests++)) || true
            
            if test_auto_clean "$image" "$project_dir" "$environment" "$test_name"; then
                ((passed_tests++)) || true
            else
                ((failed_tests++)) || true
            fi
            echo ""
        done
    done
    
    # Print summary
    echo ""
    echo "========================================"
    print_status "AUTO-CLEAN TEST SUMMARY"
    echo "========================================"
    print_status "Total test suites: $total_tests"
    print_success "Passed: $passed_tests"
    
    if [[ $failed_tests -gt 0 ]]; then
        print_error "Failed: $failed_tests"
        echo ""
        print_error "Some tests failed. The SCons auto-clean issue may still exist."
        print_error "This indicates that builds are failing during the clean phase."
        return 1
    else
        echo ""
        print_success "========================================"
        print_success "  ALL AUTO-CLEAN TESTS PASSED! ✅"
        print_success "========================================"
        print_success ""
        print_success "The SCons UnboundLocalError fix is working correctly."
        print_success "Builds complete successfully with auto-clean enabled."
        print_success "No need for --disable-auto-clean workaround."
        return 0
    fi
}

# Show usage if help requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [docker-image...]"
    echo ""
    echo "Regression test for SCons auto-clean functionality."
    echo "Verifies that builds work correctly with auto-clean enabled (default behavior)."
    echo ""
    echo "This test was created to verify the fix for the SCons UnboundLocalError issue"
    echo "that occurred with PlatformIO 6.1.13 (SCons 4.5.2) and Python 3.11."
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Arguments:"
    echo "  docker-image  Docker image(s) to test (default: builder:latest)"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Test with default builder image"
    echo "  $0 builder:latest                     # Test with specific image"
    echo "  $0 builder:latest dev:latest          # Test with multiple images"
    echo ""
    echo "Environment Variables:"
    echo "  DOCKER_REPOSITORY   Docker repository prefix (default: ghcr.io/alteriom/alteriom-docker-images)"
    echo ""
    echo "Test Procedure:"
    echo "  1. First build with auto-clean enabled (default)"
    echo "  2. Explicit clean operation"
    echo "  3. Second build after clean (incremental)"
    echo ""
    echo "Expected Result:"
    echo "  All three steps should complete without UnboundLocalError"
    exit 0
fi

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    print_error "Docker is not available. Please install Docker to run tests."
    exit 1
fi

# Run the tests
print_status "Starting auto-clean regression tests..."
print_status ""
run_auto_clean_tests "$@"
exit $?
