# Shoku

A cooking journal that remembers every version of a dish — what you changed, how
it turned out, and the photo you took when it did.

No feed, no social graph, no grocery-list builder. The point of the app is the
thing you built up over time: `v1` to `vN` of your own cooking.

## What it does

- **Journal** — a timeline of cooks, with the dish you have on the counter today.
- **Cookbook** — two shelves: what you still `To cook`, and what you've `Cooked`,
  each dish carrying its version number and status badge.
- **Cook mode** — swipeable steps, drawn diagrams for each technique, timers, and
  an assistant that answers questions without touching the recipe.
- **Debrief** — rating, mood, what changed, one photo. Saving is what commits a
  new version.
- **Dish dossier** — every version, what changed between them, and the cook log.
- **Wall** — the photos, private for now.
- **Nutrition** — coming soon, and says so rather than showing invented numbers.

## Running it

Requires Flutter (stable) and, for Android, Java 17.

```bash
flutter pub get
flutter run -d chrome      # fast loop: Chrome, hot reload
flutter run -d <device>    # phone over adb
```

Build artifacts:

```bash
flutter build web --release     # what CI checks on every pull request
flutter build apk --debug       # what releases are made of
```

## Tests

```bash
flutter analyze
flutter test
```

## Design

The visual language is documented in [DESIGN.md](DESIGN.md): paper, ink, crimson,
saffron and bay, one brutalist call-to-action, drawn diagrams instead of stock
photography.

## Releasing

Merging to `main` builds and publishes an installable APK; pull requests are
gated by analyze, tests and a web build. Version bumps, commit message rules and
the changelog are covered in [RELEASING.md](RELEASING.md); the history itself is
in [CHANGELOG.md](CHANGELOG.md).
