# 01_reproduce — reproduce the reported defect

One job: turn the report into something that fails on demand, for the reason reported.

## Inputs
- Working (this run): the report — read whole with what it links: an issue, a red workflow run (`gh run view <id> --log-failed`), a firmware build log from a consumer, a scan finding.
- Reference (every run): `.github/icm/_shared/architecture.md`
- Reference (every run): `.github/icm/_shared/build-and-test.md`
- Reference (every run): `.github/icm/_shared/gotchas.md`
- Reference (only when the report is about a published tag, a pull, or a red run on `main`): `.github/icm/_shared/publishing.md`

Do NOT load: the other pipelines, other runs' output, `docs/admin/`, `docs/migration/`, `docs/security/`.

## Process
1. Restate the report as observed versus expected: the image (`builder` or `dev`), the tag and its digest if known, the platform (`amd64` or `arm64`), the target board, and the command that failed.
2. Check [gotchas.md](../../../_shared/gotchas.md) first: a red push run on `main` from the badge step, an upper-case image reference, a volume owned by another UID and the SCons pin each look like new defects.
3. Classify: image build (a Dockerfile step fails), image content (a firmware build fails inside a good image), runtime (entrypoint, user, permissions), script, or workflow.
4. Reproduce at that level ([build-and-test.md](../../../_shared/build-and-test.md)): `docker build` of the Dockerfile; the failing `tests/` project or a minimal PlatformIO project run in the reported tag; the script with the reported arguments; for a workflow, the failed step's log quoted with its run id.
5. Keep the failing output. If nothing fails, the reproduction or the report is wrong: say which, and stop.

## Outputs
- reproduction.md → output/ — the restated report; image, tag, platform and board; the class; the command; the failing output; what this reproduction does not cover (for example the other architecture, or the registry state).

## Human check
A person runs the command, or reads the quoted log, and confirms it fails for the reported reason and not a neighbouring one.
