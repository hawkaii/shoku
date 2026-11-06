# Architecture

What lives where, what may import what, and how a change proves itself. This is
the written version of the rules the code already follows — and of the ones the
stability program is enforcing.

Read [`docs/STABILITY.md`](STABILITY.md) first for why the program exists.

## The layers

```
presentation/screens, widgets     what the user sees and taps
        ↓
presentation/state                Riverpod providers and stores: async, caching, rules
        ↓
data/sync · data/services         the wire and the platform
        ↓
data/db · data/models             storage and value types
        ↓
core                              config, theme, text, l10n helpers
```

Dependencies point **down only**. A lower layer never imports a higher one:
`data/` does not know a screen exists, and `core/` knows nothing about Shoku's
domain.

| Path | Owns | May import |
|---|---|---|
| `core/config` | API base URL, Supabase keys, feature flags | Flutter only |
| `core/theme` | `ShokuTheme`, `ShokuColors`, type, spacing, radius | Flutter only |
| `core/l10n` | `context.l10n`, label and plural helpers | generated l10n |
| `core/utils` | pure text/format helpers | Dart only |
| `data/models` | immutable value types (`CookTimer`, `PantryItem`, …) | Dart, `core` |
| `data/db` | drift schema, DAOs, row↔model mapping | `models`, drift |
| `data/services` | HTTP clients, auth, prefs, platform plugins | `models`, `core/config` |
| `data/sync` | push/pull orchestration over db + API | `db`, `services`, `models` |
| `presentation/state` | providers/stores; all app-level async | `data`, `models` |
| `presentation/widgets/kit` | the visual language (buttons, sheets, type) | `core/theme` |
| `presentation/screens` | layout, gestures, copy | `state`, `widgets`, `core` |
| `presentation/navigation` | router, gate, shell | screens, state |

## Rules

1. **A screen does not construct a service.** It reads a provider
   (`ref.read(importServiceProvider)`), so a test can override it. `AuthService()`
   inside `build()` is the anti-pattern this rule exists to kill: it bypasses
   overrides and re-subscribes on every rebuild.
2. **No HTTP or database call in `build()`.** Build is a pure function of state.
   Work starts in a provider, a store method, or an explicit user action.
3. **Every `await` continuation that touches `context` or `setState` checks
   `mounted` first.** A disposed sheet is the normal case, not an edge case.
4. **Failures are typed and mapped once.** Services throw `ApiError`,
   `ApiUnauthenticated`, `AssistantCapReached`, `ImportCapReached`; screens map
   them to copy. An unknown failure is logged, never dropped.
5. **No user-visible English in Dart.** Every string is an ARB key in all ten
   locales; the l10n parity test is a required check. English in a
   `debugPrint` is fine.
6. **A feature owns one folder under `presentation/screens/`.** Shared visual
   pieces go in `widgets/kit/`; shared logic goes in `state/`. Do not create a
   second `utils/` for domain rules.
7. **A store owns one question.** `CookTimerStore` owns the timer,
   `JournalStore` owns the journal; a screen composes them. If two screens both
   need a rule, it belongs in a store, not in both screens.
8. **Persistence is explicit.** Anything that must survive a kill is written to
   the database or `SharedPreferences` before it becomes visible state
   (`PendingImport`, `PendingShare`, `CookTimer`). Memory alone is not a queue.

## State: Riverpod

- A `Provider` for a stateless dependency (service, repository, config).
- A `StateNotifierProvider` for a store with rules and mutations
  (`CookTimerStore`, `JournalStore`).
- A `FutureProvider`/`StreamProvider` for read-only async state.
- A `StateProvider` only for one primitive the UI writes directly (`pendingShare`).
- Overrides are the test seam: `ProviderScope(overrides: [...])` in a widget
  test, `ProviderContainer(overrides: [...])` in a unit test. No singleton with
  a `static` instance.
- A provider that starts work does it once and disposes it
  (`ref.onDispose`). Starting the same subscription in three widgets is a bug.

## Testing

| Layer | Test |
|---|---|
| model / pure function | unit test in `test/*_test.dart` |
| repository / store | unit test with a fake db or overridden provider |
| service | unit test with a fake HTTP client, never a real network |
| screen state | widget test at a phone size (320×568 counts), with the keyboard inset where relevant |
| contract | API tests in `api/tests/`, Python 3.12 |

Every bug fix starts with a test that fails for the reported reason. If the
bug is in a manifest or a platform channel, the test parses the manifest or
fakes the channel — see `test/android_manifest_test.dart`.

A widget test may not hit the network, the clock, or the real Supabase. If it
needs one, the provider is not injectable enough — fix that first.

## Errors

| Kind | Where it is caught | What the user sees |
|---|---|---|
| `ApiUnauthenticated` | the surface that needed auth | an inline sign-in action, never inert text |
| `ApiError` with a known reason | the screen | `reasonText(l10n, reason)` |
| cap reached | the screen | the cap notice and when it resets |
| anything else | the screen's catch | a generic line **and** a log |

`catch (_) {}` is allowed only for optional platform work (web, a plugin that
may not exist), with a comment saying why. The allow-list lives in issue #9.

## Adding a feature

1. Model it in `data/models` (immutable, `copyWith`, no Flutter imports).
2. Add the storage or wire method in `data/db` / `data/services`.
3. Expose it through a provider in `presentation/state`, with the failure typed.
4. Build the screen from the provider; no logic in `build()`.
5. Add copy to `app_en.arb`, run `flutter gen-l10n`, translate all ten.
6. Test the store, then the screen state; add the route last.

## Known debt

Measured, not guessed. These are the files where UI, async orchestration and
business rules currently live together; they are the extraction order.

| File | Lines | Extract |
|---|---|---|
| `presentation/screens/assistant/recipe_chat_sheet.dart` | 1002 | `ChatController` (send, retry, cap, sign-in) |
| `presentation/screens/dish/dish_screen.dart` | 961 | `DishPageController` (versions, cook launch, actions) |
| `presentation/screens/pantry/pantry_add_screen.dart` | 719 | `PantryAddController` (capture, parse, save) |
| `presentation/screens/onboarding/onboarding_screen.dart` | 718 | step state machine |
| `presentation/screens/journal/journal_screen.dart` | 696 | timeline composition |
| `presentation/screens/bot/bot_surface.dart` | 670 | `BotController` |
| `presentation/screens/pantry/pantry_screen.dart` | 646 | row actions |

Extraction is only worth it with tests around the extracted controller; doing
it to shorten a file is churn.

## Enforcement

CI (`.github/workflows/checks.yml`) runs on every PR:

```
flutter gen-l10n && dart format lib/l10n && git diff --exit-code -- lib/l10n
flutter test test/l10n_keys_test.dart
flutter analyze --fatal-infos
flutter test
cd api && pytest          # Python 3.12
```

`dev` and `main` require a pull request and both checks (ruleset "Stability
gate"). `main` is only updated by a PR from `dev`.

The analyzer currently runs `package:flutter_lints/flutter.yaml` with infos
fatal. Stricter rules (`unawaited_futures`, `avoid_dynamic_calls`) are **not**
enabled yet: the codebase has existing violations, and turning them on with
`// ignore` comments would be the slop this document exists to prevent. The
next increment enables one rule at a time, fixes every site, and leaves the
rule on.
