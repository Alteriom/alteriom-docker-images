# 01-fix — fix an image

One run is one defect in what this repository ships or runs: an image that fails to build, a firmware build that fails inside an image, a pull that fails, a script that misbehaves, or a scan finding on a Dockerfile. Reproduced, fixed at its cause, verified the way CI verifies, proposed as a pull request. Issues #18, #20, #22, #25 and #30 and pull requests #19, #21, #26, #31 and #49 were runs of this job.

Stages, in order; inputs, outputs and checks for each are in [CONTEXT.md](CONTEXT.md):

1. [Reproduce](stages/01_reproduce/CONTEXT.md) — make it fail on purpose, in the image and on the platform it was reported on.
2. [Fix](stages/02_fix/CONTEXT.md) — change the cause, watch the reproduction pass.
3. [Verify](stages/03_verify/CONTEXT.md) — the checks CI runs, and the pull request; the merge publishes.

A fix that needs a new tool, a version pin change or a new image version is the `fix-to-image` route.
