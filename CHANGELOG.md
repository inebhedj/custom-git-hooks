# Changelog

## 3.0.0 (unreleased)

Rewrite. The hooks now live in a versioned `.githooks/` directory of your project, activated with `core.hooksPath`, instead of being copied into `.git/hooks/`. See "Migrating from v1/v2" in the README.

### Added
- `install.sh` with `--dry-run`, `--uninstall`, `--dir`, `--force`; idempotent, keeps `cgh.conf` and your own hooks.
- `payload/_dispatch`: ordered `hooks.d/<hook>/` scripts with correct stdin and arguments, stops at the first failure; `CGH_SKIP`, `CGH_DEBUG`; pre-existing `.git/hooks` hooks keep running.
- Configuration (`cgh.conf`, `git config cgh.*`, `CGH_*`): ticket format, no-ticket token, branch name regex, protected branches.
- `cgh-check` / `cgh check`: the same branch name and commit subject rules for CI.
- `bin/cgh` and `package.json`: `cgh prepare` for npm `prepare` scripts (replaces `postinstall-cgh.js`).
- Workflow templates (`templates/`) for the version bump on merge and for the pull request check.
- Tests (`sh tests/run.sh`) and a manually started CI workflow (shellcheck, dash, Ubuntu and macOS).

- `post-merge/00-version-bump`: the v2 version bump after merging a `-version-major|minor|patch|fix` branch into master / main, rewritten: it looks at the branches at the merged commit instead of all local branches, runs only after `git merge` (not `git pull`), is POSIX sh, and pushes the version commit and the tag together (`git push --atomic`). New settings `version_branches` and `version_push`.

### Changed
- The commit-msg hook changes only the subject line; body and comments are kept (v2 joined everything into one line).
- Protected branches: the commit is rejected when there is no terminal, unless `CGH_ALLOW_PROTECTED=1`.
- Hooks are POSIX sh (no more `[[ ]]` or `${var//}` under `#!/bin/sh`).

### Removed
- `custom-git-hooks-install.sh`, `data/`, `postinstall-cgh.js`, `VERSION.md`.

### Fixed
- The pre-commit hook read the commit message file from `$1`, which a pre-commit hook does not get, so the "Releasing version" exemption never worked.
- The `sed` call that edits `.gitignore` (broken delimiters, BSD `sed -i`); `.gitignore` is not modified any more.
- The `sendmail-validate` typo in the hook list created a useless hook.
