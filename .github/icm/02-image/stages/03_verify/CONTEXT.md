# 03_verify — checks and the pull request

One job: propose the change and get the pull request's checks green.

## Inputs
- Working (this run): `.github/icm/02-image/stages/02_change/output/change.md`
- Reference (every run): `.github/icm/_shared/build-and-test.md`
- Reference (every run): `.github/icm/_shared/publishing.md`
- Reference (every run): `.github/icm/_shared/conventions.md`

Do NOT load: the other pipelines, other runs' output.

## Process
1. Branch from `main` (`docker/<short-name>`, or `feature/` or `security/` as fits), commit as `feat:`, `fix:`, `security:` or `chore:` ([conventions.md](../../../_shared/conventions.md)).
2. Open the pull request with `gh pr create --base main`: the scope, the change, the test output, the version, and what the merge publishes ([publishing.md](../../../_shared/publishing.md)): both images as `latest`, `<VERSION>` and the date tag, and the release `v<VERSION>`.
3. Wait for the checks: the security scans, Hadolint, the local build and ESP build test, the metadata check ([build-and-test.md](../../../_shared/build-and-test.md)). A red run caused by the change is fixed and pushed, never bypassed.

## Outputs
- pull-request.md → output/ — the pull request URL; the CI result per check; the tags and the release the merge will produce; who pulls `latest`.

## Human check
A reviewer reads `pull-request.md` and the CI result and decides whether to merge, knowing the merge pushes `latest` to every consumer; nothing is published until that person merges.
