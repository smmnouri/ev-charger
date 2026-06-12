# Home Screen — Map & Station Discovery

**Screen route:** `/map`  
**Tab:** 1 of 5 (leftmost in LTR, rightmost in RTL)  
**Last Updated:** 2026-06-11  
**References:** DESIGN_SYSTEM.md, ARCHITECTURE_FINAL.md §17

The Home screen is the primary entry point after authentication. It is the most visually complex surface in the application — a live, interactive map of charging stations with floating UI elements, real-time status updates, and a multi-stage station detail flow. Every design decision here is weighted toward speed and spatial clarity: a user pulling up to a station must locate it, confirm it is available, and begin a session in under 30 seconds.

---

## Table of Contents

1. [Screen Purpose and Design Intent](#1-screen-purpose-and-design-intent)
2. [Layout Anatomy](#2-layout-anatomy)
3. [Screen States](#3-screen-states)
4. [State 1 — Default (Map Idle)](#4-state-1--default-map-idle)
5. [State 2 — Searching](#5-state-2--searching)
6. [State 3 — Station Selected (Peek)](#6-state-3--station-selected-peek)
7. [State 4 — Station Detail (Expanded)](#7-state-4--station-detail-expanded)
8. [State 5 — Filters Active](#8-state-5--filters-active)
9. [State 6 — Location Permission Denied](#9-state-6--location-permission-denied)
10. [State 7 — Offline](#10-state-7--offline)
11. [State 8 — First Launch (Empty Permission State)](#11-state-8--first-launch-empty-permission-state)
12. [Station Pin System](#12-station-pin-system)
13. [Station Detail Bottom Sheet — Full Specification](#13-station-detail-bottom-sheet--full-specification)
14. [Gestures and Interactions](#14-gestures-and-interactions)
15. [Real-Time Update Behavior](#15-real-time-update-behavior)
16. [Transition Specifications](#16-transition-specifications)
17. [Connections to Other Screens](#17-connections-to-other-screens)
18. [RTL Specifics (Persian / Farsi)](#18-rtl-specifics-persian--farsi)
19. [Accessibility Specifics](#19-accessibility-specifics)
20. [Edge Cases](#20-edge-cases)

---

## 1. Screen Purpose and Design Intent

**Primary job:** Help the user find an available charging station near them right now.

**Secondary jobs:** Let the user search for a specific station, filter by connector type or power, and initiate the reservation or session flow.

**Design principles for this screen:**

1. **Map first.** The map is not a background — it is the UI. Floating elements are as compact and out-of-the-way as possible. The user must never feel that the UI is fighting the map.
2. **Status at a glance.** From a normal map zoom level, a user must be able to tell whether any nearby station has an available connector without tapping anything.
3. **One-tap to intent.** Tapping a pin shows the minimum useful information. A second interaction (expanding the sheet) reveals everything. No three-step discovery path.
4. **Spatial continuity.** When a station is selected, the map does not reset or reload — it pans smoothly so the selected station is visible above the sheet. The user always knows where they are on the map.

---

## 2. Layout Anatomy

The map screen uses a full-bleed layout. Unlike every other screen in the app, there is no scaffold background color — the native map tiles fill the entire device screen, top safe area included.

### Layer stack (bottom → top)

```
┌─────────────────────────────────────────────────────┐
│  Layer 8  │  Session mini-card (conditional)         │ ← Above nav bar
│  Layer 7  │  Bottom navigation bar                   │ ← Always visible
│  Layer 6  │  Station detail bottom sheet             │ ← Conditional
│  Layer 5  │  Search results panel                    │ ← Conditional (search active)
│  Layer 4  │  Map controls (FAB + layer button)       │ ← Always visible
│  Layer 3  │  Filter chips row                        │ ← Always visible
│  Layer 2  │  Search bar                              │ ← Always visible
│  Layer 1  │  Status bar (transparent)                │ ← System; content-aware
│  Layer 0  │  Map tiles + station pins/clusters       │ ← Full bleed
└─────────────────────────────────────────────────────┘
```

### Fixed position measurements

Using a reference device of 390×844dp (iPhone 14 proportions). All values scale proportionally on larger devices.

| Element | Position | Size |
|---------|----------|------|
| Status bar clearance | top: 0 | System-defined (≈47dp) |
| Search bar top edge | top: status bar height + 12dp | 52dp × (screen width − 32dp) |
| Filter chips top edge | top: search bar bottom + 8dp | 36dp height, variable width |
| My location FAB | bottom: nav bar top − 16dp; end: 16dp | 48dp × 48dp |
| Layer toggle button | bottom: FAB top − 12dp; end: 16dp | 40dp × 40dp |
| Bottom nav bar | bottom: 0 | 64dp + safe area inset |
| Station detail sheet | anchored to bottom | variable height |
| Session mini-card | bottom: nav bar top − 8dp; 20dp horizontal margin | 56dp |

---

## 3. Screen States

The map screen has 8 distinct states. Transitions between them are described in Section 16.

| State | Trigger | Key visual changes |
|-------|---------|-------------------|
| **Default** | App launch / back navigation / dismiss search | Map, search bar, filter chips, controls |
| **Searching** | Tap search bar | Keyboard appears, results panel slides up, map dims |
| **Station Selected (Peek)** | Tap a station pin | Sheet peeks at bottom, selected pin enlarges, map pans |
| **Station Detail (Expanded)** | Drag sheet up or tap "View Station" | Sheet covers ~65% of screen |
| **Filters Active** | Tap filter chip | Map re-renders with filtered pins, chip shows selected state |
| **Location Denied** | OS permission denied | FAB icon changes, location prompt banner appears |
| **Offline** | Network lost | Offline banner, stale-data indicator on pins |
| **First Launch** | First app open after login | Location permission prompt, brief contextual onboarding tooltip |

---

## 4. State 1 — Default (Map Idle)

This is the resting state. All persistent UI is visible. The map is fully interactive.

### Visual composition

```
┌──────────────────────────────────────────────┐  ← Top safe area
│  ░░░░░░░░░░░░░░░░ STATUS BAR ░░░░░░░░░░░░░  │  transparent overlay
├──────────────────────────────────────────────┤  ← +12dp
│  ┌────────────────────────────────────────┐  │
│  │  🔍  Search stations...          🎤   │  │  ← Search bar 52dp
│  └────────────────────────────────────────┘  │
│  ← Type 2  CCS  CHAdeMO  ≥50kW  Available → │  ← Filter chips 36dp
│                                              │  ← +8dp gap
│                                              │
│          M A P   T I L E S                  │
│                                              │
│     📍   ⚡  ⚡  ⚡  🔶                      │  ← Station pins
│                                              │
│         ⚡(clustered: 12)                   │  ← Cluster bubble
│                                              │
│                                              │
│                               ⊕             │  ← Layer button 40dp
│                               📍            │  ← Location FAB 48dp
├──────────────────────────────────────────────┤  ← Nav bar top
│  MAP     RSVP    ⚡CHARGE   WALLET   PROFILE │  ← Bottom nav 64dp
└──────────────────────────────────────────────┘  ← Safe area
```

### Status bar treatment

The status bar is transparent; system icons (time, battery, signal) use a **dark tint** in light mode. A 48dp gradient fades from `#000000` at 30% opacity (at the very top edge) to transparent (at 48dp from top). This ensures system icons are always legible against the map tiles regardless of tile content. In dark mode, the gradient uses `#000000` at 50%.

### Search bar (idle state)

- Background: `color.surface`, elevation 3
- Shape: `radius.full`
- Height: 52dp, width: screen width − 32dp (16dp margins each side)
- Leading: 🔍 magnifier icon, 20dp, `color.text.tertiary`; 12dp gap to placeholder
- Placeholder: "Search stations…", `type.body.large`, `color.text.tertiary`
- Trailing: 🎤 microphone icon, 20dp, `color.text.tertiary`; 16dp from right edge of bar
- Shadow: elevation 3 (floats visibly above map)

### Filter chips row (idle state)

- Horizontal scroll, no snap, 16dp left inset, fades to transparent at right edge (32dp fade gradient)
- 8dp gap between chips
- Chip order (LTR): "Type 2" | "CCS" | "CHAdeMO" | "GB/T" | divider | "AC" | "DC" | "≥50 kW" | "≥150 kW" | divider | "Available now" | "Open 24h"
- Dividers: 1dp × 20dp, `color.outlineVariant`, vertically centered in the row
- All chips in unselected state

### Map controls (default state)

**My Location FAB (48dp circle):**
- Icon: hollow location arrow (crosshair style), 22dp, `color.text.primary`
- Background: `color.surface`, elevation 3
- Active state (following user): icon fills solid `color.primary`, 22dp; a 6dp `color.primary` circle appears at the arrow center-point (representing user location on map)
- Pressed: scale 0.94, 120ms ease-out

**Layer toggle button (40dp circle):**
- Icon: 3-layer stack icon, 20dp, `color.text.secondary`
- Background: `color.surface`, elevation 3
- Pressed: scale 0.94

**Position (LTR):** Both anchored to the end (right) edge. In RTL: both move to the start (left) edge.

### Map tile behavior

- Map starts centered on the user's last-known location, or the city center if no prior location
- Default zoom: level 14 (shows individual street level, 3–4 stations visible in an urban area)
- Min zoom: 8 (continent view, clusters only); max zoom: 19 (building level)
- Map style: clean, low-saturation tile set. POI labels reduced to prevent visual competition with station pins. Roads at medium weight. Water bodies in a soft blue that does not conflict with `color.primary`.

---

## 5. State 2 — Searching

### Trigger

Tap anywhere on the search bar. Not the microphone icon — that opens voice input directly.

### Entry sequence

1. Search bar receives focus → 150ms ease-out: search bar background flashes to `color.surface`, search icon transitions to `color.primary`
2. Keyboard rises from bottom (system animation)
3. Map dims: full-screen scrim layer at `#000000` × 40% opacity animates in over 200ms
4. Search results panel slides up from bottom: peeks at the keyboard top edge

### Visual composition (searching)

```
┌──────────────────────────────────────────────┐
│  ░░░░░░░░░░░░░░░░░ STATUS BAR ░░░░░░░░░░░░  │
├──────────────────────────────────────────────┤
│  ┌────────────────────────────────────────┐  │
│  │  🔍  |_________________________  ✕   │  │  ← Active, cursor blinking
│  └────────────────────────────────────────┘  │
├──────────────────────────────────────────────┤
│▓▓▓▓▓▓▓ MAP DIMMED (40% black scrim) ▓▓▓▓▓▓▓│
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
├──────────────────────────────────────────────┤  ← Search panel top
│  ┌─ Recent ──────────────────────────────┐   │
│  │  🕐  Elm Street Charging Hub           │   │
│  │  🕐  Tehran Central EV Park           │   │
│  │  ─────────────────────────────────── │   │
│  │     Search nearby stations            │   │  ← Floating suggestion
│  └───────────────────────────────────────┘   │
├──────────────────────────────────────────────┤
│  ████████████  KEYBOARD  ████████████████████│
└──────────────────────────────────────────────┘
```

### Search results panel

- Background: `color.surface`, top corners `radius.xl`, elevation 5
- Handle: shown only when panel is not pinned to keyboard top (drag to expand to full-height results list)
- Height: occupies space from keyboard top to search bar bottom edge

**Empty input (recent searches):**

Section header: "Recent", `type.title.small`, `color.text.secondary`, 16dp top padding.

Each recent item (56dp height):
- Leading: 🕐 clock icon, 20dp, `color.text.tertiary`; 16dp from left
- Text: station name or search term, `type.body.large`, `color.text.primary`
- Trailing: ↗ northeast arrow icon, 20dp, `color.text.tertiary` (tap to pre-fill search bar with this term)

Below recents: a divider, then a "Nearby stations" shortcut row — taps to show all stations sorted by distance.

Maximum 5 recent items. "Clear recent" link (tertiary, `type.label.large`, `color.text.secondary`) in the section header row.

**With input (live results):**

Results update 300ms after the last keystroke (debounced). During the debounce: a subtle loading shimmer on the first 3 result slots.

Each result (72dp height):
- Leading: ⚡ station icon in a 36dp circle — background is the dominant status color at 15% opacity, icon is the status color; `radius.full`
- Primary text: station name, `type.title.medium`, `color.text.primary`, 1 line truncated
- Secondary text: address, `type.body.small`, `color.text.secondary`, 1 line
- Trailing: distance from user, `type.label.large`, `color.text.secondary`; below distance: connector type chips stack (max 2 chips, 20dp height, `radius.xs`, connector icon 12dp)
- Divider: 1dp `color.outlineVariant` between results (not at top or bottom of list)

**No results state:**
- Within the results panel: centered illustration (simple question-mark map pin, 64dp) + "No stations found" `type.title.medium` + "Try a different search or adjust your filters" `type.body.medium`, `color.text.secondary`.

### Interaction behaviors while searching

- Tapping outside the search results panel (on the dimmed map) → dismiss search, return to Default state
- Tapping a recent item → pre-fills search bar with that term, immediately fires a search
- Tapping a result → dismisses search, map pans to the selected station, station pin selected, sheet peeks → enters State 3

### Microphone (voice search)

Tapping the microphone icon in the idle search bar:
- Platform voice input sheet appears (OS-native)
- On voice recognition complete: text inserted into search bar, search fires automatically
- Voice icon pulses red while listening (within the platform sheet)

---

## 6. State 3 — Station Selected (Peek)

### Trigger

Tap any station pin (not a cluster) while in Default state, or tap a search result.

### Entry sequence

1. Tapped pin grows from 36×44dp to 44×54dp — 150ms ease-out spring
2. Selection pulse ring appears behind the enlarged pin — begins expanding from 44dp to 64dp diameter, repeating (see Design System §10)
3. Map pans so the selected station sits at approximately 40% from the top of the visible map area above the sheet — 300ms ease-in-out cubic Bézier (0.4, 0, 0.2, 1)
4. All other pins fade to 60% opacity — 200ms
5. Sheet slides up from below screen — 280ms ease-out, stops at peek height

### Visual composition (peek state)

```
┌──────────────────────────────────────────────┐
│  ░░░░░░░░░░░░ STATUS BAR ░░░░░░░░░░░░░░░░░  │
├──────────────────────────────────────────────┤
│  ┌────────────────────────────────────────┐  │
│  │  🔍  Search stations...          🎤   │  │  ← Search bar (dimmed, not focused)
│  └────────────────────────────────────────┘  │
│  ← Type 2  CCS  CHAdeMO ...                 │  ← Filters (still visible)
│                                              │
│   ⚡60% ⚡100%                               │  ← Other pins at 60% opacity
│                                              │
│         ╔══════╗                             │
│         ║  ⚡  ║  ← Selected pin (enlarged) │
│         ╚══╤═══╝                             │
│         ◎──┘ ← pulse ring expanding         │
│                               ⊕             │
│                               📍            │
├──────────────────────────────────────────────┤  ← Sheet peek line
│  ──────  (sheet handle)  ──────             │
│                                              │
│  Elm Street Charging Hub      ✦ 1.2 km      │  ← Name + distance
│  4 of 6 connectors available                │  ← Availability summary
│                                              │
│  [⚡Type 2] [⚡CCS] [CHAdeMO]  from ¥45/kWh │  ← Connector chips + price
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │           View Station               │   │  ← Primary CTA
│  └──────────────────────────────────────┘   │
├──────────────────────────────────────────────┤
│  MAP    RSVP    ⚡    WALLET    PROFILE      │
└──────────────────────────────────────────────┘
```

### Peek sheet anatomy

**Sheet dimensions:**
- Height: 240dp (above safe area inset; safe area adds more at the bottom)
- Top corners: `radius.xl` (20dp)
- Background: `color.surface`, elevation 5
- Bottom navigation remains fully visible below the sheet

**Sheet handle:**
- Width: 32dp, height: 4dp, `radius.full`, `color.outline`
- Positioned 12dp from top edge of sheet, horizontally centered

**Row 1 — Station identity (height: 28dp, 20dp top padding below handle):**
- Start: Station name, `type.title.large`, `color.text.primary`, max 1 line, ellipsis
- End: Star icon (4dp, `color.warning`) + distance value, `type.label.large`, `color.text.secondary`

**Row 2 — Availability summary (height: 20dp, 4dp below row 1):**
- Start: Connector icon (14dp, status color of the best-available connector) + "[X] of [Y] connectors available", `type.body.medium`, `color.text.secondary`
- When all connectors occupied: "All connectors busy — check back soon", `color.warning`
- When all available: "[Y] connectors available", `color.secondary`

**Row 3 — Connector chips + price (height: 28dp, 8dp below row 2):**
- Horizontal scroll of connector type chips (see below for chip spec)
- End of row: "from [price]/kWh", `type.label.large`, `color.text.secondary` — pinned, does not scroll

**Connector type chip (within peek sheet):**
- Height: 28dp, `radius.full`
- Background: status color at 12% opacity
- Leading: connector type icon, 12dp, status color
- Label: connector type abbreviation, `type.label.small`, status color
- Chips ordered by: available first, then occupied, then unavailable

**Primary CTA button:**
- "View Station", Primary Large, full-width
- 16dp top margin above button, 16dp bottom margin below button (before safe area)

### Dismissing the peek state

- Swipe down on the sheet → sheet slides down, selected pin returns to normal size, other pins return to full opacity, pulse ring dissolves
- Tap anywhere on the visible map above the sheet → same as swipe down
- The back navigation gesture (swipe from left edge in LTR, from right in RTL) → same dismissal

---

## 7. State 4 — Station Detail (Expanded)

### Trigger

One of three actions while in Peek state:
1. Drag the sheet upward past 50% of screen height
2. Tap "View Station" in the peek sheet
3. Tap the sheet handle

### Entry animation

Sheet animates from peek height to expanded height in 280ms, cubic Bézier (0.4, 0, 0.2, 1). The map does not move during this transition — it reveals the selected station partially visible in the upper portion of the screen above the sheet.

### Visual composition (expanded state)

```
┌──────────────────────────────────────────────┐
│  ░░░░░░░ STATUS BAR ░░░░░░░░░░░░░░░░░░░░░░  │
│                                              │
│          (station visible on map)            │
│              ╔═══╗                           │
│              ║ ⚡ ║  ← selected pin          │
│              ╚═══╝                           │
│                                              │
├──────────────────────────────────────────────┤  ← Sheet top (~35% from top)
│  ──────  (handle)  ──────                   │
│                                              │
│  ← Elm Street Charging Hub      1.2 km ↗   │  ← Name + distance + nav CTA
│  Tesla Supercharger Network — Commercial    │  ← Operator + category
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │  ● 4 available  ○ 2 occupied        │    │  ← Availability summary card
│  └─────────────────────────────────────┘    │
│                                             │
│  CONNECTORS                                 │  ← Section header
│  ┌─────────────────────────────────────┐    │
│  │  ⚡  Type 2 AC    22 kW    ● Avail  │    │  ← Connector card
│  │  from ¥45/kWh          [Reserve]   │    │
│  ├─────────────────────────────────────┤    │
│  │  ⚡  CCS DC       150 kW  ● Avail  │    │
│  │  from ¥60/kWh          [Start]     │    │
│  ├─────────────────────────────────────┤    │
│  │  ⚡  CCS DC       150 kW  ○ Busy   │    │
│  │  from ¥60/kWh     Est. free: 20min │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  AMENITIES                                  │  ← Section header
│  [P Parking] [☕ Coffee] [🚻 Restroom]      │  ← Amenity chips
│                                             │
│  HOURS                                      │  ← Section header
│  Open 24 hours                              │
│                                             │
│  Updated 2 min ago                          │  ← Freshness indicator
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │         Navigate to Station          │   │  ← Secondary CTA (maps app)
│  └─────────────────────────────────────┘   │
├──────────────────────────────────────────────┤
│  MAP    RSVP    ⚡    WALLET    PROFILE      │
└──────────────────────────────────────────────┘
```

### Expanded sheet anatomy

**Maximum sheet height:** Screen height − status bar height − 48dp (leaving a strip of map always visible). The map is never fully covered.

**Sheet scrollable content:** The sheet content is a single scroll view from the handle to the bottom. The close handle and the station name header are sticky — they do not scroll. Everything from the availability summary downward scrolls.

**Sticky header (non-scrolling, 88dp):**

_Row 1 (station name + navigation):_
- Start: Station name, `type.headline.small`, `color.text.primary`, max 1 line, ellipsis
- End: Distance label + ↗ directions icon button (36dp touch target, opens native maps app to navigate to the station)

_Row 2 (operator + category):_
- Operator logo: 20dp circle, rounded
- Operator name: `type.body.medium`, `color.text.secondary`
- Separator dot (4dp, `color.outlineVariant`)
- Category: "Commercial" / "Residential" / "Workplace", `type.body.medium`, `color.text.secondary`

**Availability summary card (Standard Card, 56dp):**

Inline within the scrollable content area.
- Start: colored dot (8dp, `status.available`) + "[X] available" label (`type.label.large`, `color.text.secondary`)
- 16dp gap
- Colored dot (8dp, `status.occupied`) + "[Y] occupied" label

Full width, `color.surfaceVariant` background, `radius.md`, no shadow.

**Connectors section:**

Section header: "CONNECTORS", `type.label.small`, `color.text.tertiary`, letter-spaced, 16dp top padding, 8dp bottom padding.

Each connector card (80dp height):

```
[ Connector icon 36dp ] | [Type name (type.title.medium)]     | [Status badge] |
                        | [Power label (type.body.medium)]    |                |
                        | [Price (type.body.small, tertiary)] | [Action CTA]   |
```

- Connector icon: 36dp circle, `radius.full`; background is status color at 15%; connector type SVG icon (20dp, status color)
- Type name: e.g., "CCS DC Fast" or "Type 2 AC", `type.title.medium`, `color.text.primary`
- Power label: "[X] kW", `type.body.medium`, `color.text.secondary`
- Price: "from [formatted price]/kWh", `type.body.small`, `color.text.tertiary`
- Status badge: see Design System charger status chips
- Action CTA: right-aligned, see below
- Separator: 1dp `color.outlineVariant` between connectors; no separator after the last connector

**Connector action CTAs:**

| Connector status | User KYC | CTA |
|-----------------|----------|-----|
| Available | Approved | "Reserve" (Tertiary, `color.tertiary`, 32dp Small size) |
| Available | Approved | "Start" (Secondary, `color.primary`, 32dp Small) if walk-up session enabled |
| Available | Not approved | "Verify ID" (Tertiary, `color.warning`) |
| Occupied | Approved | "Notify me" (Tertiary, 32dp) |
| Occupied | — | "Est. free: ~20 min" (`type.body.small`, `color.text.tertiary`; no button) |
| Reserved | — | "Reserved" label only (no button) |
| Unavailable | — | No CTA |
| Faulted | — | No CTA; "Fault reported" `type.body.small`, `color.error` |

When both Reserve and Start are available (walk-up enabled and slot available): Reserve (Tertiary) + Start (Secondary Primary variant) stacked vertically, 4dp gap.

**Amenities section:**

Section header: same as Connectors.
Horizontal row of amenity chips (non-interactive, 28dp height, `radius.full`, `color.surfaceVariant`, icon 14dp + label `type.label.small`).

Available amenities: Parking (P), Coffee, Restroom, Wi-Fi, Shopping, 24h.

**Hours section:**

Simple text: "Open 24 hours" or a list of Mon–Sun rows in a compact table. `type.body.medium`, `color.text.primary`.

**Freshness indicator:**

"Updated [N] min ago", `type.body.small`, `color.text.tertiary`, left-aligned, 8dp top padding.
If last update was > 5 minutes ago: color shifts to `color.warning`.
If data is stale (offline state): "Last known status — may be outdated", `color.warning`.

**Navigate CTA:**

Secondary Medium button, full width, "Navigate to Station" label, opens the device's default maps app with walking/driving directions to the station's coordinates.

---

## 8. State 5 — Filters Active

### Trigger

Tap any filter chip in the filter row.

### Behavior

The tapped chip transitions to its selected state (see Design System §6 Filter Chips). The map immediately re-renders: pins that do not match the active filter(s) fade out to 20% opacity in 200ms. Pins that match remain fully opaque.

If the active filter results in zero visible pins: a floating chip appears centered horizontally, 16dp below the filter row: "No [filter name] stations nearby — expand area?" with an ✕ dismiss. This chip does not block map interaction.

### Filter chip selection model

**Connector type filters (CCS, Type 2, CHAdeMO, GB/T):** Multi-select. Selecting multiple shows stations that have at least one of the selected types.

**Power level filters (≥50 kW, ≥150 kW):** Single-select within the power group. Selecting ≥150 kW automatically deselects ≥50 kW.

**Status filters (Available now, Open 24h):** Multi-select.

**Active filter indicator:** When any filter is active, a small badge appears on the filter row itself — a 16dp pill reading "X active", `color.primary` background, white `type.label.small` text — positioned in the same row at the end, after the scrollable chips.

**Clear all filters:** Tapping "X active" badge clears all filters and returns to Default state.

---

## 9. State 6 — Location Permission Denied

### Visual changes from Default

1. My Location FAB icon: changes from the location arrow to a disabled location arrow with a diagonal slash, `color.text.tertiary`
2. No user location dot on the map
3. Map centers on a region default (city center, configurable per deployment)
4. A location permission prompt banner appears below the filter chips row (not a banner notification — a persistent soft prompt specific to this screen)

### Location prompt banner

- Width: screen width − 32dp (16dp margins)
- Height: 56dp
- Background: `color.primaryContainer`, `radius.md`, elevation 2
- Leading: 📍 location icon, 20dp, `color.primary`
- Text: "Enable location to find stations near you", `type.body.medium`, `color.text.primary`
- Trailing: "Enable" — Tertiary button, `color.primary`, 32dp Small
- Dismiss ✕: 20dp, `color.text.secondary`

On "Enable": triggers system location permission dialog.
On dismiss ✕: banner hides for the current session. Reappears on next cold start. After two dismissals, never shown again (stored in `SharedPreferences`).

### My Location FAB interaction when permission denied

Tapping the FAB (even in the disabled-appearance state): triggers the system permission dialog directly. This is intentional — the FAB remains a single recognizable action even when permission is missing.

---

## 10. State 7 — Offline

### Trigger

`ConnectivityNotifier` reports no network connection.

### Visual changes

1. Offline status banner appears at the top, below the status bar clearance, above the search bar:
   - Full width, 36dp height, `color.surfaceVariant` background, no shadow
   - Leading: cloud-offline icon, 16dp, `color.text.tertiary`
   - Text: "Offline — showing last known stations", `type.body.small`, `color.text.secondary`
   - No dismiss; disappears automatically when connectivity returns (200ms fade-out)

2. All station pins are shown from cache. A visual indicator is added to each pin: a 6dp warning dot (amber) at the top-right corner of the pin, indicating the status may be stale.

3. Search bar: remains functional for cached search results. Live search is not available. When user types and results are from cache: a note "Cached results" appears in `type.body.small`, `color.text.tertiary` below the search bar, above the results panel.

4. Station detail sheet: the "Updated X min ago" freshness indicator changes to "Offline — status may be outdated", `color.warning`. "Reserve" and "Start" CTAs are replaced with "Reconnect to reserve" / "Reconnect to start" in a disabled visual state with a helper text below.

5. My Location FAB: continues to function if location services are granted (GPS works offline).

### Return to online

On connectivity restored:
- Offline banner fades out (200ms)
- Station pins refresh silently: status colors update, warning dots disappear
- A brief "Connected" confirmation toast appears (2s, bottom position)
- All stale-data indicators are cleared

---

## 11. State 8 — First Launch (Empty Permission State)

Triggered only once: the first time the map screen appears after the user completes KYC.

### Sequence

**Step 1 (on mount, delay 500ms):** System location permission dialog appears (OS-native). This is the only time the system dialog is triggered automatically — all subsequent permission requests are user-initiated via the FAB or the soft prompt banner.

**Step 2a (permission granted):** Map animates to the user's location (300ms ease). A brief onboarding tooltip appears anchored below the search bar: "Search for stations nearby, or tap any pin to get started →" — `color.surface`, `radius.md`, elevation 3, 56dp height, arrow pointing right (pointing left in RTL). Auto-dismisses after 4 seconds. Can be dismissed by tap.

**Step 2b (permission denied):** Enter State 6 (Location Permission Denied). The tooltip does not appear.

The onboarding tooltip is shown exactly once per installation. It is not a core UI element — it is a first-run coach mark.

---

## 12. Station Pin System

Pins are the primary data display on the map. Their design must communicate status at a glance across varying zoom levels and map tile backgrounds.

### Pin anatomy

```
        ╔═══════════╗  ← 36dp wide
        ║  [icon]   ║  ← 36dp tall body
        ║  18dp icon║
        ╚═════╤═════╝  ← Triangle pointer, 8dp tall
              ▼        ← Tip points to exact station location
```

The entire shape (body + pointer) is a single visual unit. It is not a circle with a stem — the body corners are `radius.md` (12dp) and the pointer is an equilateral triangle emerging from the bottom center.

**White outline:** A 1.5dp solid white outline traces the entire pin shape (body + pointer). This lifts the pin off any map tile color and maintains legibility on both light and dark map styles.

**Shadow:** Elevation 3 equivalent, using the semi-transparent blue-gray shadow defined in the Design System.

### Pin sizes by state

| State | Body dimensions | Pointer height | Total height |
|-------|---------------|---------------|-------------|
| Default (unpinned) | 36×36dp | 8dp | 44dp |
| Selected | 44×44dp | 10dp | 54dp |
| Cluster mode | 40–56dp circle | — | — |

### Pin icons

| Connector type | Icon | Icon size |
|----------------|------|-----------|
| Type 2 (AC) | Type 2 plug silhouette | 18dp |
| CCS (DC) | CCS connector silhouette | 18dp |
| CHAdeMO | CHAdeMO connector silhouette | 18dp |
| GB/T | GB/T connector silhouette | 18dp |
| Mixed types | ⚡ bolt | 18dp |

A station with only one connector type shows that type's icon. A station with multiple types shows the bolt icon.

### Pin color rules

The pin body color reflects the **best available status** across all connectors at the station:
- If any connector is Available → pin shows `status.available` (green)
- If all occupied or reserved but none available → pin shows `status.occupied` (amber)
- If all unavailable (but not faulted) → pin shows `status.unavailable` (gray)
- If any connector is faulted and all others unavailable → pin shows `status.faulted` (red)
- If the station has an active session from the current user → pin shows `status.charging` (blue) with the user's charging bolt icon regardless of other connectors

### Cluster bubble

Shown below zoom level 14 or where 3+ pins overlap.

- Shape: circle, `radius.full`
- Size: 40dp (2–9 stations), 48dp (10–49), 56dp (50+)
- Background: `color.primary`
- White ring: 2dp border, white
- Label: count, `type.label.large`, white
- Sub-label (48dp+ size): "stations", `type.label.small`, white at 80% opacity
- Dominant status ring: a 3dp arc around the circle in the dominant status color (the color of the most-available status in the cluster). If 5 of 8 stations are green and 3 are amber, the ring is 63% green and 37% amber (proportional fill).
- Shadow: elevation 3

**Tap:** Animated zoom into cluster bounds, 300ms. New zoom level shows sub-clusters or individual pins.

### Real-time pin color transition

When a connector status changes (received via WebSocket):
1. Pin body fades from old color to new color — 300ms ease-in-out
2. If the change makes a previously unavailable connector available: brief brightness pulse (pin flashes 30% lighter for 200ms)
3. If the station is currently displayed in the peek or expanded sheet: the connector card within the sheet also updates (see Section 15)

---

## 13. Station Detail Bottom Sheet — Full Specification

This section consolidates all bottom sheet behavior across Peek and Expanded states.

### Sheet physics

The sheet is a draggable scroll view with two snap points:

| Snap point | Height from screen bottom | Condition |
|-----------|--------------------------|-----------|
| Dismissed | 0 (off-screen) | — |
| Peek | 240dp + safe area | Default anchor when pin tapped |
| Expanded | Screen height × 0.65 | Max expansion (always shows ≥35% map) |

**Drag physics:** Spring-based. Velocity on release determines whether the sheet snaps up to Expanded, holds at Peek, or dismisses. Threshold: 300dp/s upward → snaps to Expanded; 300dp/s downward → dismisses. Below threshold: snaps to nearest snap point by position.

**Overscroll:** Not permitted. The sheet cannot be dragged above the Expanded snap point.

**Scrolling vs. dragging:** When the sheet is at its Expanded snap point, content inside the sheet scrolls. When content is scrolled to the top (scroll offset = 0), a downward drag on the content triggers the sheet to collapse to Peek. This requires a coordinated scroll-drag controller.

### Sheet backdrop interaction

- In Peek state: tapping the visible map above the sheet dismisses the sheet (same as swiping down)
- In Expanded state: tapping the visible strip of map above the sheet collapses to Peek (does not immediately dismiss)
- The back gesture (system) dismisses the sheet if it is at Peek, or collapses it if at Expanded

### Loading state of the sheet

When the sheet first opens (pin tapped), the station detail data may still be fetching. The sheet opens at Peek height immediately and shows a skeleton:

- Station name row: two skeleton rectangles (200dp × 18dp + 60dp × 14dp)
- Availability row: one skeleton rectangle (120dp × 14dp)
- Connector chips: three skeleton pills (56dp × 24dp each)
- Price text: one skeleton rectangle (80dp × 12dp)
- CTA button: full-width skeleton rectangle (56dp)

If the station detail data arrives within 300ms, the skeleton is never shown (transitioned directly to content). Beyond 300ms, skeleton appears with the shimmer animation.

---

## 14. Gestures and Interactions

### Map gestures

| Gesture | Action |
|---------|--------|
| One-finger pan | Move map viewport |
| Two-finger pinch | Zoom in/out |
| Two-finger rotate | Rotate map (if map style supports it; disabled in RTL where north-up is mandatory) |
| Double-tap | Zoom in one level, centered on tap point |
| Two-finger double-tap | Zoom out one level |
| Long-press (on empty map) | No action in MVP (reserved for future drop-pin) |
| Long-press (on pin) | Show station name tooltip above pin (no navigation) |

### Sheet gestures

| Gesture | Context | Action |
|---------|---------|--------|
| Swipe up | Any sheet state | Expand to next snap point |
| Swipe down | Peek or Expanded | Collapse to next lower snap point |
| Swipe down (at top of scroll) | Expanded | Collapse to Peek |
| Tap sheet handle | Peek or Expanded | Toggle between Peek and Expanded |
| Tap visible map | Peek state | Dismiss sheet |
| Tap visible map | Expanded state | Collapse to Peek |

### Filter chip interactions

| Gesture | Action |
|---------|--------|
| Tap unselected chip | Select, filter map, update chip appearance |
| Tap selected chip | Deselect, remove filter, revert map |
| Scroll filter row | Horizontal scroll |
| Long-press chip | No action |

### Search bar interactions

| Gesture | Action |
|---------|--------|
| Tap search bar | Enter Searching state |
| Tap ✕ in active search | Clear input; if empty, exit Searching state |
| Swipe down on results panel | Reduce panel height; does not exit search |
| Tap map scrim | Exit Searching state |
| Tap result | Select station, exit search, enter Peek state |
| Keyboard "Search" / Enter | Fire search, hide keyboard, show results |

---

## 15. Real-Time Update Behavior

The map screen has live data from two sources: the WebSocket (connector status changes) and the HTTP layer (background polling for JWKS, token refresh). This section specifies how real-time changes are displayed without disrupting the user.

### Pin status change (WebSocket event)

When a `ConnectorStatusChangedEvent` arrives for a visible station:

**Station NOT selected (not in sheet):**
- Pin body color transitions smoothly (300ms fade)
- No user notification unless status changes from unavailable → available: in that case, if the user had previously tapped "Notify me", the in-app banner fires

**Station IS selected (in Peek or Expanded sheet):**
- Pin color updates (same 300ms fade)
- The specific connector card in the sheet refreshes in place:
  - Status badge fades to new status color (200ms)
  - CTA button updates to match new status (e.g., "Notify me" changes to "Reserve" if now available)
  - A brief highlight flash on the updated connector card: background flashes to `color.secondaryContainer` for 400ms then fades out

**Availability summary in sheet header:** Updates immediately when any connector status changes.

### Connector count change (new connector added/removed)

Rare — happens when an operator updates station hardware. When detected, the sheet shows a toast-style update notification: "Station updated — pull to refresh", `type.body.small`, `color.text.secondary`, auto-dismisses 3s. Pull-down-to-refresh re-fetches the full station detail.

### User's own active session (mid-session navigation to map)

If the user navigates to the Map tab while a charging session is active:
1. Session mini-card is visible above the nav bar (always, per Design System §9)
2. The station pin for the charging station shows `status.charging` (blue) pin, slightly larger than default (38×46dp), with the charging bolt icon
3. If the station detail sheet is not open: tapping this pin opens the sheet. Instead of "Reserve" and "Start" CTAs, each connector shows either "Your active session" (with a mini progress arc, 16dp) or the normal status
4. "Navigate to Session" Secondary button replaces "Navigate to Station" in the expanded sheet

---

## 16. Transition Specifications

All transitions reference the cubic Bézier curves defined here. These are not arbitrary — they are tuned for physical plausibility on the map screen.

| Transition | Duration | Easing | Notes |
|------------|----------|--------|-------|
| Pin tap → enlarge | 150ms | Spring (stiffness: 300, damping: 28) | Natural snap feel |
| Map pan to selected station | 300ms | Cubic Bézier (0.4, 0, 0.2, 1) | Smooth camera movement |
| Other pins fade | 200ms | Linear | Simple opacity change |
| Sheet slide up (Peek) | 280ms | Cubic Bézier (0.4, 0, 0.2, 1) | Decisively snappy |
| Sheet expand (Peek → Expanded) | 280ms | Cubic Bézier (0.4, 0, 0.2, 1) | |
| Sheet dismiss (Peek → out) | 220ms | Cubic Bézier (0.0, 0, 0.2, 1) | Slightly faster exit |
| Sheet dismiss (Expanded → out) | 300ms | Cubic Bézier (0.0, 0, 0.2, 1) | Two-snap → out is longer |
| Search results panel up | 220ms | Cubic Bézier (0.4, 0, 0.2, 1) | |
| Map scrim in | 200ms | Linear | |
| Map scrim out | 150ms | Linear | Faster to restore map |
| Pin color transition | 300ms | Ease-in-out | WebSocket update |
| Pin status flash | 400ms | Ease-in-out | Brief highlight |
| Cluster zoom | 300ms | Cubic Bézier (0.4, 0, 0.2, 1) | Map camera |
| Filter chip select | 150ms | Ease-out | Color + border |
| Pin filter fade-out | 200ms | Linear | Non-matching pins |
| Offline banner in | 250ms | Ease-out | Slide down from above search |
| Offline banner out | 200ms | Ease-in | Slide up |
| Session mini-card in | 200ms | Ease-out | Slide up from nav bar |

**Reduced motion:** All slide/move transitions shorten to 0ms (instant) or replaced by opacity fade at 150ms. Pin color transitions remain (they are non-positional). See Design System §20.

---

## 17. Connections to Other Screens

The Home screen is the hub from which two major flows begin.

### → Reservation flow

**Entry point:** "Reserve" CTA on a specific connector card within the expanded station detail sheet.

**Transition:**
1. Bottom sheet begins sliding down simultaneously
2. Screen slides up (platform page transition, directional): a new screen for `/reservations/new?stationId=&connectorId=` slides in from the end (right in LTR, left in RTL)
3. The station name and address are passed as route parameters so the new screen can display them instantly without a fetch

**Back navigation from Reservation flow:**
- Popping back from the reservation flow returns to the Home screen with the station detail sheet restored at Peek state (not Expanded, to give the user a clear re-orientation)

### → Session start flow

**Entry point:** "Start" CTA on a specific connector card.

**Transition:**
1. KYC guard evaluated: if not approved, bottom sheet shows an inline warning and "Verify Identity" button — no navigation
2. If approved: bottom sheet slides down simultaneously with a charging confirmation bottom sheet appearing (not a new route — a confirmation overlay within the same screen)

**Charging confirmation overlay (within map screen):**
This is a separate overlay bottom sheet (elevation 6) that appears over the station detail sheet:
- Title: "Start charging at [Connector type]?", `type.headline.small`
- Station info summary (address, connector, power)
- Estimated cost per hour/kWh from cached tariff
- Wallet balance + "Enough funds" checkmark (or warning if insufficient)
- "Start Session" — Primary Large Destructive variant (green, not red — starting a session is a positive action)
- "Cancel" — Tertiary

On "Start Session":
- Button transitions to loading state
- `POST /sessions/start` fires → 202 Accepted
- Overlay closes; session status screen appears (route `/charging/:sessionId`)
- Home screen's station pin changes to `status.charging` (blue)

### → Station detail screen (future, not MVP)

The `/map/station/:stationId` deep link navigates to a dedicated full-screen station detail page. In MVP, the expanded bottom sheet serves this purpose — there is no separate station detail screen. The "View Station" CTA in the peek sheet expands the sheet to the Expanded state rather than navigating to a new screen.

---

## 18. RTL Specifics (Persian / Farsi)

The map screen is the most layout-complex screen in RTL. Every positional element must be specified.

### Element position changes (LTR → RTL)

| Element | LTR position | RTL position |
|---------|-------------|-------------|
| Search bar microphone icon | Trailing (right) | Leading (left) — but note: microphone is always at the end of reading direction |
| Filter chips scroll direction | Left to right | Right to left; first chip at right edge |
| Filter chips left inset | 16dp from left | 16dp from right |
| My Location FAB | End (right), bottom | Start (left), bottom |
| Layer toggle button | End (right), above FAB | Start (left), above FAB |
| Station detail sheet: name alignment | Left | Right |
| Station detail sheet: distance | Right | Left |
| Station detail sheet: connector chips scroll | Left to right | Right to left |
| Connector card: icon position | Left | Right |
| Connector card: CTA button | Right | Left |
| Peek sheet: connector chips + price | Chips left, price right | Chips right, price left |
| Offline banner: icon + text | Left | Right |
| Session mini-card layout | Bolt+Name left, metrics center, Stop right | Stop left, metrics center, Bolt+Name right |
| Sheet swipe-up gesture | Upward (same direction; no mirror) | Upward (same) |
| Page transition on navigation | Slide from right (enter) | Slide from left (enter) |

### RTL-specific Persian formatting in this screen

- **Distance:** "1.2 km" → "۱٫۲ کیلومتر" — Persian digits, Persian "km" unit label
- **Availability summary:** "4 of 6 available" → "۴ از ۶ موجود" — Persian digits and text
- **Price:** "from ¥45/kWh" → "از ۴۵ تومان/کیلووات‌ساعت" — Persian-Indic digits; currency name follows amount; "kWh" → "کیلووات‌ساعت"
- **Last updated:** "Updated 2 min ago" → "۲ دقیقه پیش به‌روز شد"
- **"View Station" button:** "مشاهده ایستگاه"
- **"Reserve" button:** "رزرو"
- **"Start" button:** "شروع"
- **"Navigate to Station" button:** "مسیریابی"

### Map rotation in RTL

The map remains in north-up orientation. Rotating the map by gesture is disabled in RTL mode because compass navigation references are reversed and likely to cause confusion. The rotate gesture is disabled; the two-finger gesture only pinch-zooms.

---

## 19. Accessibility Specifics

### Screen reader announcements

**On map load:** "Map loaded. [N] charging stations visible. Search bar available at top of screen."

**Station pin (screen reader focus order: pins → controls → nav bar):**
- Accessibility label: "[Station name]. [N] of [M] connectors available. [Distance] away. Double-tap to view details."
- Hint: "Double-tap to view station details"

**Cluster bubble:**
- Label: "[N] charging stations. Double-tap to zoom in."

**Search bar:**
- Label: "Search charging stations"
- When focused: "Type to search nearby charging stations"

**Filter chips:**
- Label: "[Chip name] filter. [Selected/Not selected]. Double-tap to [apply/remove] filter."

**My Location FAB:**
- Label: "My location" (when permission granted)
- Label: "Enable location access" (when permission denied)

**Layer toggle button:**
- Label: "Map layers"

**Station detail sheet:**

When the sheet appears, focus is set to the station name heading. Screen reader announces: "[Station name]. [N] of [M] connectors available. Swipe to explore station details."

Each connector card:
- Label: "[Connector type], [Power] kilowatts. [Status]. [Price] per kilowatt-hour. [CTA action if available]."

**"Reserve" / "Start" buttons:**
- Label: "Reserve [Connector type] at [Station name]" / "Start charging at [Connector type], [Station name]"
- Without station context, these labels would be ambiguous for screen reader users navigating a list of connectors

### Focus management

- When a station pin is tapped: focus moves to the station detail sheet's first focusable element (station name heading)
- When the sheet is dismissed: focus returns to the station pin that opened it
- When a filter chip is tapped: focus stays on the chip (allowing the user to immediately tap again to deselect, or move to adjacent chips)
- When the search results panel opens: focus moves to the search bar (already focused) — no additional management needed
- When a search result is tapped: focus moves to the station name heading in the bottom sheet

### Keyboard navigation (accessibility keyboard / switch access)

- Tab order: Search bar → filter chips (left to right in LTR) → map pins (by proximity to user, nearest first) → My location FAB → layer button → bottom navigation tabs
- The sheet, when open, creates a new focus scope. Tab cycles through: handle → station name → distance button → scroll content → connector cards → navigation CTA → back to handle

### Motion sensitivity

The map screen is the most animation-intensive screen. All motion transitions listed in Section 16 respond to the `AccessibilityFeatures.reduceMotion` flag:
- Map pan when selecting a station: instant reposition instead of animated pan
- Sheet animation: instant snap instead of animated slide
- Pin enlarge: no animation (instant size change)
- Cluster zoom: instant viewport change
- Pin color transition: instant (no 300ms fade — accessibility users do not lose the status information, it updates immediately)
- Pulse ring on selected pin: disabled entirely (static indicator ring instead)

---

## 20. Edge Cases

### No stations in the current viewport

**Trigger:** User pans to an area with no stations, or all stations are filtered out.

**Behavior:**
- All pins disappear
- A floating chip appears centered in the map (not top/bottom — center of visible map area): "No stations in this area"
- Chip: `color.surface`, elevation 3, `radius.full`, 40dp height, `type.label.large`, `color.text.secondary`
- If filters are active: chip reads "No stations match your filters — [clear filters]" where "clear filters" is a tappable tertiary link inline
- Chip auto-dismisses when stations appear (user pans back)

### Station status changes while sheet is closed

If the user dismissed the sheet but comes back to the same station within the session, the sheet re-opens with fresh data, not the cached state from before. `StationDetailNotifier(id)` is `autoDispose: true` — it disposes when the sheet closes.

### Multiple connectors become available simultaneously

If 3 connectors change status to Available in the same WebSocket batch (e.g., after a charger reboot):
- All three pins update simultaneously
- In the open sheet: all three connector cards flash simultaneously — staggered by 100ms each to make each update individually noticeable

### Very long station names

Station names can be up to 80 characters. Rules:
- In pin: no name visible on pin (icon + status color only)
- In peek sheet Row 1: max 1 line, `type.title.large`, ellipsis after the available width
- In expanded sheet sticky header: max 1 line, `type.headline.small`, ellipsis. The full name is available to screen readers
- No tooltip on long-press for the name in the sheet header — the name is already in the semantic label

### Station with zero connectors (data anomaly)

Rendered as `status.unavailable` pin. In the sheet, the connectors section shows: "No connector data available", `type.body.medium`, `color.text.tertiary`. No CTAs. Freshness indicator: "Check the operator app for current status."

### Sheet and keyboard overlap

The station detail sheet is a bottom sheet. When the system keyboard is visible (e.g., user taps search bar while sheet is open), the sheet collapses to Peek state automatically before the keyboard animation completes. This prevents the sheet from being covered or creating a visual conflict with the keyboard.

### Very slow data connection

If `GET /stations?bounds=&zoom=` takes more than 3 seconds:
- After 1.5s: existing pins (from cache) continue to be shown, with the amber warning dot (same as offline state)
- After 3s: a toast appears: "Loading stations…" at bottom (non-blocking)
- After 8s: the toast changes to "Having trouble loading — check connection" with a "Retry" action
- On success: pins update, warning dots clear, toast dismisses

### Rapid pin tapping (race condition)

If the user taps a second pin before the first station's data has loaded:
- The first request is cancelled
- The new station's data request fires
- The sheet shows the skeleton for the new station
- The first station's pin returns to unselected state (no pulse ring)

This prevents orphaned loading states or mismatched sheet/pin combinations.

---

*This document specifies the complete design of the Home (Map) screen. Any feature, edge case, or interaction not described here must be discussed and documented before implementation proceeds.*