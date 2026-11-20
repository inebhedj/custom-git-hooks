# Contributing

## Tests

```sh
sh tests/run.sh               # all tests
sh tests/run.sh commit_msg    # one file: commit_msg, pre_commit, post_merge, dispatch, install, check, cli
```

The tests need only `git` and a POSIX shell; each runs in a fresh temporary repository and never touches your own git configuration.

The CI workflow additionally runs `shellcheck` and checks the scripts with `dash`. It is **manual only** (Actions tab → CI → "Run workflow") and never starts on push or pull request. The same goes for the publish workflow, which starts only when you publish a GitHub Release.

## Layout

- `install.sh`: the installer
- `bin/cgh`: command line (also used from npm)
- `payload/`: what gets copied into the project: `_dispatch`, `lib.sh`, `cgh-check`, `cgh.conf`, `hooks.d/`
- `templates/`: workflows to copy into other projects (not active here)
- `tests/`: the tests
- `.github/workflows/`: `ci.yml` (manual only) and `publish.yml` (npm release, see below)

## Releasing a new version

The version is a three-part number (for example `3.0.0`) and it has to be the same in `VERSION.md` and in `package.json`. The tag is `v` + the version (`v3.0.0`). The workflow `publish.yml` checks all three before it publishes.

1. Set the new version in `VERSION.md` and in `package.json`, commit and push:

   ```sh
   git commit -am "NOJIRA: Releasing version 3.1.0"
   git push
   ```

2. Tag the commit and publish a GitHub Release for the tag. That starts the npm publish:

   ```sh
   git tag v3.1.0
   git push origin v3.1.0
   gh release create v3.1.0 --generate-notes
   ```

   Without the GitHub CLI: repository page → **Releases** → **Draft a new release** → choose the tag → **Publish release**. Follow the run under the **Actions** tab.

The workflow runs `shellcheck` and the tests, and then `npm publish --access public --provenance`. A version cannot be published twice, so always raise the version first.

### One-time setup on npmjs.com

The package is `@inebhedj/ih-cgh`. Publishing uses npm trusted publishing (OIDC), so no npm token or 2FA code is needed:

- Package **Settings** → **Trusted Publisher** → GitHub Actions: owner `inebhedj`, repository `ih-cgh`, workflow filename `publish.yml`. Leave the environment name empty. Check **allow npm publish**; leave **allow npm dist-tag** unchecked.
- **Publishing access** → *Require two-factor authentication and disallow bypass 2fa tokens*.
- The Trusted Publisher shows *Pending validation* until the first successful publish through the workflow.
- Manual fallback (interactive login and 2FA): `npm run publish:npm`.
