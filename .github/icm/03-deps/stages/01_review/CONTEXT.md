# 01_review — review the bump

One job: decide whether the bump is safe for what uses it, with evidence.

## Inputs
- Working (this run): the pull request — `gh pr view <n> --repo Alteriom/alteriom-docker-images --comments` and its diff.
- Reference (every run): `.github/icm/_shared/build-and-test.md`
- Reference (every run): `.github/icm/_shared/gotchas.md`
- Reference (only when the bump touches `package.json` or `.github/workflows/compliance.yml`): `.github/icm/_shared/conventions.md`

Do NOT load: the other pipelines, other runs' output, the Dockerfiles.

## Process
1. Name each package or action that moved, from and to, and whether it crosses a major version.
2. Find where it is used: `grep` the workflows for the action and the inputs passed to it; for npm, `package.json` and the `npm run metadata:*` steps of `.github/workflows/compliance.yml`.
3. Read the release notes between the two versions for breaking changes in what is used (removed inputs, a new Node runtime, changed defaults).
4. Read the pull request's checks ([build-and-test.md](../../../_shared/build-and-test.md)); an action used only on `main` (badge, release, login and push) is not exercised by a pull request run, so say so.
5. Say what the merge does: a bump in a workflow or in `package.json` is build-related, so the merge rebuilds and pushes both images ([gotchas.md](../../../_shared/gotchas.md)).
6. Recommend merge, hold or close; for a held major, the change it needs.

## Outputs
- review.md → output/ — what moved with versions; where it is used; breaking changes that touch it (or none found, with the notes read); the CI result and what it did not exercise; what the merge publishes; the recommendation.

## Human check
A person reads `review.md` and the CI result and decides to merge, hold or close the pull request.
