# Integration tests

These run on a real device or emulator, not on the host. They are **not** part of
`flutter test` (which runs the unit/widget suite) and are not yet a required
check.

## Running locally

```bash
flutter devices                      # must list a phone or emulator
flutter test integration_test/ -d <device-id>
```

## What exists

- `app_test.dart` — boots the app and paints the first screen. Runs anywhere a
  device exists.

## What still needs a device (manual until an emulator job exists)

These are the acceptance criteria from `docs/STABILITY.md` that cannot be
automated today. Each is a one-line check on a phone:

1. A 1-minute cook timer with the screen locked rings at the minute (record the
   schedule→fire delta).
2. Denying notifications shows "alerts are off" while the countdown continues;
   denying exact alarms shows "late"; granting "Alarms & reminders" while a
   timer runs clears the note without a restart.
3. Force-stop, share an Instagram reel: Shoku opens on the import sheet,
   prefilled and importing. Repeat on a fresh install through onboarding.
4. An image-only share shows the no-link notice; a signed-out share offers
   **Sign in** and imports the same URL afterwards.
5. A 5" phone with the keyboard up: every sign-in control is reachable.
6. Two devices converge to `dirtyCount == 0`; a >500-row table restores fully
   on an empty device.

When an emulator job is added (`.github/workflows/integration.yml`), items 1–6
become automated and this file shrinks.
