# 03_verify — checks and the pull request

One job: prove the fix the way CI will, and propose it.

## Inputs
- Working (this run): `.github/icm/01-fix/stages/02_fix/output/change.md`
- Reference (every run): `.github/icm/_shared/build-and-test.md`
- Reference (every run): `.github/icm/_shared/publishing.md`
- Reference (every run): `.github/icm/_shared/conventions.md`

Do NOT load: the other pipelines, other runs' output.

## Process
1. Build both images locally without pushing and run the ESP build test on the `:local` tags ([build-and-test.md](../../../_shared/build-and-test.md)); run `scripts/test-persistent-volumes.sh` when the entrypoint or the user moved. Never run `scripts/build-images.sh push` or `dev-only`.
2. Branch from `main` (`fix/<short-name>`), commit as `fix: <what>` ([conventions.md](../../../_shared/conventions.md)).
3. Open the pull request with `gh pr create --base main`: the defect, the cause, the change, the test output, and what the merge publishes ([publishing.md](../../../_shared/publishing.md)): both images as `latest`, and over `<VERSION>` unless `VERSION` moved.
4. Wait for the pull request's checks; a red run caused by the change is fixed and pushed, never bypassed.

## Outputs
- pull-request.md → output/ — the pull request URL; the commands run here and their output; the CI result; the tags the merge will push and the consumers who will pull them.

## Human check
A reviewer reads `pull-request.md` and the CI result, then merges knowing the merge pushes `builder:latest` to every consumer; afterwards the same person starts the `publish-check` route.
