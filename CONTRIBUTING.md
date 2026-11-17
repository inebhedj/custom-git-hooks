# Contributing

## Tests

```sh
sh tests/run.sh               # all tests
sh tests/run.sh commit_msg    # one file: commit_msg, pre_commit, post_merge, dispatch, install, check, cli
```

The tests need only `git` and a POSIX shell; each runs in a fresh temporary repository and never touches your own git configuration.

The CI workflow additionally runs `shellcheck` and checks the scripts with `dash`. It is **manual only** (Actions tab → CI → "Run workflow") and never starts on push or pull request.

## Layout

- `install.sh`: the installer
- `bin/cgh`: command line (also used from npm)
- `payload/`: what gets copied into the project: `_dispatch`, `lib.sh`, `cgh-check`, `cgh.conf`, `hooks.d/`
- `templates/`: workflows to copy into other projects (not active here)
- `tests/`: the tests
- `.github/workflows/`: manual only

## Version of this repository

The version is the number in `VERSION.md` (for example `3`). `package.json` needs the same number as a three-part version (`3.0.0`, npm accepts nothing else). Set both by hand, commit, and put the tag `v` + the number on the commit:

```sh
git commit -am "NOJIRA: Releasing version 3"
git tag v3
git push
git push origin v3
```
