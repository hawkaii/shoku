# Shoku — Play Store readiness

Audited **1 Nov 2026** on a real device (Xiaomi 2109119DI, Android 14) and against
the repo. Every row is checked, not inferred. Owner and verdict included so this
can be argued with rather than nodded at.

## Blockers — nothing ships until these are true

| # | Requirement | Verdict | Evidence / what it needs | Owner |
|---|---|---|---|---|
| 1 | **HTTPS API** | **FAIL — launch blocker** | `ShokuConfig.apiBaseUrl` defaults to `http://35.188.27.251:8000`. No `usesCleartextTraffic` in the manifest, so on targetSdk 36 the release build **cannot reach the API at all**. Debug works only because Flutter injects a debug network config. Needs a domain + TLS (or a proxy) before any release build is useful. | Backend |
| 2 | **Release signing** | **FAIL** | `android/app/build.gradle.kts:40` → `signingConfig = signingConfigs.getByName("debug")`. No `key.properties`, no `.jks`. Play refuses debug-signed uploads. | Frontend |
| 3 | **AAB upload** | **FAIL** | CI builds `flutter build apk` only. New apps must upload `.aab`. | Frontend |
| 4 | **applicationId** | **DECIDE NOW** | `com.foodfinder.food_finder` — valid but ugly, and **permanent after the first upload**. Changing it later means a new listing with zero installs. | Owner decision |
| 5 | **Account deletion** | **FAIL** | Play requires an in-app path *and* a public web URL when accounts exist. No endpoint exists for either. | Backend + Frontend |
| 6 | **Privacy policy URL** | **FAIL** | None. Required once an email is collected. | Owner |
| 7 | **Data safety form** | **TODO** | Must declare: email (auth), photos (synced, not local-only), and that auth is Supabase. Must match behaviour exactly or it is a policy strike. | PM |
| 8 | **Content rating** | **TODO** | IARC questionnaire. A public feed means answering user-generated-content questions truthfully. | PM |
| 9 | **UGC + IP policy** | **HIGHEST RISK** | The Wall serves scraped third-party reels to strangers with **no report button, no moderation queue and no removal path**. Play requires rights to distributed content and a reporting/takedown surface for UGC. This is the item most likely to sink the submission, and no amount of signing fixes it. | Product decision |
| 10 | **Closed test** | **CALENDAR BLOCKER** | New personal accounts need **12 testers opted in, continuously, for 14 days** before production unlocks. Starts the day the AAB is uploadable, so it sets the launch date. | Owner |
| 11 | **Store listing assets** | **TODO** | 512×512 icon, 1024×500 feature graphic, screenshots per device type, descriptions. | Designer |

## Checks that PASS

| Requirement | Verdict | Evidence |
|---|---|---|
| `targetSdk` 36 (required since 31 Aug 2026) | **PASS** | Flutter 3.47's `FlutterExtension.kt` sets `targetSdkVersion = 36` and `compileSdkVersion = 36`; the app uses `flutter.targetSdkVersion`. |
| 64-bit / arm64 | **PASS** | The installed APK runs on an arm64 device. |
| Auth hardening | **PASS** | JWT verified server-side against project JWKS; no/garbage token → 401. |
| Takedown path | **PASS (operator only)** | `DELETE /v1/content/{shortcode}` erases a reel from the Wall. No user-facing route to it. |

## Defects found by driving the real app

1. **Every Wall card thumbnail is a grey box** — yet the same image renders inside
   the detail sheet. The card passes a wrong URL or a broken widget; not a network
   problem, since the sheet loads it.
2. **The Wall header still shows a "SHARED" chip** — leftover from the publishing
   model that was deleted. It promises a control that no longer exists.
3. **The Journal's cook-log empty-state card is clipped by the tab bar.**
4. **One Journal dish shows a grey box** instead of its cover.
5. The labels disagree: the dish says "View the reel", the Wall sheet says
   "Open the reel". Same action, two words.
6. Opening a Wall card on a poor connection shows a retry, even though the card
   already holds the title, steps and tags it could render immediately.

## Working, verified on the device

- Sign-in and sync: 5 dishes arrived from the server with no prompt.
- Wall: 18 reels, newest first, title / creator · platform / step count / tags.
- Card detail: thumbnail, `46 min · 18 ingredients · 7 steps`, tags, full method,
  **"Open the reel"** and **"In your cookbook"**, both rendering correctly.
- Import provenance, ingredient links, timer, long-press: unit-tested, and the
  provenance card was seen working earlier in the session.

## The product question, stated plainly

The Wall shows every reel anyone imports, to every signed-in user, permanently,
with no consent step and no way for a user to remove their own. That is a
deliberate choice. It is also the single largest risk to the store submission,
because Play judges the *feed*, not the intent behind it.

Three ways to resolve it, none of which is a code change alone:

- **Keep it** and build moderation: report button, operator queue, auto-hide at N reports.
- **Make it opt-in again** — the flag and endpoints still exist, disabled.
- **Ship without the Wall**, which removes the entire class of risk.

## Suggested order

1. HTTPS + signing + AAB — without these there is nothing to submit. *(1–3 days)*
2. applicationId decision, then never think about it again.
3. Moderation or removal of the Wall — decide before uploading, not after.
4. Privacy policy, deletion, data safety, content rating. *(paperwork, parallel)*
5. Thumbnails, "SHARED" chip, clipped card, label mismatch. *(an afternoon)*
6. Start the 12-tester clock the moment an AAB is uploadable.
