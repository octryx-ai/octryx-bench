# Octryx bench

Small apps and task cases for the Octryx end-to-end bench.

- `coffee/flutter/claude`: a Flutter coffee companion (brews, beans, equipment, water, care).
- `e2e/python` and `e2e/node`: two deliberately small apps with one known bug each (see `e2e/README.md`).

`cases/cases.json` lists the bench cases: the work item (title, description, acceptance criteria), the app folder and
the workflow the case runs. Each case pins its own base branch (`base/<id>-env`, one commit, `base_sha`) with the
exact code it starts from; check out that commit and work inside the case's app folder. Some base branches also hold
sibling apps of the same task (`coffee/web/*`, `coffee/flutter/codex`) as reference material.

The specs and case texts of the Coffee app are in German; the app itself is bilingual (German and English).
