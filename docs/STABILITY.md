# Shoku stability program

Status: **active** · Base: `dev` at `v1.29.5` · Owner: this program · Scope: app + API correctness, not features

## Why this exists

Three failures were reported from daily use of `v1.29.5`:

| Report | Reality on `main` |
|---|---|
| "import reel doesn't work when I share the first time" | The share listener only starts inside `AppShell`, which is not mounted while onboarding or the splash gate is up. A cold-start share is read once, held in memory, and dropped. |
| "the sign-in isn't placed properly" | The sheet is a non-scrollable `Column` with `viewInsets` padding and no `SafeArea`; the keyboard overflows it. Three other surfaces tell the user to sign in with no way to do it. |
| "the timer doesn't do any notification or alarm" | `flutter_local_notifications` schedules into `ScheduledNotificationReceiver`, which the app never declares in its manifest. The alarm is created, then silently dropped by Android. No boot receiver either. |

An audit of the whole app found two data-integrity defects that matter more than any of those:

* `markClean` never clears `dirty` for `pantry_items` or `photos`, so every sync re-pushes them forever.
* The pull ignores `has_more`; anything past the first 500-row page of a table is skipped permanently because the cursor advances anyway.

"Stable" therefore means **no silent loss**: no lost share, no lost alarm, no lost row, no lost page, no lost error. It does not mean "no features".

## Definition of done

A workstream is done when all of these are true:

1. The failure has a test that fails before the fix and passes after it. Android-manifest fixes are proven by a test that parses the manifest, plus a device check where one is possible.
2. `flutter analyze --fatal-infos` reports zero issues.
3. `flutter test` passes in full, not just the new tests.
4. `cd api && pytest` passes on **Python 3.12** (never a newer local venv).
5. The behaviour is observable: a user-visible failure says so on screen, and a non-visible one is logged.
6. The change is one PR to `dev`, reviewed against this document, with the issue linked.

## Branch and release model

```
main ──●──────────────────────────────●──  (release commits only)
        \                            /
         ●──●──●──●──●──●──●──●──●──●      dev  (integration)
            \    \      /
             ●    ●    ●                   fix/*  (one issue each)
```

* `main` is only updated by a PR from `dev`, after the full gate below.
* `dev` is only updated by PRs. Direct commits are limited to this document.
* Every PR runs `.github/workflows/checks.yml` (analyze, l10n parity, Flutter tests, API tests). A red check blocks the merge.
* One issue per PR, except where two issues share a file and cannot be separated without a flag day; then one PR closes both and says so.

## Workstreams

### WS0 — Gate (`ci`)

A `checks.yml` workflow on every PR and every push to `dev`:

* `flutter analyze --fatal-infos`
* `flutter gen-l10n` + the l10n parity test
* `flutter test`
* `cd api && pytest` on `python:3.12`
* Marked as required in the branch ruleset.

Acceptance: a deliberately broken commit on a scratch PR fails the check; the same commit with the break reverted passes.

### WS1 — Timers ring (`app`)

Root cause: missing `<receiver>` declarations and `RECEIVE_BOOT_COMPLETED`.

* Declare `ScheduledNotificationReceiver` and `ScheduledNotificationBootReceiver` (with the boot intent filter) in the main manifest.
* Add `RECEIVE_BOOT_COMPLETED`.
* Surface `TimerAlertPermission.unavailable` in `timer_card.dart` instead of rendering nothing.
* Move the notification title and body through `AppLocalizations`; they are hardcoded English today in a ten-locale app.
* Re-check `canScheduleExactNotifications()` on resume rather than caching the answer for the process.
* Remove the stale "it will not alert you" comment in `cook_timer.dart`; it contradicts the shipped code.
* Add a manifest test (receivers + permission present) and a `LocalTimerAlerts` test with a fake plugin that asserts the argument shape.

Acceptance: with the app backgrounded and the screen off, a 1-minute timer posts a notification at the expected minute. Verified on a physical device.

### WS2 — A shared reel survives the gate (`app`)

Root cause: `ShareIntake` lives in `AppShell`, reads the launching intent exactly once, and holds it in memory.

* Move intake to app scope: start it from `main()` (or an eagerly watched provider) before the router gate can redirect.
* Persist the extracted URL immediately (`SharedPreferences`), with the same pattern as `PendingImportStore`.
* Consume it from one place once a navigator exists; make it work from `/welcome`, `/splash`, and a warm shell.
* Handle a share with no URL (image-only, caption-only) by opening the import sheet with an explanation instead of resetting silently.
* Widen the manifest filters to the plugin's contract: `text/*`, `video/*`, `SEND_MULTIPLE` for `*/*`; remove `taskAffinity=""` unless proven necessary for `singleTask` delivery.
* If the user is signed out, the import sheet offers an inline **Sign in** action that opens the sheet and retries the same URL.
* Tests: cold start with an initial payload, warm `onNewIntent`, no-URL payload, payload consumed after onboarding.

Acceptance: after a force-stop, sharing a reel from Instagram opens Shoku directly on the import sheet, with the URL filled and the import running. On a first install, the same share survives onboarding and lands on the sheet after the user finishes it.

### WS3 — Sign-in that fits (`app`)

Root cause: non-scrollable sheet, no safe area, and dead-end prompts.

* Wrap the sheet in `SafeArea` + `SingleChildScrollView`; keep `viewInsets` padding.
* Add `ShokuSheetHeader` (drag handle + close) so it matches the other sheets.
* `AutofillGroup`, `autofillHints`, `textInputAction.next/done`, password visibility toggle, submit on done.
* Use `authServiceProvider`, not `AuthService()` in `build()`; hoist the stream.
* Make the `importSignIn` and `botSignInNotice` surfaces actionable (same sheet, then continue).
* Fix the same non-scrollable pattern in `import_sheet.dart`.
* Define the email-confirmation return path: register the `com.shoku.app` scheme in Android + iOS, or switch to a code flow. Until one exists, the sheet must not promise a link that cannot work.
* Tests: sheet layout at 320×568 with keyboard inset; signed-out import shows a working sign-in action.

Acceptance: on a 5" phone, with the keyboard up, every field and the submit button remain reachable. No `RenderFlex overflow` in the widget test.

### WS4 — Sync converges (`app`)

Root causes: `markClean` misses two tables; `has_more` ignored; concurrent `syncNow` dropped.

* Clear `dirty` for `pantry_items` and `photos` in the same transaction that handles dishes/versions/logs.
* Loop `pull` until `has_more == false` (with a hard page cap and a progress callback) before writing the cursor.
* Queue a sync requested during a running pass and run exactly one more pass after it.
* Tests: a page sequence `has_more: true → false` pulls every row; `dirtyCount` reaches 0 after a push containing pantry/photos; a mutation during a pass is not dropped.

Acceptance: after ten minutes of editing, `dirtyCount` is 0 and no row is re-pushed. A >500-row table pulls completely.

### WS5 — One import, one dish (`app`)

* Add `mounted` guards to every `setState` after `await` in `import_sheet.dart`.
* Single-flight `createDish(shortcode)` so the sheet's poller and the tracker's poller cannot both insert.
* Tests: dismissing the sheet mid-start raises no error; two concurrent `createDish` calls produce one dish.

Acceptance: closing the sheet during an import cannot crash it; a job adopted by both pollers produces exactly one dish.

### WS6 — Errors are not swallowed (`app`)

* Replace silent `catch (_) {}` on user-visible paths with a logged, typed failure.
* Keep bare catches only for optional platform work, with a comment saying why.
* Add `FlutterError.onError` + `PlatformDispatcher.onError` that log in release (no third-party SDK yet).
* Add a route `errorBuilder` and preserve the destination through the gate redirect.

Acceptance: the count of unexplained `catch (_)` drops to the documented allow-list; a bad deep link shows an in-app error, not GoRouter's red screen.

### WS7 — Written structure (`docs`)

* `docs/ARCHITECTURE.md`: the layer rules (`core` / `data` / `presentation` / `state`), what may import what, where async work lives, and the "no business logic in a 900-line screen" rule.
* Record the state architecture (Riverpod providers own async; screens own layout) and the testing rule (a widget test per screen state, a unit test per store).
* Link it from `README.md`.

Acceptance: a new contributor can answer "where does this file go?" from the document alone.

## What the reference app teaches

The comparison app (`bwi-cabswalle`, ~10k active users, 51 Dart files) was read end to end. It is **not** a model to copy wholesale: it has no tests, no CI, no migrated checks, no share intake and no local notifications, and it swallows errors at the same rate this app does. What is worth taking:

* **One boot gate that owns all startup async.** Its splash decides everything and nothing else does startup work. Shoku already has this shape (`AppGate` + `authReadyProvider`); the share bug is what happens when a feature ignores it. Fix the rule, not only the symptom: startup work belongs in the gate or in an app-scope provider, never in a shell that may not be mounted.
* **Version gating that refuses to be dismissed.** An outdated client is a support burden. Out of scope for this milestone, but the mechanism (block on a minimum version) is the honest way to retire a broken build.
* **Localisation as a first-class concern.** Its `gen-l10n` setup with a persisted locale is clean, and it guards `setLocal` against unsupported locales. Shoku is ahead here (ten locales at parity); keep the parity test as a required check.
* **Optimistic write with rollback.** The one place it treats a remote write as fallible. Useful for the fridge later.
* **What not to copy:** provider-as-repository, navigation through `showDialog`, `static BuildContext`, unawaited `static async` init, zero `mounted` checks, `catch`-to-empty-list, print logging, a committed keystore, and a template test that would fail if anyone ran it. Each of those has a Shoku counterpart in the findings above; that is why this program exists.

The lesson that drives the plan: **the reference app's age did not make it stable, its gate did.** Every fix here ends at the gate — a test, a check, or a visible state.

## Out of scope (separate programs)

* Play submission: applicationId, upload keystore, AAB, HTTPS, data-safety form, store assets. Tracked in `PLAY_STORE_READINESS.md`.
* Import/ask caps and paywall.
* New product features, including anything on `voice-hands-free`.

## Verification log

### 2026-11-06 — `dev` at `1b91825`, released as `1.30.0`

| Gate | Command | Result |
|---|---|---|
| Analyzer | `flutter analyze --fatal-infos` | No issues found |
| Flutter tests | `flutter test` | **387 passed, 0 failed** |
| API tests | `docker run python:3.12-slim … pytest` | **292 passed** |
| l10n | `gen-l10n && dart format && git diff --exit-code` | stable, 10 locales at parity |
| Android packaging | CI `Android build` on `dev` (run `42215997782`) | APK assembled; merged manifest contains both notification receivers, `RECEIVE_BOOT_COMPLETED`, `SEND_MULTIPLE` |

| Workstream | PR | Evidence |
|---|---|---|
| WS0 gate | #12, #25 | a deliberately broken commit goes red; the APK job asserts the **merged** manifest |
| WS1 timers | #13, #22 | 23 new tests, including a Hindi notification body proving the copy is not hardcoded |
| WS2 share | #13, #26 | 10 new tests: cold start, warm, no-link, persisted-after-gate, consume-once |
| WS3 sign-in | #21, #23 | 320×568 + 300 px keyboard inset with no overflow; signed-out surfaces open the sheet and retry |
| WS4 sync | #20 | dirty reaches 0 for all five tables; `has_more` pages loop with a bound; a pass during a pass is queued |
| WS5 import | #29 | dismiss mid-request raises nothing; concurrent `createDish` produces one dish |
| WS6 errors | #28, #30 | 56 bare catches → 0 unexplained; global framework and async handlers |
| WS7 docs | #14, #24 | architecture, module map, measured debt; in-app route error |

**Not verifiable in this environment, still required on a phone:**

1. A 1-minute cook timer with the screen locked rings at the minute; record the
   schedule→fire delta.
2. Denying notifications shows "alerts are off" while the countdown continues;
   denying exact alarms shows "late"; granting "Alarms & reminders" while a
   timer runs clears the note without a restart.
3. Force-stop, share an Instagram reel: Shoku opens on the import sheet,
   prefilled and importing. Repeat on a fresh install through onboarding.
4. An image-only share shows the no-link notice; a signed-out share offers
   **Sign in** and imports the same URL afterwards.
5. A 5" phone with the keyboard up: every sign-in control is reachable.
6. Two devices converge to `dirtyCount == 0`; a >500-row table restores fully on
   an empty device.

The machine used for this work has no Android SDK or device; the APK was
assembled by CI, which is why the merged-manifest assertions live in the
workflow rather than in a local script.

