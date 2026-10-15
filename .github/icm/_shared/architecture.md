---
verified_at: 2026-10-15
verified_commit: 3d4618bc15b17f0fe481c80791555904c69ba49b
---

# Architecture — the two images and what surrounds them

- **`builder`** is built from `production/Dockerfile`: `python:3.11-slim` (`production/Dockerfile:7`), PlatformIO pinned at `production/Dockerfile:48` with the reason for each Python pin in the comment above it (`production/Dockerfile:30-36`), build tools removed in the same layer. ESP platforms are not baked in: PlatformIO downloads them on first use inside the container.
- **`dev`** is built from `development/Dockerfile`: the same base and pins (`development/Dockerfile:6`, `development/Dockerfile:51`) plus `vim`, `less`, `htop` and `twine` (`development/Dockerfile:37-51`).
- Both run as the non-root user `builder` (UID 1000) in `/workspace` (`production/Dockerfile:57-71`, `development/Dockerfile:60-74`), the default since 1.8.11 (`CHANGELOG.md`, "1.8.11"). The entrypoint is `docker-entrypoint.sh`, which fixes volume ownership when the container starts as root and then drops to `builder` before running `platformio` (`production/docker-entrypoint.sh`, `production/Dockerfile:83`). The two images' entrypoints are byte-identical today (`development/docker-entrypoint.sh`); a change to one is a change to both.
- The image version comes from `VERSION` and is passed as the `VERSION` build argument; the `ARG VERSION` default in each Dockerfile is only a fallback (`scripts/build-images.sh:31-36`, `scripts/build-images.sh:157-161`).
- `scripts/` holds the build helper (`scripts/build-images.sh`), the ESP build test (`scripts/test-esp-builds.sh`), image checks (`scripts/verify-images.sh`, `scripts/status-check.sh`), the daily package audit (`scripts/audit-packages.sh`) and the security scanners the workflow runs; [docs/development/SCRIPTS_GUIDE.md](../../../docs/development/SCRIPTS_GUIDE.md) describes each.
- `tests/` holds one PlatformIO project per target (ESP32, ESP32-S3, ESP32-C3, ESP8266) that the ESP build test compiles inside an image (`scripts/test-esp-builds.sh:35-41`, [tests/README.md](../../../tests/README.md)).
- `package.json` exists only to run the organisation's metadata compliance tool (`package.json`, "scripts"); nothing in the images uses Node.
