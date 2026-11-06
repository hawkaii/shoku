# Play Console: everything that is not code

The console asks for the same information every submission, and each answer is
a policy statement. This file is the answer sheet — copy from it, and keep it
true when the product changes.

## Assets in this folder

| File | Console field | Size |
|---|---|---|
| `icon-512.png` | App icon | 512 × 512, full bleed, no transparency |
| `feature-graphic-1024x500.png` | Feature graphic | 1024 × 500, no text |
| `screenshot-import.png` | Phone screenshot 1 | 1080 × 1920 |
| `screenshot-assistant.png` | Phone screenshot 2 | 1080 × 1920 |
| `screenshot-fridge.png` | Phone screenshot 3 | 1080 × 1920 |
| `screenshot-cook.png` | Phone screenshot 4 | 1080 × 1920 |

All four screenshots are real captures of the app, on the app's own night
background. The icon is the brush mark on the launcher's cream, rendered from
`app/assets/brand/mark.svg`, so it cannot drift from the installed icon.

## Listing copy

**App name** (30 max)

```
Shoku · cooking journal
```

**Short description** (80 max)

```
A reel becomes a recipe you cook from, and every version you make is kept.
```

**Full description**

```
Shoku reads a cooking reel and gives you the recipe back — the method in order,
eleven steps, twenty-three ingredients, and each step carrying the amounts it
uses. No typing, no screenshots in your camera roll.

Cook it in Cook mode: one step at a time, the ingredients for that step beside
it, timers that survive a locked screen, and a speaker that reads the step
aloud if your hands are full.

Ask at the stove. Every step has its own question, and the answer is about the
pan in front of you. Ask for a change and Shoku shows the diff first: the old
version stays, the new one becomes v2, and you pick the one that fits tonight.

Count what you already have. Every ingredient is checked against your fridge,
units convert inside a family, and the shopping list is the difference — five
here, one on the list, seventeen to buy, which is twenty-three. A receipt photo
fills the shelf in one pass.

The Wall is a feed of reels other people imported, already read into steps, and
each one says where it came from. In ten languages.

Amounts read off a video are estimates and the page says so. Nutrition is not
guessed. Your journal is yours: it syncs, it works offline, and it deletes when
you ask.
```

**Category** Food & Drink · **Contact email** `hello@gradientdescent.wiki` ·
**Privacy** `https://shoku.gradientdescent.wiki/privacy` ·
**Account deletion** `https://hawkaii.github.io/shoku/account-deletion.html`

## Data safety

Every answer below must match the app or it is a policy strike.

| Question | Answer |
|---|---|
| Does the app collect or share user data? | **Yes, collects** |
| Is all collected data encrypted in transit? | **Yes — only true once the API serves HTTPS** |
| Can users request data deletion? | **Yes**, in-app and at the URL above |
| Email address | Collected · Account management · Required · Not shared |
| Photos | Collected · App functionality · Optional · Not shared |
| App activity — other user-generated content (dishes, versions, cooks, fridge) | Collected · App functionality · Optional · Not shared |
| App activity — in-app actions (assistant questions) | Collected · App functionality · Optional · Not shared |
| Advertising or marketing | **No** |
| Analytics | **No** — the app carries no analytics SDK |
| Data sold to third parties | **No** |
| Data shared with third parties | **No** — Meta's model API processes content on our behalf and is named in the privacy policy as a processor, not a recipient |

## Content rating (IARC questionnaire)

| Question | Answer |
|---|---|
| Category | Utility / productivity / other (not a game) |
| Violence, sexuality, language, controlled substances, gambling | **No** to every one |
| Users can see content created by other users | **Yes** — the Wall shows reels other people imported |
| Users can interact or share content | **No** messaging; report only |
| User-generated content is moderated | **Yes** — every card has Report; three reports remove it; an operator can remove any reel |
| Digital purchases | **No** (until Play Billing ships) |
| Target audience | 13+; not designed for children |

## App access

The app requires an account, so the reviewer needs one. Create it before
submitting and paste it into **App access → All functionality is restricted**:

1. Sign up in the app with `review@gradientdescent.wiki` and a throwaway
   password, confirm the email, and sign in.
2. Import two reels so the journal is not empty, cook one of them, and add a
   third reel from the Wall. Add three fridge items.
3. Enter that email and password in the console with the note: *"Sign in on the
   first screen. The journal already has three dishes; the Wall, the assistant
   and the fridge are all reachable from the bottom bar."*

## Before pressing submit

- [ ] `api.gradientdescent.wiki` resolves and serves HTTPS (the data-safety
      answer above is false without it)
- [ ] Version code in `app/pubspec.yaml` is higher than every previous upload
- [ ] The AAB is the one CI published, not a local build
- [ ] Closed test ran for 14 days with 12+ testers (personal account rule)
- [ ] Privacy policy mentions the model provider, storage and deletion
- [ ] The account-deletion URL loads in a private window
