# custom-git-hooks

Shared git hooks for JIRA-style workflows:

- **commit-msg:** puts the ticket of the branch name in front of the commit subject (`ABC-123: Fix it`, or `NOJIRA: …`).
- **pre-commit:** checks the branch name (`ABC-123-some-topic` or `NOJIRA-some-topic`) and asks for confirmation before a commit to `master` / `main`.
- **post-merge:** after `git merge` into `master` / `main`, a branch whose name ends with `-version-major|minor|patch|fix` bumps the npm version, tags it and pushes (Node projects).
- **Several scripts per hook:** every hook runs the scripts of its `hooks.d/<hook>/` directory in order, so you can add your own next to ours.

The hooks are copied into **your repository's `.githooks/` directory** and activated with `core.hooksPath`. They are committed with your code, so the whole team runs the same version.

> **Upgrading from v1/v2?** See [Migrating](#migrating-from-v1v2). The old documentation is in [README-v2.md](README-v2.md).

## Install

Run the installer from the repository you want to set up (any clone of this repo will do; there is no need to keep it inside your project):

```sh
git clone git@github.com:inebhedj/custom-git-hooks.git ~/tools/custom-git-hooks   # once
cd /path/to/your/project
sh ~/tools/custom-git-hooks/install.sh
git add .githooks && git commit
```

Teammates only need to enable the committed hooks after cloning (`install.sh` does the same, plus updates):

```sh
git config core.hooksPath .githooks
```

### Node projects (npm)

Instead of cloning, add the package from a **tag** (so every developer gets the same version) and let `npm install` set up the hooks:

```sh
npm install --save-dev github:inebhedj/custom-git-hooks#v3.0.0
```

```json
{
  "scripts": {
    "prepare": "cgh prepare"
  }
}
```

`cgh prepare` installs quietly, does nothing on CI servers (`CI` is set), outside of git repositories or with `CGH_SKIP_INSTALL=1`, and never makes `npm install` fail. Other commands: `cgh install`, `cgh uninstall`, `cgh check`, `cgh version` (`npx cgh help`). Replace `v3.0.0` with a release tag; there is no tag yet, see [Releases](#releases).

### Options

`--dry-run` shows what would happen, `--uninstall` removes everything again, `--dir NAME` uses another directory than `.githooks`, `--force` takes over an existing `core.hooksPath`. Running the installer again updates the hooks; your `cgh.conf` and your own scripts are never overwritten.

## Configuration

`.githooks/cgh.conf` (one `key = value` per line). Every value can also be set with `git config cgh.<key-with-dashes>` or with the environment variable `CGH_<KEY>`, which take precedence.

| key | default | meaning |
|---|---|---|
| `ticket_regex` | `[A-Z][A-Z0-9]+-[0-9]+` | ERE matching a ticket key |
| `no_ticket` | `NOJIRA` | token used when there is no ticket |
| `branch_regex` | `^(<ticket>\|<no_ticket>)-[a-zA-Z0-9-]+$` | ERE every new branch name has to match |
| `protected_branches` | `master main` | space separated globs (`release/*`); `none` protects nothing |
| `version_branches` | `master main` | space separated globs: a merge into these branches can bump the version |
| `version_push` | `yes` | `no`: do not push the version commit and tag |

## What the hooks do

**`commit-msg/00-jira-prefix`**: takes the ticket from the start of the branch name and prepends it to the commit subject. The body and comments are left alone. Nothing happens if the subject already starts with a ticket (a different one only gives a notice), for `fixup!`/`squash!` commits, merges, rebases, cherry-picks and a detached HEAD.

**`pre-commit/00-branch-name`**: a new branch (one without commits of its own) whose name does not match `branch_regex` is rejected, with a suggestion how to rename it. An old branch with a bad name only gets a notice.

**`pre-commit/10-protected-branch`**: asks `Are you sure you want to commit to master? (y/N)`. Without a terminal (IDE, scripts) the commit is rejected, unless you override it explicitly:

```sh
CGH_ALLOW_PROTECTED=1 git commit ...
```

**`post-merge/00-version-bump`**: after a `git merge` into `master` / `main` (see `version_branches`) it looks at the branches that point at the merged commit. If one of them ends with `-version-major`, `-version-minor`, `-version-patch` or `-version-fix` (the highest wins), it runs `npm version` (commit `NOJIRA: Releasing version X`, tag `vX`) and pushes the commit **and** the tag together (`git push --atomic`: both arrive or neither). If the push fails, the commit and tag stay local and the message tells you the command to retry.

```sh
git switch -c ABC-5-new-login-version-minor
git commit -m "..."
git switch master
git merge -
```

It needs a `package.json` and `npm`. It does **not** run after `git pull` (also not when you pull a merge that was made on GitHub; for that see [`templates/release-on-merge.yml`](templates/release-on-merge.yml)) and not for `git merge --squash`.

### Skipping and debugging

- `git commit --no-verify` skips `pre-commit` and `commit-msg` as usual. Client-side hooks can always be bypassed, so enforce important rules in CI as well.
- `CGH_SKIP=1 git ...` skips all custom-git-hooks scripts for one command.
- `CGH_DEBUG=1 git ...` prints every script that is run.

## Adding your own hooks

Put an executable script into `.githooks/hooks.d/<hook-name>/` (for example `.githooks/hooks.d/pre-push/50-tests`) and run `install.sh` again, which creates the missing stub for that hook. Scripts run in lexical order and the first one that fails stops the hook. Files ending in `.sample`, `.backup` or `.disabled` are ignored. A script gets the hook's arguments and its standard input.

A hook that already existed in `.git/hooks/` when you installed keeps running after the custom scripts.

## Checking on the server

Client-side hooks can be skipped, so `install.sh` also puts `.githooks/cgh-check` into your repository (`cgh check` from npm). It checks the branch name and the subject of every commit in `BASE..HEAD` with the same configuration as the hooks:

```sh
sh .githooks/cgh-check --base origin/main --branch "$BRANCH"
```

Exit status 0 means fine, 1 means something is wrong. A ready-to-copy GitHub workflow is in [`templates/check-pull-request.yml`](templates/check-pull-request.yml). The files in `templates/` are **not active**; nothing in this repository starts automatically.

## Releases

The version of this repository is set by hand: write the new number into `VERSION` and into the `version` field of `package.json`, commit, and put a tag `vX.Y.Z` on the commit:

```sh
git commit -am "NOJIRA: Releasing version 3.0.0"
git tag v3.0.0
git push
git push origin v3.0.0
```

For your own projects the version bump is done by the `post-merge` hook (see above) when you merge locally. If you merge pull requests on GitHub instead, [`templates/release-on-merge.yml`](templates/release-on-merge.yml) does the same on the server: a merged branch ending in `-version-minor` (and so on) bumps the version with `npm version`, tags and pushes. Use one of the two, not both.

## Migrating from v1/v2

v1/v2 copied the hooks into `.git/hooks/` and kept the scripts in `.git/hooks/<hook>.d/`. Installing v3 switches to `core.hooksPath`, which makes git ignore `.git/hooks` completely, so:

1. Run `install.sh`. It tells you which old skeleton hooks it found.
2. Scripts you added yourself to `.git/hooks/<hook>.d/` are **not** run any more. Move them to `.githooks/hooks.d/<hook>/` and run `install.sh` again.
3. Delete the old `.git/hooks/*.d` directories and, if you like, the `custom-git-hooks/` lines from your `.gitignore`.
4. The `post-merge` version bump is still there with the same rule (`-version-major|minor|patch|fix` at the end of the merged branch name), with its bugs fixed: it finds the merged branch among the branches at the merged commit (v2 took the list of all local branches), it does not run after `git pull`, it is plain POSIX sh, and it pushes the version commit together with the tag (v2 pushed the tag only). The `postinstall-cgh.js` helper is replaced by `cgh prepare`, see [Node projects](#node-projects-npm).

## Development

```sh
sh tests/run.sh               # all tests
sh tests/run.sh commit_msg    # one file: commit_msg, pre_commit, dispatch, install
```

The tests need only `git` and a POSIX shell; each runs in a fresh temporary repository and never touches your own git configuration. The CI workflow additionally runs `shellcheck` and checks the scripts with `dash`; it is **manual only** (Actions tab → CI → "Run workflow") and never starts on push or pull request.

Layout: `install.sh` (installer), `bin/cgh` (command line / npm), `payload/` (what gets copied into your project: `_dispatch`, `lib.sh`, `cgh-check`, `cgh.conf`, `hooks.d/`), `templates/` (workflows to copy, not active), `tests/`, `.github/workflows/` (manual only).

## License

ISC, see [ISC-LICENSE.md](ISC-LICENSE.md).
