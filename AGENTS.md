# alteriom-docker-images

Alteriom's PlatformIO builder images for ESP32, ESP32-S3, ESP32-C3 and ESP8266 firmware: `builder` (minimal, `production/`) and `dev` (with editors and `twine`, `development/`), both published to GitHub Container Registry for `linux/amd64` and `linux/arm64`. Firmware CI elsewhere in the organisation runs inside `builder:latest`, so a merge here changes other repositories' builds. What leaves here is a reviewed pull request on `main`; the merge itself builds and pushes the images, and no agent pushes an image or a tag.

## Where things live

| Path | What it holds |
|---|---|
| `production/`, `development/` | one `Dockerfile` and `docker-entrypoint.sh` per image — mapped in [architecture.md](.github/icm/_shared/architecture.md) |
| `scripts/` | build and push (`build-images.sh`), ESP build tests, image checks, the daily package audit, security scanners |
| `tests/` | four PlatformIO projects the ESP build test compiles inside each image |
| `VERSION`, `BUILD_NUMBER`, `CHANGELOG.md` | the image version every tag and release carries, the daily build counter, what changed |
| `.github/workflows/` | the build-and-publish pipeline, the metadata compliance check, `ICM check` |
| `docs/` | user, admin, security and history documents; see [documents.md](.github/icm/_shared/documents.md) for which are current |
| `.github/copilot-instructions.md` | GitHub Copilot's file: points back here |
| [`.github/icm/_shared/`](.github/icm/_shared/CONTEXT.md) | what every job below draws on, one file per question |
| [`.github/icm/01-fix/`](.github/icm/01-fix/CLAUDE.md) | fix an image that fails a build, a script or a scan |
| [`.github/icm/02-image/`](.github/icm/02-image/CLAUDE.md) | change an image or cut a version, and confirm what the merge published |
| [`.github/icm/03-deps/`](.github/icm/03-deps/CLAUDE.md) | review a Dependabot pull request |

## Route by what just happened

| Route | If | Go to | Then stop at |
|---|---|---|---|
| triage | an issue or report arrives and its kind is unclear | read it whole (`gh issue view <n> --comments`) and take the row below that fits | the row chosen, said to the person |
| fix | an image fails to build, a firmware build fails inside an image, a pull fails, or a script or scan reports a defect | [01_reproduce](.github/icm/01-fix/stages/01_reproduce/CONTEXT.md) | a person has seen the reproduction fail |
| ci-red | the build-and-publish or compliance workflow is red on `main` or on a pull request | [01_reproduce](.github/icm/01-fix/stages/01_reproduce/CONTEXT.md), with the run log as the report | a person has seen the reproduction fail |
| image | a tool, platform, base image or PlatformIO version is to change in an image | [01_scope](.github/icm/02-image/stages/01_scope/CONTEXT.md) | a person approves the scope and the version |
| version | a new image version is to be cut | [01_scope](.github/icm/02-image/stages/01_scope/CONTEXT.md), with the unreleased `CHANGELOG.md` entries as the request | a person approves the scope and the version |
| fix-to-image | a fix turns out to need a new tool, a version pin change or a new version | [01_scope](.github/icm/02-image/stages/01_scope/CONTEXT.md), with the fix run's `reproduction.md` as the request | a person approves the scope and the version |
| publish-check | a pull request merged to `main`, or a person ran the workflow by hand, and the published images must be confirmed | [04_publish](.github/icm/02-image/stages/04_publish/CONTEXT.md), with the run as the input | a person has seen the tags and the run |
| deps | Dependabot opened a pull request | [01_review](.github/icm/03-deps/stages/01_review/CONTEXT.md) | a person decides to merge it or not |
| next | a stage's output was approved | the next numbered stage of the same job | a person reads that stage's output |
| status | asked for status | scan `.github/icm/*/stages/*/output/` | report what exists |

## Agents connecting remotely

This repository is the MemoryRelay workspace `alteriom-docker-images`, which a person creates from this repository's `main`; the Alteriom hub `portfolio` delegates to it once both exist. Until the workspace exists, an agent reads these files on a clone. An agent on a clone needs nothing: this file is the entry and the table above is the route. An agent that is not on a clone reaches the same files over MCP at `https://api.memoryrelay.net/mcp` through the `alteriom-docker-images` workspace, with a key in `MEMORYRELAY_API_KEY` (Claude Code, Codex) or as a connector that signs in (claude.ai, Claude Desktop). None of it holds a secret.

- Start with `icm_context_build` for the route that fits, not with the whole repository: a route is a few thousand tokens.
- Report what you read with `icm_report_reads` when a stage ends, and what the task came to with `icm_report_outcome`.
- Never write through MCP: a change is a branch and a pull request here, read and merged by a person.

## Rules

- Nothing moves to the next stage until a person has read the output of the last one.
- A stage writes to its own `output/`, which is not committed: one run per worktree or branch, and clear that job's `stages/*/output/` when its pull request merges or is abandoned.
- A job reads only its own run's output; moving to another job is a route above, started by the person.
- No agent pushes an image, a tag or a release, or runs `scripts/build-images.sh push`: the workflow does that when a person merges or dispatches it ([publishing.md](.github/icm/_shared/publishing.md)).
- `.github/icm/` points at the files that own each fact. When they disagree, the owning file is right: correct `.github/icm/` in the same pull request, and bump its `verified_commit`.
