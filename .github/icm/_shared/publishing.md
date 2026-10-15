---
verified_at: 2026-10-15
verified_commit: 3d4618bc15b17f0fe481c80791555904c69ba49b
---

# Publishing — what reaches the registry, when, and who pulls it

Only the workflow `.github/workflows/build-and-publish.yml` publishes. A person starts it by merging to `main` or by "Run workflow"; no agent runs `scripts/build-images.sh push` or `dev-only`, pushes a tag or edits a release.

- **Registry path**: `ghcr.io/<owner in lower case>/alteriom-docker-images/{builder,dev}`, unless the repository variable `DOCKER_REPOSITORY` overrides it (`.github/workflows/build-and-publish.yml:287-299`). Platforms: `linux/amd64,linux/arm64` (`.github/workflows/build-and-publish.yml:17`).
- **A push to `main`** that is not documentation only (the file classes are at `.github/workflows/build-and-publish.yml:345-361`; anything unlisted counts as build-related) builds and pushes both images as `latest`, `<VERSION>` and `<YYYYMMDD>` (`.github/workflows/build-and-publish.yml:414-426`, `scripts/build-images.sh:157-161`, `scripts/build-images.sh:249-255`), increments `BUILD_NUMBER` and the README badge with a bot commit (`.github/workflows/build-and-publish.yml:446-495`), runs the ESP build test against `latest`, and creates or updates the GitHub release `v<VERSION>` (`.github/workflows/build-and-publish.yml:730-743`). Today the bot commit is refused and the run stops there ([gotchas.md](gotchas.md)).
- **A manual run** on `main` does the same build and release, without the badge step (`.github/workflows/build-and-publish.yml:403-426`).
- **The daily schedule** (02:00 UTC, `.github/workflows/build-and-publish.yml:10-12`) runs `scripts/audit-packages.sh`; when it recommends a build, only `dev` is pushed, as `latest`, `<VERSION>-dev-build.<BUILD_NUMBER>` and `build.<BUILD_NUMBER>` (`.github/workflows/build-and-publish.yml:375-401`, `scripts/build-images.sh:48-60`, `scripts/build-images.sh:138-154`).
- **The version** is `VERSION`, bumped by hand in the pull request with a `CHANGELOG.md` entry; automatic version bumping is disabled (`.github/workflows/build-and-publish.yml:301-307`, pull request #49). A build-related merge that does not bump `VERSION` re-pushes `builder:<VERSION>` and `dev:<VERSION>` over the existing tags and edits the existing release.
- **Consumers** pull `builder:latest`: Alteriom's firmware CI runs inside it (Alteriom/alteriom-firmware), and users follow [README.md](../../../README.md), "Quick Start for Users". A change to `latest` reaches them on their next run, with no pin to hold it back.
- **Confirming a publish**: `gh run list --repo Alteriom/alteriom-docker-images --branch main --limit 5`; the run's "Build and Push Images" and "Image Summary" steps (`.github/workflows/build-and-publish.yml:769`); `gh release view v<VERSION> --repo Alteriom/alteriom-docker-images`; `docker pull` of each tag, then `docker run --rm <image> --version`.
