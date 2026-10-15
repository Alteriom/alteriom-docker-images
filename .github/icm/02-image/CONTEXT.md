# 02-image — the pipeline

Decide the change and its version, make it in both images, prove it the way CI will, and confirm what the merge published.

| Stage | Job | Input | Output | Human check |
|---|---|---|---|---|
| [`01_scope`](stages/01_scope/CONTEXT.md) | the change and its version | the request | `output/scope.md` | A person reads `scope.md` and approves the change and the version number, or names a different one; nothing is edited before that. |
| [`02_change`](stages/02_change/CONTEXT.md) | change and test locally | 01_scope's `scope.md` | `output/change.md` | A person reads the diff and the test output beside `scope.md`: the change is the approved one, both images moved together where they should, and the tests ran on the local images. |
| [`03_verify`](stages/03_verify/CONTEXT.md) | checks and the pull request | 02_change's `change.md` | `output/pull-request.md` | A reviewer reads `pull-request.md` and the CI result and decides whether to merge, knowing the merge pushes `latest` to every consumer; nothing is published until that person merges. |
| [`04_publish`](stages/04_publish/CONTEXT.md) | confirm what the workflow published | 03_verify's `pull-request.md` | `output/publish.md` | A person reads `publish.md`, pulls `builder:latest` once, and decides whether anything skipped must be finished by hand. |
