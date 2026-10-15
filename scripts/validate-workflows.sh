#!/bin/bash

# Validate Workflows Script
# Checks every workflow file in .github/workflows/ and ensures only one of them
# builds and pushes the images, to prevent duplicate builds.
#
#   1. Every workflow parses as YAML and has an `on:` trigger and a `jobs:` map
#      whose jobs each declare `runs-on` or `uses` (needs python3 with PyYAML;
#      without it the structure check is skipped with a warning).
#   2. Exactly one workflow runs the image build (scripts/build-images.sh,
#      docker/build-push-action or `docker buildx build`).
#
# Exit 0 when both hold, 1 otherwise.

set -euo pipefail

WORKFLOW_DIR="${WORKFLOW_DIR:-.github/workflows}"

echo "🔍 Validating workflow configuration..."
echo ""

if [ ! -d "$WORKFLOW_DIR" ]; then
    echo "❌ $WORKFLOW_DIR not found (run from the repository root)"
    exit 1
fi

WORKFLOWS=()
while IFS= read -r file; do
    WORKFLOWS+=("$file")
done < <(find "$WORKFLOW_DIR" -maxdepth 1 -type f \( -name "*.yml" -o -name "*.yaml" \) | sort)

echo "📁 Local workflow files (${#WORKFLOWS[@]}):"
for file in "${WORKFLOWS[@]}"; do
    echo "  - $file"
done
echo ""

if [ "${#WORKFLOWS[@]}" -eq 0 ]; then
    echo "❌ No workflow files found in $WORKFLOW_DIR"
    exit 1
fi

# 1. Structure of every workflow
STRUCTURE_STATUS="PASS"
PYTHON=""
for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c "import yaml" >/dev/null 2>&1; then
        PYTHON="$candidate"
        break
    fi
done

if [ -n "$PYTHON" ]; then
    echo "🧪 Checking the structure of every workflow:"
    for file in "${WORKFLOWS[@]}"; do
        if RESULT=$("$PYTHON" - "$file" <<'PY' 2>&1
import sys

import yaml

path = sys.argv[1]
with open(path, encoding="utf-8") as handle:
    doc = yaml.safe_load(handle)

problems = []
if not isinstance(doc, dict):
    problems.append("not a YAML mapping")
else:
    # PyYAML reads the bare key `on` as the boolean True.
    if "on" not in doc and True not in doc:
        problems.append("no `on:` trigger")
    jobs = doc.get("jobs")
    if not isinstance(jobs, dict) or not jobs:
        problems.append("no `jobs:` map")
    else:
        for name, job in jobs.items():
            if not isinstance(job, dict) or not ("runs-on" in job or "uses" in job):
                problems.append(f"job `{name}` has neither `runs-on` nor `uses`")

if problems:
    print("; ".join(problems))
    sys.exit(1)
print(f"{len(doc['jobs'])} job(s)")
PY
        ); then
            echo "  ✅ $file: $RESULT"
        else
            echo "  ❌ $file: $RESULT"
            STRUCTURE_STATUS="FAIL"
        fi
    done
else
    echo "⚠️  python3 with PyYAML not found - structure check skipped"
    STRUCTURE_STATUS="SKIPPED"
fi
echo ""

# 2. Only one workflow builds and pushes the images
BUILD_WORKFLOWS=()
for file in "${WORKFLOWS[@]}"; do
    if grep -Eq 'scripts/build-images\.sh|docker/build-push-action|docker buildx build' "$file"; then
        BUILD_WORKFLOWS+=("$file")
    fi
done

echo "🏗️  Workflows that build the images (${#BUILD_WORKFLOWS[@]}):"
for file in "${BUILD_WORKFLOWS[@]}"; do
    echo "  - $file"
done

if [ "${#BUILD_WORKFLOWS[@]}" -eq 1 ]; then
    echo "✅ Exactly one workflow builds the images"
    BUILD_STATUS="PASS"
else
    echo "❌ Expected exactly one image-building workflow, found ${#BUILD_WORKFLOWS[@]}"
    echo "⚠️  More than one causes duplicate builds and cost overruns; none means no images are published"
    BUILD_STATUS="FAIL"
fi
echo ""

# Informational: workflows active on GitHub
if command -v gh >/dev/null 2>&1; then
    GITHUB_WORKFLOWS=$(gh api repos/Alteriom/alteriom-docker-images/actions/workflows --jq '.workflows[] | select(.state == "active") | "\(.name) (\(.path))"' 2>/dev/null || echo "")
    if [ -n "$GITHUB_WORKFLOWS" ]; then
        echo "🌐 Active GitHub workflows (for information):"
        echo "$GITHUB_WORKFLOWS" | sed 's/^/  - /'
        echo ""
    fi
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 VALIDATION SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Workflow structure:     $STRUCTURE_STATUS (${#WORKFLOWS[@]} files)"
echo "Image-building workflow: $BUILD_STATUS (${#BUILD_WORKFLOWS[@]} found)"

if [ "$STRUCTURE_STATUS" != "FAIL" ] && [ "$BUILD_STATUS" = "PASS" ]; then
    echo ""
    echo "🎉 OVERALL STATUS: ✅ VALIDATION PASSED"
    exit 0
else
    echo ""
    echo "🚨 OVERALL STATUS: ❌ VALIDATION FAILED"
    exit 1
fi
