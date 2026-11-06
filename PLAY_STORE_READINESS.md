# Shoku — Play Store readiness

Audited **1 Nov 2026** on a real device (Xiaomi 2109119DI, Android 14) and against
the repo. Every row is checked, not inferred. Owner and verdict included so this
can be argued with rather than nodded at.

## Blockers — nothing ships until these are true

| # | Requirement | Verdict | Evidence / what it needs | Owner |
|---|---|---|---|---|
| 1 | **HTTPS API** | **FAIL — launch blocker** | `ShokuConfig.apiBaseUrl` still defaults to `http://35.188.27.251:8000`. `api.gradientdescent.wiki` has no A record yet, so the certificate cannot be issued. Needs a DNS record, then Caddy on the VM and a base URL change. | Owner + Backend |
| 2 | **Release signing** | **PASS** | Upload keystore generated (RSA-4096, 10,000 days), stored in GitHub secrets; CI decodes it into `android/key.properties`. The `v1.29.2` AAB's signer SHA-256 matches the keystore. Back up `~/.config/shoku/shoku-upload.jks` + `upload-key-password`: losing them means a new upload key and a Play support request. | Backend |
| 3 | **AAB upload** | **PASS** | `v1.29.2` and later publish `shoku-<version>.aab` beside the APKs; `flutter build appbundle` runs in CI. | Backend |
| 4 | **applicationId** | **PASS** | `wiki.gradientdescent.shoku` — reverse-DNS of the domain the owner controls, so it cannot collide on Play. It matches the auth deep link. Verified inside the `v1.29.5` bundle manifest. | Backend |
| 5 | **Account deletion** | **PASS (code) / web page pending** | `You → Delete account` confirms, calls `DELETE /v1/account`, wipes the device and signs out. The server deletes every table with a `user_id`, the photo objects, and — with a service key — the auth identity. `shoku-landing/site/account-deletion.html` is committed; Vercel has not picked up the deploy, so the URL still 404s. | Backend + Owner |
| 6 | **Privacy policy URL** | **PASS** | `https://shoku.gradientdescent.wiki/privacy` is live and now points at the deletion page. | Owner |
| 7 | **Data safety form** | **TODO** | Email, photos, app activity; deletion available; no ads; encrypted in transit only after HTTPS. | Owner |
| 8 | **Content rating** | **TODO** | IARC questionnaire; the public feed means declaring user-generated content. | Owner |
| 9 | **UGC + IP policy** | **PASS (code)** | Every Wall card has **Report**; `feed_report_threshold` (3 distinct users) unshares it; `DELETE /v1/content/{shortcode}` is the operator queue. Takedown contact lives in the terms page. | Backend |
| 10 | **Closed test** | **CALENDAR BLOCKER** | Personal accounts need 12 testers opted in for 14 continuous days. Starts when an AAB is uploadable — it is now. | Owner |
| 11 | **Store listing assets** | **PASS (produced)** | Icon, feature graphic and four 1080×1920 screenshots in `docs/play/`, with the listing copy, data-safety answers, content-rating answers and reviewer instructions in `docs/play/README.md`. Uploading them is console work. | Backend |

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
