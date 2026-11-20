# SKELETON: how to prepare the `ih-doc/` folder of your product

This folder is a complete, working template of the `ih-doc/` folder of a product (a software package) that is published on the **inebhedj.hu** portal. The example product in it is called `ih-foo`.

This guide is written for you if you do **not** have access to the portal's files, documentation or repository. Everything you need to know is in this one file. If you follow it, the portal's maintainer can use your `ih-doc/` as it is, without further questions.

## Contents

1. [How the portal works](#1-how-the-portal-works)
2. [What is in this folder](#2-what-is-in-this-folder)
3. [The work in ten steps](#3-the-work-in-ten-steps)
4. [Your repository root: `package.json`](#4-your-repository-root-packagejson)
5. [`meta.json`](#5-metajson)
6. [`locales/<lang>.json`](#6-localeslangjson)
7. [`page.json`](#7-pagejson)
8. [`content/`: text fragments](#8-content-text-fragments)
9. [`examples/`: code examples](#9-examples-code-examples)
10. [`public/`: icons, logo, scripts, styles, published files](#10-public-icons-logo-scripts-styles-published-files)
11. [`resources/`: logo tools](#11-resources-logo-tools)
12. [`server-checks.json`](#12-server-checksjson)
13. [Handing the product over](#13-handing-the-product-over)
14. [Rules and limits](#14-rules-and-limits)
15. [Build error messages](#15-build-error-messages)
16. [Checklist](#16-checklist)

## 1. How the portal works

- The portal is a static, multilingual website (its languages today: `en` and `hu`). It has a **hub** (the home page, with a catalog of products) and **one documentation page per product**. A product provides its own documentation languages (`supportedLanguages`), so its pages are `/<slug>/<lang>/`; the languages of the portal are independent.
- Your product lives in **its own repository**. The portal includes it as a git submodule and reads exactly two things from it: the repository's `package.json` and the `ih-doc/` folder.
- **A product ships data, never code for the portal.** In `ih-doc/` you write JSON, locale files, small HTML fragments and code examples. The portal decides how everything looks. You cannot ship components or page templates.
- **Everything is checked while the portal is built.** A mistake does not produce a broken page: it stops the build with a message that names your product and the place of the mistake (see section 15). Nothing is published until the build passes.
- Your product's page may run its own scripts and styles and may publish files, but only on your own pages. On the shared surfaces (the catalog on the home page and the catalog window) your product appears only as plain text, checked links and a checked logo.
- The portal itself is served as static files. Your demo may use a backend; the files are only copied (see section 10), and what the web server can run for them is your concern.

### Words used in this guide

| Word            | Meaning                                                                                                          |
| --------------- | ---------------------------------------------------------------------------------------------------------------- |
| slug            | The identifier of your product and the URL segment of its page, for example `ih-foo`.                           |
| locale file     | `locales/<lang>.json`: a flat list of texts, one file per language.                                              |
| key             | The name of a text in the locale file, for example `overview`.                                                   |
| block           | One element of the page structure in `page.json`, for example a paragraph or a table.                            |
| text box        | What a `"text"` block becomes on the page: a box with one text (paragraphs). Its CSS class is `text-box`.        |
| section box     | What a `"section-box"` block becomes on the page: a titled box that holds other blocks. Its CSS class is `section-box`. |
| source          | Where the content of a block comes from: `value`, `key` or `file`.                                               |
| fragment        | A small HTML file in `content/<lang>/` for formatted text.                                                       |
| default language | The product's default language (`defaultLanguage`, or the first entry of `supportedLanguages` when omitted). Every text must exist in the default language; other languages fall back to the default language. |

## 2. What is in this folder

This folder is the template of your `ih-doc/`. Copy its **contents** into the `ih-doc/` folder of your repository (the `SKELETON.md` file and the two `*.snippet` files are for you and are not read by the portal).

```text
SKELETON/
├── SKELETON.md              this guide
├── meta.json                facts about the product: name, links, tags, colors, privacy
├── page.json                the structure of the documentation page
├── server-checks.json       optional checks of the web server's answers ({"checks": []} = no checks)
├── gitmodules.snippet       the lines the maintainer adds to .gitmodules (section 13)
├── products.ts.snippet      the line the maintainer adds to the product list (section 13)
├── locales/
│   ├── en.json              one file per listed language; default language is required (en here)
│   └── hu.json              recommended for every other listed language (hu here); a missing file falls back to the default language with a warning
├── content/
│   ├── en/                  formatted text fragments (*.html), empty here (example: en)
│   └── hu/                  the same fragments for other languages, empty here (example: hu)
├── examples/                code example files, empty here
├── public/                  icons, logo, own script and style, published files, empty here
└── resources/               never read by the portal: logo tools
    ├── rovas_mono_chars.html
    └── logo/
        ├── R-MONO-U.TTF
        ├── SquadaOne-Regular.ttf
        └── logo_maker.sh
```

Folders that are empty in this skeleton contain a hidden `.gitkeep` file only, so that git keeps them. You may delete it as soon as the folder has real files.

In your repository the result looks like this:

```text
your-repository/            ← its folder name is the slug, for example ih-foo
├── package.json            ← section 4
└── ih-doc/                 ← the contents of this SKELETON folder
    ├── meta.json
    ├── page.json
    ├── server-checks.json
    ├── locales/<lang>.json
    ├── content/<lang>/…
    ├── examples/…
    ├── public/…
    └── resources/…
```

Everything else in your repository (your source code, tests, build files) is invisible to the portal.

## 3. The work in ten steps

1. **Choose the slug** (section 5, `slug`). It must start with `ih-`, use lowercase letters, digits and single hyphens (`ih-foo`, `ih-my-tool`), and be the same as the folder name of your repository.
2. **Copy** the contents of this folder into `ih-doc/` of your repository and create the `package.json` of section 4.
3. **Replace `ih-foo` and the example values.** Search every file for `ih-foo`, `ihFoo`, `your-scope`, `your-org` and `Your Name` and replace them with your own.
4. **Write `meta.json`** (section 5): the facts about your product.
5. **Write `locales/<lang>.json`** (section 6): the texts of your page for every language listed in `supportedLanguages`.
6. **Compose `page.json`** (section 7): the structure of the page. Start from the example and delete the blocks you do not need.
7. **Add fragments and examples** if you need formatted text or code files (sections 8 and 9).
8. **Add icons, a logo and, if you have a demo, your script and style** to `public/` (section 10). If the demo uses your own code, bundle it into one file first (section 10, "A demo that uses your own code").
9. **Go through the checklist** (section 16).
10. **Hand the product over** (section 13): send the repository address to the maintainer.

## Conventions in the cheatsheets

Every file has a **cheatsheet**: a table of all its keys with their type, whether they are required, their default, and an example. A key marked **yes** in the *Required* column must be there; a key marked **no** may be left out. After the table you find a minimal valid example and, where it helps, a short example for each key.

All JSON files are plain JSON: double quotes, no comments, no trailing commas. Unknown keys are rejected everywhere, so a misspelled key stops the build instead of being silently ignored.

## 4. Your repository root: `package.json`

The portal reads the `package.json` in the root of your repository (next to `ih-doc/`). It does not have to be a real npm package, but the file must exist. If your repository is not published to npm, set `"private": true` (see the table below).

### Cheatsheet

| Field            | Required | Used for                                                                                                                                      | Example                                                    |
| ---------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `name`           | yes      | The package name. Shown in the page footer with a link to `https://www.npmjs.com/package/<name>` (not with `"private": true`). Default of `installCommand` in `meta.json` (not with `"private": true`). | `"@your-scope/ih-foo"`                                     |
| `private`        | no       | `true` if your repository is not published to npm. The footer then shows no npm link and no install command, and `installCommand` in `meta.json` has no default (write one there if there is another way to install). | `true`                                                     |
| `version`        | yes      | Shown on the catalog card and in the page footer.                                                                                             | `"0.1.0"`                                                  |
| `repository.url` | no       | The repository link (a leading `git+` and a trailing `.git` are removed). It must be an `https://` or `http://` address. Preferred over `githubUrl` in `meta.json`. | `"https://github.com/your-org/ih-foo.git"` |
| `license`        | no       | Default of `license` in `meta.json`.                                                                                                          | `"MPL-2.0"`                                                |
| `keywords`       | no       | Default of `tags` in `meta.json`, if `meta.json` has no `tags`.                                                                               | `["foo", "skeleton"]`                                      |

All other fields of `package.json` are ignored by the portal.

### Minimal valid example

```json
{
  "name": "@your-scope/ih-foo",
  "version": "0.1.0",
  "license": "MPL-2.0",
  "repository": {
    "type": "git",
    "url": "https://github.com/your-org/ih-foo.git"
  },
  "keywords": ["foo", "skeleton", "documentation"]
}
```

## 5. `meta.json`

`meta.json` holds the **facts** about your product: its name, links, tags, colors and privacy notes. It is required. The long, translatable texts (description, headings, paragraphs) do not go here: they go into the locale file (section 6).

All texts in `meta.json` are shown as **plain text**: HTML written there is displayed literally. All links must be valid `https://` or `http://` addresses.

### Cheatsheet

| Key                  | Type            | Required | Default                                                | Meaning                                                                                                                                                         | Example                                          |
| -------------------- | --------------- | -------- | ------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `slug`               | text            | yes      | -                                                      | The identifier and URL segment. Lowercase letters, digits and single hyphens; starts with `ih-`; identical to the repository folder name.                        | `"ih-foo"`                                       |
| `name`               | text            | yes      | -                                                      | The short product name. Shown as the page title and on the catalog card.                                                                                        | `"ihFoo"`                                        |
| `fullName`           | text            | yes      | -                                                      | The long product name.                                                                                                                                          | `"inebHedj Foo Product"`                         |
| `author`             | text            | no       | the portal's name                                      | The author's name (not empty). Used in the metadata of the page (the `author` meta tag and the structured data).                                                | `"Your Name or Team"`                            |
| `startYear`          | number          | no       | the portal's start year                                | The first year of the copyright notice in the footer of your page (`© <startYear>-<current year>`). A whole number, not later than the current year.            | `2026`                                           |
| `status`             | text            | no       | `"stable"`                                             | `"stable"`, `"preview"` or `"alpha"`.                                                                                                                           | `"preview"`                                      |
| `githubUrl`          | link            | no       | `repository.url` of `package.json`                     | The repository link, shown in the footer. Used only if `package.json` has no `repository.url`.                                                                  | `"https://github.com/your-org/ih-foo"`           |
| `license`            | text            | no       | `license` of `package.json`                            | The license name shown in the footer.                                                                                                                           | `"MPL-2.0"`                                      |
| `licenseUrl`         | link            | no       | the portal's license link                              | The link of the license text.                                                                                                                                   | `"https://mozilla.org/MPL/2.0/"`                 |
| `installCommand`     | text            | no       | `npm install <name of package.json>` (none if `package.json` has `"private": true`) | Shown on the catalog card and, for a package that is on npm, in the footer.                                                                                                                    | `"npm install @your-scope/ih-foo"`               |
| `supportedLanguages` | list of texts   | yes      | -                                                      | The languages provided by this product (D-32). Two to three lowercase letters with hyphenated additions (`/^[a-z]{2,3}(-[A-Za-z0-9]{2,8})*$/`). The package author is responsible for ensuring the code identifies a valid, released language; the portal only checks the format. There is no default: the portal does not guess them. Providing a complete `locales/<lang>.json` for each language is recommended; keys missing from non-default language locale files fall back to the default language text with a build warning. A fragment for each `file` text (section 8) must exist for every listed language. | `["en", "hu"]` |
| `defaultLanguage`    | text            | no       | first item of `supportedLanguages`                     | The default language of this product. Must be one of the codes listed in `supportedLanguages`.                                                                 | `"en"`         |
| `tags`               | list of texts   | no       | `keywords` of `package.json`                           | Short words shown as pills on the catalog card and on the product page. Visitors can filter the catalog by them.                                                | `["foo", "skeleton", "documentation"]`           |
| `thumbnail`          | text            | no       | the portal's default picture                           | The picture shown when your page is shared (Open Graph and Twitter). Exactly 1200×630 pixels. See section 10.                                                   | `"/ih-foo/ih-foo.png"`                           |
| `maskIconColor`      | color           | no       | the portal's brand color                               | The color of the Safari pinned-tab icon.                                                                                                                        | `"#00b0ff"`                                      |
| `themeColor`         | color           | no       | `"#263238"`                                            | The theme color of the browser.                                                                                                                                 | `"#263238"`                                      |
| `logoSvg`            | text            | no       | `public/safari-pinned-tab.svg`, then the portal's logo | An inline SVG logo for multi-color or special logos. Must pass the SVG rules of section 14.                                                                     | `"<svg viewBox=\"0 0 24 24\">…</svg>"`          |
| `hasWiki`            | true / false    | no       | `true` if `wikiUrl` is set, else `false`               | `true` shows a wiki link at `<repository>/wiki`.                                                                                                                | `true`                                           |
| `wikiUrl`            | link            | no       | -                                                      | A wiki link at another address (used instead of the `hasWiki` address).                                                                                         | `"https://github.com/your-org/ih-foo/wiki"`      |
| `privacy`            | object          | no       | -                                                      | Product-specific privacy notes shown in the footer next to the portal's own. Keys: `short`, `paragraphs`, `3rd`.                                                | see below                                        |
| `description`, `keywords` | text       | no       | the locale file                                        | Used for every language whose locale file has no `description` or `keywords` key (the key counts, not the file). Normally the texts come from the locale file (section 6).                      | -                                                |

### `privacy`

This is the only place in the format where an object with one text per language is used.

| Key          | Type                                  | Meaning                                                                                                    | Example                                                              |
| ------------ | ------------------------------------- | ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `short`      | object: language → text               | One sentence shown in the footer.                                                                          | `{ "en": "This product collects no data." }`                         |
| `paragraphs` | list of objects: language → text      | Paragraphs of the full privacy information.                                                                | `[{ "en": "We store nothing." }]`                                    |
| `3rd`        | list of objects                       | Third-party services your product uses. Each has a `name` and a `url`.                                     | see below                                                            |
| `name`       | object: language → text               | The name of the third-party service (inside a `3rd` entry).                                                | `{ "en": "Example service" }`                                        |
| `url`        | link, or object: language → link      | The privacy page of the service (inside a `3rd` entry): one address, or one address per language.          | `"https://example.com/privacy"` or `{ "en": "https://example.com/en" }` |

```json
"privacy": {
  "short": { "en": "This product collects no data." },
  "paragraphs": [{ "en": "A paragraph of the full privacy information." }],
  "3rd": [
    { "name": { "en": "Example service" }, "url": "https://example.com/privacy" }
  ]
}
```

If your product has nothing to add to the portal's own privacy information, delete the whole `privacy` object.

### Minimal valid example

```json
{
  "slug": "ih-foo",
  "name": "ihFoo",
  "fullName": "inebHedj Foo Product",
  "supportedLanguages": ["en", "hu"]
}
```

### One more look: where each key appears

| Place                                              | Comes from                                                                                                               |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Catalog card (home page and catalog window)        | `name`, `description` (locale file), the logo, `tags`, `installCommand`, `version` (`package.json`), a link to your page |
| Header and footer of your page                     | `name`, the logo, `tags`, `license`, `licenseUrl`, repository link, npm link, install command, wiki link, `privacy`      |
| Product language switcher (if >= 2 languages)      | `supportedLanguages`: rendered in the tag row as `.product-lang-switch`, independent of the header portal switcher       |
| Metadata of your page (not visible)                | `description`, `keywords`, `author`, `themeColor`, the icons, `thumbnail`                                                |

The URL path `/<slug>/<lang>/` belongs to the product scope (`main[data-scope="package"]`); the portal UI frame (header, footer, catalog overlay) operates in its own independent portal language scope.

## 6. `locales/<lang>.json`

The locale files hold **every text of your page**: one file for each language listed in `supportedLanguages`, `<lang>.json` (for example `locales/en.json`, `locales/hu.json`), with the same keys. The product's default language is configured via `defaultLanguage` in `meta.json` (or defaults to the first item of `supportedLanguages` if omitted). The package author is responsible for ensuring the language code represents a real, released language; the portal validator only checks the code format (`/^[a-z]{2,3}(-[A-Za-z0-9]{2,8})*$/`).

The file is one flat JSON object: each key has one text. The values are **plain text**; HTML written in them is displayed literally. Formatted text goes into fragments (section 8).

### Cheatsheet

| Key                            | Required                    | Used for                                                                                       | Example                                                          |
| ------------------------------ | --------------------------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `description`                  | recommended (or `tagline`)  | The text on the catalog card and the description of the page. If it is missing, `tagline` is used. | `"A short description of the product."`                       |
| `tagline`                      | no                          | A one-line summary; the fallback of `description`.                                             | `"One-line summary of the product."`                             |
| `keywords`                     | recommended                 | The keywords of the page's metadata: a comma separated list in one text.                       | `"foo, skeleton, documentation"`                                 |
| any other key you choose       | if `page.json` uses it      | A text that `page.json` points to with `"key": "…"`.                                           | `"overview": "A text that page.json points to."`                 |

Key names are yours to choose. Use readable, unique names: the key of a heading becomes its anchor (`overviewSection` becomes `#overview-section`).

### Rules

- A key used in `page.json` **must exist in the default language's locale file** (`<defaultLanguage>.json`), otherwise the build fails.
- A key that is missing from another language's locale file (or if a non-default `locales/<lang>.json` file is omitted entirely) prints a build warning and falls back to the default language text. The fallback text appears in the default language within the other language's view, so providing complete files for all supported languages is recommended.
- Every value is a non-empty text.
- A key that nothing uses is harmless.

### Minimal valid example

```json
{
  "description": "A short description of the product.",
  "keywords": "foo, skeleton",
  "overviewSection": "Overview",
  "overview": "A text that page.json points to."
}
```

## 7. `page.json`

`page.json` describes the **structure** of your page. It contains no prose: every text is a locale key (`"key"`), a literal (`"value"`) or a file (`"file"`).

### Root cheatsheet

| Key       | Type             | Required | Meaning                                                                                                                                             | Example                                           |
| --------- | ---------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `schema`  | number           | yes      | The format version. Always `1`.                                                                                                                     | `1`                                               |
| `content` | list or object   | yes      | Either a list of blocks (only the main column), or an object `{ "main": […], "aside": […] }`. `main` is required and not empty; `aside` is optional. | `{ "main": [ … ], "aside": [ … ] }`              |
| `runtime` | object           | no       | `scripts`, `styles`, `publish`: lists of file paths relative to `public/` (section 10).                                                             | `{ "scripts": ["demo.js"] }`                      |

```json
{
  "schema": 1,
  "content": {
    "main": [ { "type": "h2", "key": "overviewSection" }, { "type": "text", "key": "overview" } ],
    "aside": [ { "type": "section-box", "key": "notesSection", "blocks": [ { "type": "text", "key": "notesText" } ] } ]
  }
}
```

### How the page is built

1. The tags of your product are shown as pills.
2. The **table of contents** follows. It is built automatically from your headings.
3. The **article** follows, with the `main` column and, if you provide `aside`, a second column. On wide screens the two columns stand side by side; on narrow screens the `aside` comes below the `main` column.

Rules for the order of blocks:

- The first block of `main` must be an `"h2"`. The `aside` does not have to start with one.
- After an `"h2"` only a `"text"`, a `"section-box"` or an `"example"` may follow.
- The blocks `"h4"`, `"h5"`, `"list"`, `"pairs"`, `"code"` and `"table"` belong **inside a section box** (in its `blocks`).
- After every text box and every section box the portal adds a "back to the table of contents" link.

### The table of contents and the anchors

- The table of contents is built from the `"h2"` blocks, the titles of the `"section-box"` blocks and the `"h4"` blocks, in the order of the page (first the `main` column, then the `aside`). The `"h5"` headings are not listed.
- Each of these gets an **anchor** from its key: `overviewSection` becomes `overview-section`. If two anchors would be equal, a number is appended (`overview-section-2`). Anchors never collide with the portal's own ids.
- A heading written with `"value"` gets its anchor from its text.

### Sources: `value`, `key`, `file`

Every block that shows content has **exactly one** source:

| Source    | Meaning                                                                                                                                                         | Example                                  |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| `value`   | A literal text (or code). The same in every language; shown once. Plain text.                                                                                   | `{ "type": "text", "value": "Hello" }`   |
| `key`     | A key of the locale file; shown in the language of the page.                                                                                                    | `{ "type": "text", "key": "overview" }`  |
| `file`    | For a `"text"`: the **base name** of a fragment, `"overview-details"` means `content/<lang>/overview-details.html` (needed for every supported language). For a `"code"`: a path that starts with `examples/`. | `{ "type": "text", "file": "overview-details" }`, `{ "type": "code", "file": "examples/usage.js" }` |

- A source must be a non-empty text. Giving none, or more than one, of `value`, `key`, `file` is an error.
- Headings (`"h2"`, `"h4"`, `"h5"` and the title of a section box) take only `key` or `value`, never `file`.
- A file path must not contain `..`, a backslash or a null character, and must not start with `/`.

### Block cheatsheet

| `type`           | Where it may stand                         | Keys                                                                                       |
| ---------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------ |
| `"h2"`           | top level of `main` or `aside`             | a source: `key` or `value`                                                                 |
| `"text"`         | top level, in `blocks`, in table cells, `intro` | a source: `key`, `value` or `file`                                                    |
| `"section-box"`  | top level of `main` or `aside`             | the title (`key` or `value`), optional `intro`, `blocks`                                   |
| `"example"`      | top level, in `blocks`                     | optional `id`, `class`, `style`, `attributes`                                              |
| `"h4"`, `"h5"`   | in `blocks`                                | a source: `key` or `value`                                                                 |
| `"list"`         | in `blocks`, in table cells                | `items`                                                                                    |
| `"pairs"`        | in `blocks`, in table cells                | `items` of `term` and `description`                                                        |
| `"code"`         | in `blocks`, in table cells                | `value` or `file`; in `blocks` also `lang`, `numbered`, `collapsible`, `copyable`          |
| `"table"`        | in `blocks`                                | `caption`, `columns`, `rows`                                                               |

### Every block, with an example

#### `"h2"`: a chapter heading

Starts a chapter. The first block of `main` is always one.

```json
{ "type": "h2", "key": "overviewSection" }
{ "type": "h2", "value": "Overview" }
```

#### `"text"`: a paragraph

With `key` or `value` it is a plain paragraph; with `file` it is a formatted fragment (section 8).

```json
{ "type": "text", "key": "overview" }
{ "type": "text", "value": "A literal paragraph." }
{ "type": "text", "file": "overview-details" }
```

#### `"section-box"`: a titled box

A box with a title. The title (`key` or `value`) is shown as a heading and listed in the table of contents. The box holds the content in `blocks`.

| Key      | Required | Meaning                                                                                                                                  | Example                                         |
| -------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| `key` or `value` | yes | The title of the box.                                                                                                              | `"key": "installSection"`                       |
| `intro`  | no       | A `"text"` block shown at the top of the box.                                                                                            | `"intro": { "type": "text", "key": "installIntro" }` |
| `blocks` | yes      | The list of blocks inside the box. An empty list `[]` is allowed, but then nothing is shown (the box is not listed in the table of contents either). | `"blocks": [ { "type": "h4", "key": "installTitle" } ]` |

```json
{
  "type": "section-box",
  "key": "installSection",
  "intro": { "type": "text", "key": "installIntro" },
  "blocks": [
    { "type": "h4", "key": "installTitle" },
    { "type": "code", "value": "npm install @your-scope/ih-foo", "lang": "bash" }
  ]
}
```

#### `"h4"` and `"h5"`: sub-headings

Only inside the `blocks` of a section box. `"h4"` headings are listed in the table of contents; `"h5"` headings are not.

```json
{ "type": "h4", "key": "installTitle" }
{ "type": "h5", "value": "A literal sub-heading" }
```

#### `"list"`: a list

| Key     | Required | Meaning                                                                                               | Example                                                          |
| ------- | -------- | ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `items` | yes      | A list of sources (`key`, `value` or `file`), at least one. The items may use different sources.      | `"items": [ { "key": "listItemKey" }, { "value": "A literal item" } ]` |

```json
{
  "type": "list",
  "items": [
    { "key": "listItemKey" },
    { "value": "A literal list item (the same text in every language)" },
    { "file": "note" }
  ]
}
```

An item with `value` is the same in every language. An item with `key` or `file` is shown in the language of the page.

#### `"pairs"`: terms with descriptions

| Key           | Required | Meaning                                                                              | Example                                                                 |
| ------------- | -------- | ------------------------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| `items`       | yes      | A list of entries, at least one.                                                     | `"items": [ { "term": { "key": "pairTerm1" }, "description": { "key": "pairDesc1" } } ]` |
| `term`        | yes      | (in an entry) The term. A source object: `{ "key": … }`, `{ "value": … }` or `{ "file": … }`.        | `{ "value": "--verbose" }`                                              |
| `description` | yes      | (in an entry) The description of the term. A source object.                                           | `{ "key": "pairDesc2" }`                                                |

```json
{
  "type": "pairs",
  "items": [
    { "term": { "key": "pairTerm1" }, "description": { "key": "pairDesc1" } },
    { "term": { "value": "--verbose" }, "description": { "key": "pairDesc2" } }
  ]
}
```

#### `"code"`: a code block

| Key           | Required | Default                           | Meaning                                                                                                                      | Example                          |
| ------------- | -------- | --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| `value` or `file` | yes  | -                                 | The code itself, or a path under `examples/`. Exactly one of them.                                                           | `"value": "npm install foo"`     |
| `lang`        | no       | `"text"`                          | The language for syntax coloring: a standard name such as `javascript`, `typescript`, `json`, `bash`, `html`, `css`, `yaml`; `text` colors nothing. | `"lang": "bash"`   |
| `numbered`    | no       | `true`                            | Show line numbers (`true` or `false`).                                                                                       | `"numbered": false`              |
| `collapsible` | no       | `true` for more than 6 lines      | A long block can be collapsed and expanded.                                                                                  | `"collapsible": false`           |
| `copyable`    | no       | `true`                            | Show a copy button.                                                                                                          | `"copyable": true`               |

```json
{ "type": "code", "value": "npm install @your-scope/ih-foo", "lang": "bash", "numbered": false, "collapsible": false }
{ "type": "code", "file": "examples/usage.js", "lang": "javascript", "numbered": true, "copyable": true }
```

Write line breaks in a `value` as `\n`. Blank lines at the beginning and the end are removed, and a common indentation is removed automatically. Inside a table cell a `"code"` element is shown as short inline code and has only `value` or `file`.

#### `"table"`: a table

| Key       | Required | Meaning                                                                                              | Example                                                            |
| --------- | -------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| `caption` | no       | A **locale key** (not a text): the caption under the table.                                          | `"caption": "tableCaption"`                                        |
| `columns` | yes      | A list of columns, at least one. Each column has a `title` and an optional `small`.                  | `"columns": [ { "title": "colName" } ]`                            |
| `title`   | yes      | (in a column) A **locale key**: the heading of the column.                                           | `{ "title": "colName" }`                                           |
| `small`   | no       | (in a column or a cell) `true` makes the column narrow. Set it on the column and on its cells.       | `{ "title": "colType", "small": true }`                            |
| `rows`    | yes      | A list of rows, at least one. A row is a list of cells; it has exactly as many cells as there are columns. | `"rows": [ [ { "content": [ … ] }, { "content": [ … ] } ] ]` |
| `th`      | no       | (in a cell) `true` makes the cell a row header.                                                      | `{ "th": true, "content": [ { "type": "text", "value": "title" } ] }` |
| `content` | yes      | (in a cell) A list of elements shown from top to bottom: `"text"`, `"code"`, `"list"`, `"pairs"`.    | `"content": [ { "type": "text", "key": "optTitleDescription" } ]`  |

```json
{
  "type": "table",
  "caption": "tableCaption",
  "columns": [
    { "title": "colName" },
    { "title": "colType", "small": true },
    { "title": "colDescription" }
  ],
  "rows": [
    [
      { "th": true, "content": [{ "type": "text", "value": "title" }] },
      { "small": true, "content": [{ "type": "code", "value": "string" }] },
      {
        "content": [
          { "type": "text", "key": "optTitleDescription" },
          { "type": "code", "value": "title: 'Hello'" }
        ]
      }
    ]
  ]
}
```

The flags `th` and `small` must be `true` or `false` (without quotes).

#### `"example"`: a container for a live demo

An empty container that your own script fills in (section 10). It has no frame while it is empty. With a `min-height` in `style` it still keeps that space until your script puts something into it.

| Key          | Required | Meaning                                                                                                                                                                       | Example                                    |
| ------------ | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `id`         | no       | A DOM id your script can use to find the container. Not one of the reserved ids (section 14), not starting with `ctrl-` or `copy-text-`, not used twice on the page.          | `"id": "foo-demo"`                         |
| `class`      | no       | Extra CSS classes (text), added to the class `example-box`.                                                                                                                   | `"class": "foo-demo-box"`                  |
| `style`      | no       | Inline CSS (text).                                                                                                                                                            | `"style": "min-height: 3rem;"`             |
| `attributes` | no       | An object of `data-*` attributes (values: text, number, `true` or `false`). A key without the `data-` prefix gets it automatically (`x` becomes `data-x`) with a warning. Names: `data-` and then lowercase letters, digits and hyphens. | `"attributes": { "data-demo": "hello" }` |

```json
{
  "type": "example",
  "id": "foo-demo",
  "class": "foo-demo-box",
  "style": "min-height: 3rem;",
  "attributes": { "data-demo": "hello" }
}
```

It becomes `<div class="example-box foo-demo-box" id="foo-demo" style="min-height: 3rem;" data-demo="hello"></div>`.

If two keys of `attributes` would become the same name with **different** values (for example `x` and `data-x`), the build fails.

### Minimal valid example

```json
{
  "schema": 1,
  "content": [
    { "type": "h2", "key": "overviewSection" },
    { "type": "text", "key": "overview" }
  ]
}
```

## 8. `content/`: text fragments

A **fragment** is a small HTML file for text that needs formatting (bold words, links, lists, inline code). It is the **only** place where text can be formatted; everything else is plain text.

- Location: `content/<lang>/<name>.html`, for example `content/en/overview-details.html`.
- You use it in `page.json` with `{ "type": "text", "file": "overview-details" }` (or as a list item or pair term: `{ "file": "note" }`). The `file` value is the **base name**: no folder, no `.html` ending.
- Write one file **per supported language** with the same name (`content/en/overview-details.html`, and `content/hu/overview-details.html`). A missing file for a supported language stops the build.
- You do not write `lang` attributes; the build rejects them inside fragments, because the portal uses `lang` to show only the language of the page.

### Cheatsheet: allowed tags

| Tag          | Use                                       | Example                                                                 |
| ------------ | ----------------------------------------- | ----------------------------------------------------------------------- |
| `p`          | a paragraph                               | `<p>A paragraph.</p>`                                                   |
| `ul`, `li`   | a bulleted list                           | `<ul><li>One</li><li>Two</li></ul>`                                     |
| `ol`, `li`   | a numbered list                           | `<ol><li>First</li><li>Second</li></ol>`                                |
| `strong`, `b` | strong text                              | `<strong>important</strong>`, `<b>bold</b>`                             |
| `em`, `i`    | emphasis                                  | `<em>emphasis</em>`, `<i>italic</i>`                                    |
| `code`       | inline code                               | `<code>npm install</code>`                                              |
| `br`         | a line break                              | `first line<br>second line`                                             |
| `a`          | a link; only the attributes `href`, `target`, `rel` | `<a href="https://example.com/" target="_blank" rel="noopener noreferrer">example.com</a>` |

### Rules

- `href` may be: `https:` or `http:` addresses, `mailto:` addresses, a path starting with `/`, an anchor starting with `#`, or a relative path.
- `target="_blank"` **requires** `rel="noopener"` (or `rel="noopener noreferrer"`).
- Write a literal `<` or `>` in text as `&lt;` or `&gt;`.
- Not allowed (build error): every other tag, every other attribute, `style` and event attributes (`onclick`, …), `javascript:` and `data:` links, a backslash in `href`.

### Minimal valid example (`content/en/overview-details.html`)

```html
<p>A fragment may contain <strong>strong</strong> and <em>emphasized</em> text and <code>inline code</code>.</p>
<ul>
  <li>A list item.</li>
  <li>A link: <a href="https://example.com/" target="_blank" rel="noopener noreferrer">example.com</a>.</li>
</ul>
```

## 9. `examples/`: code examples

A code example is a plain file that is shown in a code block. It is **not** executed.

- Location: `examples/<file>`, for example `examples/usage.js`.
- You use it in `page.json` with `{ "type": "code", "file": "examples/usage.js", "lang": "javascript" }`. The `file` value **starts with `examples/`**.
- It is the same in every language (there is no per-language folder).
- Short code can be written directly into `page.json` with `"value"` instead (`{ "type": "code", "value": "npm install foo" }`); use a file when the code is longer.

### Minimal valid example (`examples/usage.js`)

```js
const ihFoo = require('@your-scope/ih-foo');

ihFoo({ title: 'Hello' });
```

## 10. `public/`: icons, logo, scripts, styles, published files

`public/` is where everything goes that must be served as a **file**. It holds only a hidden `.gitkeep` in this skeleton. Only the icons below and the files you list under `runtime` in `page.json` are published; anything else in `public/` is ignored with a warning, so nothing leaks by accident. Hidden files (names that start with a dot, such as `.gitkeep`) are the exception: they are ignored without a warning, unless you list them under `runtime.publish`. Your files are served at `/<slug>/<path>`; for example `public/data/sample.json` is served at `/ih-foo/data/sample.json`.

### Icons (cheatsheet)

Put these files **directly** into `public/` (subfolders are ignored for icons). Any icon you do not provide falls back to the portal's icon.

| File                    | Note                                                                                                                              | Example                                |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| `favicon.ico`           | The classic browser icon.                                                                                                         | `public/favicon.ico`                   |
| `favicon-<N>x<N>.png`   | Square PNG icons. The sizes the portal uses are `16`, `32`, `48`, `64`, `180`, `192` and `512`.                                   | `public/favicon-32x32.png`             |
| `apple-touch-icon.png`  | The icon for the iOS home screen (usually 180×180).                                                                               | `public/apple-touch-icon.png`          |
| `safari-pinned-tab.svg` | A one-color SVG. Also **your logo** on the page and in the catalog. Must pass the SVG rules of section 14.                        | `public/safari-pinned-tab.svg`         |
| `site.webmanifest`      | The web app manifest. Use **relative** icon paths inside it.                                                                      | `public/site.webmanifest`              |

You can make the PNG icons and `favicon.ico` from your `safari-pinned-tab.svg` with `resources/logo/logo_maker.sh` (section 11).

### `site.webmanifest`

Use relative `src` paths. A path that starts with `/` would point to the portal's own icons, not yours.

```json
{
  "name": "ihFoo",
  "short_name": "ihFoo",
  "icons": [
    { "src": "favicon-192x192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "favicon-512x512.png", "sizes": "512x512", "type": "image/png" }
  ],
  "theme_color": "#263238",
  "background_color": "#263238",
  "display": "standalone"
}
```

### The logo

The logo is shown on your page and on the catalog card. The portal looks for it in this order: (1) `logoSvg` in `meta.json` (an inline SVG, for multi-color or special logos), (2) `public/safari-pinned-tab.svg`, (3) the portal's own logo. The SVG may contain only the elements listed in section 14; anything else stops the build. The ids you declare inside the SVG are renamed automatically (prefixed with your slug), so they cannot collide with anything.

A valid minimal `safari-pinned-tab.svg`:

```svg
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 4h16v16H4z" fill="none" stroke="currentColor" stroke-width="2"/>
  <path d="M8 12h8M12 8v8" stroke="currentColor" stroke-width="2"/>
</svg>
```

### The social image (`thumbnail`)

The picture shown when your page is shared on social media. It must be **exactly 1200×630 pixels**; the portal does not check the size, so keeping to it is your responsibility.

1. Put the image into `public/`, for example `public/ih-foo.png`.
2. In `meta.json`: `"thumbnail": "/ih-foo/ih-foo.png"`.
3. In `page.json`: `"runtime": { "publish": ["ih-foo.png"] }`.

The `thumbnail` must be an absolute `http(s)` address or a path of the form `/<slug>/<file>`; the file must exist in `public/` and be listed in `runtime.publish`, otherwise the build fails. Without a `thumbnail` the portal's default picture is used.

### Scripts, styles and published files: `runtime` in `page.json`

| Key       | Type              | Meaning                                                                                                                              | Example                                |
| --------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------- |
| `scripts` | list of paths     | Scripts loaded on **your product's pages only**, as module scripts. Paths are relative to `public/`.                                 | `"scripts": ["demo.js"]`               |
| `styles`  | list of paths     | Style sheets loaded on your product's pages only.                                                                                    | `"styles": ["demo.css"]`               |
| `publish` | list of paths     | Any other file to publish: images, data, documents, files that emulate a server's answers. May be in subfolders.                     | `"publish": ["data/sample.json"]`      |

```json
"runtime": {
  "scripts": ["demo.js"],
  "styles": ["demo.css"],
  "publish": ["data/sample.json", "ih-foo.png"]
}
```

Rules: every listed file must exist in `public/` and stay inside it (no `..`); the paths do not start with `/`.

### Example: a live demo

1. `page.json` has an empty container: `{ "type": "example", "id": "foo-demo", "class": "foo-demo-box" }`.
2. `public/demo.js` fills it. It is a file (the portal's security policy does not allow inline scripts) and uses only the portal's own address:

```js
const box = document.getElementById('foo-demo');

if (box) {
  fetch('/ih-foo/data/sample.json')
    .then((response) => response.json())
    .then((data) => {
      // textContent, never innerHTML: the text is data, not markup.
      box.textContent = data.message;
    })
    .catch(() => {
      box.textContent = 'sample.json could not be loaded';
    });
}
```

3. `public/demo.css` styles it. Use the portal's CSS custom properties (section 14) so that the demo follows the light and dark themes:

```css
.foo-demo-box {
  color: var(--c-accent);
  font-family: var(--f-l);
}
```

4. `public/data/sample.json` is the data file: `{ "ok": true, "message": "Hello from sample.json" }`.
5. `page.json` lists all three under `runtime` (see above).

### A demo that uses your own code

Use this when your demo needs the code of your product itself, for example the npm package whose source is your repository. The portal does not install packages and does not build your code: it only publishes the files you list under `runtime`. So you bundle the demo into **one file** in your own repository, commit that file, and list it.

The layout (for `ih-foo`):

```text
ih-foo/                           your repository, and the source of the npm package
├── package.json
├── src/index.js                  your package
└── ih-doc/
    ├── page.json
    ├── resources/demo-entry.js   the source of the demo (not published)
    └── public/demo.js            the bundle (published; you commit it)
```

1. **Install a bundler** as a development tool of your repository, for example esbuild: `npm install --save-dev esbuild`. You do not install your own package; the demo imports it from `src/`.
2. **Write the demo** in `ih-doc/resources/demo-entry.js`. It imports your code by a relative path:

```js
import { Foo } from '../../src/index.js';

const box = document.getElementById('foo-demo');

if (box) {
  // textContent, never innerHTML: the text is data, not markup.
  box.textContent = new Foo(7).label;
}
```

3. **Add a script** to the `package.json` in your repository root (the portal ignores every field except those of section 4, so `scripts` and `devDependencies` do no harm):

```json
"scripts": {
  "build:demo": "esbuild ih-doc/resources/demo-entry.js --bundle --minify --format=esm --target=es2020 --outfile=ih-doc/public/demo.js"
}
```

4. **Build and commit:** run `npm run build:demo` and commit `ih-doc/public/demo.js`.
5. **List the file** in `page.json`: `"runtime": { "scripts": ["demo.js"] }`.

What to keep in mind:

| Topic                 | Rule                                                                                                                                                                                                                                                                                                  |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Rebuild               | The portal never builds your demo. Run `npm run build:demo` and commit the result every time `src/` or the demo changes; an old `demo.js` shows the old code.                                                                                                                                         |
| `--format=esm`        | The portal loads your scripts as module scripts (section 14).                                                                                                                                                                                                                                         |
| `--target=es2020`     | The portal must work in the browsers that are still in use (section 14). The oldest of them (today about Chrome 109, Firefox 121 and iOS Safari 16.6) understand JavaScript of the year 2020. With this target the bundler rewrites newer syntax (for example `??=`, `#private` fields, `static { }` blocks) and stops with an error for syntax it cannot rewrite (for example top-level `await`). |
| Browser functions     | The bundler rewrites syntax only; it does not add functions that a browser lacks. Use only functions that these browsers have, or give a fallback that keeps the feature.                                                                                                                             |
| Security policy       | The bundle runs under the policy of section 14. A bundle that calls `eval` or `new Function` fails in the browser, and so does a script that loads something from another address.                                                                                                                    |
| Your npm package      | Keep `ih-doc/` out of the package that you publish to npm: put `"files": ["src"]` (or the folders you need) into the root `package.json`. Without it, `npm pack` includes `ih-doc/public/demo.js` and `ih-doc/resources/`.                                                                            |

### A demo with a backend

The portal itself is served as static files, but your demo may have a backend. The portal only copies the files you list under `runtime.publish` to `/<slug>/…`. The web server provides some kind of support for running backend files (for example PHP, CGI, Node), and **using what is available is your concern**: write the backend files for what the server offers, publish them under `runtime.publish`, and describe checks of their answers in `server-checks.json` (section 12). If you publish a web server configuration file such as `.htaccess`, the portal's tests check that your pages still carry the portal's security headers.

## 11. `resources/`: logo tools

**The portal never reads `resources/`.** It is a place for your working files. This skeleton brings the tools the portal's own logos were made with.

| File                                  | What it is                                                                                                                                       |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `resources/logo/logo_maker.sh`        | A shell script that makes all the icons from your `safari-pinned-tab.svg`.                                                                       |
| `resources/logo/R-MONO-U.TTF`         | The font file *Rovas Mono Unicode*, for drawing a logo from Rovas script characters.                                                             |
| `resources/logo/SquadaOne-Regular.ttf` | The font *Squada One*, the portal's display font (`--f-l`), used for the product name in the header and the footer.                              |
| `resources/rovas_mono_chars.html`     | A page that shows the characters of the Rovas Mono font. Open it in a browser; clicking a character inserts it into the editor field and copies it. |

### Making the icons with `logo_maker.sh`

1. Install ImageMagick (the command `magick` or `convert` must work).
2. Put your logo as `safari-pinned-tab.svg` into `resources/logo/` (next to the script).
3. If you want other colors, edit the two lines at the top of the script: `FG="#ff1744"` is the drawing color, `BG="#263238"` is the background color.
4. Run it from anywhere: `sh resources/logo/logo_maker.sh`.
5. It creates, next to the script: `favicon-16x16.png`, `favicon-32x32.png`, `favicon-48x48.png`, `favicon-64x64.png`, `favicon-180x180.png`, `favicon-192x192.png`, `favicon-512x512.png`, `apple-touch-icon.png` and `favicon.ico`.
6. Copy these files and `safari-pinned-tab.svg` into `public/`.

## 12. `server-checks.json`

An optional file in which you describe checks of the web server's answers for the files you publish. The maintainer's server tests run them against the real servers. The file is **not published**. In this skeleton it contains `{ "checks": [] }`: no checks, which is valid and does nothing.

### Cheatsheet

| Key            | Type            | Required | Meaning                                                                                                   | Example                                  |
| -------------- | --------------- | -------- | --------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| `checks`       | list            | yes      | The list of checks (may be empty).                                                                        | `"checks": []`                           |
| `name`         | text            | yes      | A name for the check, shown in the test output (inside a check).                                          | `"name": "sample data is served as JSON"` |
| `path`         | text            | yes      | The address to request. Starts with `/<slug>/`; no spaces, no `..`, no backslash.                         | `"path": "/ih-foo/data/sample.json"`     |
| `servers`      | list of texts   | yes      | Where the check runs: `"apache"`, `"nginx"` or both. The check runs only on the listed servers.            | `"servers": ["apache", "nginx"]`         |
| `method`       | text            | no       | `"GET"` (default) or `"HEAD"`.                                                                            | `"method": "GET"`                        |
| `status`       | number          | yes      | The expected HTTP status, 100 to 599.                                                                     | `"status": 200`                          |
| `contentType`  | text            | no       | The start of the expected `Content-Type` header.                                                          | `"contentType": "application/json"`      |
| `bodyContains` | text            | no       | A text the response body must contain. Requires `"method": "GET"`.                                        | `"bodyContains": "\"ok\": true"`         |

Requests with a body (`POST`) are not supported.

### Example with one check

```json
{
  "checks": [
    {
      "name": "sample data is served as JSON",
      "path": "/ih-foo/data/sample.json",
      "servers": ["apache", "nginx"],
      "status": 200,
      "contentType": "application/json",
      "bodyContains": "\"ok\": true"
    }
  ]
}
```

## 13. Handing the product over

When `ih-doc/` is ready and the checklist (section 16) is done, you hand the product over to the portal's maintainer. The maintainer registers it with two small additions. The skeleton gives you both, filled in for `ih-foo`:

**`gitmodules.snippet`**: a block for the `.gitmodules` file of the portal:

```ini
# .gitmodules (add)
[submodule "packages/ih-foo"]
	path = packages/ih-foo
	url = https://github.com/your-org/ih-foo.git
	ignore = all
```

**`products.ts.snippet`**: a line for the product list of the portal (`src/config/products.ts`):

```ts
// src/config/products.ts: new line into codeProducts list
await defineProduct('ih-foo')
```

### What you do

1. Edit the two snippets: replace `ih-foo` with your slug (in both files, three places in the first) and the `url` with the address of your repository.
2. Make sure everything is on the **default branch** of your repository (`main`, `master` or any other) and that the repository can be read by the maintainer. If the portal should follow another branch, tell the maintainer its name; the maintainer then adds a `branch = <name>` line to the block.
3. Send the two edited snippets to the maintainer.

### What the maintainer does with them

1. Adds the `.gitmodules` block (and the submodule) to the portal.
2. Adds the line to the `codeProducts` list (a comma separates it from the other entries).
3. Builds the portal. If the build reports an error, the maintainer sends you the message; section 15 explains it.

### After that

The portal always builds from the **newest commit of the default branch** of your repository. A commit to that branch that breaks a rule stops the portal's build; that is the intended signal. Keep the default branch valid and develop on another branch.

## 14. Rules and limits

What a product may and may not do, and why. Every rule here is enforced when the portal is built (a violation stops the build) unless it says otherwise.

### Who the portal trusts, and how far

The portal assumes that a product's author is not the portal's maintainer. A product appears only after the maintainer registers it, and nothing goes live until the maintainer builds and publishes the portal. Within that:

- **On your own pages** you may run your own scripts and styles and publish your own files.
- **On shared surfaces** (the catalog on the home page and in the catalog window) your product contributes only **plain text, checked links and a checked logo**. This keeps one product from changing or misleading visitors on pages that belong to the portal or to other products.

### Plain text everywhere except fragments

All text values in `meta.json` and in the locale files are shown as **plain text**: HTML in them is displayed literally. Formatting is possible only in fragments (section 8) and in the logo SVG, and both are checked.

### Links (URLs)

These must be valid `https://` or `http://` addresses: `githubUrl`, `licenseUrl`, `wikiUrl`, every `url` in `privacy` (also each language's address if it is an object), `thumbnail` (if it is a full address), and `repository.url` in `package.json`. An address must not contain credentials (`user:password@host`), whitespace, quotes, angle brackets, a backslash or control characters, and its protocol must be `http:` or `https:`.

### The logo (SVG)

`logoSvg` in `meta.json` and `public/safari-pinned-tab.svg` are checked. The SVG may contain only these elements:

`svg`, `g`, `path`, `circle`, `ellipse`, `rect`, `line`, `polyline`, `polygon`, `defs`, `clipPath`, `linearGradient`, `radialGradient`, `stop`, `title`, `desc`.

Rejected (build error):

- every other element (`script`, `style`, `foreignObject`, `a`, `image`, …),
- the attributes `style`, `class` and `tabindex`, and event attributes (`onclick`, …),
- comments and declarations (`<!`), and processing instructions (`<?xml … ?>`),
- `javascript:` references,
- a reference to something outside the SVG: an external `href`, or a `url(...)` that is not `url(#id)` (also when written with character entities),
- a reference `#id` or `url(#id)` to an id that does not exist in the SVG,
- an id that is not made of letters, digits, `_` and `-`, that is one of the reserved ids below, or that starts with `lang-`,
- an unquoted value of `id`, `href` or `xlink:href` (write `id="a"`, not `id=a`).

The ids you declare are renamed automatically: every id and every reference to it gets your slug as a prefix.

### What your scripts and styles may do (the security policy)

The portal sends a Content Security Policy with every page. It applies to your scripts and styles too:

| Policy                              | What it means for you                                                                                                                                          |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `script-src 'self'`                 | Scripts must be **files served by the portal**, listed under `runtime.scripts`. No inline scripts, no `onclick="…"` attributes, no scripts from other addresses, no `eval`-style code. |
| `style-src 'self' 'unsafe-inline'`  | Styles may be files (listed under `runtime.styles`) or inline `style` attributes (the `style` of an `example` block). Style sheets from other addresses are blocked. |
| `connect-src 'self'`                | `fetch` and similar requests may only go to the portal's own address (your published files, for example).                                                      |
| `img-src 'self' data: https:`       | Images may come from the portal, from `data:` addresses and from any `https:` address.                                                                          |
| `font-src 'self' data:`             | Fonts may be files from the portal or `data:` addresses.                                                                                                        |
| `default-src 'self'`                | Everything not listed (frames, media, …) may only come from the portal's own address.                                                                           |
| `object-src 'none'`                 | No plug-in objects.                                                                                                                                             |
| `form-action 'self'`                | Forms may only be sent to the portal's own address.                                                                                                             |
| `frame-ancestors 'none'`            | Your page cannot be shown inside a frame of another page.                                                                                                       |
| `Permissions-Policy`                | The camera, microphone, geolocation and payment features are switched off.                                                                                      |

Also:

- Your scripts are loaded as **module scripts**, and your scripts and styles load **only on your own product's pages**, never on the home page or on other products.
- Your JavaScript must work in the browsers that the portal supports: every browser that has at least 0.25% of the users and is not dead. The oldest of them today are about Chrome 109, Firefox 121 and iOS Safari 16.6, and the set changes over time. Use syntax that your bundler rewrites for them (section 10, `--target=es2020`), and use only browser functions that these browsers have, or give a fallback that keeps the feature.
- Put texts into the page with `textContent`, not `innerHTML`.
- Do not change the portal's own elements (the header, the footer, the catalog window); work inside your `example` containers.
- The portal makes no assumption about the files you publish. If you publish a web server configuration file such as `.htaccess`, the portal's server tests check that your pages still carry the portal's security headers; a configuration that removes them fails those tests.

### Reserved ids

Ids that belong to the portal. An `example` block's `id` must not be one of these, and the anchors the portal generates for your headings never collide with them (such an anchor gets a number, for example `code-2`):

```text
toc, top, links, main-content, menu-ctrl, privacy-ctrl, privacy-content,
catalog-modal, catalog-modal-title, catalog-search, catalog-modal-search,
site-nav, site-nav-title, code, sites, modal-code, modal-sites,
lang-en, lang-hu, theme-toggle, theme-toggle-btn
```

`lang-<code>` is reserved for every portal language (today `lang-en` and `lang-hu`), and `plang-` is reserved for product language radio buttons. An `example` `id` also must not start with `ctrl-`, `copy-text-` or `plang-` (the portal's code blocks and language switchers use these).

### Files and paths

- A path in `page.json` (`file`, `runtime`) must not contain `..`, a backslash or a null character, and must not start with `/`.
- A text `file` is a base name (no slash, no `.html` ending). A code `file` starts with `examples/`.
- Everything listed under `runtime` must exist in `public/` and stay inside it.
- Only listed files (and the icons) are published. A published file never overwrites a page that the portal itself generated; such a collision prints a warning and the file is skipped.

### Design tokens you may use

Your style sheet may use the portal's CSS custom properties, so that your demo follows the light and dark themes. Use the **semantic** names (the palette steps do not switch with the theme).

| Group      | Properties                                                                                                                                      |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Surfaces   | `--c-canvas` (page background), `--c-surface`, `--c-surface-hover`, `--c-border`, `--c-border-subtle`                                           |
| Text       | `--c-text-h` (headings), `--c-text-h3`, `--c-text-p` (paragraphs), `--c-text-sub`, `--c-text-muted`, `--c-text-dim`, `--c-code-text`            |
| Links      | `--c-link`, `--c-link-hover`                                                                                                                    |
| Accent     | `--c-accent`, `--c-pill-bg`, `--c-pill-text`, `--c-focus-border`                                                                                |
| Fonts      | `--f-h` (headings), `--f-b` (body text), `--f-l` (the portal's display font)                                                                    |
| Sizes      | `--s-fb` (body text), `--s-fc` (code), `--s-fh1` … `--s-fh5` (headings), `--s-sm`, `--s-nm` (spacing steps)                                      |
| Palette    | `--c-50` … `--c-900`, `--c-999` (fixed colors, the same in both themes)                                                                         |

The theme is switched by the `data-theme` attribute of the `<html>` element (`dark` or `light`); the semantic properties change with it. If your product needs its own fixed colors, define them in your own style sheet.

## 15. Build error messages

When a rule is broken, the portal build stops and prints a message. Nothing is published until the build passes. The maintainer sends you the message.

### How to read a message

```text
[product-page] "ih-foo": translation key "overview" is missing from default language (en) locales at content.main[1]
 └─ the check    └─ slug   └─ what is wrong                                                           └─ where
```

The **where** is a path into your files:

| Path                              | Means                                                                  |
| --------------------------------- | ---------------------------------------------------------------------- |
| `content.main[1]`                 | the second block (counting from 0) of the `main` column in `page.json` |
| `content[0]`                      | the first block, when `content` is a list                              |
| `content.aside[2]`                | the third block of the `aside` column                                  |
| `content.main[3].blocks[1]`       | the second block inside the `blocks` of the fourth block               |
| `content.main[3].intro`           | the `intro` of that section box                                        |
| `….rows[2][1].content[0]`         | in a table: row 3, cell 2, its first element                           |
| `….items[1].term`                 | the term of the second entry of a `pairs` block                        |
| `runtime`                         | the `runtime` object of `page.json`                                    |
| `content/en/overview.html`        | a fragment file                                                        |

The build reports **one error at a time**: fix it, and the next one may appear.

### A. The product is not found

| Message (shortened)                                                            | Cause and fix                                                                                            |
| ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| `invalid product slug "…"`                                                     | The slug has capital letters, underscores or doubled hyphens. Use lowercase letters, digits and single hyphens. |
| `No package.json found for product slug "…"`                                   | The repository has no `package.json` in its root.                                                        |
| `No ih-doc/meta.json found` / `No ih-doc/page.json found`                      | The file is missing or misnamed (the folder is `ih-doc`, the names are lowercase).                       |
| `product slug mismatch. meta.json slug "…" does not match registered slug "…"` | `slug` in `meta.json` differs from the slug in the product list. Make them identical.                    |

### B. The structure of `page.json`

| Message (shortened)                                                                | Cause and fix                                                                                              |
| ---------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `page.json must be an object`                                                      | The file is not a JSON object at its root.                                                                 |
| `unknown key "…"`                                                                  | A key that does not exist: a typo. Compare with the cheatsheets. This message appears for every block.   |
| `unsupported schema version "…", expected 1`                                       | Set `"schema": 1`.                                                                                         |
| `page.json content must be a non-empty array`                                      | `content` is missing, empty, or neither a list nor an object.                                              |
| `page.json content.main must be a non-empty array`                                 | With `{ "main": …, "aside": … }`, `main` must be a list with at least one block.                            |
| `page.json content.aside must be an array`                                         | `aside` is present but not a list.                                                                         |
| `first content block must be "h2", found "…"`                                      | The `main` column (or the list) must start with an `"h2"`.                                                 |
| `"h2" can only be followed by "text", "section-box", or "example", but found "…"`  | Put a `"text"` or a `"section-box"` after the `"h2"`. `"h4"` and `"h5"` belong inside a section box.       |
| `unknown root content block type "…"`                                              | Only `"h2"`, `"text"`, `"section-box"` and `"example"` may stand at the top level.                         |
| `expected text element in section-box intro`                                       | `intro` must be a `{ "type": "text", … }` block.                                                           |
| `section-box must have "blocks" array`                                             | Add a `blocks` list to the section box.                                                                    |
| `invalid content item` / `invalid block` / `invalid element`                       | An entry of a block list is not an object.                                                                 |

### C. Sources, keys and files

| Message (shortened)                                                                  | Cause and fix                                                                                         |
| ------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| `… must have exactly one source (value, key or file), but found: …`                  | A block has none or more than one of `value`, `key`, `file`. Keep exactly one.                        |
| `headings (…) cannot use "file" source; only "key" or "value" is permitted`          | Replace the `file` of the heading with a `key`.                                                       |
| `expected non-empty string for "…"`                                                  | `value`, `key`, `file`, `caption`, `title` or `id` is empty, only spaces, or not a text.              |
| `translation key "…" is missing from default language (<defaultLanguage>) locales`                  | Add the key to the locale file of the default language.                                              |
| `text file "…" must be a base name … without slashes or ".html" extension`           | Write `"overview-details"`, not `"content/en/overview-details.html"`.                                 |
| `referenced text content file "content/<lang>/<name>.html" missing for supported language "<lang>"` | Create the fragment for every language in `supportedLanguages`.                        |
| `code example file "…" must start with "examples/"`                                  | Write `"examples/usage.js"`.                                                                          |
| `referenced code example file "…" does not exist in ih-doc/examples/`                | Create the file or fix the path.                                                                      |
| `file path "…" is invalid or traverses outside ih-doc/ directory`                    | The path contains `..`, a backslash, a null character, or starts with `/`.                            |

### D. Lists, pairs, code and tables

| Message (shortened)                                                  | Cause and fix                                                                              |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `expected items array in list` / `… in pairs`                        | `items` is missing or not a list.                                                          |
| `list must define at least one item` / `pairs must define at least one item` | The `items` list is empty. Add an entry or remove the block.                       |
| `list item must be an object` / `pair item must be an object`        | An entry of `items` is not an object.                                                      |
| `pair item requires a "term" source object` / `… "description" …`    | Give both as source objects, for example `{ "key": "…" }`.                                 |
| `expected non-empty string for "lang"`                               | The `lang` of a code block is empty. Write a language name or leave it out.                |
| `expected boolean for "numbered"` (also `collapsible`, `copyable`, `th`, `small`) | Use `true` or `false` without quotes.                                       |
| `table must define at least one column` / `… at least one row`      | Add columns or rows, or remove the table.                                                  |
| `expected rows array in table`                                       | `rows` is missing or not a list.                                                           |
| `table row length (…) does not match columns length (…)`             | A row has more or fewer cells than the table has columns.                                  |
| `expected cell content array`                                        | A cell needs a `content` list of elements.                                                 |
| `unknown element type "…"`                                           | The `type` does not exist or is not allowed there. Inside `blocks`: `"h4"`, `"h5"`, `"text"`, `"list"`, `"pairs"`, `"code"`, `"table"`, `"example"`. In a table cell: `"text"`, `"code"`, `"list"`, `"pairs"`. |

### E. The `"example"` block

| Message (shortened)                                                        | Cause and fix                                                                              |
| -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `"id" "…" conflicts with reserved portal identifier`                       | Choose another `id` (list in section 14; an `id` starting with `plang-` also causes this).|
| `example id "…" cannot start with reserved prefix "ctrl-" or "copy-text-"` | Choose another `id`.                                                                       |
| `duplicate example id "…"`                                                 | Two examples have the same `id`.                                                           |
| `expected string for "class"` / `"style"`                                  | Write a text.                                                                              |
| `expected key-value object for "attributes"`                               | `attributes` must be an object.                                                            |
| `invalid attribute name "…" (must match /^data-[a-z0-9-]+$/)`              | The name contains other characters than letters, digits and hyphens (spaces, underscores). |
| `attribute value must be string, number or boolean`                        | Use a text, a number, `true` or `false` as the value.                                      |
| `attributes "…" and "…" both resolve to "…" with different values`         | For example `x` and `data-x` with different values. Keep one.                              |

### F. Fragments (HTML)

These messages name the fragment file ("in content file").

| Message (shortened)                                                    | Cause and fix                                                                                  |
| ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `malformed HTML: mismatched angle brackets`                            | A `<` without a `>` or the other way round. Write literal ones as `&lt;` and `&gt;`.           |
| `disallowed HTML tag "<…>" found in content file`                      | Use only `p`, `ul`, `ol`, `li`, `i`, `b`, `em`, `strong`, `code`, `br`, `a`.                   |
| `closing tag "</…>" must not contain attributes`                       | Remove the attributes from the closing tag.                                                    |
| `unbalanced attribute quotes in tag "<…>"`                             | A quote is missing in a tag.                                                                   |
| `attribute "…" contains disallowed characters "<" or ">"`              | Remove `<` and `>` from the attribute value.                                                   |
| `disallowed attribute "…" on <a> tag … Only href, target, rel allowed` | Remove the attribute (for example `class`, `style`, `onclick`).                                |
| `disallowed attribute "…" on <…> tag`                                  | Only `a` may have attributes.                                                                  |
| `disallowed attribute "lang" on <…> tag`                                | Remove `lang`: the portal wraps each fragment in the right language container.                  |
| `unsafe backslash in href attribute "…"`                               | Use `/`, not `\`.                                                                              |
| `unsafe or disallowed href protocol "…"`                               | Use `https:`, `http:`, `mailto:`, `/…`, `#…` or a relative path.                               |
| `<a> tag with target="_blank" must include rel="noopener" …`           | Add `rel="noopener noreferrer"`.                                                               |

### G. The logo (SVG)

These messages name the SVG source (`logoSvg` or the file).

| Message (shortened)                                                   | Cause and fix                                                                                   |
| --------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `SVG content must not be empty`                                       | The SVG file or `logoSvg` is empty.                                                             |
| `comments and declarations ("<!") are disallowed`                     | Remove comments and `<!DOCTYPE …>` from the SVG.                                               |
| `XML processing instructions ("<?") are disallowed`                   | Remove `<?xml … ?>`.                                                                            |
| `malformed SVG: mismatched angle brackets`                            | A `<` or `>` is unbalanced.                                                                     |
| `disallowed SVG element "<…>" … Allowed elements: …`                  | Use only the elements of section 14 (for example convert text to paths; remove `style`, `image`). |
| `disallowed "style"` / `"class"` / `"tabindex"` attribute             | Write presentation as attributes (`fill`, `stroke`), not as `style`; remove `class`.            |
| `disallowed event handler attribute "…"`                              | Remove `onclick`, `onload`, … from the SVG.                                                     |
| `reserved portal ID "…" is disallowed in SVG logo`                    | Rename the id.                                                                                  |
| `invalid ID "…" in SVG logo`                                          | Ids may contain only letters, digits, `_` and `-`.                                              |
| `attribute "…" … must have a quoted value`                            | Write the value of `id`, `href` and `xlink:href` in quotes.                                     |
| `disallowed "javascript:" reference …`                                | Remove it.                                                                                      |
| `disallowed external href …` / `… external or non-fragment url() reference …` / `… encoded url() reference …` | The SVG points outside itself. Only `#id` and `url(#id)` are allowed.        |
| `unresolved internal fragment reference "#…"`                         | A `#id` or `url(#id)` points to an id that is not in the SVG.                                   |

### H. Links and `meta.json`

| Message (shortened)                                                    | Cause and fix                                                                                   |
| ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `URL must be a non-empty string`                                       | A link field is empty.                                                                          |
| `URL "…" contains disallowed characters …`                             | Remove quotes, angle brackets, spaces, backslashes and control characters from the address.     |
| `invalid URL "…"`                                                      | The address is not a valid web address.                                                         |
| `unsafe URL protocol "…" … Only "http:" and "https:" protocols are allowed.` | Use `https://…`.                                                                          |
| `user credentials ("user:pw@") are disallowed in URL "…"`              | Remove `user:password@` from the address.                                                       |
| `author must be a non-empty string`                                    | `author` in `meta.json` must be a text that is not empty.                                       |
| `startYear must be a whole year not later than the current year`       | `startYear` in `meta.json` must be a number such as `2026`, not a text (`"2026"`) and not a future year. |
| `unknown key "…" at meta.json …`                                        | A key that does not exist in `meta.json`: a typo.                                               |
| `status must be one of "stable", "preview", "alpha"`                    | Use one of the three values.                                                                    |
| `supportedLanguages is required …` / `supportedLanguages must be a non-empty list …` / `language "…" must match /^[a-z]{2,3}(-[A-Za-z0-9]{2,8})*$/` / `defaultLanguage "…" must be included in supportedLanguages` | Write `supportedLanguages` with valid language codes and ensure `defaultLanguage` (if set) is in that list. |
| `tags must be a list of non-empty strings` / `hasWiki must be a boolean` / `<field> must be a non-empty string` | Fix the type of the field (see the cheatsheet of section 5).                                    |
| `privacy… must be an object with one text per language` / `privacy.3rd[…].url must be an address or an object …` | Fix the shape of the `privacy` object (section 5).                                             |

### I. Scripts, styles and published files

| Message (shortened)                                               | Cause and fix                                                                                   |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `referenced runtime file "…" does not exist in ih-doc/public/`    | A file listed under `runtime` is missing. Create it or remove the entry.                        |
| `runtime path "…" must not traverse outside public/ directory`    | The path contains `..`, a backslash or a null character, or starts with `/`.                    |
| `expected array in runtime.<group>`                               | `scripts`, `styles` and `publish` must be lists.                                                |
| `failed to parse ih-doc/page.json`                                | `page.json` is not valid JSON (a missing comma, a trailing comma, an unquoted key).             |
| `thumbnail "…" must be an absolute http(s) URL or a path of the form "/<slug>/<file>"` | Write the address as `/<slug>/<file>` or a full `https://` address.                             |
| `thumbnail file "…" does not exist in ih-doc/public/`             | Create the file or fix the name.                                                                |
| `thumbnail file "…" must be listed in runtime.publish of page.json` | Add the file name to `runtime.publish`.                                                       |

### J. `server-checks.json`

All messages have the form `[server-checks] "<slug>": <message> at <path>`.

| Message (shortened)                                                              | Cause and fix                                                               |
| -------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `invalid JSON in server-checks.json` / `failed to read server-checks.json`       | The file is not valid JSON or cannot be read.                               |
| `expected object at root` / `missing required "checks" array` / `unknown root key "…"` | The root must be `{ "checks": [ … ] }` and nothing else.              |
| `unknown key "…"`                                                                | A check has a key that does not exist.                                      |
| `name is required and must be a non-empty string`                                | Give the check a name.                                                      |
| `path must start with "/<slug>/"`, `… must not contain whitespace / ".." / "\"`  | Fix the path.                                                               |
| `servers is required and must be a non-empty array` / `invalid server "…"`       | List `"apache"` and/or `"nginx"`.                                           |
| `invalid method "…"`                                                             | Use `"GET"` or `"HEAD"`.                                                    |
| `status is required and must be an integer between 100 and 599`                  | Write the expected status as a number.                                      |
| `bodyContains requires method "GET"`                                             | A `HEAD` response has no body. Use `"GET"`.                                 |

### Warnings (the build continues)

| Message                                                                            | Meaning and fix                                                                                         |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `key "…" missing from "<lang>" locales, falling back to <defaultLanguage>`         | Add the key to that language's locale file, or accept the text in the default language.               |
| `attribute "…" in example block … normalized to "data-…"`                          | An `example` attribute name was rewritten. Write the `data-` name yourself to silence it.               |
| `attributes "…" and "…" both resolve to "…" with identical value, merged`          | Two attribute names became one. Remove the duplicate.                                                   |
| `Skipping disallowed asset "…" in ih-doc/public of "<slug>"`                       | A file in `public/` is neither an icon nor listed under `runtime`; it is not published. List it under `runtime.publish` or delete it. |
| `Skipping directory "…" in ih-doc/public … subdirectories are not supported`       | Icons must be directly in `public/`. Files in a subfolder are published only if listed under `runtime`. |
| `Skipping runtime asset "…": destination file already exists`                      | The file would overwrite a page of the portal. Rename it.                                               |

## 16. Checklist

Go through this list before you hand the product over (section 13):

1. The repository root has a `package.json` (`name`, `version`, and ideally `repository.url`, `license`, `keywords`).
2. `ih-doc/meta.json` and `ih-doc/page.json` exist; `page.json` has `"schema": 1`.
3. The `slug` in `meta.json` is the folder name of your repository, starts with `ih-`, and matches lowercase letters, digits and single hyphens.
4. `supportedLanguages` lists the product's languages. Providing a complete `locales/<lang>.json` for every one of them is recommended so that translations do not fall back to the default language.
5. Every `key` used in `page.json` (including table `caption` and column `title`) exists in the default language locale file; other languages are complete, so that there are no warnings.
6. No `value`, `key` or `file` is empty; no `list`, `pairs` or table is empty; every table row has as many cells as the table has columns.
7. Every `file` exists: fragments as `content/<lang>/<name>.html` for **every** supported language, code examples under `examples/`.
8. Fragments use only the allowed tags and attributes (section 8); every `target="_blank"` has `rel="noopener noreferrer"`.
9. Every link in `meta.json` and `repository.url` in `package.json` starts with `https://` or `http://`.
10. The logo (`safari-pinned-tab.svg` or `logoSvg`) uses only the allowed elements (section 14).
11. Every file under `runtime` exists in `public/`. Your scripts are files (not inline code) and load nothing from other addresses.
12. `thumbnail`, if used, is exactly 1200×630 pixels and listed under `runtime.publish`.
13. No `example` `id` is a reserved id, starts with `ctrl-`, `copy-text-` or `plang-`, or is used twice.
14. `server-checks.json` is valid JSON with a `checks` list (it may be empty).
15. All the example values of the skeleton are replaced: search every file for `ih-foo`, `ihFoo`, `your-scope`, `your-org` and `Your Name`.
16. The two snippets of section 13 are filled in with your slug and the address of your repository, and everything is on the default branch of your repository.
17. If your demo uses your own code: `public/demo.js` was built again from the current `src/` and committed, and the `package.json` in your repository root has a `files` list that leaves `ih-doc/` out of your npm package.
