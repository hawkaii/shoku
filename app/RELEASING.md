# Releasing Shoku

Two lanes: **Checks** for anything going into main, **Release APK** for main.

| Lane | Trigger | What runs | Output |
|---|---|---|---|
| `Checks` | pull request into `main` | analyze, test, `flutter build web` | a green/red gate, no APK |
| `Release APK` | push to `main`, or manual dispatch | analyze, test, APK build, changelog, GitHub release | installable APK + release notes |

## Testing before you merge

Chrome is the fast loop — it mirrors the Flutter widget tree the APK runs:

```bash
flutter run -d chrome            # hot reload while you work
flutter build web --release      # what Checks runs
```

`flutter build web` is also worth running on a 360 px viewport, because the
narrow layout is where overflow shows up:

```bash
python3 -m http.server 3020 -d build/web
```

## Cutting a release

1. Bump `version:` in `pubspec.yaml` — `name+number`, e.g. `1.6.0+16`.
   The `name` part becomes the tag (`v1.6.0`) and the release title.
2. Merge into `main`.
3. `Release APK` builds, publishes `v1.6.0`, and commits the regenerated
   `CHANGELOG.md` back to main. The release page is the changelog, so the
   installable link and the "what changed" always live together.

A second push without a version bump still ships: the tag becomes
`v1.6.0+build.<run_number>`, so nothing is silently overwritten and no release
is ever published twice under one tag.

## Writing commit messages that read well

Release notes are generated from commit subjects by
[git-cliff](https://git-cliff.org), so the shape matters:

```
feat(cookbook): a to-cook / cooked toggle with counts
fix(journal): stop the header from overflowing at 360 px
docs: explain the version bump in RELEASING.md
```

`feat` -> Added, `fix` -> Fixed, `perf` -> Performance, `refactor`/`style` ->
Changed, `chore`/`ci`/`test`/`docs` get their own sections, and anything else
lands under "Other" instead of being dropped. The `(scope)` shows in italics.

## Changelog

`CHANGELOG.md` is generated, never hand-edited. The config lives in
`cliff.toml`; the Release workflow regenerates the file after every release and
commits it back to main.

Preview locally:

```bash
cargo install git-cliff          # or: brew install git-cliff
git cliff --unreleased --tag v1.6.0 --strip header   # one release's notes
git cliff --tag v1.6.0 --output CHANGELOG.md         # the whole file
```

Sections are cut at release tags (`vX.Y.Z`), so the history stays correct even
if a version bump is skipped between merges.

## Runner minutes

A release costs 7–10 minutes; a Checks run costs 2–3. That is why the APK is
built once per merge instead of on every push.
