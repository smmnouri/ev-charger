# Design System Review

**Document type:** Cross-screen consistency audit  
**Last Updated:** 2026-06-11  
**Scope:** All designed screens: HOME_SCREEN.md, CHARGING_SESSION_SCREEN.md, STATION_DETAILS_SCREEN.md, RESERVATION_FLOW.md, CHARGING_SUMMARY_SCREEN.md, WALLET_SCREENS.md, PAYMENT_FLOW.md, PROFILE_SCREENS.md, NOTIFICATION_SCREENS.md, SETTINGS_SCREENS.md  
**References:** DESIGN_SYSTEM.md (authoritative), ARCHITECTURE_FINAL.md §25 (i18n)

This document audits consistency across all designed screens against the design system specification. It identifies component reuse, token adherence, and gaps or conflicts that must be resolved before implementation begins.

---

## Table of Contents

1. [Component Inventory](#1-component-inventory)
2. [Color Token Usage Audit](#2-color-token-usage-audit)
3. [Typography Token Usage Audit](#3-typography-token-usage-audit)
4. [Spacing and Layout Audit](#4-spacing-and-layout-audit)
5. [Elevation and Surface Audit](#5-elevation-and-surface-audit)
6. [Border Radius Token Audit](#6-border-radius-token-audit)
7. [Animation Consistency Audit](#7-animation-consistency-audit)
8. [RTL Consistency Audit](#8-rtl-consistency-audit)
9. [Accessibility Audit](#9-accessibility-audit)
10. [Icon Usage Audit](#10-icon-usage-audit)
11. [Navigation Pattern Audit](#11-navigation-pattern-audit)
12. [Loading State Consistency](#12-loading-state-consistency)
13. [Error State Consistency](#13-error-state-consistency)
14. [Empty State Consistency](#14-empty-state-consistency)
15. [Conflicts and Gaps](#15-conflicts-and-gaps)
16. [Implementation Guidance](#16-implementation-guidance)

---

## 1. Component Inventory

All reusable components identified across the designed screens. Each component should be implemented once and consumed everywhere.

### Primary Action Button
Used in: every screen  
Spec: 48dp height, `radius.full` (9999dp), `color.primary` fill, white text, `type.label.large`, horizontal 24dp padding  
Variants: Primary / Primary Large (56dp) / Primary Outlined  
Screens using "Primary Large": RESERVATION_FLOW.md (check-in CTA), HOME_SCREEN.md (sticky stop), STATION_DETAILS_SCREEN.md (Start Charging)

### Sticky CTA Bar
Used in: STATION_DETAILS_SCREEN.md §19, CHARGING_SESSION_SCREEN.md §8 (stop button), RESERVATION_FLOW.md §9  
Spec: 80dp height (including safe-area bottom), `color.surface` background, elevation 4, 16dp horizontal padding  
Note: The charging session stop button uses a persistent bar but with a dark background. This is the exception pattern — the stop button inherits the session screen's always-dark theme.

### Bottom Sheet (modal)
Used in: HOME_SCREEN.md §6, STATION_DETAILS_SCREEN.md §19, RESERVATION_FLOW.md §10, CHARGING_SESSION_SCREEN.md §12, NOTIFICATION_SCREENS.md §8  
Spec: 28dp top drag handle (36dp wide, 4dp tall, `color.outline` at 30%), `radius.xl` top corners, `color.surface` background, elevation 5  
Snap points (where applicable): 240dp (peek) / 65% screen height (expanded) per HOME_SCREEN.md §6

### Station Status Chip
Used in: HOME_SCREEN.md §7, STATION_DETAILS_SCREEN.md §8  
Spec: 24dp height, `radius.full`, type-dependent fill (6 variants: available/charging/occupied/reserved/unavailable/faulted), `type.label.small`

### Session Ring
Used in: CHARGING_SESSION_SCREEN.md §5, CHARGING_SUMMARY_SCREEN.md §3  
Spec: 220dp diameter, 12dp stroke, clockwise (LTR) / counter-clockwise (RTL)  
Summary screen: ring shrinks to 80dp medallion during transition

### Transaction Card
Used in: WALLET_SCREENS.md §4, CHARGING_SUMMARY_SCREEN.md §11  
Spec: 72dp height, 40dp icon circle, `type.title.medium` primary text, `type.body.small` secondary text

### Notification Card
Used in: NOTIFICATION_SCREENS.md §4, in-app foreground banner  
Spec: 80dp min height, 40dp icon circle, left accent bar for unread, swipe-to-dismiss

### Loading Skeleton / Shimmer
Used in: every screen  
Spec: Shimmer animation: left-to-right fade (400ms ease-in-out, repeating). `color.surfaceVariant` base. Skeleton shapes: rounded rectangles, `radius.sm`.  
RTL exception: shimmer direction reverses (right-to-left) when locale is `fa`.

### Input Field
Used in: RESERVATION_FLOW.md §5, PROFILE_SCREENS.md §5, SETTINGS_SCREENS.md §8, onboarding  
Spec: 52dp height, `radius.md` border, 1dp `color.outline`, active 2dp `color.primary`, label above (not inside), `type.body.large` text

### Avatar
Used in: PROFILE_SCREENS.md §1, NOTIFICATION_SCREENS.md (future), SETTINGS_SCREENS.md (future)  
Spec: Circle, `radius.full`. Initials fallback: deterministic color from name hash (8 `color.tertiary`-family variants), white `type.headline.small` initials.

### Settings Row
Used in: SETTINGS_SCREENS.md §9, PROFILE_SCREENS.md §1 (account list)  
Spec: 52dp height, 20dp leading icon, `type.body.large` text, trailing value + 16dp chevron. Section header: `type.label.small` letter-spaced, `color.text.tertiary`.

### Toggle Switch
Used in: SETTINGS_SCREENS.md §6, NOTIFICATION_SCREENS.md §7, PROFILE_SCREENS.md §8  
Spec: 44dp touch target, `color.secondary` track (on), `color.outline` track (off). Standard OS component.

### Connector Status Card
Used in: STATION_DETAILS_SCREEN.md §11, RESERVATION_FLOW.md §4  
Spec: Full-width card, 72dp min height, connector type icon, status chip, power spec, CTA

### Collapsing Navigation Bar
Used in: STATION_DETAILS_SCREEN.md §7, CHARGING_SUMMARY_SCREEN.md §2  
Spec: Transparent at 0-80dp scroll → opaque at 200dp scroll. Title opacity follows same curve.

### Inline Error / Offline Banner
Used in: every screen  
Spec: Full-width, 40dp, `color.errorContainer` (error) or `color.warningContainer` (offline), `type.body.small`, centered. Animates down from nav bar.

### Date Group Header
Used in: WALLET_SCREENS.md §4, NOTIFICATION_SCREENS.md §3, CHARGING_SUMMARY_SCREEN.md §9 (session list)  
Spec: `type.label.small`, letter-spaced, `color.text.tertiary`, 12dp top padding, 8dp bottom padding

---

## 2. Color Token Usage Audit

### Primary (`#0F5EFF`)
Used as: interactive elements (CTAs, links, selected states), progress ring fill during charging, unread notification accent, toggle track (off-primary but this should be secondary per below)

**Conflict found:** WALLET_SCREENS.md §3 says the "+ Add Funds" button has "white background, `color.primary` text" and CHARGING_SESSION_SCREEN.md uses `color.primary` for the session ring. This is correct. However, PROFILE_SCREENS.md §1 says the "Edit Profile" button is "Tertiary, `color.primary`" — which is consistent (Tertiary variant uses primary color for text, not fill).

### Secondary (`#00D68F`) — "Energy Green"
Used as: success/positive states, available station pins, energy metric highlights, credit amounts in wallet, charging ring fill color (energy being delivered)

**Audit:** WALLET_SCREENS.md credits use `color.secondary` (correct — money received is energy-positive). CHARGING_SESSION_SCREEN.md: energy metric value should use `color.secondary` to create semantic consistency with wallet credits. Confirmed consistent.

### Tertiary (`#6B4EFF`)
Used as: reservation status, balance card gradient endpoint, KYC-related UI tints, operator credits in wallet

**Audit:** RESERVATION_FLOW.md uses tertiary for reservation status consistently. WALLET_SCREENS.md §6 uses `color.tertiary` for `ReservationFee` transaction type — consistent.

### Error (`color.error`)
Used as: faulted station pins, fault session states, debit amounts in wallet, cancellation fees, Delete Account row

**Audit:** All debit amounts across WALLET_SCREENS.md, CHARGING_SUMMARY_SCREEN.md use `color.error` consistently. CHARGING_SESSION_SCREEN.md fault state uses `color.error` ring. No conflicts found.

### Warning (`color.warning`)
Used as: low balance states, no-show fees, cancellation fees, KYC pending state tint, check-in window urgency (5-min countdown)

**Audit note:** RESERVATION_FLOW.md §11 specifies "urgency color transitions at 15min (`color.warning`) and 5min (`color.error`)". CHARGING_SESSION_SCREEN.md does not have a time-based urgency transition (session ring stays primary blue throughout). This divergence is intentional — reservations have a hard cutoff (check-in window expires), sessions do not.

### Background (`#0A0F1E`)
Used exclusively in: CHARGING_SESSION_SCREEN.md (always-dark). No other screen uses this deep navy background.

**Audit:** CHARGING_SUMMARY_SCREEN.md §2 transitions from dark background to light during the open animation — this transition is from the session dark background to the standard light/dark background. This is correctly specified. No conflict.

### `color.text.tertiary`
Used as: timestamps, placeholder text, non-tappable version numbers, section headers, shimmer base, divider insets

**Audit:** Consistent usage across all screens. No conflicts.

---

## 3. Typography Token Usage Audit

### Display (`type.numeric.display`, 48sp/700)
Used in: Wallet balance card (large number), Charging Summary amount display  
Note: This token is numeric-only. All usage sites are correct — both are financial amounts.

### Headline sizes
`type.headline.small` used for: screen titles in profile header, KYC status titles, empty state primary messages  
`type.headline.medium` is not explicitly referenced in any screen spec — confirm this token exists in DESIGN_SYSTEM.md

### Title sizes
`type.title.medium` is the most common label: notification titles, transaction primary text, settings row labels, connector names  
`type.title.large` is used for: station name in station details hero area

### Body sizes
`type.body.large` is the standard text size for: input field content, settings row main labels, profile field values  
`type.body.medium` is used for: standard body copy, confirmation sheet text  
`type.body.small` is used for: secondary lines in transaction cards, timestamps, notes and caveats throughout

### Label sizes
`type.label.large` is used for button labels  
`type.label.small` is used for section headers, status chips, timestamps  
**Audit:** CHARGING_SUMMARY_SCREEN.md uses `type.label.small` for the tariff snapshot link. NOTIFICATION_SCREENS.md uses it for date group headers. Consistent.

### Duration display (`type.numeric.medium` + Inter font, LTR explicit container)
Per ARCHITECTURE_FINAL.md §25: durations (HH:MM:SS) must always render in LTR, Inter font, regardless of locale.  
**Audit:** CHARGING_SESSION_SCREEN.md §5 specifies the center mode "duration elapsed" as always-LTR in Inter. RESERVATION_FLOW.md §11 specifies the countdown as always-LTR with explicit direction. CHARGING_SUMMARY_SCREEN.md §8 shows duration as always-LTR. Consistent.

### Session/Transaction IDs (Latin, LTR, monospace)
Per ARCHITECTURE_FINAL.md §25.  
**Audit:** CHARGING_SUMMARY_SCREEN.md §19 specifies "Transaction ID — monospace, LTR, Latin digits, long-press to copy." WALLET_SCREENS.md §5 specifies "Reference — Transaction ID (long-press to copy)." No explicit LTR/monospace call-out in WALLET_SCREENS.md §5 — this is a gap. Implementation must apply monospace + LTR to all transaction ID display fields.

**Gap identified:** WALLET_SCREENS.md §5 (Transaction Detail) must add explicit monospace + LTR specification for the "Reference" field. Implementation guidance: always use `SelectableText(id, style: TextStyle(fontFamily: 'monospace'), textDirection: TextDirection.ltr)`.

---

## 4. Spacing and Layout Audit

### Standard horizontal padding: 16dp
Used consistently as the outer horizontal margin in: all list screens, settings screens, notification cards, wallet transactions. Confirmed consistent.

### Card padding: 16dp horizontal, 12dp vertical (standard) / 20dp–24dp (hero cards)
- Standard content card: 16dp × 12dp
- Balance card (WALLET_SCREENS.md §3): 24dp
- Profile header card (PROFILE_SCREENS.md §1): 20dp
- Session ring card area (CHARGING_SESSION_SCREEN.md §5): fills available width with 24dp horizontal padding  
No conflicts found.

### Bottom safe area
All sticky CTAs and tab bars must account for iOS home indicator (34dp) and Android gesture bar. Specified in: STATION_DETAILS_SCREEN.md §19, HOME_SCREEN.md §6. Implicit in all other screens.

**Gap:** SETTINGS_SCREENS.md and NOTIFICATION_SCREENS.md do not explicitly call out bottom safe area. These are scrollable list screens — the last item should have extra bottom padding (24dp + safe area inset). Implementation must handle this universally.

### 8dp grid adherence
All specified heights are divisible by 8: 48dp buttons, 52dp rows, 72dp cards, 80dp CTAs, 240dp peek sheet. No violations found.

### Touch target minimum: 44dp
Confirmed in: toggle switches (44dp), action buttons (48dp min), navigation bar items (44dp). All interactive elements meet the 44dp minimum. Swipe targets on cards (full card height) are all ≥ 72dp.

---

## 5. Elevation and Surface Audit

| Level | dp | Usage |
|-------|----|-------|
| 0 | 0dp | Flat surfaces, backgrounds |
| 1 | 1dp | Content cards (profile header, settings groups) |
| 2 | 2dp | Bottom sheets (resting) |
| 3 | 4dp | Navigation bar / tab bar |
| 4 | 6dp | Bottom sheets (elevated, active) |
| 5 | 8dp | Modal sheets, dialogs |
| 6 | 12dp | Overlays (not yet used) |

**Audit:** HOME_SCREEN.md station list bottom sheet uses elevation 4 (bottom nav equivalent) — this should be elevation 5 (modal sheet). Mark as a gap. STATION_DETAILS_SCREEN.md sticky CTA bar uses elevation 4 (correct — same level as nav bar). CHARGING_SESSION_SCREEN.md operates in a dark surface environment; shadows use `color.primary` blue-tinted shadows per design system spec.

**Shadow tint:** Design system specifies blue-tinted shadows (`color.primary` at low opacity) on dark backgrounds. CHARGING_SESSION_SCREEN.md must use `rgba(15, 94, 255, 0.3)` for its card shadows instead of pure black.

---

## 6. Border Radius Token Audit

| Token | Value | Used in |
|-------|-------|---------|
| `radius.none` | 0dp | Dividers, full-bleed images |
| `radius.xs` | 4dp | Inline chips, small tags |
| `radius.sm` | 8dp | Skeleton placeholders |
| `radius.md` | 12dp | Input fields, small cards |
| `radius.lg` | 16dp | Content cards |
| `radius.xl` | 20dp | Balance card, bottom sheet corners, hero cards |
| `radius.full` | 9999dp | Buttons, avatars, status chips, icon circles |

**Audit:**
- All buttons: `radius.full` ✓
- Status chips: `radius.full` ✓
- Station PIN cluster arc: custom `radius.xl` ✓
- Bottom sheets: `radius.xl` top corners only ✓
- Settings rows (grouped): outer wrapper uses `radius.lg`, individual rows have no radius ✓

No violations found. All usage sites consistently reference the token set.

---

## 7. Animation Consistency Audit

### Transitions between screens

| Transition | Duration | Easing | Spec source |
|------------|----------|--------|-------------|
| Standard push/pop | 300ms | `easeInOut` | DESIGN_SYSTEM.md |
| Shared element (map → station details) | 400ms | `spring(0.8)` | STATION_DETAILS_SCREEN.md §5 |
| Session screen entry | 600ms | `easeOut` | CHARGING_SESSION_SCREEN.md §26 |
| Summary screen ring shrink | 800ms | `spring(0.6)` | CHARGING_SUMMARY_SCREEN.md §4 |

### Micro-animations

| Component | Behavior | Duration |
|-----------|----------|----------|
| Station pin status change | Pulse ring + color fade | 400ms |
| Charging ring fill | Continuous smooth arc extend | 1s per segment |
| Cost counter | ¥0 → final value, ease-out | 1200ms |
| Balance card | No animation on load (static) | — |
| Skeleton shimmer | Left-to-right (LTR) / right-to-left (RTL) | 400ms repeating |
| Bottom sheet snap | Spring physics | 350ms |
| Notification foreground banner | Slide down / slide up | 300ms |

**Audit:** CHARGING_SUMMARY_SCREEN.md §4 specifies the cost counter animation at 1200ms ease-out. WALLET_SCREENS.md does not specify any balance animation — balances are static on load (correct, since they're historical data not a live counter).

**Conflict found:** HOME_SCREEN.md §15 specifies station status update animations at 400ms. CHARGING_SESSION_SCREEN.md §24 specifies heartbeat border flash at 2s interval. These are different components with different purposes — not a conflict.

---

## 8. RTL Consistency Audit

Per ARCHITECTURE_FINAL.md §25: all layout must mirror in RTL (Farsi locale).

### Verified RTL behaviors across screens

| Component | LTR | RTL | Source |
|-----------|-----|-----|--------|
| Tab bar order | L→R: Map/Reservations/Charging/Wallet/Profile | R→L: same semantic order | HOME_SCREEN.md §1 |
| Bottom sheet drag | Drag up to expand | Same | HOME_SCREEN.md §6 |
| Session ring direction | Clockwise | Counter-clockwise | CHARGING_SESSION_SCREEN.md §5 |
| Timer / duration | LTR explicit container | LTR explicit container (unchanged) | All screens |
| Transaction amounts | Aligned to end (right in LTR) | Aligned to end (left in RTL) | WALLET_SCREENS.md §13 |
| Station gallery scroll | Left-to-right | Right-to-left | STATION_DETAILS_SCREEN.md §6 |
| Reservation slot grid | Monday first | Monday first (calendar logic unchanged) | RESERVATION_FLOW.md §5 |
| Notification accent bar | Left side of card | Right side of card | NOTIFICATION_SCREENS.md §13 |
| Settings rows | Icon left, chevron right | Icon right, chevron left | SETTINGS_SCREENS.md §12 |
| Skeleton shimmer | Left→Right | Right→Left | §1 above |

### RTL numeric display

All monetary values, distances, and percentages use Persian-Indic digits (۰-۹) in the `fa` locale. Duration values (HH:MM:SS) remain in Latin digits, always in LTR containers with Inter font.

**Gaps:**
- WALLET_SCREENS.md §13 specifies Persian-Indic digit amounts for the RTL section but does not call out the `type.numeric.medium` token specifically. Implementation must use `CurrencyFormatter.formatToman(amount, locale: 'fa')` which handles digit substitution.
- PROFILE_SCREENS.md §13 mentions "Persian-Indic digits" for the stats row but does not specify the formatting class. Same implementation note applies.

---

## 9. Accessibility Audit

### Semantic label coverage

All interactive elements across all designed screens have accessibility labels specified. Confirmed coverage:

| Screen | Labeled elements | Gaps |
|--------|----------------|------|
| HOME_SCREEN.md | Map, pins, bottom sheet, stop button | None identified |
| CHARGING_SESSION_SCREEN.md | Ring, metrics, stop button, fault state | None identified |
| STATION_DETAILS_SCREEN.md | Gallery, CTA bar, connector cards | None identified |
| RESERVATION_FLOW.md | Time slots, countdown, check-in CTA | None identified |
| CHARGING_SUMMARY_SCREEN.md | Ring medallion, amounts, chart | Chart requires audio description |
| WALLET_SCREENS.md | Balance card (privacy mode), transactions | None identified |
| PAYMENT_FLOW.md | (browser-based; accessibility is OS/browser's responsibility) | — |
| PROFILE_SCREENS.md | KYC camera, avatar edit, sign out | None identified |
| NOTIFICATION_SCREENS.md | Bell badge, notification cards, swipe | None identified |
| SETTINGS_SCREENS.md | Toggles, language selection, version | None identified |

### Chart accessibility (CHARGING_SUMMARY_SCREEN.md §16)

The power-vs-time chart (cubic spline, 96dp height) presents a significant accessibility challenge. The specification notes the chart must have:
- An accessible description: "Power delivery over time. Peak [N] kW at [time]. Average [N] kW."
- The data table must be available via an alternative view (a "View data" toggle that shows the underlying data as a list)

### Color-only information

The design does not rely on color alone to convey meaning anywhere:
- Station status: color chip + text label
- Transaction types: color + icon + text
- KYC states: color + icon + text
- Charging ring states: color + animation + text in center

Confirmed: no color-only information patterns.

### Focus order

All screens with complex layouts (HOME_SCREEN.md, CHARGING_SESSION_SCREEN.md) specify linear focus order. The map screen (HOME_SCREEN.md) requires special treatment: the map itself is an accessibility container with "Explore charging stations near you" description, not individually focusable pins (which would be hundreds of items). The bottom sheet content is the primary accessibility surface for station selection.

---

## 10. Icon Usage Audit

All icons should come from a single icon library (e.g., Material Symbols or Lucide). The design does not specify which library — this must be resolved before implementation.

**Recommendation:** Use Material Symbols (Outlined weight, 24dp optical size) as the baseline. This integrates with Flutter's `Icons` class with no additional package. Exception: specialized EV icons (connector types: CCS/CHAdeMO/Type 2/GB/T) require a custom icon set — these are not in Material Symbols.

### Custom icon requirements

| Icon | Used in | Design note |
|------|---------|-------------|
| CCS connector | STATION_DETAILS_SCREEN.md, HOME_SCREEN.md | Custom SVG required |
| CHAdeMO connector | Same | Custom SVG required |
| Type 2 connector | Same | Custom SVG required |
| GB/T connector | Same | Custom SVG required |
| EV pin cluster | HOME_SCREEN.md §7 | Custom proportional arc — canvas-drawn, not an icon |
| Charging ring | CHARGING_SESSION_SCREEN.md §5 | Canvas-drawn arc, not an icon |

---

## 11. Navigation Pattern Audit

### Go Router route structure

All screens reference routes defined as Go Router paths. A summary:

| Route | Screen | Guard |
|-------|--------|-------|
| `/map` | Home (Tab 1) | Auth |
| `/reservations` | Reservations (Tab 2) | Auth |
| `/charging/:sessionId` | Active Session | Auth + session ownership |
| `/wallet` | Wallet (Tab 4) | Auth |
| `/profile` | Profile (Tab 5) | Auth |
| `/settings` | Settings | Auth |
| `/stations/:id` | Station Details | None (public) |
| `/stations/:id/reserve` | Reservation Creation | Auth + KYC |
| `/reservations/:id` | Reservation Detail | Auth + ownership |
| `/charging/:sessionId/summary` | Charging Summary | Auth + ownership |
| `/wallet/topup` | Top-up Flow | Auth |
| `/wallet/transactions/:id` | Transaction Detail | Auth + ownership |
| `/profile/edit` | Edit Profile | Auth |
| `/profile/kyc` | KYC Flow | Auth |
| `/profile/kyc/status` | KYC Status | Auth |
| `/profile/security` | Account Security | Auth |
| `/notifications` | Notification Center | Auth |
| `/payment/result` | Payment Deep Link | Auth (deep link return) |

**Back-navigation pattern:** All secondary screens (pushed) use the back chevron (←). No screen uses a "Close" (✕) except modal sheets and bottom sheets.

**Audit:** PAYMENT_FLOW.md uses the OS browser (not an in-app route). The `/payment/result` deep link is the return entry point. This is not a navigable screen — it's a deep link handler that dispatches to `/wallet` with a status toast. Confirmed correct.

---

## 12. Loading State Consistency

All screens define loading states. Standard pattern:
1. Skeleton fills the expected layout of the loaded content
2. Shimmer animates LTR (RTL in fa locale)
3. No full-screen loading spinners (content renders as it loads)
4. Tab-level screens load their data on mount; secondary screens may show skeletons for 300-500ms

**Exceptions:**
- PAYMENT_FLOW.md: loading states are in the OS browser, not the app
- CHARGING_SESSION_SCREEN.md: no loading state — the screen only exists if a session is active (guard-protected)
- Settings sub-screens: most settings are local or synchronously available — no skeleton needed

**Gap:** STATION_DETAILS_SCREEN.md §26 specifies loading behavior for the gallery but not for the connector card list. If the connector status is real-time (WebSocket), there may be a brief lag between screen open and live connector status. Implementation should show "..." in the connector status chip during initial load.

---

## 13. Error State Consistency

All screens define error states. Standard pattern:
1. Inline error within the content area (not a full-screen takeover)
2. Error message + "Retry →" link
3. Previously cached content displayed alongside the error indicator

**Full-screen errors** (only when no cached content exists):
- STATION_DETAILS_SCREEN.md §22 (if station not found: 404 full-screen)
- CHARGING_SESSION_SCREEN.md §14 (if session cannot be loaded: redirect)

**Never use dialogs for errors** (per DESIGN_SYSTEM.md philosophy — dialogs interrupt flow). All error states are inline. Confirmed: no screen spec uses error dialogs.

---

## 14. Empty State Consistency

Empty state pattern across all screens:
1. Illustration (SVG, 80dp, `color.text.tertiary` at 20% opacity)
2. Primary message: `type.headline.small`, centered
3. Secondary message: `type.body.medium`, `color.text.secondary`, centered
4. CTA button (where applicable)

| Screen | Empty trigger | CTA |
|--------|--------------|-----|
| HOME_SCREEN.md | No stations near location | "Expand search area" |
| RESERVATION_FLOW.md | No reservations | "Find a station" → map |
| WALLET_SCREENS.md | No transactions | "Add Funds" → top-up |
| NOTIFICATION_SCREENS.md | No notifications | None |
| NOTIFICATION_SCREENS.md | All dismissed | None |

Consistent pattern confirmed.

---

## 15. Conflicts and Gaps

### Conflicts

**C-1: Bottom sheet elevation**
HOME_SCREEN.md bottom sheet uses elevation 4. DESIGN_SYSTEM.md reserves elevation 5 for modal sheets. Since the home screen bottom sheet IS a modal-type overlay, it should be elevation 5.
**Resolution:** Update HOME_SCREEN.md bottom sheet to elevation 5.

**C-2: "Sign Out" placement duplication**
PROFILE_SCREENS.md §1 includes "Sign Out" and SETTINGS_SCREENS.md originally could have included it. Current design keeps Sign Out only in Profile. Confirmed: SETTINGS_SCREENS.md does not include Sign Out — it has "Delete Account" under the DATA section. No conflict.

**C-3: KYC gate messaging**
STATION_DETAILS_SCREEN.md §12 specifies KYC-gated CTAs (showing "Verify Identity" instead of "Reserve"). PROFILE_SCREENS.md §6 specifies the KYC flow is accessible "from any screen that requires KYC." The two need a shared KYC modal/sheet component. This is specified but must be a single implementation.

### Gaps

**G-1: Transaction ID rendering spec missing from WALLET_SCREENS.md §5**
The "Reference" field in the Transaction Detail screen must explicitly specify: monospace font, LTR text direction, Latin digits, long-press to copy. CHARGING_SUMMARY_SCREEN.md §19 is the authoritative reference. Implementation must apply this consistently.

**G-2: Connector type icon set not defined**
The custom SVG icon set for CCS/CHAdeMO/Type 2/GB/T connectors must be created before implementation. No file in the docs set addresses this. Resolution: create `docs/ui/CONNECTOR_ICONS.md` or include as an appendix.

**G-3: Station Details loading state for connector status**
Connector status chips should show a neutral skeleton state (not a "loading" text) during the initial real-time status fetch. Add to STATION_DETAILS_SCREEN.md §26.

**G-4: DESIGN_SYSTEM.md `type.headline.medium` token**
No screen spec references `type.headline.medium`, only `type.headline.small`. Either the token is unused and should be removed, or it should be used (e.g., screen titles in the nav bar). Confirm with design system.

**G-5: Haptic feedback not specified**
No screen spec mentions haptic feedback (vibration). Haptics are expected on: button taps, charging start/stop confirmation, fault alerts, check-in success. A haptic feedback guideline should be added to DESIGN_SYSTEM.md.

---

## 16. Implementation Guidance

### Component build order (recommended)

Build in dependency order — foundational components first:

**Phase 1 — Core primitives:**
1. Color, typography, spacing tokens (Dart constants from DESIGN_SYSTEM.md)
2. Button variants (Primary/Secondary/Tertiary × Large/Normal)
3. Input field
4. Loading skeleton + shimmer
5. Inline error banner
6. Settings row

**Phase 2 — Domain components:**
7. Station status chip
8. Connector status card
9. Transaction card
10. Notification card
11. Avatar with initials fallback
12. Bottom sheet wrapper (with snap points)

**Phase 3 — Screen-specific:**
13. Session ring (canvas) 
14. Station pin cluster (canvas)
15. Power-vs-time chart (canvas)
16. Balance card (with gradient)
17. Collapsing navigation bar

**Phase 4 — Navigation:**
18. Tab bar
19. Go Router configuration
20. Auth guard + KYC guard
21. Deep link handlers

### Token adherence rules

1. Never use hex color values in widgets — always reference `Theme.of(context).colorScheme.X`
2. Never use hard-coded `TextStyle` — always use `Theme.of(context).textTheme.X`
3. Never use raw `BorderRadius.circular(N)` — define radius tokens as constants and use those
4. Never use raw `EdgeInsets.all(N)` — use spacing token constants

### Locale-sensitive rendering rules

1. Any numeric duration (HH:MM:SS): wrap in `Directionality(textDirection: TextDirection.ltr, child: Text(..., style: TextStyle(fontFamily: 'Inter')))`
2. Any ID, transaction reference: monospace + LTR + Latin digits
3. Any monetary amount in `fa` locale: use `CurrencyFormatter.formatToman(amount, locale: 'fa')` which substitutes Persian-Indic digits
4. Shimmer direction: `Directionality`-aware — reads from `TextDirection` automatically if using `LinearGradient` with `AlignmentDirectional`