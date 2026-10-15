# 03-deps — the pipeline

Read the bump against what uses it, read CI, recommend; a person merges, and a merge that touches a workflow or `package.json` rebuilds and pushes the images.

| Stage | Job | Input | Output | Human check |
|---|---|---|---|---|
| [`01_review`](stages/01_review/CONTEXT.md) | review the bump | the pull request | `output/review.md` | A person reads `review.md` and the CI result and decides to merge, hold or close the pull request. |
