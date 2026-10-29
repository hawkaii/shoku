# Shoku — Design Language: "Kitchen Ticket"

The app is a culinary press, not a game. Paper and ink, one hot accent, monospace
for anything you measure. Brutalism survives in exactly two places — the primary
CTA and a live cooking timer — so it reads as a physical switch, not a cartoon.

Two references set the bar, neither is copied: **Simmr** (information architecture,
onboarding that teaches a share gesture, calm empty states) and **Matiks** (crisp
dark surfaces, gamification with restraint). Craft level: editorial.

---

## 1. Colour

Light is the default; dark is a first-class mode.

| Role | Light | Dark | Use |
|---|---|---|---|
| Canvas | `#F2CCBD` | `#17100E` | page background, ≥75% of a screen |
| Surface | `#FBF1E9` | `#221816` | cards, sheets, inputs |
| Surface alt | `#E9BDAE` | `#2E211E` | nested blocks, chips, tracks |
| Ink | `#2B1E19` | `#F6EDE4` | primary text, active segment fill |
| Ink muted | `#7C5B51` | `#B79C90` | metadata, secondary copy |
| Hairline | `#DFB2A2` | `#3A2A26` | 1 px structure: dividers, card bounds |
| **Accent** | `#8E2A22` | `#E0705A` | primary action, selection, active tab dot |
| Reward | `#A65C3B` | `#D9A05B` | streak, XP, note rules |
| Ready | `#6F7A52` | `#8FA37A` | pantry matches, completed steps |
| Danger | `#B3261E` | `#EF8E7C` | destructive only |

Rules:
- Accent ≤6% of a screen. Reward and ready ≤2% each.
- **No coloured cards.** Food imagery is the only loud colour field.
- Never place accent text on surface alt — contrast drops below AA.

## 2. Type

Three Google Fonts. No bundled assets.

| Token | Face | Size / weight / tracking | Used for |
|---|---|---|---|
| display | Fraunces | 34 / 700 / −0.8 | screen heroes, recipe titles |
| h1 | Fraunces | 26 / 600 / −0.5 | screen titles, empty states |
| h2 | Fraunces | 19 / 600 / −0.2 | card titles |
| title | Plus Jakarta Sans | 16 / 700 / −0.1 | rows, buttons, small headings |
| body | Plus Jakarta Sans | 16 / 400 / 0, height 1.55 | reading, steps, ingredients |
| bodySmall | Plus Jakarta Sans | 13 / 500 | metadata, helper copy |
| label | JetBrains Mono | 11 / 600 / +1.2, uppercase | overlines, chips, tabs |
| stat | JetBrains Mono | 15 / 700, tabular | quantities, timers, counts |
| statHero | JetBrains Mono | 22 / 700, tabular | the one number that matters |

Rules: Fraunces is for editorial voice only — never for UI labels or buttons.
Reading text is never below 15 px. Numbers always tabular.

## 3. Shape, depth, motion

- Radii: `6` chips · `8` media · `12` cards · `20` sheets. No 999 px pills except
  tiny status chips.
- Depth is tonal: canvas → surface → surface alt. **No shadows on cards.**
- Hairlines (1 px) carry structure.
- **Brutal treatment** — 1.5 px ink border + 2 px hard offset shadow — is allowed
  on: the primary CTA, the live timer pill, and a single highlighted plan card.
  Nothing else.
- Motion: 150–240 ms, `easeOutCubic`. No bounce, no spring. The only celebration
  is a haptic tick plus a vertical number roll.

## 4. Signature elements

1. **Split-stub ticket card** — content above, dashed perforation, then a
   three-cell mono stub: `PANTRY 6/8` · `XP +60` · `STEPS 2/5`.
2. **Inline mono pills inside steps** — every `200°C`, `150 g`, `8 mins` becomes a
   bordered chip; tapping a duration starts a countdown in place.
3. **Wisdom index cards** — no photo, saffron double rule on the top edge,
   `WISDOM // 042` overline, the note set in Fraunces italic.
4. **Pantry tick meter** — eight 4×12 px ticks; owned ingredients in Ready green.
   Answers "can I cook this tonight?" at a glance.
5. **Brass stamp HUD** — streak and level in one compact mono badge with a 1 px
   saffron border. Gamification as stamped metal.

## 5. Product model — a cook journal, not a save inbox

The product answers one question: *what have I cooked, and how is my food evolving?*

Three entities:

- **Dish** — the living concept. `id`, `title`, `coverUrl`, `sourceHandle`, `status`
  (`wantToTry` / `inProgress` / `signature`), `currentVersion`, `cookCount`.
- **RecipeVersion** — a snapshot: `number`, `changes[]`, `ingredients[]`, `createdAt`.
  A version is created only when the cook changed something.
- **CookLog** — a night: `cookedAt`, `versionNumber`, `photoUrl`, `outcome`
  (`needsWork` / `good` / `nailedIt`), `note`, `changes[]`.

Logging is **delta-first**: photo, outcome, one line of changes. Thirty seconds,
never a full recipe edit. If nothing changed, no new version.

## 6. Screen inventory

| Route | Screen | Loudest element |
|---|---|---|
| `/onboarding` | 4 steps: intro → share → save → notify | the mock reel |
| `/journal` | month header, on-the-counter card, photo timeline with date spine | the photos |
| `/recipes` | cookbook grid, status filters, version badge per dish | the food |
| `/dish/:id` | version scrubber, changes, ingredients, cook history | the hero photo |
| `/groceries` | to-buy list ⇄ pantry | the "to buy" count |
| `/profile` | cooks / upgrades / signature, month strip, appearance | the counts |
| `/help` | FAQ | the questions |

Deleted from the earlier build: the Discover tab (a detail view masquerading as a
tab), the permanent extract bar on Home, the All/Recipes/Notes filter, the dashed
reward rows, and the saves-balance quota.

## 7. Motion

Tactile, fast, earned. Every action is acknowledged within 100 ms; travel settles
once; spectacle only for milestones.

| Motion | Duration | Curve |
|---|---|---|
| Page push | 280 ms | easeOutCubic, 6% horizontal travel + fade |
| Page pop | 220 ms | easeInCubic |
| Tab switch | 180 ms | easeOutCubic, 4 px shift |
| Sheet | 280 / 220 ms | easeOutCubic in, easeInCubic out |
| List entrance | 240 ms, 28 ms stagger (first 8) | easeOutCubic, 10 px rise |
| Button press | 80 ms down / 120 ms up | easeOutBack on release, scale 0.97 |
| Number change | 240 ms | odometer roll |
| Recipe → detail | 280 ms | shared image (Hero), radius 8 → 0 |

No confetti. No elastic bounce on repeated taps. No full-screen tab transitions.
Reduced motion (`MediaQuery.disableAnimations`) removes travel, stagger and rolls,
leaving a 120 ms crossfade.

## 8. Voice

Short declaratives. No exclamation marks. No emoji in body copy — emoji only as
category marks. Numbers in mono.

- "Saved to your stash." not "Saved! 🎉"
- "One save is one extraction." not "Each extraction costs 1 credit."
- Empty states say what to do next, in one line.

## 9. Do not

- Coloured card backgrounds — they fight food photography.
- Serif in UI labels, buttons, or numbers.
- Shadows on cards, buttons (except the primary), or the tab bar.
- Full-screen confetti or mascots.
- Stadium pills everywhere — they read as generic Material defaults.
- Centre-aligned paragraphs.


## 10. Diagram language

Taken from the chosen marks (`brand/5-rim-tomato.svg`, `brand/6-rim-knife.svg`):

- 256-unit design space, scaled from the widget size — never redrawn per screen.
- Ink outlines at 7 units, round caps and joins. Nothing thinner.
- Flat fills only: ink `#1C1614`, crimson `#9E281E`, bay leaf `#28664B`, paper.
- No gradients, no shadows, no stock photography inside a diagram.
- One idea per diagram: a bowl, a pan, a knife, a plate. Never two objects competing.
- Diagrams map to intents derived from the step's own verbs: whisk, chop, fold,
  separate, simmer, bake, chill, plate.
- Motion is a slow loop (2.6 s) of the *object*, never of the layout. Reduced
  motion renders a single frame.
