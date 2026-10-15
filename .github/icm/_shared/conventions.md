---
verified_at: 2026-10-15
verified_commit: 4eb7f0f7dcc234d37bb20ea76a77ca0473249c82
---

# Conventions — branches, commits, versions, reviews

- Branches `fix/`, `feature/`, `docs/`, `docker/`, `security/` and Conventional Commit messages (`feat`, `fix`, `docs`, `security`, `perf`, `test`, `ci`, `chore`) ([CONTRIBUTING.md](../../../CONTRIBUTING.md), "Development Workflow"). Dependabot uses `chore(deps)` (`.github/dependabot.yml`).
- Every pull request targets `main`, which is protected: no direct push, including the workflow's own bot commit ([gotchas.md](gotchas.md)). `@Alteriom/alteriom-team` owns every path (`.github/CODEOWNERS`). The pull request template is `.github/PULL_REQUEST_TEMPLATE.md` (the lower-case duplicate was removed in #67; two names differing only by case collide on Windows checkouts).
- A change to an image adds an entry under "Unreleased" in `CHANGELOG.md` (Keep a Changelog, semantic versions); cutting a version moves those entries under the new number and sets `VERSION` to it in the same pull request ([CONTRIBUTING.md](../../../CONTRIBUTING.md), "Version Documentation"; [publishing.md](publishing.md)). A change users must act on, such as the 1.8.11 move to a non-root user, gets a "BREAKING CHANGES" section and a migration note (`CHANGELOG.md`, "1.8.11").
- Every version pin in a Dockerfile carries a comment saying why (`production/Dockerfile:30-36`); keep the two Dockerfiles' pins equal.
- The metadata compliance check (`.github/workflows/compliance.yml`) runs `repo-manager` from `@alteriom/repository-metadata-manager` (`package.json`, "scripts" and "devDependencies"; [docs/development/METADATA_MANAGER.md](../../../docs/development/METADATA_MANAGER.md)); on a push to `main` it applies fixes to the repository's GitHub metadata with the workflow token.
- Security reports follow `SECURITY.md`; never commit a credential (`.gitignore` ignores `.env`; `.env.example` holds placeholders only).
