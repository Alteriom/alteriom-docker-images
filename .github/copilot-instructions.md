# GitHub Copilot instructions — alteriom-docker-images

The entry for this repository, for every agent, is [AGENTS.md](../AGENTS.md): what the repository is, where things live, and the route to take for what just happened. Each route names the stage contract to follow and the shared facts in [`.github/icm/_shared/`](icm/_shared/CONTEXT.md) to load. Read those instead of restating them here; when this file and a file it points at disagree, the file pointed at is right.

What is specific to Copilot:

- **Long commands.** Image builds and the ESP build test run for many minutes and can sit silent while toolchains download; set the tool timeout well above the times in [docs/development/SCRIPTS_GUIDE.md](../docs/development/SCRIPTS_GUIDE.md) and never cancel a build or a workflow run part-way.
- **No publishing.** Never run `scripts/build-images.sh push` or `dev-only`, push a tag or edit a release. A pull request on `main`, merged by a person, is the only way an image is published ([publishing.md](icm/_shared/publishing.md)).
- **Network.** The coding agent's firewall must allow the hosts in [docs/guides/FIREWALL_CONFIGURATION.md](../docs/guides/FIREWALL_CONFIGURATION.md) for builds and ESP platform downloads to work; a blocked host looks like a hung or failing build.
- **Start here:** [build-and-test.md](icm/_shared/build-and-test.md) for commands, [gotchas.md](icm/_shared/gotchas.md) before calling something a new defect.
