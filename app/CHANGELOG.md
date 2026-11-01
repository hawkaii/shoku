## [1.22.1] - 2026-11-01

### 🚀 Features

- *(ui)* Shoku design language — kitchen ticket theme, 13-component kit, 5-tab shell, 10 screens, mock data
- *(ui)* Paper palette, crimson accent, gradient system; food-only notes
- Cook journal IA — dish/version/cook-log model, photo timeline, motion system, 4-tab shell
- Onboarding v2 (persisted, interactive share demo), back/exit handling, share-sheet intent, bundled fonts
- Cook mode, debrief commit, version memory, wall, nutrition lens, share intake, interactive onboarding
- *(visual)* Plate-and-knife diagram language, drawn step diagrams, floating AI in cook mode, onboarding arrow
- *(brand)* Plate mark as launcher + in-app, app-level exit guard, auto-publish every build
- To-cook/cooked status badges, two-state cookbook filter, real cook photo, nutrition coming soon, 360px overflow fixes
- *(journal)* Persist the journal in drift, with a sync-ready schema
- *(auth)* Supabase sign-in, API client with bearer token, account row in profile
- *(sync)* Push/pull sync engine, launch+post-write triggers, import a reel end to end
- *(dish)* Reel thumbnail as cover, creator handle, and a link back to the reel
- *(import)* Say when a reel has nothing to read, and when we are watching it
- Ship an empty app instead of a demo kitchen
- *(cook)* A timer that survives the app being killed
- *(recipe)* Show each step's ingredients in the recipe's own words
- *(cookbook)* Long-press a card to move it or remove it from the journal
- *(cook)* Ring a timer with the phone in a pocket
- *(wall)* A public feed of shared reels, and a way to share one
- *(recipe)* Carry tags on the wire, and say when amounts were read off video
- *(journal)* Show the mood and the rating of each cook again
- *(journal)* Show a running import by name until it lands
- *(wall)* Tapping a card opens the reel's extraction
- Shoku backend — sync, imports, content cache, assistant, photos
- Backend rewrite — routes, imports pipeline, sync, alembic, 60 tests
- *(auth)* Verify Supabase JWTs against the project JWKS
- *(imports)* Real yt-dlp extractor, faster-whisper transcriber, heuristic structurer + redis queue
- *(imports)* Use published YouTube subtitles instead of ASR when available
- *(api)* CORS for the Flutter web build
- *(provenance)* Thumbnail, platform and creator handle; model structurer with heuristic fallback
- *(imports)* Provenance columns + explain platform blocks instead of internal_error
- *(imports)* Read the pinned comment when the caption has no recipe
- *(imports)* Decode shortcode to media id so the comments endpoint works
- *(structurer)* Meta Muse with schema-constrained decoding
- *(imports)* Read silent reels from frames; never show a numeric handle
- *(sync)* Photos as a fourth append-only table
- *(content)* A step can name the ingredients it uses
- *(feed)* The Wall publishes an extraction, never a users work
- *(imports)* Re-parse cached reels so they carry step_ingredients
- *(sync)* A version carries the extraction tags
- *(worker)* A queued job wakes the VM, an idle worker stops it
- *(feed)* The Wall is every imported reel, minus takedowns
- *(thumbnails)* Copy a reel cover into our storage, once
- *(storage)* Google Cloud Storage backend, signed by the VM identity

### 🐛 Bug Fixes

- *(brand)* Regenerate launcher icons from one render so no size is blank
- *(ci)* Write CHANGELOG.md from the git-cliff output, bump action majors
- *(journal)* Make every cook path persist, and migrate timestamps to text
- *(import)* Report the server's reason instead of 'could not reach server'
- *(theme)* Follow the device theme instead of forcing light
- *(import)* Say when the platform is blocking us instead of 'could not read'
- *(sync)* Fill the journal on sign-in instead of waiting for a reload
- *(sync)* Signing in now pulls the journal, and the app says when it is syncing
- *(import)* Keep an import alive through a dropped poll and a restart
- *(recipe)* Read step links from the recipe payload, where the API puts them
- *(import)* Wait four minutes for a reel the server is still reading
- *(import)* Treat a waking worker as a stage, and name a dead one
- *(import)* Keep the poller alive for the whole app, not just the Journal
- *(ui)* A photo slot is never a grey box, and the Wall header stops repeating itself
- *(worker)* Treat an empty blocking pop as no job, and never die on a bad one
- *(queue)* Catch redis.exceptions.TimeoutError, not the builtin
- *(imports)* Fail with invalid_recipe, not internal_error, when text has no recipe
- *(imports)* Give yt-dlp a JS runtime; YouTube refuses to extract without one
- *(imports)* Report a platform block as source_blocked, not invalid_recipe
- *(worker)* Mount cookies relative to the compose file's parent
- *(worker)* Cookies must be writable — yt-dlp refreshes the jar
- *(imports)* Call the comments endpoint with the CSRF header Instagram requires
- *(structurer)* Provenance names the parser that actually ran
- *(imports)* A stale parse is re-extracted, not served forever
- *(imports)* Defer annotations so Python 3.12 can import the pipeline
- *(imports)* Fall back to the video when the text yields no recipe
- *(sync)* Accept origin_handle and origin_platform on version rows
- *(worker)* Load the speech model before the first job, on a volume
- *(imports)* A 180s ceiling, because 60s failed every reel over ~50s
- *(storage)* Sign presigned URLs by impersonating the machine identity

### 📚 Documentation

- *(changelog)* V1.5.1 [skip ci]
- *(changelog)* V1.6.0 [skip ci]
- *(changelog)* V1.6.1 [skip ci]
- *(changelog)* V1.7.0 [skip ci]
- *(changelog)* V1.9.0 [skip ci]
- *(changelog)* V1.9.1 [skip ci]
- *(changelog)* V1.9.2 [skip ci]
- *(changelog)* V1.9.3 [skip ci]
- *(changelog)* V1.10.0 [skip ci]
- *(changelog)* V1.11.0 [skip ci]
- *(changelog)* V1.12.0 [skip ci]
- *(changelog)* V1.13.0 [skip ci]
- *(changelog)* V1.14.0 [skip ci]
- *(changelog)* V1.15.0 [skip ci]
- *(changelog)* V1.17.0 [skip ci]
- *(changelog)* V1.17.1 [skip ci]
- *(changelog)* V1.18.0 [skip ci]
- *(changelog)* V1.19.0 [skip ci]
- *(changelog)* V1.19.1 [skip ci]
- *(changelog)* V1.20.0 [skip ci]
- *(changelog)* V1.21.1 [skip ci]
- *(changelog)* V1.22.0 [skip ci]
- README, MIT licence and a root gitignore

### 🚜 Refactor

- *(wall)* The Wall is a feed of imports, not something you post to

### 🧪 Testing

- Settle onboarding animations before asserting
- Assert onboarding CTA instead of animated copy

### ⚙️ Miscellaneous Tasks

- Build debug APK on GitHub Actions
- Name the app Shoku on the launcher
- *(release)* Git-cliff changelog, APK only on main, checks on pull requests
- A changelog push must not fail a shipped release
- Cache Gradle and stop building commits that cannot change the APK
- A release is a version bump, not a commit
- Retry the release publish instead of losing it to a 403
- Build image to GHCR and deploy to the VM over SSH
- *(worker)* Downsize VM to e2-custom-4-8192 and add start/stop helper
- Run the tests on 3.12, the version the images use
- Make the import check a valid one-liner

### 💼 Other

- One repo for the app, the api and the deploy
- Nutrition flow changes before backup
- App, with its full history
- Split api and worker images; worker (yt-dlp + whisper) moves to its own VM
- Multi-stage image, drop apt ffmpeg (1 GB -> 430 MB), slim worker extra
- Install node only in the worker image
- Separate dev/prod compose so a git pull cannot clobber the deployed one
- Pin the compose project name so restarts don't collide
- *(worker)* Mount the cookies file read-only
- Install dependencies before copying code
- Api, with its full history
