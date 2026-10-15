# 04_publish — confirm what the workflow published

One job: after a person merged or ran the workflow, confirm what reached the registry and the releases.

## Inputs
- Working (this run): `.github/icm/02-image/stages/03_verify/output/pull-request.md`
- Reference (every run): `.github/icm/_shared/publishing.md`
- Reference (every run): `.github/icm/_shared/gotchas.md`

Do NOT load: the other pipelines, other runs' output, the Dockerfiles.

## Process
1. A person merges the pull request, or runs the workflow on `main` with "Run workflow". The agent does neither, and never runs `scripts/build-images.sh push`. On the `publish-check` route the input is the run the person names instead of `pull-request.md`.
2. Find the run (`gh run list --repo Alteriom/alteriom-docker-images --branch main --limit 5`) and read "Build and Push Images", "Update Development Badge", "Test ESP Platform Builds" and "Create GitHub Release with Enhanced Notes" ([publishing.md](../../../_shared/publishing.md)). A failure at the badge step is the known one ([gotchas.md](../../../_shared/gotchas.md)): say which later steps were skipped.
3. Confirm the tags: pull `builder` and `dev` at `latest` and `<VERSION>`, and run `--version` in each; compare the digest of `latest` with that of `<VERSION>`.
4. Confirm the release `v<VERSION>` (`gh release view`), or say it was skipped and why.

## Outputs
- publish.md → output/ — the run id and each step's result; the tags pulled with digests and `--version` output; the release state; what a person must still do (re-run the skipped steps, publish the release by hand, tell consumers).

## Human check
A person reads `publish.md`, pulls `builder:latest` once, and decides whether anything skipped must be finished by hand.
