#!/bin/bash
# Package Visibility Checker
# This script helps verify that Docker images are publicly accessible

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Docker Package Visibility Checker                      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Package details
REGISTRY="ghcr.io"
OWNER="alteriom"
REPO="alteriom-docker-images"
BUILDER_IMAGE="${REGISTRY}/${OWNER}/${REPO}/builder:latest"
DEV_IMAGE="${REGISTRY}/${OWNER}/${REPO}/dev:latest"

echo -e "${YELLOW}Checking package visibility...${NC}"
echo ""

# Function to check if image is pullable
check_image_pullable() {
    local image=$1
    local name=$2
    
    echo -n "Testing ${name} image pull... "
    
    if docker pull "${image}" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ SUCCESS${NC}"
        echo "  → Image is publicly accessible"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        echo "  → Image is NOT publicly accessible"
        return 1
    fi
}

# Function to check package API endpoint
check_api_endpoint() {
    local owner=$1
    local package=$2
    local name=$3
    
    echo -n "Checking ${name} package metadata... "
    
    # Try to get basic image manifest (lightweight check)
    local response=$(curl -sI "https://${REGISTRY}/v2/${owner}/${package}/manifests/latest" 2>&1)
    
    if echo "$response" | grep -q "200 OK\|302 Found\|Docker-Content-Digest" 2>/dev/null; then
        echo -e "${GREEN}✅ ACCESSIBLE${NC}"
        echo "  → Package metadata is accessible (public)"
        return 0
    else
        echo -e "${YELLOW}⚠️  METADATA CHECK SKIPPED${NC}"
        echo "  → Will verify via docker pull instead"
        return 0  # Don't fail on this check, docker pull is more reliable
    fi
}

# Function to test image functionality
test_image_functionality() {
    local image=$1
    local name=$2
    
    echo -n "Testing ${name} image functionality... "
    
    if docker run --rm "${image}" --version >/dev/null 2>&1; then
        local version=$(docker run --rm "${image}" --version 2>&1)
        echo -e "${GREEN}✅ WORKING${NC}"
        echo "  → ${version}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        echo "  → Image downloaded but not working correctly"
        return 1
    fi
}

# Check builder image
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Builder Image (${BUILDER_IMAGE})${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
BUILDER_PULL_SUCCESS=0
BUILDER_FUNC_SUCCESS=0
check_api_endpoint "${OWNER}/${REPO}" "builder" "Builder"
check_image_pullable "${BUILDER_IMAGE}" "Builder" || BUILDER_PULL_SUCCESS=1
test_image_functionality "${BUILDER_IMAGE}" "Builder" || BUILDER_FUNC_SUCCESS=1
echo ""

# Check dev image
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Dev Image (${DEV_IMAGE})${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
DEV_PULL_SUCCESS=0
DEV_FUNC_SUCCESS=0
check_api_endpoint "${OWNER}/${REPO}" "dev" "Dev"
check_image_pullable "${DEV_IMAGE}" "Dev" || DEV_PULL_SUCCESS=1
test_image_functionality "${DEV_IMAGE}" "Dev" || DEV_FUNC_SUCCESS=1
echo ""

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if critical operations succeeded (pull and functionality)
BUILDER_SUCCESS=$((BUILDER_PULL_SUCCESS + BUILDER_FUNC_SUCCESS))
DEV_SUCCESS=$((DEV_PULL_SUCCESS + DEV_FUNC_SUCCESS))

if [ $BUILDER_SUCCESS -eq 0 ] && [ $DEV_SUCCESS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CHECKS PASSED!${NC}"
    echo ""
    echo "Both images are:"
    echo "  • Publicly accessible (no authentication required)"
    echo "  • Downloadable via docker pull"
    echo "  • Functional and working correctly"
    echo ""
    echo -e "${GREEN}The packages are properly configured as PUBLIC! 🎉${NC}"
    echo ""
    echo "You can now use the images with:"
    echo "  docker pull ghcr.io/alteriom/alteriom-docker-images/builder:latest"
    echo "  docker pull ghcr.io/alteriom/alteriom-docker-images/dev:latest"
    exit 0
else
    echo -e "${RED}❌ SOME CHECKS FAILED${NC}"
    echo ""
    echo "Issues detected:"
    if [ $BUILDER_PULL_SUCCESS -ne 0 ]; then
        echo "  • Builder image cannot be pulled (ACCESS DENIED)"
    fi
    if [ $BUILDER_FUNC_SUCCESS -ne 0 ]; then
        echo "  • Builder image pulled but not functional"
    fi
    if [ $DEV_PULL_SUCCESS -ne 0 ]; then
        echo "  • Dev image cannot be pulled (ACCESS DENIED)"
    fi
    if [ $DEV_FUNC_SUCCESS -ne 0 ]; then
        echo "  • Dev image pulled but not functional"
    fi
    echo ""
    echo -e "${YELLOW}Troubleshooting steps:${NC}"
    echo ""
    echo "1. Verify package visibility settings:"
    echo "   • Builder: https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fbuilder"
    echo "   • Dev: https://github.com/Alteriom/alteriom-docker-images/pkgs/container/alteriom-docker-images%2Fdev"
    echo ""
    echo "2. To change visibility to Public:"
    echo "   • Click 'Package settings' on the right side"
    echo "   • Scroll to 'Danger Zone'"
    echo "   • Click 'Change visibility' → Select 'Public'"
    echo "   • Confirm the change"
    echo ""
    echo "3. Wait a few minutes for changes to propagate"
    echo ""
    echo "4. Run this script again to verify"
    echo ""
    exit 1
fi
