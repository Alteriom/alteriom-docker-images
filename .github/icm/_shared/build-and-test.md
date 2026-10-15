---
verified_at: 2026-10-15
verified_commit: 3d4618bc15b17f0fe481c80791555904c69ba49b
---

# Build and test — locally, and what CI runs on a pull request

- **Local build, no push**: `DOCKER_REPOSITORY` must be set (`scripts/build-images.sh:19-23`), in lower case; with no argument the script builds both images as `<repo>/builder:local` and `<repo>/dev:local` and pushes nothing (`scripts/build-images.sh:262-269`). One image: `docker build -t test-prod production/` then `docker run --rm test-prod --version`. Builds are long; never cancel one ([docs/development/SCRIPTS_GUIDE.md](../../../docs/development/SCRIPTS_GUIDE.md), "build-images.sh").
- **ESP build test**: `./scripts/test-esp-builds.sh <builder image> <dev image>` compiles the four `tests/` projects in each image given (`scripts/test-esp-builds.sh:35-41`); pass the `:local` tags after a local build, as CI does on a pull request (`.github/workflows/build-and-publish.yml:537-556`). It needs network access for the platform downloads.
- **Other checks a change may call for**: `scripts/test-persistent-volumes.sh` (entrypoint or user changes), `scripts/test-auto-clean.sh` (the SCons regression, [tests/README.md](../../../tests/README.md)), `scripts/verify-images.sh` and `scripts/status-check.sh` (published images).
- **On a pull request to `main`** (`.github/workflows/build-and-publish.yml:3-14`): "Security Validation & Vulnerability Assessment", "Code Analysis & SARIF Integration" (Trivy, Hadolint on both Dockerfiles, a Python dependency scan) and "Build, Deploy & Service Validation", which builds both images locally and runs the ESP build test on them (`.github/workflows/build-and-publish.yml:403-431`). "Repository Metadata Compliance" runs the metadata check and does not block a pull request (`.github/workflows/compliance.yml:34-36`). `ICM check` runs `generate.py --check` when the entry or `.github/icm/` changes (`.github/workflows/icm-check.yml`).
- **The workspace files**: `python .github/icm/_system/generate.py` regenerates `icm.source.json` and the stage tables; `--check` is what `ICM check` runs.
