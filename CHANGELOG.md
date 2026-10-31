# Changelog

What changed in each Shoku build, newest first. Generated from commit history
by [git-cliff](https://git-cliff.org) — see RELEASING.md, don't hand-edit.

## [1.19.1] — 2026-10-31

### Docs
- V1.19.0 [skip ci] *(changelog)* — [`20346de`](https://github.com/hawkaii/food-finder-app/commit/20346dedcc486ded3d2c9f7578ed5d273047d1e8)

### Fixed
- Treat a waking worker as a stage, and name a dead one *(import)* — [`0028484`](https://github.com/hawkaii/food-finder-app/commit/00284843a00f0995821e6a2c7815e500b3739c73)

## [1.19.0] — 2026-10-31

### Added
- Carry tags on the wire, and say when amounts were read off video *(recipe)* — [`2d9a368`](https://github.com/hawkaii/food-finder-app/commit/2d9a368bc057db70753912e3a9d61608af56c760)
- Show the mood and the rating of each cook again *(journal)* — [`05439c4`](https://github.com/hawkaii/food-finder-app/commit/05439c4177c8b398d1b3b30b3c1cc780c72b131a)

### CI
- Cache Gradle and stop building commits that cannot change the APK — [`07a7bb5`](https://github.com/hawkaii/food-finder-app/commit/07a7bb591f7bdfb8e16620a4313183a96e6946f0)
- A release is a version bump, not a commit — [`e9ffabc`](https://github.com/hawkaii/food-finder-app/commit/e9ffabc1f0c978cbeb797aab7c7a9e7491196b47)

### Docs
- V1.17.1 [skip ci] *(changelog)* — [`152578c`](https://github.com/hawkaii/food-finder-app/commit/152578c33985d48ca092c84249b76a8d6839e57a)
- V1.18.0 [skip ci] *(changelog)* — [`5d5b300`](https://github.com/hawkaii/food-finder-app/commit/5d5b3006b9ee64338a589f8cc07c07faa2cb6dd9)

## [1.18.0] — 2026-10-31

### Added
- A public feed of shared reels, and a way to share one *(wall)* — [`af28b47`](https://github.com/hawkaii/food-finder-app/commit/af28b47cf54f264867f5005d7742a4ea0dacccf4)

## [1.17.1] — 2026-10-31

### Docs
- V1.17.0 [skip ci] *(changelog)* — [`1c357d9`](https://github.com/hawkaii/food-finder-app/commit/1c357d96bfc72baa8535547a8c36956803b123b1)

### Fixed
- Wait four minutes for a reel the server is still reading *(import)* — [`544cf1c`](https://github.com/hawkaii/food-finder-app/commit/544cf1cf48c4abfd57027c3edb168c223c5279da)

## [1.17.0] — 2026-10-31

### Added
- Ring a timer with the phone in a pocket *(cook)* — [`3f20c56`](https://github.com/hawkaii/food-finder-app/commit/3f20c56a2c9f5d1d6d5592de3dc0f344c2d921a2)

### CI
- A changelog push must not fail a shipped release — [`d76b6fb`](https://github.com/hawkaii/food-finder-app/commit/d76b6fb8bf7fcbaf04085ee1c6507e68aa0cec4f)

### Docs
- V1.15.0 [skip ci] *(changelog)* — [`68a66f1`](https://github.com/hawkaii/food-finder-app/commit/68a66f1ad6d92eadbb49fe9fcaab411fe90b7bd3)

## [1.16.0] — 2026-10-31

### Added
- Long-press a card to move it or remove it from the journal *(cookbook)* — [`1178f69`](https://github.com/hawkaii/food-finder-app/commit/1178f69bfa4ceae11b7fdeb739b7ecc23d64efaf)

### Fixed
- Read step links from the recipe payload, where the API puts them *(recipe)* — [`355adf8`](https://github.com/hawkaii/food-finder-app/commit/355adf8663d330282d228480b0ca5b72fb4fcfe4)

## [1.15.0] — 2026-10-31

### Added
- Show each step's ingredients in the recipe's own words *(recipe)* — [`52acae3`](https://github.com/hawkaii/food-finder-app/commit/52acae3660e73aed7ea3bfb0576915ed4c0627b3)

### Docs
- V1.14.0 [skip ci] *(changelog)* — [`290b8d3`](https://github.com/hawkaii/food-finder-app/commit/290b8d3753bf8a774873f48ffa814f046c912f97)

## [1.14.1] — 2026-10-31

### Fixed
- Keep an import alive through a dropped poll and a restart *(import)* — [`3acde63`](https://github.com/hawkaii/food-finder-app/commit/3acde631595c2aed72a9adf82c03b57e61aad140)

## [1.14.0] — 2026-10-31

### Added
- A timer that survives the app being killed *(cook)* — [`76828bf`](https://github.com/hawkaii/food-finder-app/commit/76828bfb547b4f305dd29d1b39f80841bec3cd49)

### Docs
- V1.13.0 [skip ci] *(changelog)* — [`e6bb635`](https://github.com/hawkaii/food-finder-app/commit/e6bb635a3e18a9630cd7c8b105bc4eb3cbf32110)

## [1.13.0] — 2026-10-31

### Docs
- V1.12.0 [skip ci] *(changelog)* — [`d91beb3`](https://github.com/hawkaii/food-finder-app/commit/d91beb339efaceaca65485d6533d01ef5a467c51)

### Fixed
- Fill the journal on sign-in instead of waiting for a reload *(sync)* — [`6309fef`](https://github.com/hawkaii/food-finder-app/commit/6309fef1b53e54db31623f89a43643451ed9eaca)
- Signing in now pulls the journal, and the app says when it is syncing *(sync)* — [`bcabe4f`](https://github.com/hawkaii/food-finder-app/commit/bcabe4f97cfd546028ad0dc469d86c33f4d1791f)

## [1.12.0] — 2026-10-31

### Added
- Ship an empty app instead of a demo kitchen — [`7d002bc`](https://github.com/hawkaii/food-finder-app/commit/7d002bc758e6f8159acbfcd14d04ff17a1206447)

### Docs
- V1.11.0 [skip ci] *(changelog)* — [`de2307d`](https://github.com/hawkaii/food-finder-app/commit/de2307d3a08b2fe3b3e17d30030e4bff2660d52c)

## [1.11.0] — 2026-10-31

### Added
- Say when a reel has nothing to read, and when we are watching it *(import)* — [`c0673d6`](https://github.com/hawkaii/food-finder-app/commit/c0673d60f7bca1664b300a4274dec61c6fc32ffb)

### Docs
- V1.10.0 [skip ci] *(changelog)* — [`9dda98e`](https://github.com/hawkaii/food-finder-app/commit/9dda98e6c683d2b43f3083b16310b1266301f7a1)

## [1.10.0] — 2026-10-31

### Added
- Reel thumbnail as cover, creator handle, and a link back to the reel *(dish)* — [`e13d971`](https://github.com/hawkaii/food-finder-app/commit/e13d9718703dca818a8cfcf9b618a48aca635a2b)

### Docs
- V1.9.3 [skip ci] *(changelog)* — [`f991ef5`](https://github.com/hawkaii/food-finder-app/commit/f991ef527a57cdc76010a1ec97098ca680eaa958)

## [1.9.3] — 2026-10-31

### Docs
- V1.9.2 [skip ci] *(changelog)* — [`29d80d0`](https://github.com/hawkaii/food-finder-app/commit/29d80d086268bda42b4c21cc089756d63da22e1a)

### Fixed
- Say when the platform is blocking us instead of 'could not read' *(import)* — [`5b328bc`](https://github.com/hawkaii/food-finder-app/commit/5b328bcd784df2a757b995c4e4fa4b9dbf08727c)

## [1.9.2] — 2026-10-30

### Docs
- V1.9.1 [skip ci] *(changelog)* — [`47394fd`](https://github.com/hawkaii/food-finder-app/commit/47394fd4737555bda866e8ae2215c39cb409841a)

### Fixed
- Follow the device theme instead of forcing light *(theme)* — [`594143b`](https://github.com/hawkaii/food-finder-app/commit/594143b93a0d0461dad4b62a4b6f1136e359b976)

## [1.9.1] — 2026-10-30

### Docs
- V1.9.0 [skip ci] *(changelog)* — [`57a93b0`](https://github.com/hawkaii/food-finder-app/commit/57a93b005306c8e7709e220e6276081b30e27886)

### Fixed
- Report the server's reason instead of 'could not reach server' *(import)* — [`117fb1c`](https://github.com/hawkaii/food-finder-app/commit/117fb1c658eb32395f9d6c79cfa13f1c65903c4f)

## [1.9.0] — 2026-10-30

### Added
- Push/pull sync engine, launch+post-write triggers, import a reel end to end *(sync)* — [`a13b5ad`](https://github.com/hawkaii/food-finder-app/commit/a13b5addfb7d212aca581ff494496f0a28827002)

### Docs
- V1.7.0 [skip ci] *(changelog)* — [`2f60f49`](https://github.com/hawkaii/food-finder-app/commit/2f60f49e105a08a669a2ff5a7b6226a7c5a3d88e)

## [1.7.0] — 2026-10-30

### Added
- Supabase sign-in, API client with bearer token, account row in profile *(auth)* — [`98db607`](https://github.com/hawkaii/food-finder-app/commit/98db6071cb9c3d5ce3f2ba1cefaebbdb61b3ba47)

### Docs
- V1.6.1 [skip ci] *(changelog)* — [`4ea64de`](https://github.com/hawkaii/food-finder-app/commit/4ea64de03cb5fe2392103a335de0d36696b5f791)

## [1.6.1] — 2026-10-30

### Docs
- V1.6.0 [skip ci] *(changelog)* — [`917c0eb`](https://github.com/hawkaii/food-finder-app/commit/917c0ebc898f25779d51f82c67827c210b0b59ed)

### Fixed
- Make every cook path persist, and migrate timestamps to text *(journal)* — [`5475825`](https://github.com/hawkaii/food-finder-app/commit/547582543b01d0421cebdf89d28e7a67b30d33e2)

## [1.6.0] — 2026-10-30

### Added
- Persist the journal in drift, with a sync-ready schema *(journal)* — [`78fe583`](https://github.com/hawkaii/food-finder-app/commit/78fe583bd81bb0ca100fd17d9016a35b4841f198)

### Docs
- V1.5.1 [skip ci] *(changelog)* — [`f0d45d9`](https://github.com/hawkaii/food-finder-app/commit/f0d45d916e40bf1e494c80e31af7a67ec57575eb)

## [1.5.1] — 2026-10-30

### Fixed
- Write CHANGELOG.md from the git-cliff output, bump action majors *(ci)* — [`1036b01`](https://github.com/hawkaii/food-finder-app/commit/1036b01eab1ed4e4a7886ca6f1ad36980d977609)

## [1.5.0] — 2026-10-30

### Added
- Plate mark as launcher + in-app, app-level exit guard, auto-publish every build *(brand)* — [`e4eff0d`](https://github.com/hawkaii/food-finder-app/commit/e4eff0da6b193101d7878e63860053114083521b)
- To-cook/cooked status badges, two-state cookbook filter, real cook photo, nutrition coming soon, 360px overflow fixes — [`646d592`](https://github.com/hawkaii/food-finder-app/commit/646d5921f2dcb24f0afd4f8876b8dec71e947e07)

### CI
- Git-cliff changelog, APK only on main, checks on pull requests *(release)* — [`4cf80dc`](https://github.com/hawkaii/food-finder-app/commit/4cf80dc11d5e58854c3b60a16b9b1816722ecc6f)

### Fixed
- Regenerate launcher icons from one render so no size is blank *(brand)* — [`b7a3688`](https://github.com/hawkaii/food-finder-app/commit/b7a36884cabe090b4eaa80ac6ae2d5a9f6660b44)

## [1.4.0] — 2026-10-29

### Added
- Plate-and-knife diagram language, drawn step diagrams, floating AI in cook mode, onboarding arrow *(visual)* — [`c970174`](https://github.com/hawkaii/food-finder-app/commit/c97017479ef960fe7c21f6b8bcbeb8d21e52c4ef)

## [1.3.0] — 2026-10-29

### Added
- Cook mode, debrief commit, version memory, wall, nutrition lens, share intake, interactive onboarding — [`23d0686`](https://github.com/hawkaii/food-finder-app/commit/23d0686d90cdb6480877fc2519f4073922a5ab2d)

### Tests
- Settle onboarding animations before asserting — [`7ea1bcb`](https://github.com/hawkaii/food-finder-app/commit/7ea1bcb7e4e48d9e78a630871d2a407cbc4d34fa)
- Assert onboarding CTA instead of animated copy — [`56d0a75`](https://github.com/hawkaii/food-finder-app/commit/56d0a75763fe64949d9d6b7f2098bb3ffc8225bc)

## [1.2.0] — 2026-10-29

### Added
- Onboarding v2 (persisted, interactive share demo), back/exit handling, share-sheet intent, bundled fonts — [`648c376`](https://github.com/hawkaii/food-finder-app/commit/648c3760be406ffcc62d791619cfcf937f0eecff)

## [1.1.0] — 2026-10-29

### Added
- Cook journal IA — dish/version/cook-log model, photo timeline, motion system, 4-tab shell — [`b16f88d`](https://github.com/hawkaii/food-finder-app/commit/b16f88d96d1b4e25d0d5ca01180633c2fc7186c0)

## [1.0.0] — 2026-10-29

### Added
- Shoku design language — kitchen ticket theme, 13-component kit, 5-tab shell, 10 screens, mock data *(ui)* — [`0794b62`](https://github.com/hawkaii/food-finder-app/commit/0794b628f9dc7d98e0e7ed82cdd688039881bb06)
- Paper palette, crimson accent, gradient system; food-only notes *(ui)* — [`85ec9fc`](https://github.com/hawkaii/food-finder-app/commit/85ec9fcd636373129bfc93f1ed559e205696346d)

### Chores
- Name the app Shoku on the launcher — [`7beb6f1`](https://github.com/hawkaii/food-finder-app/commit/7beb6f1f519fce3725f97008ed4c6378c6dc6e7c)

## [1.0.0-debug] — 2026-10-29

### CI
- Build debug APK on GitHub Actions — [`142d6b0`](https://github.com/hawkaii/food-finder-app/commit/142d6b06db1e9d9a35534b4cff6ca07815156a7d)

### Other
- Initial — [`6f341ba`](https://github.com/hawkaii/food-finder-app/commit/6f341ba74db2dfa72d0d638a8b5c5117898c518b)
- Nutri flow till now — [`c65cf7a`](https://github.com/hawkaii/food-finder-app/commit/c65cf7a67b66ed49357c3b5c270246501ee16f6d)
- Nutrition flow changes before backup — [`cc26c8a`](https://github.com/hawkaii/food-finder-app/commit/cc26c8a71c7f71ae59472e9bec858ff71282b16d)


