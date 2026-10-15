# 03-deps — review a dependency bump

One run is one Dependabot pull request: an npm package (`dotenv`, the metadata compliance tool and its dependencies) or a GitHub Action the workflows use. Reviewed against what this repository uses of it, checked in CI, recommended to a person. Pull requests #54, #55, #56, #57, #59, #60 and #62 were runs of this job.

Stages, in order; inputs, outputs and checks for each are in [CONTEXT.md](CONTEXT.md):

1. [Review](stages/01_review/CONTEXT.md) — what moved, what it touches, what CI says, and a recommendation.

A bump of the base image, PlatformIO or a pip pin is not Dependabot's: that is the `image` route.
