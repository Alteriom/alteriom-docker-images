# 02_change — change and test locally

One job: make the approved change in the repository and show both images build and work.

## Inputs
- Working (this run): `.github/icm/02-image/stages/01_scope/output/scope.md`
- Reference (every run): `.github/icm/_shared/architecture.md`
- Reference (every run): `.github/icm/_shared/build-and-test.md`
- Reference (every run): `.github/icm/_shared/conventions.md`

Do NOT load: the other pipelines, other runs' output.

## Process
1. Edit the Dockerfiles named in the scope; keep the two images' shared lines and pins equal, and a comment beside each pin saying why ([conventions.md](../../../_shared/conventions.md)).
2. Add the `CHANGELOG.md` entry. For a version cut, move "Unreleased" under the approved number with today's date and set `VERSION` to it; nothing else writes `VERSION`.
3. Update a document only where the change makes it wrong (`README.md`, the user guide, `docs/development/SCRIPTS_GUIDE.md`).
4. Build both images locally without pushing, run `--version` in each, and run the tests the scope listed ([build-and-test.md](../../../_shared/build-and-test.md)). Record the image sizes beside those of the current `latest` when size was in scope.

## Outputs
- change.md → output/ — the files changed and why each; the version; the commands run and their output; sizes if measured; anything the scope did not foresee.

## Human check
A person reads the diff and the test output beside `scope.md`: the change is the approved one, both images moved together where they should, and the tests ran on the local images.
