# 01_scope — the change and its version

One job: say what changes in which image, who notices, and the version it ships as.

## Inputs
- Working (this run): the request — an issue, a person's ask, a fix run's `reproduction.md`, or the "Unreleased" section of `CHANGELOG.md` for a version cut.
- Reference (every run): `.github/icm/_shared/architecture.md`
- Reference (every run): `.github/icm/_shared/publishing.md`
- Reference (every run): `.github/icm/_shared/gotchas.md`

Do NOT load: the other pipelines, other runs' output, `docs/admin/`, `docs/migration/`, `docs/security/`.

## Process
1. Name the change and the image or images it touches (`builder`, `dev`, both).
2. For a version pin (base image, PlatformIO, a pip package): the current pin and its comment, the target, and the upstream release notes between the two; for PlatformIO, the SCons version it bundles ([gotchas.md](../../../_shared/gotchas.md)).
3. Say who notices after the merge: users of `builder:latest` (firmware CI included), image size, the default user, the entrypoint, the ESP platforms supported ([publishing.md](../../../_shared/publishing.md)).
4. Propose the version: `VERSION` now, the next number by semantic versioning (major for a change a consumer must act on), and whether this pull request cuts it or leaves the entry under "Unreleased".
5. List the tests the change needs: the ESP build test always; `scripts/test-persistent-volumes.sh` for the user or the entrypoint; `scripts/test-auto-clean.sh` for PlatformIO.

## Outputs
- scope.md → output/ — the change; the images; pins from and to with the notes read; who notices; the proposed version and why; the tests to run.

## Human check
A person reads `scope.md` and approves the change and the version number, or names a different one; nothing is edited before that.
