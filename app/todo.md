# Shoku — todo

Backlog from the handwritten notes (30 Oct) and the grilling session.
Decision: **pantry is v1.1** — it decrements from the cook log, so the cook log has
to be real (persisted, synced) before inventory means anything.

---

## v1.0 — make the journal real

- [ ] **drift schema + repository** — UUID keys, `schemaVersion`, migration test,
      server schema mirrors it. Nothing else is real until this lands.
- [ ] **Firebase Auth (Google) + claim** — sign-in after the first cook, one-way
      ownership claim, `uid` as identity, offline writes queue with `dirty = 1`.
- [ ] **Sync API** — union by UUID for versions/cooks, LWW on dish metadata with
      server-stamped times, tombstones for deletes.
- [ ] **R2 photos** — presigned direct upload, content-addressed by SHA-256,
      client thumbnails, never routed through the API process.
- [ ] **Import pipeline** — caption-first → yt-dlp (audio only, transient) → Meta →
      strict schema + prose tier → global shortcode cache.
- [ ] **Import job states** — `queued · extracting · ready · failed`, 60 s budget,
      caption-only partial tier, failures never create a dish.
- [ ] **Scoped assistant** — answers from the dish's own versions, capped, never
      mutates. Proposals become a version only when accepted.
- [ ] **Ops** — nightly `pg_dump` → R2 (+ one restore performed), circuit breaker
      metrics (`blocked`, `no_audio`, `no_speech`, `too_long`), per-user import cap.
- [ ] **`+` action sheet** — mic · paste link · recipe dictionary · wanted list.
      (UI over what already exists; the dictionary needs a content decision first.)

## v1.1 — pantry (from the notes)

- [ ] **Receipt intake** — photo or voice ("tell what he brought") or typed; OCR a
      grocery bill into line items.
- [ ] **Ingredient mapping** — "AMUL BUTTER 500G" → ingredient + quantity + unit,
      dedupe, unit conversion. The accuracy risk is the whole feature.
- [ ] **Inventory** — quantities on hand, per ingredient, per user.
- [ ] **Decrement on cook** — the debrief consumes ingredients from inventory.
      Requires the cook commit to carry structured quantities.
- [ ] **Low-stock alerts** — "this is about to end", push via FCM.
- [ ] **Suggest from what you have** — dishes rankable by pantry coverage
      (the "minimum order" note: what's missing, and how little you'd need to buy).

## UI track

- [ ] **Merge `ui/hearth`** (Evening Kitchen) — fast-forward, 2 commits ahead of main.
- [ ] **Port the 360 px fixes** — `ShokuChip` unflexible label, journal counter pills.
      Real defect in main today.
- [ ] **Finish the undesigned screens** — wall, profile, debrief, every sheet.
- [ ] **Draw the backend surfaces** — imports strip, limited-mode banner, claim
      prompt, creator chips, photo states, assistant cap, paste fallback.
- [ ] **Rewrite `DESIGN.md`** from the hearth tokens — it still documents the dead
      Kitchen Ticket palette.

## Play Store

- [ ] **Rename to `com.shoku.app`** — `applicationId`, `namespace`, `MainActivity`
      package + directory. Permanent after the first upload.
- [ ] **Release signing** — upload keystore, `key.properties` (gitignored), CI
      secrets, Play App Signing.
- [ ] **AAB in CI** — build `.aab` alongside the debug APK; production promotion
      stays manual.
- [ ] **Declarations** — Data safety (email, photos), privacy policy, account
      deletion in-app **and** at a public URL.
- [ ] **12 testers / 14 days** closed test before production unlocks.

## Open questions

- [ ] "and should only go to ___" — unfinished sentence from the grilling.
- [ ] Residential proxy budget for yt-dlp (~$2–5/GB) — unpriced.
- [ ] Meta API limits and current pricing — verify before relying on them.
- [ ] Recipe dictionary: licensed, generated, or not at all?
- [ ] Legal posture: global cache + self-hosted scraping holds only while no bulk
      endpoint exists.

## Accepted risks

- Global cache serves one creator's extracted text to every user (decided).
- No merge in v1 — a duplicate dish is permanent.
- Tombstones forever; hard deletion only on account deletion.
