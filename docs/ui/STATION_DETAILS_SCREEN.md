# Station Details Screen

**Screen route:** `/stations/:stationId`  
**Entry points:** "View Station" in Home screen expanded sheet · Station search result tap · Notification deep link · Reservation history tap  
**Tab context:** Pushes over the 5-tab shell; back navigation returns to the originating screen  
**Last Updated:** 2026-06-11  
**References:** DESIGN_SYSTEM.md · ARCHITECTURE_FINAL.md §17 · HOME_SCREEN.md §17 · CHARGING_SESSION_SCREEN.md

The Station Details screen is the user's primary decision surface. It answers one question — "Should I charge here?" — with enough depth that the answer is always complete. The user arrives from a pin tap or a search result having already seen the station's name and distance. Everything on this screen is new information: the connectors in detail, the exact pricing, the amenities, and the actions available to them right now based on their account state.

---

## Table of Contents

1. [Screen Purpose and Design Intent](#1-screen-purpose-and-design-intent)
2. [User Goals and Priorities](#2-user-goals-and-priorities)
3. [Information Hierarchy](#3-information-hierarchy)
4. [Screen Entry Points and Navigation Architecture](#4-screen-entry-points-and-navigation-architecture)
5. [Layout Anatomy](#5-layout-anatomy)
6. [Station Gallery](#6-station-gallery)
7. [Station Header](#7-station-header)
8. [Real-Time Connector Availability Summary](#8-real-time-connector-availability-summary)
9. [Connector Cards](#9-connector-cards)
10. [Connector Selection Behavior](#10-connector-selection-behavior)
11. [Pricing Display](#11-pricing-display)
12. [Amenities Section](#12-amenities-section)
13. [Operator Information](#13-operator-information)
14. [Opening Hours](#14-opening-hours)
15. [Navigation Integration](#15-navigation-integration)
16. [Reservation Entry Point](#16-reservation-entry-point)
17. [Start Charging Entry Point](#17-start-charging-entry-point)
18. [KYC-Dependent Actions](#18-kyc-dependent-actions)
19. [Loading States](#19-loading-states)
20. [Empty States](#20-empty-states)
21. [Error States](#21-error-states)
22. [Offline Behavior](#22-offline-behavior)
23. [Accessibility Requirements](#23-accessibility-requirements)
24. [RTL Behavior (Persian / Farsi)](#24-rtl-behavior-persian--farsi)
25. [Edge Cases](#25-edge-cases)
26. [Future Expansion Surfaces](#26-future-expansion-surfaces)
27. [Transitions and Animations](#27-transitions-and-animations)

---

## 1. Screen Purpose and Design Intent

**Single sentence purpose:** Give the user every piece of information they need to decide whether to charge at this station, and then let them act on that decision immediately.

The station details screen is the contract between the platform and the user's trust. A user who reads this screen and decides to charge is implicitly agreeing to the pricing, the connector type, and the operator's terms. If anything on this screen is misleading or out of date, the billing dispute that follows is a product failure, not a support ticket.

**Design principles for this screen:**

1. **Stale data is harmful.** Connector status is the highest-risk information on the screen. A user who drives 15 minutes to a station because the app showed it as available — only to find every connector occupied — will not use the app again. Status must be live, its freshness must be visible, and the limits of the data must be communicated honestly.

2. **Price must be unambiguous.** The user must know exactly what they will be charged before they tap "Start" or "Reserve". Tariff complexity is the operator's problem, not the user's. The screen translates every pricing model into plain language.

3. **Connectors are the product.** The station itself is just an address. The connectors — their type, power level, status, and price — are what the user came to evaluate. The connector section is the center of gravity.

4. **Two flows, one screen.** Reserve-first and walk-up-start are different intents that the same user may have at the same station on different days. The screen supports both without privileging one over the other.

5. **KYC state is not the user's problem.** If the user cannot act because their identity is unverified, the screen explains what to do — it does not simply disable the button and leave the user confused.

---

## 2. User Goals and Priorities

Users arrive at this screen with one of three intents. The screen must serve all three without each getting in the way of the others.

**Intent A — Immediate charge (walk-up driver)**  
Arriving at or near the station now. Goal: confirm a connector is available and start a session in under 30 seconds.

**Intent B — Advance planner**  
Not at the station yet. Goal: assess the station, check pricing, and reserve a slot for a future visit.

**Intent C — Researcher**  
Exploring options in an unfamiliar area. Goal: compare this station against others — network reliability, amenities, operator.

| Priority | Goal | Which intent |
|----------|------|-------------|
| 1 | Is a compatible connector available right now? | A, B |
| 2 | How much will it cost? | A, B, C |
| 3 | How do I get there? | A, B |
| 4 | Can I reserve a connector? | B |
| 5 | What amenities are nearby? | B, C |
| 6 | Is the station open right now? | A, B |
| 7 | Who operates this station and how do I contact them? | C, and A when faulted |
| 8 | What do other users say about this station? | C |

---

## 3. Information Hierarchy

### Available at a glance (no scrolling, no interaction)

- Station name and network operator
- Is the station open right now?
- How many connectors are available vs. occupied
- Connector types supported (visual chips)
- Price starting from (summary only)
- Distance from current location

### Available on single scroll (scanning the page)

- Each connector: type, power, status, exact price, and available action
- Full pricing breakdown for each tariff component
- Amenities as icon chips
- Opening hours summary

### Available on interaction (tap to expand)

- Full hours schedule (Mon–Sun table, collapsed by default)
- Operator contact details (collapsed by default)
- Photo lightbox (tap gallery image)
- Connector type explanation (tap the "?" next to connector type name)
- Pricing explanation (tap "?" next to tariff structure)

---

## 4. Screen Entry Points and Navigation Architecture

### Entry point 1 — Home screen expanded bottom sheet

The user tapped "View Station" from the expanded sheet on the Home screen. The station ID and partial data (name, address, connector chips, distance) were already loaded in the sheet.

**Transition:** The expanded bottom sheet morphs into a full-screen push. The station name, address, and connector chips slide up to their positions in the Station Header section. The gallery fades in behind them. This is a shared-element transition — the user does not experience a jarring screen change, but a continuation of the detail reveal.

Duration: 350ms, cubic Bézier (0.4, 0, 0.2, 1).

**Data pre-population:** Because the partial data was already in memory, the Station Header renders immediately without a skeleton. The gallery and detailed connector cards fetch concurrently on screen mount.

### Entry point 2 — Search result tap

User tapped a result in the map search. No prior data is cached. Full skeleton shown on entry.

**Transition:** Standard horizontal push transition from right (LTR) / from left (RTL).

### Entry point 3 — Notification deep link

Push notification "Your reservation at [Station] starts in 30 minutes" is tapped. App opens directly to this screen with the station pre-selected.

**Transition:** Screen slides up from below, over whatever screen the app was on (or cold-starts directly to this screen after auth guard passes).

**Special state:** If the user arrives via a reservation notification, the active reservation for this station is highlighted at the top of the connector cards section (pinned card before the regular connector list).

### Entry point 4 — Reservation history

User taps a past or upcoming reservation from the Reservations tab. Arrives at this screen with the reservation context — the reserved connector is highlighted.

### Back navigation

- From Entry 1 (Home sheet): back collapses back into the expanded sheet state on the Home screen (reverse shared-element transition)
- From Entries 2, 3, 4: standard back pop (slides right in LTR / left in RTL)

---

## 5. Layout Anatomy

The screen is a single vertically scrolling column with a collapsing sticky navigation bar.

### Navigation bar collapse behavior

**Scroll position 0 (top):**
- Nav bar: transparent, no background
- Back icon: 40dp circle, `color.surface` background at 80%, `radius.full` — a "floating pill" button that maintains legibility over the gallery image
- Share icon: same floating pill style, end-aligned
- Station name in nav bar title: opacity 0 (hidden)

**Scroll position 80dp to 200dp (transition zone):**
- Nav bar background: `color.surface` animating from 0% to 100% opacity, linearly proportional to scroll within this 120dp window
- Station name: fades in, opacity proportional to scroll within the same window
- Back and Share icons: pill background fades out as the nav bar background fades in (they become normal bar icons at 100% scroll)

**Scroll position ≥ 200dp (nav bar fully opaque):**
- Nav bar: fully opaque `color.surface`, elevation 2
- Station name: `type.title.medium`, `color.text.primary`, 1 line, ellipsis
- Back and Share icons: standard icon buttons, `color.text.primary`

### Content column (top to bottom)

```
┌────────────────────────────────────────────────────────────────┐
│  [Gallery — 260dp tall, full bleed]                            │  §6
│  [Station Header — name, address, distance, badges]            │  §7
│  [Availability Summary — quick status row]                     │  §8
│  [Connector Cards — one card per connector]                    │  §9
│  [Pricing Section — tariff breakdown]                          │  §11
│  [Amenities Section — icon chips + labels]                     │  §12
│  [Operator Information — name, logo, contact]                  │  §13
│  [Opening Hours — today highlighted + expandable week]         │  §14
│  [Location Map Thumbnail — static map + directions CTA]        │  §15
│  [32dp bottom spacer above sticky CTA bar]                     │
└────────────────────────────────────────────────────────────────┘
                    ↑ scroll content ends here

┌────────────────────────────────────────────────────────────────┐
│  [Sticky CTA Bar — appears when connectors scroll off screen]  │  §10
└────────────────────────────────────────────────────────────────┘
```

### Sticky CTA bar

The sticky CTA bar is a persistent action surface that ensures the primary actions (Reserve, Start) are always reachable, even when the user has scrolled past the connector cards into the pricing or amenities sections. It sits above the device safe area, below the scrollable content.

- Height: 72dp + bottom safe area inset
- Background: `color.surface`, top border 1dp `color.outline` at 40% opacity
- Appears with a 200ms upward slide when the bottom of the last connector card scrolls off the top of the viewport
- Disappears with the reverse animation when the user scrolls back up to the connector section

**Content when ≥1 connector is available:**
```
  [ ⚡ 3 available ] ————————— [Reserve] [Start Now]
```
- Left: availability chip — bolt icon 16dp, `color.secondary` + "[N] available" `type.label.large`, `color.secondary`
- Right: Reserve (Secondary, 32dp Small) + Start Now (Primary, 32dp Small)
- 8dp gap between the two buttons

**Content when no connectors available:**
```
  [ ○ All busy — est. free in ~20 min ]  [Notify Me]
```

**Content when KYC not approved:**
```
  [ ! Action required ]  [Verify Identity →]
```

---

## 6. Station Gallery

The gallery is a horizontally scrollable full-bleed photo strip at the top of the screen. It is the first thing the user sees.

### Gallery dimensions and behavior

- Height: 260dp (fixed, does not grow or shrink with scroll — the scroll collapses the nav bar, not the gallery itself)
- Width: full screen, edge-to-edge
- Photos: up to 5 images provided by the operator
- Swipe: horizontal swipe to advance through photos
- No auto-advance
- Page indicator: row of dots centered at the bottom of the gallery, 20dp from bottom edge

**Page indicator dots:**
- Active: 20dp × 6dp pill, `radius.full`, white
- Inactive: 6dp circle, white at 50% opacity
- Gap: 6dp between dots
- Animate: active pill slides to the new position as the user swipes (width simultaneously collapses/expands)

### Photo treatment

Photos are displayed with `BoxFit.cover` — they fill the 260dp height without letterboxing, cropping top/bottom as needed. A 48dp gradient at the bottom edge of each photo: black at 50% → transparent. This gradient ensures the page indicator remains legible over bright or white photos.

### Tap to expand (lightbox)

Tapping any gallery photo opens a full-screen lightbox:
- Background: `#000000`
- Photo centered and pinch-zoomable (up to 4×)
- Swipe horizontally to navigate between photos
- Page indicator at bottom, same dot style
- Close button: ✕ 40dp circle, `color.surface` at 80%, top-right, 16dp from edges
- Back swipe from left edge (LTR) / right edge (RTL) closes the lightbox
- The lightbox is a standard push navigation with a fade transition (200ms), not a modal

### Fallback: no photos available

When the operator has not provided photos:

- Gallery area renders a 260dp static map thumbnail centered on the station's coordinates
- Map style: low-saturation, no POI labels except the station pin
- Station pin: the standard map pin from the Home Screen pin spec, centered in the thumbnail
- Bottom-left overlay badge: 28dp height, `radius.full`, `color.surface` background, map icon 14dp + "View on map" `type.label.small`, `color.text.secondary`
- No page indicator (single image, no navigation)
- Tapping the thumbnail: navigates to the Home screen with this station's pin selected and the expanded sheet open (not to a photos lightbox)

### Photo source and attribution

Operator-provided photos. If the operator has also uploaded a logo, the logo is not placed in the gallery — it appears in the Operator Information section.

---

## 7. Station Header

The station header is a content block immediately below the gallery. It is the first text-based section and must orient the user to the station's identity and context quickly.

### Header layout

```
  ┌──────────────────────────────────────────────────────┐
  │                                              24dp top │
  │  Elm Street Charging Hub               ★ 4.2  (127)  │  ← Name + rating
  │  12 Elm Street, District 4, Tehran                   │  ← Address
  │                                                      │  ← 8dp gap
  │  [⚡ FastCharge Network]  [📍 1.2 km]  [✓ Open now]  │  ← Badges row
  │                                             16dp btm  │
  └──────────────────────────────────────────────────────┘
```

### Station name

- Typography: `type.headline.large` (28sp/600)
- Color: `color.text.primary`
- Max 2 lines, ellipsis on overflow
- Aligned start (left in LTR, right in RTL)

### Rating

Shown only if rating data is available from the station record. Positioned inline at the end of the name row:
- Star icon: 14dp, `color.warning` (#F59E0B)
- Rating value: `type.title.medium`, `color.text.primary`
- Review count: `type.body.medium`, `color.text.secondary`, in parentheses

If no rating data: this element is absent (no "No ratings yet" placeholder — absence is cleaner than a zero state here).

### Address

- `type.body.large`, `color.text.secondary`
- Full address, 1 line, ellipsis on overflow
- Tapping the address copies it to the clipboard. A brief toast confirms: "Address copied" (1.5s, bottom-center)

### Badges row

Horizontally scrollable row of context badges. Scroll only when badges overflow — most stations fit without scrolling.

| Badge type | Icon | Label | Color |
|-----------|------|-------|-------|
| Operator network | Operator logo 16dp circle | Network name | `color.text.secondary` |
| Distance | 📍 14dp | Distance from user | `color.text.secondary` |
| Open now | ✓ 14dp, `color.secondary` | "Open now" or "Closes at [time]" | `color.secondary` |
| Closed | ✗ 14dp, `color.error` | "Closed · Opens [day] [time]" | `color.error` |
| Membership required | 🔒 14dp | "Members only" | `color.warning` |

**Badge chip design:**
- Height: 28dp, `radius.full`
- Background: `color.surfaceVariant`
- Padding: 8dp horizontal
- 8dp gap between chips
- `type.label.large` (14sp/500)

---

## 8. Real-Time Connector Availability Summary

A compact summary bar between the Station Header and the first connector card. Provides instant answer to "is anything available?" before the user processes individual connector cards.

### Summary bar layout (40dp height)

```
  CONNECTORS (6)         ● 4 available  ○ 2 occupied
```

- Left: "CONNECTORS ([total count])", `type.label.small` (11sp), letter-spaced, `color.text.tertiary`
- Right: status summary in the format "[color dot] [N] [label]" pairs
  - Available: `color.secondary` dot (8dp) + "[N] available", `type.label.large`, `color.secondary`
  - Occupied/Reserved/Unavailable: `color.warning` or `color.outline` dot + count

**Live freshness indicator:**
A subtle element at the far end of the summary bar (after the status pairs, if space allows) or on a second line on small screens:
- "Live" label when data is fresh (last update < 60 seconds): `type.label.small`, `color.secondary`, with a 6dp `color.secondary` pulse dot
- "Updated [N]s ago" when data is older than 60 seconds: `type.label.small`, `color.text.tertiary`, no dot
- "Last known" when offline: `type.label.small`, `color.warning`

### Real-time update behavior

The availability summary updates instantly when a WebSocket event changes any connector's status. The status label transitions with a 150ms cross-fade. The dot changes color with a 150ms ease-in-out. There is no jarring recount — the numbers animate smoothly from old value to new value using a fast counter animation (100ms, ease-out).

---

## 9. Connector Cards

Connector cards are the most important section of this screen. Each connector at the station has its own card. Cards are arranged vertically, in this sort order:

1. User's active session connector (pinned first, if applicable)
2. User's active reservation connector (pinned second, if applicable)
3. Available connectors (by power level, highest first)
4. Reserved connectors (by release time, soonest first)
5. Occupied connectors (by estimated availability, soonest first)
6. Unavailable connectors (by connector ID)
7. Faulted connectors (always last)

### Connector card anatomy (standard, 104dp height)

```
  ┌────────────────────────────────────────────────────────┐
  │   [type icon]   CCS DC Fast              ● Available   │  ← Row 1
  │    36dp         Connector 3 · 150 kW                   │  ← Row 2
  │                 ¥60/kWh (fixed)  [Reserve]  [Start]   │  ← Row 3
  └────────────────────────────────────────────────────────┘
```

**Card container:**
- Background: `color.surface`
- Border: 1dp `color.outline` at 30% opacity
- Border radius: `radius.lg` (16dp)
- Padding: 16dp horizontal, 14dp vertical
- Horizontal margin: 16dp from screen edges
- Vertical gap between cards: 12dp
- Elevation: 1

**Left column — Connector type icon:**
- Circle: 44dp diameter, `radius.full`
- Background: status color at 12% opacity
- Icon: connector type SVG, 22dp, status color
- The icon and background color both reflect the connector's current status

**Connector type icons (each is a distinct SVG silhouette):**

| Connector type | Icon description |
|----------------|-----------------|
| Type 2 (IEC 62196) | 7-pin round plug silhouette |
| CCS Combo 2 | Type 2 with two DC pins below |
| CHAdeMO | Circular two-lug connector |
| GB/T AC | Chinese AC connector |
| GB/T DC | Chinese DC connector |

**Right column — Three rows:**

**Row 1 — Identity and status (20dp height):**
- Start: Connector type full name, `type.title.medium` (16sp/600), `color.text.primary`
- End: Status badge — colored dot (8dp) + status label, `type.label.large`, status color

**Row 2 — Connector detail (18dp height, 4dp below row 1):**
- "Connector [N]", `type.body.small`, `color.text.tertiary`
- Separator dot (4dp, `color.outline`)
- "[Power] kW", `type.body.small`, `color.text.secondary`
- If bidirectional (V2G capable, future): "↕ V2G" badge in `type.label.small`, `color.tertiary`, `color.tertiaryContainer` background, `radius.xs`

**Row 3 — Price and actions (32dp, 8dp below row 2):**
- Start: Price summary, `type.body.medium`, `color.text.secondary`. Format: "¥[rate]/kWh" or "¥[rate]/min" or "Mixed" (with "?" tap for detail)
- End: Action CTAs — see status-specific specifications below

### Status-specific card designs

**Status: Available**

Row 3 actions:
- "Reserve" — Secondary button, Small (32dp), `radius.full`, 56dp wide
- "Start" — Primary button, Small (32dp), `radius.full`, 64dp wide

If walk-up (direct start) is disabled by the operator: only "Reserve" shown.  
If reservations are disabled by the operator: only "Start" shown.  
If both are enabled (default): both shown, 8dp gap.

Card border: standard `color.outline` at 30%.

**Status: Occupied (another user's session)**

Row 2 addition: Estimated free time badge: "Est. free: ~20 min", `type.label.small`, `color.text.tertiary`
Row 3 actions:
- "Notify Me" — Tertiary button, Small, `color.primary`
  - On tap: user subscribes to an availability notification for this specific connector
  - Button changes to "Notifying ✓" (filled, `color.primaryContainer`, not interactive after tap)

Card border: standard.

**Status: Reserved (by another user)**

Row 1 status badge: `color.tertiary` dot + "Reserved" label
Row 2 addition: "Until [time]", `type.label.small`, `color.text.tertiary`
Row 3: No CTA. Reserve-until time shown instead: "Released at [HH:MM]" `type.body.small`, `color.text.tertiary`, right-aligned.

Card border: `color.tertiary` at 20% (subtle purple tint to distinguish from occupied).

**Status: Reserved by current user**

Pinned to the top of the connector list (after active session pin).

Row 1 status badge: `color.tertiary` dot + "Your reservation" label
Row 2 addition: Reservation details — "Reserved until [HH:MM]", `type.label.small`, `color.tertiary`
Row 3 actions:
- "Start" — Primary button, Small — visible when within reservation window
- "Cancel Reservation" — Tertiary button, Small, `color.error` text

Card border: 1.5dp `color.tertiary` (stronger visual distinction — this is the user's connector).
Card background: `color.tertiaryContainer` at 8% (very subtle tint).

**Status: Unavailable**

Row 1 status badge: `color.outline` dot + "Unavailable" label
Row 3: No CTA. "Check operator for schedule" `type.body.small`, `color.text.tertiary`, right-aligned.

Card: reduced opacity — all content at 60% (not the card border or background — the text and icon content). This visually recedes without disappearing.

**Status: Faulted**

Row 1 status badge: `color.error` dot + "Fault reported" label, `color.error`
Row 3: "Report Issue" — Tertiary button, Small, `color.error` text; "Contact Operator" — Tertiary button, Small, `color.primary` text

Card border: 1dp `color.error` at 40%.

**Status: Current user's active session**

Pinned to the absolute top of the connector list. This card is larger than the standard connector card: 120dp height.

Row 1: "Your Active Session" label in `color.secondary`
Row 2: Standard connector detail
Row 3: Session mini-progress row — mini version of the session ring (48dp), current kWh delivered, elapsed time
Row 4 (additional): "View Session" — Primary button, Small — navigates to the Charging Session screen

Card border: 1.5dp `color.secondary` (matches the session ring color).
Card background: `color.secondaryContainer` at 8%.

---

## 10. Connector Selection Behavior

The connector selection model determines what happens when the user taps "Reserve" or "Start". The behavior depends on whether multiple connectors of the same type are available.

### Single available connector of the user's type

If only one connector of the user's likely type is available: the "Reserve" and "Start" buttons on that specific connector card are the direct entry point. No selection modal needed — the connector is already identified.

### Multiple connectors of the same type and power

When more than one connector of identical type and max power is available, and the user taps "Reserve" or "Start" from one of them, a bottom sheet appears asking them to confirm which connector they want:

**Connector selection sheet (280dp height):**
- Title: "Select a connector", `type.headline.small`
- Subtitle: "All connectors below are available", `type.body.medium`, `color.text.secondary`
- List of eligible connectors, each row (64dp):
  - Connector number (e.g., "Connector 3"), `type.title.medium`
  - Power rating, `type.body.small`, `color.text.secondary`
  - Status dot, `color.secondary`
  - Physical location hint if available (e.g., "Left side of station"), `type.body.small`, `color.text.tertiary`
  - Trailing radio button (single-select)
- "Continue" — Primary Large, full-width, enabled when a connector is selected
- Pre-selection: the connector whose CTA was tapped is pre-selected; user can change before confirming

### Walk-up without connector selection

If the station has a single connector type and multiple available units, and the operator has enabled "any connector" reservation mode, the app may not ask the user to select a specific connector. The reservation is attached to a connector type at the station level, not a specific connector ID. In this case, the selection sheet is skipped entirely — "Reserve" or "Start" proceeds directly.

This is an operator-configured behavior. The station data includes a flag: `requiresConnectorSelection: bool`.

### Cable check reminder (AC charging only)

For Type 2 AC connectors specifically: after the user taps "Start" and before the confirmation screen appears, a one-time contextual tooltip appears (shown once per user account, then never again):

"Bring your own cable for Type 2 AC charging. Most AC stations require a tethered cable from the vehicle side."

This is shown as a 56dp inline information card within the confirmation flow, not a blocking modal.

---

## 11. Pricing Display

The pricing section is a dedicated content block below the connector cards. Because pricing can vary between connectors at the same station, this section aggregates and explains all tariff structures present at this station.

### Pricing section header

"PRICING", `type.label.small`, letter-spaced, `color.text.tertiary`, 24dp top padding.

### Tariff structure types

| Tariff type | Description | Display format |
|------------|-------------|---------------|
| Fixed per kWh | Flat rate per unit of energy | "¥[rate] / kWh" |
| Time-based | Flat rate per minute (regardless of power) | "¥[rate] / min" |
| Session fee only | Flat fee to start, no per-unit charge | "¥[fee] per session" |
| Mixed: session + energy | Flat start fee plus per-kWh | "¥[fee] + ¥[rate]/kWh" |
| Mixed: energy + idle | Per-kWh while charging; per-minute after session ends | "¥[rate]/kWh · ¥[idle]/min idle fee" |
| Tiered energy | Rate changes after N kWh | "¥[rate1]/kWh for first [N] kWh, ¥[rate2]/kWh after" |
| Dynamic | Varies by time of day | "Varies · from ¥[min_rate]/kWh" |
| Free | No charge | "Free" |

### Tariff display card

Each distinct tariff at the station gets its own subsection within the pricing block:

```
  ┌──────────────────────────────────────────────────────┐
  │  CCS DC Fast · Type 2 AC          [?]                │  ← Applies to these connectors
  │                                                      │
  │  Energy            ¥60 / kWh                        │
  │  Session fee       ¥500 (one-time, per session)      │
  │  Idle fee          ¥10 / min (after session ends)    │
  │                                                      │
  │  ─────────────────────────────────────────────────   │
  │  Example: 30 min · 25 kWh ≈ ¥2,000                  │
  └──────────────────────────────────────────────────────┘
```

**Card design:**
- Background: `color.surfaceVariant`
- Border radius: `radius.md` (12dp)
- Padding: 16dp
- No shadow

**"Applies to" label row (24dp):**
- Connector type chip(s): 24dp height, `radius.full`, `color.surface`, connector icon 14dp + connector name `type.label.small`
- "?" icon: 16dp, `color.text.tertiary`. Tap opens a tooltip explaining the connector type.

**Fee rows:**
- Each fee row: 44dp height, fee name left (`type.body.medium`, `color.text.secondary`), fee value right (`type.title.medium`, `color.text.primary`)
- No dividers between fee rows — visual separation by spacing alone (8dp between rows)

**Estimated cost example:**
- Separator: 1dp `color.outline`, full width
- "Example: [N] min · [N] kWh ≈ [cost]", `type.body.medium`, `color.text.secondary`
- The example figures are calculated from the operator-provided typical session parameters, not real-time
- If the station has only energy-based pricing: example shows "e.g., 30 kWh ≈ [cost]" without a time estimate

**Pricing notes (below card, if present):**
- Billing: "Billed at session end from your wallet", `type.body.small`, `color.text.tertiary`
- Minimum charge: "Minimum session charge: ¥[amount]" if applicable
- Currency clarification: In fa locale — "Prices in Iranian Tomans (تومان)", `type.body.small`, `color.text.tertiary`

### Multiple tariffs at one station

If the station has connectors with different tariff structures (e.g., AC connectors are ¥45/kWh and DC connectors are ¥60/kWh), each tariff gets its own card within the pricing section, separated by 12dp vertical gap.

### Dynamic pricing indicator

If any tariff at this station is dynamic, a yellow banner appears at the top of the Pricing section:
- Height: 44dp, `color.warningContainer` background, `radius.md`
- ⚡ icon 16dp, `color.warning` + "Prices vary by time of day" `type.body.medium`, `color.text.primary`
- Trailing: "View schedule →" Tertiary, `color.primary`, `type.label.large`
- Tapping "View schedule" expands a time-of-day pricing grid inline below the card (see §26 Future Expansion Surfaces for full dynamic pricing design)

---

## 12. Amenities Section

Amenities help the user decide whether to stay at the station or return to their vehicle. A 45-minute fast charge is more appealing if there is a coffee shop next door.

### Amenities section header

"AMENITIES", `type.label.small`, letter-spaced, `color.text.tertiary`, 24dp top padding.

### Amenities chip grid

A wrapping grid of amenity chips. Unlike the filter chips on the Home screen (which are horizontally scrollable), these wrap to multiple rows to show all amenities at once.

**Each amenity chip (32dp height):**
- `radius.full`, `color.surfaceVariant` background
- Icon: 16dp, `color.text.secondary`
- Label: amenity name, `type.label.large` (14sp), `color.text.secondary`
- 12dp horizontal padding, 8dp gap between chips

**Available amenities and icons:**

| Amenity | Icon |
|---------|------|
| Parking | P (parking symbol) |
| Covered parking | Roof-over-P |
| 24-hour access | Clock face |
| Coffee / Café | Coffee cup |
| Restaurant | Fork and knife |
| Restroom | Person silhouettes |
| Wi-Fi | Wi-Fi signal arc |
| Convenience store | Shopping basket |
| Shopping mall | Shopping bag |
| Hotel | Bed |
| Hospital / Clinic | Medical cross |
| Gym / Fitness | Dumbbell |
| ATM | Card with chip |
| EV accessories | Charging cable coil |
| Disabled access | Wheelchair symbol |
| Security / CCTV | Camera |

### Empty amenities

If no amenity data is provided: the section is absent entirely. Do not show "No amenities listed" — the absence of information is less disruptive than a placeholder that implies emptiness.

---

## 13. Operator Information

The operator is the company that owns and maintains the charging station. This information is secondary during the evaluation phase but becomes critical when something goes wrong (fault, billing dispute).

### Operator section header

"OPERATOR", `type.label.small`, letter-spaced, `color.text.tertiary`, 24dp top padding.

### Operator card (80dp height default, expandable)

```
  ┌──────────────────────────────────────────────────────┐
  │  [Operator logo]   FastCharge Network                │
  │       40dp         Commercial EV charging            │  ← Row 2: tagline
  │                    ──────────────────────────        │
  │                    [📞] [✉]  [Contact Support ↗]    │  ← Row 3: contact actions
  └──────────────────────────────────────────────────────┘
```

**Operator logo:** 40dp circle, `radius.full`, `color.surfaceVariant` background (fallback if no logo). Image loaded from operator record. No letterboxing — `BoxFit.cover`.

**Operator name:** `type.title.medium`, `color.text.primary`

**Tagline / category:** `type.body.small`, `color.text.secondary`. Operator-provided short description (max 48 characters). If absent: "EV charging operator".

**Contact actions row (conditionally shown):**

Contact details are collapsed by default to save vertical space. A "Show contact" link (`type.label.large`, `color.primary`, Tertiary) expands the row.

On expand (animated in, 200ms ease-out):
- Phone icon button (40dp): tapping opens the device phone dialer
- Email icon button (40dp): tapping opens the device mail client
- "Contact Support →" Tertiary button: opens the operator's support page in the in-app browser (WebView, not external browser — to maintain the app context)

If the operator has no contact details in their record: "Contact via operator app" note instead, `type.body.small`, `color.text.tertiary`.

---

## 14. Opening Hours

### Hours section header

"HOURS", `type.label.small`, letter-spaced, `color.text.tertiary`, 24dp top padding.

### Today's status banner (44dp height)

The most prominent element in this section. Always shown, always current.

**Station currently open:**
- `color.secondaryContainer` background, `radius.md`
- ✓ icon 16dp, `color.secondary` + "Open now" `type.title.medium`, `color.text.primary`
- Trailing: "Closes at [time]" `type.body.medium`, `color.text.secondary`

**Station currently closed:**
- `color.errorContainer` background, `radius.md`
- ✗ icon 16dp, `color.error` + "Closed" `type.title.medium`, `color.text.primary`
- Trailing: "Opens [day] at [time]" `type.body.medium`, `color.text.secondary`

**Open 24 hours:**
- `color.secondaryContainer` background
- ✓ icon + "Open 24 hours" `type.title.medium`
- No trailing content

**Hours unknown (no data):**
- Neutral `color.surfaceVariant` background
- "Hours not available" `type.body.medium`, `color.text.secondary`

### Full week schedule (collapsed by default)

Below the today's status banner: "Show full schedule" Tertiary link, `color.primary`, `type.label.large`.

On tap: the week schedule expands below (200ms ease-out):

| Day | Hours display |
|-----|--------------|
| Mon | 08:00 – 22:00 |
| Tue | 08:00 – 22:00 |
| … | … |
| Sun | 09:00 – 20:00 |

**Row format (40dp each):**
- Day name: `type.body.medium`, `color.text.secondary`; today's row uses `type.title.medium`, `color.text.primary` (bold emphasis)
- Hours: right-aligned, `type.body.medium`, `color.text.primary`; "Closed" in `color.error` if closed that day
- Today's row: a 2dp left border in `color.primary`, full row height, offset 8dp from the row start

"Collapse" link appears below the schedule to collapse it back. Arrow icon rotates 180° on expand/collapse (200ms).

### Special hours note

If the station has holiday hours or temporary schedule changes, an amber note below the schedule: "⚠ Hours may vary on public holidays · Check operator app for updates." `type.body.small`, `color.warning`.

---

## 15. Navigation Integration

The location section sits near the bottom of the screen, after hours. It is a map thumbnail combined with navigation actions.

### Location section layout

```
  ┌────────────────────────────────────────────────────────┐
  │                                                        │
  │         [Static map thumbnail, full width, 160dp]     │
  │               [station pin centered]                   │
  │                                                        │
  ├────────────────────────────────────────────────────────┤
  │  12 Elm Street, District 4, Tehran      [Copy ↑]      │
  │  📍 1.2 km from you                                    │
  │                                                        │
  │  [🚶 12 min walk]    [🚗 4 min drive]                  │
  │                                                        │
  │  ┌──────────────────────────────────────────────────┐ │
  │  │  ↗  Navigate to Station                          │ │
  │  └──────────────────────────────────────────────────┘ │
  └────────────────────────────────────────────────────────┘
```

### Static map thumbnail

- Height: 160dp, full width
- Border radius: `radius.lg` (16dp)
- Overflow: clipped to border radius
- Station pin: standard pin from Design System §10, centered
- Map style: same low-saturation style as the Home screen
- No interaction except: tapping the thumbnail opens the Home screen with this station pin selected and the full map visible (dismisses the Station Details screen)

### Distance and travel time

- Distance: "📍 [N] km from you" or "📍 [N] m from you" (switches to meters below 1.0 km), `type.body.medium`, `color.text.secondary`
- Walking time: 🚶 icon + "[N] min walk", `type.label.large`, `color.text.secondary`
- Driving time: 🚗 icon + "[N] min drive", `type.label.large`, `color.text.secondary`
- Both are estimates computed from the distance using standard speed assumptions (not live traffic). They are static once loaded — not live navigation estimates.
- If location permission is denied: distance and travel time are not shown. The static map thumbnail shows the station location without the user's position.

### Navigate button

"↗ Navigate to Station" — Secondary Medium button, full width.

On tap: opens the device's default maps application with driving directions to the station coordinates. On iOS: opens Apple Maps. On Android: opens Google Maps. Both platforms support the standard `maps:` URI with latitude/longitude.

### Address copy

"Copy ↑" — Tertiary, `type.label.large`, `color.primary`, trailing in the address row. Copies the full formatted address to the clipboard. Toast: "Address copied" (1.5s).

---

## 16. Reservation Entry Point

The reservation entry point is the "Reserve" CTA on each individual available connector card, as well as the "Reserve" action in the sticky CTA bar when the user has scrolled past the connector section.

### Pre-reservation information

Before navigating to the reservation creation screen, the user must understand:
1. Which connector they are reserving
2. How long the reservation window is
3. Whether there is a reservation fee

This information is surfaced in a confirmation sheet, not a new screen. Only after the user confirms does the app navigate to the full reservation creation flow.

### Reservation confirmation sheet (on "Reserve" tap)

Height: 360dp + safe area. Standard handle. Slides up 280ms.

```
  ──── (handle)

  Reserve Connector 3?
  type.headline.small

  ─── Connector ────────────────────────────────────────

  [CCS icon 36dp]  CCS DC Fast
                   150 kW max · ¥60/kWh (fixed)

  ─── Reservation window ───────────────────────────────

  Reservation valid for  30 minutes
  type.body.medium       type.title.medium

  ⚠  If you do not start charging within 30 minutes,
     the reservation is automatically released.
     type.body.small, color.text.secondary

  ─── Cost ─────────────────────────────────────────────

  Reservation fee  Free
  (Charged when session completes)

  ────────────────────────────────────────────────────

  [  Confirm Reservation  ]  ← Primary Large
  [  Cancel              ]  ← Tertiary
```

**Reservation window duration:** Operator-configured, shown from station data. Common values: 15, 30, 45, 60 minutes.

**Reservation fee:** Shown explicitly. Most stations have no reservation fee — "Free" is shown. If there is a fee (operator-configured), the amount is shown with "Deducted from wallet on reservation." The presence or absence of a fee must be explicit.

### After confirmation

On "Confirm Reservation":
- Sheet closes (slides down, 220ms)
- App navigates to the Reservation Creation screen (`/reservations/new?stationId=&connectorId=&connectorType=`)
- The station name, connector details, and reservation window are passed as route parameters so the creation screen renders immediately without an additional fetch

---

## 17. Start Charging Entry Point

### Walk-up session (no prior reservation)

On "Start" tap from a connector card:

**Confirmation sheet (on "Start" tap, 400dp height):**

```
  ──── (handle)

  Start charging?
  type.headline.small

  ─── Connector ────────────────────────────────────────

  [CCS icon 36dp]  CCS DC Fast · Connector 3
                   150 kW max

  ─── Pricing ──────────────────────────────────────────

  ¥60 / kWh (fixed)
  Session fee: ¥500

  ─── Payment ──────────────────────────────────────────

  Wallet balance   ¥50,000          ✓ Sufficient
  type.body.med    type.title.med    color.secondary

  ─── Reminder ─────────────────────────────────────────

  Connect the charging cable before tapping Start,
  or within 3 minutes of starting the session.
  type.body.small, color.text.secondary

  ────────────────────────────────────────────────────

  [  Start Charging  ]  ← Primary Large (Filled, color.primary)
  [  Cancel         ]  ← Tertiary
```

**Wallet balance check:** The app computes whether the wallet balance covers a minimum session (operator-configured minimum, defaulting to ¥1,000 or equivalent). If insufficient:
- Balance row: `color.error` text
- "✓ Sufficient" replaced by "⚠ Low balance"
- "Top Up Wallet" Secondary button added above "Start Charging"
- "Start Charging" is shown but disabled until the user tops up, or the operator allows sessions with low balance (configurable)

**Start Charging button:**
- On tap: closes sheet (180ms), sends `POST /sessions/start` → 202 Accepted, navigates to Charging Session screen
- The Charging Session screen opens with a loading state while the OCPP authorization completes

### From an existing reservation

When the user has an active reservation for a connector at this station, the "Start" button on their reservation's connector card is labeled "Start Reserved Session" (slightly different label — clarifies it uses the reservation).

The confirmation sheet in this case is simplified:
- No wallet balance check shown (already verified at reservation time)
- Adds: "Using your reservation (expires at [time])"
- "Start Charging" → Primary Large

---

## 18. KYC-Dependent Actions

KYC state affects all primary actions on this screen. The following matrix defines behavior for each combination.

### KYC state × action matrix

| User KYC state | "Reserve" tap | "Start" tap | "Notify Me" tap |
|----------------|--------------|------------|----------------|
| Approved | Opens reservation confirmation sheet | Opens start confirmation sheet | Subscribes; button confirms |
| Pending review | Shows KYC pending sheet | Shows KYC pending sheet | Works normally |
| Not started | Shows KYC prompt sheet | Shows KYC prompt sheet | Works normally |
| Rejected | Shows KYC rejected sheet | Shows KYC rejected sheet | Works normally |

### KYC prompt sheet (not started or pending)

Shown when the user taps "Reserve" or "Start" without an approved KYC.

Height: 340dp + safe area.

```
  ──── (handle)

  [Shield icon 48dp, color.primary]

  Verify your identity to charge
  type.headline.small, centered

  We're required by regulations to verify your     type.body.medium
  identity before you can start or reserve a      color.text.secondary
  charging session. It takes about 2 minutes.     centered

  What you'll need:
  · A valid national ID or passport
  · A selfie for face matching

  [  Verify Identity  ]  ← Primary Large
  [  Not now         ]  ← Tertiary
```

"Not now" dismisses the sheet. No action is taken on the connector. The user can browse the station details but cannot initiate a session.

"Verify Identity" navigates to the KYC flow (pushes the KYC screen on top of the Station Details screen so the user returns here on completion).

### KYC pending sheet

Shown when KYC has been submitted but not yet reviewed.

```
  ──── (handle)

  [Hourglass icon 48dp, color.warning]

  Identity verification in progress
  type.headline.small, centered

  Your documents are being reviewed. This usually   type.body.medium
  takes a few minutes. You'll receive a             color.text.secondary
  notification when it's complete.                  centered

  [  Close  ]  ← Primary Large
```

### KYC rejected sheet

Shown when KYC was rejected.

```
  ──── (handle)

  [Alert icon 48dp, color.error]

  Verification unsuccessful
  type.headline.small, centered

  We couldn't verify your identity. This may be    type.body.medium
  because the document image was unclear or        color.text.secondary
  the selfie didn't match.

  [  Try Again  ]  ← Primary Large
  [  Contact Support  ]  ← Secondary
```

### Connector card visual treatment when KYC not approved

The connector cards show the actions in a modified form — not hidden, but indicated as requiring action:
- "Reserve" button: replaced by "Verify ID" (Tertiary, `color.warning`, same size)
- "Start" button: replaced by "Verify ID" (Tertiary, `color.warning`, same size)
- Tapping either opens the appropriate KYC sheet

This design is deliberate: the user sees what action is available, and what they need to do to unlock it. Showing disabled buttons with no explanation would leave the user confused.

---

## 19. Loading States

### Full-screen skeleton (entry from cold / search result)

When the screen opens without pre-populated data, a skeleton layout fills the screen.

**Gallery skeleton:**
- 260dp full-width rectangle, `radius.none`, `color.surfaceVariant` with shimmer

**Station header skeleton:**
- Name: 200dp × 24dp rectangle
- Address: 160dp × 16dp rectangle
- Badges row: three 80dp × 24dp rounded rectangles

**Availability summary skeleton:**
- 300dp × 16dp rectangle

**Connector card skeletons (×3, assuming 3 connectors):**
- Each card: 104dp height, full border radius, with three internal skeleton rectangles representing the three content rows

**Shimmer animation:** A highlight band (white at 15% opacity) sweeps left-to-right across all skeleton elements simultaneously. Duration: 1.2s per sweep, 0.8s pause, repeat. In RTL: sweeps right-to-left.

**Data arrival and skeleton resolution:**

If station data arrives within 300ms: skeleton is never shown (transition directly from blank to content with a 100ms fade-in).

If data arrives 300ms–2s: skeleton is shown, then content fades in over 200ms as data arrives section by section:
1. Station header (first, from route params if available)
2. Gallery images (each image fades in as it loads)
3. Connector cards (all at once, when connector data is ready)
4. Pricing, amenities, hours (as they arrive from the API)

Sections that have not yet loaded continue showing their skeleton until their data arrives. The page does not "jump" — new sections expand in place with their final height, since the skeleton reserved the approximate space.

### Connector status loading

Even when the station metadata has loaded, live connector status may still be fetching. In this case:
- Connector cards show their type, power, and price (from cached metadata)
- Status badge shows a small loading spinner (12dp) in `color.text.tertiary` where the status dot normally appears
- CTAs show skeletons (80dp × 32dp pills)
- When status arrives: status dot animates in (100ms fade), CTAs replace skeletons (100ms fade)

---

## 20. Empty States

### Station has no connectors in the data

Occurs when the station record exists but has no connector records. This is a data quality issue.

**Display:**
Below the availability summary bar: a full-width inline state within the connector section area:
- Illustration: a plug icon with a question mark, 64dp, `color.text.tertiary`
- Primary: "No connector data available", `type.title.medium`, `color.text.primary`, centered
- Secondary: "Contact the operator for current availability.", `type.body.medium`, `color.text.secondary`, centered
- CTA: "Contact Operator" Secondary, full-width (links to operator contact per §13)

The rest of the screen (pricing, amenities, hours, location) continues to render normally — the data quality issue is isolated to the connector section.

### Station has no amenities (design choice: section is hidden)

As noted in §12: if no amenity data, the section is absent. Not an empty state — just section omission.

### No pricing data

If the tariff data cannot be loaded for a connector:
- The price field in the connector card row 3 shows: "Price unavailable — see operator app"
- The entire Pricing section shows: "Pricing information is not available for this station. Check the operator's app or website."
- Reserve and Start CTAs are still shown — the user has been informed of the pricing gap and can proceed at their own discretion

---

## 21. Error States

### Failed to load station (network error on fresh load)

Full-screen error state, centered:

```
  [Station-not-found illustration: empty EV plug, 96dp]

  Couldn't load station details
  type.headline.small, color.text.primary

  Check your connection and try again.
  type.body.medium, color.text.secondary

  [  Try Again  ]  ← Primary Large
  [  Back       ]  ← Tertiary
```

"Try Again" retries the `GET /stations/:id` request with a loading state on the button.
"Back" pops the screen.

### Station not found (404 response)

```
  [Compass-off illustration, 96dp]

  Station not found
  type.headline.small

  This station may have been removed or the link is outdated.
  type.body.medium, color.text.secondary

  [  Search for Nearby Stations  ]  ← Primary Large
```

"Search for Nearby Stations" navigates to the Home screen (Map) centered on the user's current location.

### Connector status fetch failed (partial error)

If the metadata loaded but live connector status returned an error:
- Connector cards render with metadata (type, power, tariff)
- Status badge shows: ⚠ "Status unavailable", `color.warning`
- All CTAs replaced by "Status unavailable" in `color.warning`
- Below the availability summary: amber banner — "Live status unavailable. Connector data shown may be outdated." + "Retry" Tertiary link

"Retry" refetches only the connector status endpoint, not the full station record.

### Reserve / Start action failed

If `POST /reservations` or `POST /sessions/start` returns an error (after the user confirmed in the sheet):

The confirmation sheet is dismissed, and an error toast appears:
- Position: above the sticky CTA bar, 16dp margin
- Height: 56dp, `color.errorContainer`, `radius.md`, elevation 3
- Content: ⚠ icon + error message + "Try Again" Tertiary button
- Auto-dismisses after 5 seconds

**Specific error messages:**

| Error code | User-facing message |
|-----------|--------------------| 
| Connector taken (race condition) | "This connector was just taken. Please select another." |
| Wallet insufficient | "Your wallet balance is insufficient. Top up to continue." |
| Session already active | "You already have an active charging session." |
| KYC not approved | "Please complete identity verification first." |
| Station offline | "The charging station is offline. Try again shortly." |
| Generic server error | "Something went wrong. Please try again." |

---

## 22. Offline Behavior

### Station Details screen behavior when offline

The screen can be accessed offline from cached data. The experience is gracefully degraded, not broken.

**Data availability:**
- Station metadata (name, address, photos cache, amenities, hours, operator): available from Hive cache, keyed by `station_<id>_<locale>`
- Live connector status: unavailable (WebSocket is offline)
- Pricing data: available from cache (tariff snapshot at last fetch time)

**Visual treatment in offline mode:**

Top of screen (below gallery, above station header): an offline banner — 36dp, `color.surfaceVariant` background:
- Cloud-offline icon 16dp + "Offline — showing cached station data" `type.body.small`, `color.text.secondary`
- This banner is persistent until connectivity is restored

**Connector cards in offline mode:**
- Status badge: replaces live status with "Last known: [status]", `type.body.small`, `color.text.tertiary`
- Status dot: amber (`color.warning`) regardless of last-known status — indicates uncertainty
- All CTAs (Reserve, Start) are shown visually but with a tooltip on tap: "Reconnect to perform this action."

**Pricing in offline mode:**
- Shown from cache with "Prices as of [date/time of last fetch]" note, `type.body.small`, `color.text.tertiary`

**Navigate button:**
Remains functional (opens native maps app with coordinates from cache).

**"Contact Operator" button:**
Remains functional (opens phone/email with cached contact details).

**On restore:**
When connectivity returns:
- Offline banner fades out (200ms)
- Connector status is automatically refetched (no user action needed)
- Cards update silently with live status

---

## 23. Accessibility Requirements

### Screen reader navigation order

The screen follows a top-to-bottom reading order matching the visual layout. Within each section, reading order matches visual order (left-to-right in LTR, right-to-left in RTL).

**Navigation bar:** "Back" (role: button) · Station name (role: heading) · "Share" (role: button)

**Gallery:** Announced as "Photo gallery: [station name]. [N] photos. Swipe left to see more." Individual photos: "Photo [N] of [N]: [alt text from operator, or 'Charging station exterior']."

**Station header:** Station name (role: heading, level 1). Address (role: button — "tap to copy"). Each badge announced individually.

**Availability summary:** "Connectors: [N] available, [N] occupied. Data updated [N] seconds ago."

**Each connector card:**
- Full card as a single focusable element for overview: "[Connector type]. [Power] kilowatts. [Status]. [Price]. [Available actions]."
- Sub-elements focusable for detail: connector type (with type explanation on double-tap), status, price, each CTA button

**CTA button labels (contextual — not just the button text):**

| Button visible label | Accessibility label |
|---------------------|---------------------|
| Reserve | "Reserve [connector type] at [station name]. Opens reservation confirmation." |
| Start | "Start charging at [connector type], [station name]. Opens charging confirmation." |
| Notify Me | "Notify me when [connector type] becomes available at [station name]." |
| Verify ID | "Identity verification required to [reserve/start charging] at [station name]. Opens verification." |

**Pricing section:** Each fee row announced: "[Fee name]: [Amount]." Example row: "Energy fee: 60 tomans per kilowatt-hour."

**Hours section:** Today's status announced first. Full schedule: each day announced as "[Day]: [hours] or Closed."

**Navigate button:** "Navigate to [station name]. Opens maps application."

### Focus management

- On screen entry: focus is set to the station name heading
- On confirmation sheet open: focus moves to the sheet title
- On confirmation sheet close: focus returns to the CTA that triggered it
- On error toast: focus is NOT moved (error is communicated by the `LiveRegion` accessibility property — the toast content is announced as a live region update without stealing focus)
- On KYC sheet open: focus moves to the sheet's first heading
- On KYC sheet close ("Not now"): focus returns to the connector card's Reserve/Start button

### Color independence

Every status indicator uses both color and a text label:
- "Available" is not just a green dot — it is a labeled green dot
- "Faulted" is not just a red dot — it is a labeled red dot with a ⚠ icon

### Touch targets

All interactive elements: 44×44dp minimum.
- Connector card CTAs: 32dp height buttons — supplemented by padding so the touch target is 44dp tall
- Each connector card can also be activated as a whole to expand detail (see §26 for future connector detail expansion)
- Gallery dots (page indicator): 44dp virtual touch target each, even though visual size is 6–20dp

---

## 24. RTL Behavior (Persian / Farsi)

### Navigation bar

- Back arrow: appears on the right (start of reading direction in RTL)
- Share icon: appears on the left (end of reading direction)
- Station name: right-aligned

### Gallery

- Swipe direction to advance: right-to-left in LTR → left-to-right in RTL
- Page indicator dot movement: right-to-left (active dot leads in reading direction)
- Lightbox swipe direction: same mirror

### Station header

- Name: right-aligned, `TextAlign.start`
- Rating: left-aligned (end of reading direction) — star + value appear on the left in RTL
- Address: right-aligned
- Badges row: starts from right edge, scrolls left

### Connector cards (most critical RTL section)

Each connector card row mirrors:
- **Row 1:** Type icon on the right, connector name aligned right; status badge on the left
- **Row 2:** "Connector N · [power] kW" right-aligned; separator dot positions correctly between RTL text
- **Row 3:** Price right-aligned; CTAs on the left side

The icon circle (type icon) remains on the **start** side of the card (right in RTL). CTA buttons remain on the **end** side (left in RTL).

**Connector number:** "Connector 3" → "پریز ۳" (Persian-Indic digit for the number).

**Power display:** "150 kW" → "۱۵۰ کیلووات"

**Status labels:**

| English | Persian (fa) |
|---------|-------------|
| Available | موجود |
| Occupied | اشغال |
| Reserved | رزرو شده |
| Your reservation | رزرو شما |
| Unavailable | غیرفعال |
| Faulted | خراب |
| Your active session | جلسه فعال شما |

### Pricing section

- Fee names: right-aligned (start)
- Fee values: left-aligned (end)
- All numeric values: Persian-Indic digits (٠-٩)
- "kWh": "کیلووات‌ساعت" — note the zero-width non-joiner (ZWNJ) in "واتساعت" is required for correct Persian typography
- "min": "دقیقه"
- Currency: "تومان" follows the number (Persian convention: number first, then unit)

### Pricing example:

```
LTR: ¥60 / kWh
 fa: ۶۰ تومان / کیلووات‌ساعت
```

### Sticky CTA bar

In RTL: availability chip on the left, CTA buttons on the right — mirror of LTR layout.

### Opening hours

Day names in Persian:
- Monday → دوشنبه
- Tuesday → سه‌شنبه
- Wednesday → چهارشنبه
- Thursday → پنج‌شنبه
- Friday → جمعه (weekend in Iran — often listed first)
- Saturday → شنبه
- Sunday → یک‌شنبه

If the deployment is in Iran: the week schedule may reorder to show Saturday–Friday, with Friday/Saturday as the weekend columns shown in `color.secondary` text.

**Time display in RTL:** Times remain LTR within an explicit LTR container (same as session duration in CHARGING_SESSION_SCREEN.md). "08:00 – 22:00" is always read left-to-right regardless of layout direction.

---

## 25. Edge Cases

### Two users tap "Start" on the same connector simultaneously

Server handles: the second `POST /sessions/start` returns a 409 Conflict. The second user sees the error toast: "This connector was just taken. Please select another." The connector's status updates on both clients via WebSocket within seconds.

### Station has one connector of a type the user's vehicle doesn't support

The station shows all connectors regardless of vehicle compatibility (the app does not know the user's vehicle type in MVP). The user must determine compatibility themselves. In future (see §26), a "My Vehicle" profile allows the app to highlight compatible connectors.

### Connector count changes (operator adds/removes hardware)

Detected when the station's `connectorCount` changes in a WebSocket event. An inline notification appears below the availability summary: "Station updated — pull to refresh". Pull-to-refresh re-fetches the full station record. The connector list refreshes in place.

### Very long station name (>50 characters)

Gallery: no text overlay for station name — not an issue.
Navigation bar: 1 line max, ellipsis. Full name available to screen reader.
Station header: max 2 lines, `type.headline.large`, ellipsis after line 2.
Sticky CTA bar: station name not shown in this bar (only availability count and CTAs).

### Station with 10+ connectors (large DC hub)

The connector cards section becomes very long. No changes to the design — vertical scroll handles it. However, a section anchor is added: tapping any status in the availability summary bar auto-scrolls to the first connector of that status. Example: tapping "4 available" scrolls to the first available connector card.

### User already has active session at a different station

The sticky CTA bar shows: "Active session at [Other Station] · View →" instead of the Reserve/Start actions. Reserve and Start are still accessible in the individual connector cards (as a second session at a second station — platform-supported but unusual).

The "View →" link navigates to the Charging Session screen for the active session.

### Reservation conflicts

If the user already has an active reservation elsewhere and taps "Reserve" here:
- Reservation confirmation sheet shows a warning banner: "You have an active reservation at [Other Station] until [time]. Reserving here will not cancel it."
- User proceeds at their own discretion.

### Price changes between view and session start

If the tariff changes between the time the user viewed the station and the time they tap "Start" (e.g., dynamic pricing shift):
- The session start confirmation sheet fetches the current tariff on open (not on screen load)
- If the tariff has changed: a banner appears in the confirmation sheet: "Prices have changed since you viewed this station." The updated price is shown.
- The user confirms the new price before starting.

### Station at exact user location (0m distance)

Distance shown as "You're here" instead of "0 m" or "0 km". Walking/driving time row is hidden.

### Lost WebSocket during viewing

If the WebSocket disconnects while the user is on this screen:
- Connector status badges quietly transition to the offline amber dot treatment (§22 offline behavior)
- The freshness indicator in the availability summary changes to "Last known"
- No modal or blocking dialog — the user can still read all cached data and browse
- Reserve/Start are disabled with the offline tap treatment

---

## 26. Future Expansion Surfaces

These surfaces are not in scope for MVP. They are defined here as reserved placeholders within the existing layout so that adding them is additive rather than disruptive.

### My Vehicle compatibility filter

**Visual location:** A row of filter chips above the connector cards section, initially hidden.

**When active:** A "My Vehicle" profile has been set (future feature). Connector cards that are compatible with the user's vehicle are shown normally. Incompatible connector cards are visually muted (opacity reduced to 60%, "Not compatible with your vehicle" sub-label added to Row 2).

**Future entry point:** "Add your vehicle" banner chip in the connector filter row when no vehicle profile exists.

### Dynamic pricing schedule

**Visual location:** Expands inline below the dynamic pricing banner in the Pricing section (§11).

**Content:** A 24-hour bar chart showing the price per kWh at each hour of the day. The current time is marked with a vertical line. Current price is highlighted. The chart uses a color gradient: cheaper times in `color.secondary`, expensive times in `color.warning`.

**User benefit:** Plan arrival time to minimize charging cost.

### Station ratings and reviews

**Visual location:** A new section between the Amenities section and the Operator Information section.

**Content:** Average star rating (large display), review count, 3 most recent text reviews (truncated to 2 lines, "Read more" expands inline). "Write a review" CTA at the bottom (only shown after the user has charged at this station at least once).

### User charging history at this station

**Visual location:** Below the station header, a compact row: "You've charged here [N] times · Last visit [date]". Tapping navigates to the wallet history filtered to this station.

**Availability:** Only shown if the user has prior sessions at this station.

### Smart Charging schedule preview

**Visual location:** A new card between the Pricing section and the Amenities section.

**Content:** When ISO 15118 Smart Charging profiles are available at a station, this card shows: "Smart Charging available · Charge overnight from ¥30/kWh". Tapping expands to show a scheduling interface where the user sets a departure time and target SoC, and the app proposes an off-peak charging schedule.

### V2G / Vehicle to Grid

**Visual location:** Modifications to connector cards that support V2G (flagged in the connector record).

**Connector card addition:** A "↕ V2G" badge on Row 2 (described in §9).

**Additional CTA on V2G-capable connectors:** "Export to grid" — a Tertiary button alongside "Reserve" and "Start". Tapping opens a V2G session configuration sheet (departure time, minimum SoC to maintain, export rate negotiation).

### Operator loyalty program

**Visual location:** A compact banner below the station header (above the availability summary).

**Content:** "Earn 100 points charging here · Your balance: 2,400 pts" — `color.primaryContainer` background, 44dp height.

### EV fleet management view

**Visual location:** A toggle at the top of the connector section: "Personal view · Fleet view"

**Fleet view:** Shows connector utilization statistics (by hour of day), fleet booking capabilities, and invoice-level reporting links.

---

## 27. Transitions and Animations

### Screen entry

| Entry point | Transition | Duration |
|------------|-----------|---------|
| From Home sheet expanded | Shared element: name/address/connector chips slide to final positions; gallery fades in behind | 350ms, cubic Bézier (0.4, 0, 0.2, 1) |
| From search result | Standard horizontal push (slide from end) | 300ms, cubic Bézier (0.4, 0, 0.2, 1) |
| From notification deep link | Slide up from below | 350ms, ease-out |
| From reservation history | Standard horizontal push | 300ms |

### Scroll animations

| Element | Behavior |
|---------|---------|
| Navigation bar background | Linear opacity 0%→100% over 80–200dp scroll range |
| Station name in nav bar | Linear opacity 0%→100% over same range |
| Back/Share pill buttons | Fade out (inverse of nav bar) over same range |
| Sticky CTA bar | Slides up 200ms when connector section exits viewport; slides down 200ms on return |

### Live status updates

| Event | Animation |
|-------|-----------|
| Connector status changes | Status dot color transitions 200ms ease-in-out; status label cross-fades 150ms; CTA buttons update 150ms |
| Connector becomes available (was occupied) | Brief card border brightness flash — `color.secondary` at 40% for 400ms |
| Connector becomes occupied (was available) | Brief card background flash — `color.warning` at 10% for 300ms |
| Counter in availability summary changes | Fast count animation: 100ms, ease-out |

### Sheet animations (confirmation sheets)

| Action | Animation |
|--------|-----------|
| Sheet appears | Slide up, 280ms, cubic Bézier (0.4, 0, 0.2, 1) |
| Sheet dismissed (Cancel) | Slide down, 220ms, ease-in |
| Sheet dismissed (action confirmed) | Slide down, 180ms (faster — confirms decisiveness) |
| KYC sheet appears | Slide up, 280ms |

### Gallery transitions

| Event | Animation |
|-------|-----------|
| Swipe to next photo | Photo slides with finger; snap to position on release |
| Lightbox open | Tap target scales from card position to full screen, 250ms ease-out |
| Lightbox close | Reverse scale, 200ms ease-in |

### Hours section expand/collapse

Arrow rotates 180° over 200ms ease-in-out, simultaneous with height animation of the schedule rows (each row slides down from zero height, staggered by 20ms per row, 150ms per row expansion).

### Offline banner appear/disappear

| Direction | Animation |
|-----------|-----------|
| Appear | Slides down from behind navigation bar, 250ms ease-out |
| Disappear | Slides up behind navigation bar, 200ms ease-in |

### Reduced motion

Under `AccessibilityFeatures.reduceMotion`:
- All slide animations replaced with 150ms fade-in/out
- Shared element transition replaced with fade transition (300ms)
- Gallery swipe: still works (user-driven gesture, not auto-animation)
- Counter animation: instant number update
- Live status dot pulse: removed; static dot only
- Card flash animations on status change: removed

---

*This document specifies the complete design of the Station Details screen. The screen is the primary decision surface in the user's charging journey — every element serves the goal of confident, informed action. No implementation proceeds without alignment on every state, interaction, and edge case defined here.*