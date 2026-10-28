# App Store assets: RandoSquad

Portfolio rules, specs and workflow: `Aguach1leLabs/APP_STORE_ASSETS.md` (in the main
Aguach1leLabs repo; this app lives in its own repo). Upload-ready files go in
[store-assets/](store-assets/), one folder per slot. Check them from the Aguach1leLabs repo:
`python3 scripts/store_assets.py check "/Users/aguachile/Desktop/DEVELOPMENTS/02_RandyTheStudent/RandytheStudent V2.0"`.

**State (2026-10-06):** Nothing is captured. The target is `TARGETED_DEVICE_FAMILY = "1,2"`, so iPhone 6.3" and iPad 13" are both required. Capture on **iPhone 17 Pro** and **iPad Pro 13-inch (M5)** simulators, EN + ES, with a **fictional roster**.

## Screenshot story

Up to three can appear in search on their own, so 1-3 must explain the product without help.

1. **Balanced groups** generated in one tap
2. **A fair pick**: weighted toward who's participated least
3. **Participation counts** per student
4. Grading group work
5. The roster

## Capture

Read by `python3 scripts/capture_screens.py "/Users/aguachile/Desktop/DEVELOPMENTS/02_RandyTheStudent/RandytheStudent V2.0"`: one line per shot (name: launch
arguments), captured on iPhone 17 Pro and iPad Pro 13-inch (M5) in every language the app
ships. `-uiTestSeed` renames the default class and fills it with twelve fictional students, groups, two graded activities and some participation (Debug builds only); `-uiTestTab` picks the tab.

- **01-groups:** -uiTestSeed -uiTestTab 1
- **02-participation:** -uiTestSeed -uiTestTab 4
- **03-activities:** -uiTestSeed -uiTestTab 2
- **04-stats:** -uiTestSeed -uiTestTab 3
- **05-roster:** -uiTestSeed -uiTestTab 0
- **Scheme:** RandyTheStudent
- **Wait:** 8

## On-image text

| # | EN | ES |
|---|---|---|
| 1 | Fair groups in one tap | Grupos justos en un toque |
| 2 | Quieter students get a turn too | Los más callados también tienen su turno |
| 3 | Offline and private | Sin conexión y privado |

## Art spec

Read by `python3 scripts/creative_assets.py "/Users/aguachile/Desktop/DEVELOPMENTS/02_RandyTheStudent/RandytheStudent V2.0"` (in the Aguach1leLabs repo). Edit a line, then
re-run: `--force` regenerates the AI art, while the search composite re-renders free from the cached
background. `Search screens` match the upload-ready screenshots by number (`01` → `en-01-*.png`), so
the search asset appears as soon as screenshots exist. Art direction is this app's own; no
sibling uses the same medium (4.3 rule (`Aguach1leLabs/APP_STORE_ASSETS.md`)).

- **Header prompt:** Wide classroom chalkboard illustration in chalk on a deep green board: a big six-sided die mid-bounce drawn in chalk at the centre, with small rounded student figures gathering into four balanced groups around it, a few chalk arrows and stars, wooden board frame at the bottom edge with chalk and an eraser. Friendly, fair, teacher-made. The die sits in the central 60%. No real children's faces, no text, letters, numbers, logos, phones or UI.
- **Search background prompt:** Deep green chalkboard texture with faint chalk smudges, small chalk stars and a die doodle only at the outer edges and corners. The top third and the centre must stay calm and nearly empty so a headline and phone screenshots can sit there. No text, letters, numbers, logos, phones or UI anywhere.
- **Search screens:** 01, 02, 03
- **Search headline:** en = Fair groups in one tap | es = Grupos justos en un toque
- **Ink:** #F7F4E8
- **Font:** SFNSRounded.ttf Heavy

## Product Page Optimization

Rules: APP_STORE_ASSETS.md §6 (`Aguach1leLabs/APP_STORE_ASSETS.md`).
Starts once a version is approved and live. One test at a time, up to 90 days.

**Test 1: Groups vs participation.** Do teachers respond more to balanced groups or to fair participation picks? Use 2 treatments at 50% traffic (25% each), in every language the
page has.

- **Original:** balanced groups generated
- **Treatment A** (`store-assets/ppo/a-participation-first/`): the fair pick first
- **Treatment B** (`store-assets/ppo/b-grades-first/`): grading group work first

Apply a winner only at 90% confidence. **Next test:** captions on vs off the first three
screenshots. An icon test needs the alternate icon shipped in a build first (§6).

**Results log:** none yet.

## Custom Product Pages

Rules: APP_STORE_ASSETS.md §7 (`Aguach1leLabs/APP_STORE_ASSETS.md`).
In App Store Connect: *Custom Product Pages → +*. Choose **Copy Existing Product Page** and use
Reference Name `RandoSquad · <slug> · <audience>`. Files go in `store-assets/cpp/<slug>/<slot>/`.
Each keyword can belong to only one page.

| Slug | Audience · keywords | First screenshot | Promo text | Deep link |
|---|---|---|---|---|
| `groups` | Teachers grouping students · random group generator, student groups | balanced groups | Make balanced student groups in one tap, without the same pairs every time.<br>ES: Haz grupos de alumnos equilibrados en un toque, sin repetir siempre las mismas parejas. | opens Groups |
| `participation` | Teachers tracking participation · random name picker, cold call | the fair pick | Call on students fairly. Quieter students get their turn too.<br>ES: Pregunta a tus alumnos de forma justa. Los más callados también tienen su turno. | opens Pick |

## Watch-outs

- Every asset must be 4+, with no prices, URLs, ©, Apple awards, other platforms or competitor names.
- Fictional student names only. Never a real class list; it's minors' data.
- No real school names or logos.
- No grades that single out a named child as failing.
