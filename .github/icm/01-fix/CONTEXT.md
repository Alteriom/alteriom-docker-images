# 01-fix — the pipeline

Make it fail, make it pass for the right reason, prove it the way CI will, and remember that the merge pushes `latest`.

| Stage | Job | Input | Output | Human check |
|---|---|---|---|---|
| [`01_reproduce`](stages/01_reproduce/CONTEXT.md) | reproduce the reported defect | the report | `output/reproduction.md` | A person runs the command, or reads the quoted log, and confirms it fails for the reported reason and not a neighbouring one. |
| [`02_fix`](stages/02_fix/CONTEXT.md) | change the cause, not the symptom | 01_reproduce's `reproduction.md` | `output/change.md` | A person reads the diff beside the reproduction: it removes the cause, both images moved together where they should, and nothing a consumer relies on changed silently. Edit `change.md` if the explanation is wrong; stage 03 reads it. |
| [`03_verify`](stages/03_verify/CONTEXT.md) | checks and the pull request | 02_fix's `change.md` | `output/pull-request.md` | A reviewer reads `pull-request.md` and the CI result, then merges knowing the merge pushes `builder:latest` to every consumer; afterwards the same person starts the `publish-check` route. |
