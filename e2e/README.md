# e2e test apps

Two deliberately small apps used by the bench cases `python-*` and `node-*`. Each has one known bug and room for one
small story.

- `python/` — splitbill: split a bill in cents among people (Python 3.9+, pytest).
- `node/` — booklist: list books with paging (Node 20+, built-in `node --test`, no dependencies).

A case starts from its own base branch (`base/<case id>-env`, listed with its commit in `cases/cases.json` on `main`):
check out that commit, work inside the app folder named by the case, and run the commands from the app's
`.octryx/environment.json`.
