# Premium UI/UX Polish (no billing)

**Status:** Implemented — hot restart / flutter run to preview  
**Scope:** Light-red brand refine + home/cards hierarchy + plan strip + Pro badges + loading/empty polish

## Goal

Make Tubora feel like a finished premium product on the home dashboards and profile chrome, while keeping the existing light red brand and leaving purchases as “coming soon.”

## Design direction

- Keep light surfaces (`#FAFAFA` / white) and red primary (`#E53935`).
- Refine brand chrome (hero row, plan strip, badges, dialogs) — not a dark-mode redesign.
- Keep colorful feature-card gradients (they give tool identity); improve hierarchy so brand red still owns the first viewport.
- No buy button / price — Play policy. Upgrade stays a polished teaser.

## What changes

### 1. Home hierarchy + plan strip

Primary file: `lib/features/home/widgets/feature_dashboard.dart`

- Under the Tubora hero, add a compact **plan strip** (badge + soft copy — NO exact number):
  - Free: `Free plan · resets daily` + small **Pro** chip that opens the existing teaser dialog.
  - Pro: `Pro` badge + soft access copy (no counter).
- Why no exact count: free limit is **per-feature** (each feature its own 1/day), not one global counter — a "1 left today" strip on home would be misleading.
- Data source: **`userPlanProvider` only** — no extra `users/{uid}/usage/{date}` read on home.
- Soft entrance motion already present; extend to strip + section headers (2–3 intentional motions max).

### 2. Feature cards: subtitle + premium press

Primary file: `lib/features/home/widgets/feature_card.dart`

- Show catalog `subtitle` under the title (defined in `lib/features/home/models/feature_catalog.dart` but never rendered).
- Slightly taller aspect / better padding so Grow titles never feel cut off.
- **No Pro pill on cards** — all tools are available to free users; Pro messaging lives only in the plan strip + quota-hit dialog.

### 3. Brand refine (tokens only)

Primary files: `lib/core/constants/app_colors.dart`, light theme if needed

- Tighten red family: `primarySoft`, divider, subtle hero wash (very light red/warm wash — not purple/glow).
- Align dark-theme hard-coded radii with `AppSizes` only if touched; no dark redesign.

### 4. Pro look without billing

Files:

- `lib/features/pro/widgets/pro_upgrade_dialog.dart`
- `lib/features/profile/screens/profile_screen.dart`
- `lib/shared/models/user_plan.dart` (lifetime → Pro display)

- Redesign dialog: clearer benefits, red accent header, separate copy for “from Profile” vs “quota hit”.
- Profile plan card: stronger Free vs Pro visual; Upgrade CTA only for free.
- Treat `lifetime` as Pro-equivalent in UI parsing (display fix only).

### 5. Loading / empty / error consistency

- Shared generators: loading skeletons or branded progress match Content Studio quality.
- Empty result + retry: reuse patterns from `lib/core/widgets/common/error_state.dart`.
- Home has no empty state needed; generator screens get the polish.

### 6. Nav chrome (light touch)

`lib/core/navigation/main_shell.dart`: keep 4 tabs; slight selected-state refinement.

## Todos checklist

- [x] Add home plan strip (badge + soft copy, no exact count) via `userPlanProvider` only
- [x] Show subtitles, fix card aspect/hierarchy (no Pro pill on cards)
- [x] Refine light red tokens + subtle hero atmosphere
- [x] Polish Pro dialog copy variants + Profile plan card; lifetime displays as Pro
- [x] Align generator loading/empty/error polish with Content Studio patterns
- [x] Light bottom-nav selected-state refinement

## Out of scope

- Play Billing / RevenueCat / prices / restore
- Region move / App Check / generation speed
- Full admin console work
- Replacing Create tab or feature set

## Success check

- First viewport: brand + one line + plan strip + Create cards (no clutter).
- Every card shows readable title + subtitle.
- Free user sees plan badge + Pro teaser path; Pro user sees badge without fake buy CTA.
- No misleading usage counter on home; no purchase UI that cannot complete.

## How to resume tomorrow

In Cursor: “Execute the Premium UI/UX polish plan in `PREMIUM_UI_UX_POLISH_PLAN.md`”
