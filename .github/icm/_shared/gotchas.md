---
verified_at: 2026-10-15
verified_commit: 3d4618bc15b17f0fe481c80791555904c69ba49b
---

# Gotchas — traps that have already cost something

- **`main` goes red on every build-related merge.** "Update Development Badge" pushes a bot commit to protected `main` and is refused (GH006), so "Build, Deploy & Service Validation" fails after the images were already pushed, and the later steps (ESP build test against `latest`, release notes, the release) are skipped (`.github/workflows/build-and-publish.yml:446-495`; the push runs of 2026-08-26 and 2026-08-29). A red push run does not mean nothing was published: read its "Build and Push Images" step.
- **Almost any file is build-related.** Only `*.md`, `*.txt`, `*.rst`, `LICENSE`, `docs/`, `.gitignore` and the issue and pull request templates count as documentation (`.github/workflows/build-and-publish.yml:345-361`). `package.json`, `.github/icm/icm.source.json` and any workflow file make the merge rebuild and push both images.
- **PlatformIO is pinned below the newest release on purpose.** PlatformIO 6.1.16 ships SCons 4.8.1, which fails with `UnboundLocalError` under Python 3.11; 6.1.15 (SCons 4.7.0) does not (`production/Dockerfile:32-35`, `CHANGELOG.md` "1.8.12", [docs/fixes/SCONS_UNBOUNDLOCALERROR_FIX.md](../../../docs/fixes/SCONS_UNBOUNDLOCALERROR_FIX.md)). A PlatformIO bump is the `image` route with the ESP build test and `scripts/test-auto-clean.sh`, never a one-line change.
- **Image references are lower case.** The workflow lower-cases the owner (`.github/workflows/build-and-publish.yml:294-297`); the defaults inside `scripts/test-esp-builds.sh:10` and `scripts/audit-packages.sh:11` keep an upper-case owner, which Docker rejects as a reference, so export `DOCKER_REPOSITORY` in lower case before running them locally.
- **The containers start as `builder`, not root.** Mounted volumes owned by another UID need `--user root` so the entrypoint can fix ownership before dropping privileges ([docs/guides/PERSISTENT_VOLUMES.md](../../../docs/guides/PERSISTENT_VOLUMES.md), `production/docker-entrypoint.sh`).
- **`scripts/validate-workflows.sh` fails today.** It expects exactly one workflow file (`scripts/validate-workflows.sh:13-25`), and `compliance.yml` has sat beside `build-and-publish.yml` since pull request #11, with `icm-check.yml` now a third. No CI job runs it; do not delete a workflow to satisfy it.
- **Dependabot does not watch the Dockerfiles.** It covers npm and GitHub Actions only (`.github/dependabot.yml`); the base image, PlatformIO and pip pins move by hand through the `image` route.
