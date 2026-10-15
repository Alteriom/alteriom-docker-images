# 02-image — change an image, cut a version, confirm the publish

One run is one intended change to what the images contain or how they are versioned: a tool added or removed, a platform supported, the base image, PlatformIO or a pip pin moved, or a new `VERSION` cut from the unreleased changelog. Scoped with its version number, changed and tested locally, proposed as a pull request, and, after a person merges it, confirmed in the registry. Pull requests #19, #21, #26 and #31 and the releases v1.8.5 to v1.8.12 were runs of this job.

Stages, in order; inputs, outputs and checks for each are in [CONTEXT.md](CONTEXT.md):

1. [Scope](stages/01_scope/CONTEXT.md) — what changes, for whom, and the version it ships as.
2. [Change](stages/02_change/CONTEXT.md) — the Dockerfiles, `VERSION` and `CHANGELOG.md`, built and tested locally.
3. [Verify](stages/03_verify/CONTEXT.md) — the checks CI runs, and the pull request.
4. [Publish](stages/04_publish/CONTEXT.md) — a person merges or dispatches the workflow; the agent confirms what reached the registry.

No stage pushes an image, a tag or a release: the workflow does, when a person merges or runs it.
