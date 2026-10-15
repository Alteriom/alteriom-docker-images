---
verified_at: 2026-10-15
verified_commit: 3d4618bc15b17f0fe481c80791555904c69ba49b
---

# Documents — what a contributor reads, and who owns its facts

The agent-facing files are `AGENTS.md` (the entry) and this `_shared/` folder; `.github/copilot-instructions.md` points back to them. The documents below are read by people. Each restates facts that a Dockerfile, a script or the workflow owns, and the owner is right when they disagree.

## Pinned

| Document | What it answers | Owner of the facts | Last changed |
|---|---|---|---|
| [README.md](../../../README.md) | what the images are, how to pull and run them, the CI summary | the Dockerfiles, `.github/workflows/build-and-publish.yml` | 2025-12-11 |
| [CONTRIBUTING.md](../../../CONTRIBUTING.md) | branches, commits, testing and pull request expectations | itself for conventions; `scripts/` for the commands | 2025-08-27 |
| [CHANGELOG.md](../../../CHANGELOG.md) | what each image version changed, breaking changes, migrations | itself | 2025-11-19 |
| [tests/README.md](../../../tests/README.md) | the four ESP test projects and how the build test runs them | `scripts/test-esp-builds.sh`, `tests/` | 2025-11-16 |
| [docs/development/SCRIPTS_GUIDE.md](../../../docs/development/SCRIPTS_GUIDE.md) | what each script does, its arguments and how long it takes | `scripts/` | 2025-10-09 |
| [docs/guides/USER_INSTALLATION_GUIDE.md](../../../docs/guides/USER_INSTALLATION_GUIDE.md) | installing Docker, pulling the images, building a project with them | the Dockerfiles | 2025-11-18 |
| [docs/guides/PERSISTENT_VOLUMES.md](../../../docs/guides/PERSISTENT_VOLUMES.md) | caching PlatformIO in a volume, `--user root`, ownership repair | `production/docker-entrypoint.sh` | 2025-11-18 |
| [docs/fixes/SCONS_UNBOUNDLOCALERROR_FIX.md](../../../docs/fixes/SCONS_UNBOUNDLOCALERROR_FIX.md) | why PlatformIO is pinned where it is | `production/Dockerfile`, `CHANGELOG.md` | 2025-11-16 |
| [docs/development/METADATA_MANAGER.md](../../../docs/development/METADATA_MANAGER.md) | what the metadata compliance check does here | `.github/workflows/compliance.yml`, `package.json` | 2025-08-28 |

## Not pinned, on purpose

- `docs/admin/`, `docs/migration/` and `docs/security/` record one-off audits, migrations and security work from 2025; they are history, read only when a run needs the reasoning behind a past change. `SECURITY.md` is the reporting policy.
- `docs/README.md`, `docs/index.md`, `.github/DOCUMENTATION.md` and `docs/DOCUMENTATION_SUMMARY.md` are indexes of the above.

## Known drift

| Where | What it says | What is true, and who owns it |
|---|---|---|
| `README.md:279`, `docs/development/AUTOMATED_VERSIONING.md`, `docs/development/VERSION_CONTROL.md:13` | versions bump automatically from commit messages on merge | disabled since pull request #49 (`.github/workflows/build-and-publish.yml:301-307`); `VERSION` is bumped by hand ([publishing.md](publishing.md)) |
| `README.md:250`, `docs/FAQ.md:283` | PlatformIO 6.1.13 | 6.1.15 (`production/Dockerfile:48`, `development/Dockerfile:51`) |
| `tests/README.md:91` | the fix was the upgrade to PlatformIO 6.1.16 | 6.1.16 caused the failure and 1.8.12 went back to 6.1.15 (`CHANGELOG.md`, "1.8.12") |
| `README.md:132`, `docs/FAQ.md:117`, `docs/QUICK_REFERENCE.md:187`, `docs/guides/USER_INSTALLATION_GUIDE.md:268` | a workflow named "Build and Publish Docker Images" | it is named "ESP32/ESP8266 Docker Pipeline - Build & Security Validation" (`.github/workflows/build-and-publish.yml:1`) |
| `CONTRIBUTING.md:176`, `docs/development/SCRIPTS_GUIDE.md:213` | only one workflow may exist; `validate-workflows.sh` passes | there are three, and the script fails ([gotchas.md](gotchas.md)) |
| the former `.github/copilot-instructions.md`, replaced in the pull request that added this workspace | versions, PlatformIO pin, entrypoint, image references | listed with evidence in that pull request; the owners are the files this folder points at |
