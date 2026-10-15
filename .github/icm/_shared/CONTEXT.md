# Shared reference

What every job on this repository draws on. Each file points at the repository file that owns a fact; follow the pointer for the detail, and when the two disagree the owning file is right.

| File | Answers |
|---|---|
| [architecture.md](architecture.md) | the two images, what each installs, the entrypoint, the scripts and the test projects |
| [build-and-test.md](build-and-test.md) | how to build and test an image locally, and what CI runs on a pull request |
| [publishing.md](publishing.md) | what a merge, the daily schedule and a manual run publish, with which tags, and who consumes them |
| [conventions.md](conventions.md) | branches, commits, the changelog, the version, reviews, the metadata compliance check |
| [gotchas.md](gotchas.md) | traps that have already cost a broken build, a red `main` or a wrong instruction |
| [documents.md](documents.md) | the documents of this repository, which are pinned, and where they have drifted |

Each stage's contract names the files it loads.
