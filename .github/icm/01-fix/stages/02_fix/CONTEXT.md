# 02_fix — change the cause, not the symptom

One job: change what makes the reproduction fail, and watch it pass.

## Inputs
- Working (this run): `.github/icm/01-fix/stages/01_reproduce/output/reproduction.md`
- Reference (every run): `.github/icm/_shared/architecture.md`
- Reference (every run): `.github/icm/_shared/conventions.md`
- Reference (only when the fix touches a version pin, the user or the entrypoint): `.github/icm/_shared/gotchas.md`

Do NOT load: the other pipelines, other runs' output, documents the fix does not touch.

## Process
1. Read the files the reproduction points at whole: the Dockerfile, the entrypoint, the script or the workflow step.
2. Fix the cause. A Dockerfile change goes into both `production/Dockerfile` and `development/Dockerfile` unless it is specific to one image; an entrypoint change goes into both `docker-entrypoint.sh` files ([architecture.md](../../../_shared/architecture.md)). A pin keeps its comment, updated with the reason ([conventions.md](../../../_shared/conventions.md)).
3. If the fix needs a different PlatformIO, base image or tool version, stop and say so: that is the `fix-to-image` route.
4. Run the reproduction again; it passes. Add an entry under "Unreleased" in `CHANGELOG.md`.
5. Note what users of `builder:latest` will see after the merge (a changed tool, a changed user, a changed default).

## Outputs
- change.md → output/ — the cause in one paragraph; the files changed and why each; the reproduction's output now; the changelog entry; what consumers of `latest` will see after the merge.

## Human check
A person reads the diff beside the reproduction: it removes the cause, both images moved together where they should, and nothing a consumer relies on changed silently. Edit `change.md` if the explanation is wrong; stage 03 reads it.
