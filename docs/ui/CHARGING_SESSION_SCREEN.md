# Active Charging Session Screen

**Screen route:** `/charging/:sessionId`  
**Tab:** None — this screen lives outside the 5-tab shell. It is pushed modally over the shell on session start and dismissed to the shell on session end.  
**Last Updated:** 2026-06-11  
**References:** DESIGN_SYSTEM.md, ARCHITECTURE_FINAL.md §16, HOME_SCREEN.md §17

The Charging Session screen is the most important screen in the application. A user may spend 20 to 90 minutes on this screen while their vehicle charges. Every design decision here serves one purpose: give the user complete confidence that their vehicle is charging, that the meter is running correctly, and that they are fully in control.

---

## Table of Contents

1. [Screen Purpose and Design Intent](#1-screen-purpose-and-design-intent)
2. [User Goals and Priorities](#2-user-goals-and-priorities)
3. [Information Hierarchy](#3-information-hierarchy)
4. [Layout Anatomy](#4-layout-anatomy)
5. [The Session Ring — Hero Visualization](#5-the-session-ring--hero-visualization)
6. [Metric Grid — Real-Time Data Presentation](#6-metric-grid--real-time-data-presentation)
7. [Status Bar — Session Health and Context](#7-status-bar--session-health-and-context)
8. [Station Info Card](#8-station-info-card)
9. [OCPP State Mapping to UI States](#9-ocpp-state-mapping-to-ui-states)
10. [State 1 — Preparing](#10-state-1--preparing)
11. [State 2 — Authorizing](#11-state-2--authorizing)
12. [State 3 — Charging (Primary Active State)](#12-state-3--charging-primary-active-state)
13. [State 4 — Suspended by Vehicle](#13-state-4--suspended-by-vehicle)
14. [State 5 — Suspended by Charger](#14-state-5--suspended-by-charger)
15. [State 6 — Interrupted](#15-state-6--interrupted)
16. [State 7 — Finishing](#16-state-7--finishing)
17. [State 8 — Faulted](#17-state-8--faulted)
18. [State 9 — Completed](#18-state-9--completed)
19. [State 10 — Cancelled](#19-state-10--cancelled)
20. [State 11 — Unknown](#20-state-11--unknown)
21. [Stop Charging Flow](#21-stop-charging-flow)
22. [Emergency and Fault Scenarios](#22-emergency-and-fault-scenarios)
23. [Network Loss Behavior](#23-network-loss-behavior)
24. [Loading and Entry States](#24-loading-and-entry-states)
25. [Transitions and Animations](#25-transitions-and-animations)
26. [RTL Behavior (Persian / Farsi)](#26-rtl-behavior-persian--farsi)
27. [Accessibility Requirements](#27-accessibility-requirements)
28. [Edge Cases](#28-edge-cases)
29. [Future Feature Design Surfaces](#29-future-feature-design-surfaces)

---

## 1. Screen Purpose and Design Intent

**Single sentence purpose:** Confirm to the user that energy is flowing into their vehicle, keep them informed of the session's progress, and give them full control to stop the session at any time.

This screen must function as a **live meter receipt**. Whatever the user sees here must match what will appear on their final transaction record. Trust is the only currency: any discrepancy between the live display and the final receipt destroys it.

**Design principles for this screen:**

1. **Charge first, everything else second.** The active energy flow state — "is my car charging right now?" — must be answerable within 1 second of opening the screen, without reading any text.

2. **Real numbers, always.** Never round live metrics during a session. The user is watching cost accumulate in real time. A rounded display that suddenly jumps by ¥5 feels like a bug.

3. **Control is always reachable.** The Stop button must be visible on every scrollable position of this screen. The user should never have to hunt for it. But stopping must require deliberate confirmation — not a single tap.

4. **Failures must be honest.** When the charger pauses, faults, or loses communication, the screen says so immediately and unambiguously. It never hides a problem behind a frozen counter.

5. **Duration matters more than users think.** This screen is viewed repeatedly across a 20–90 minute session, mostly as a glance. The layout must be glanceable at a distance — ring state, active metric, status label. Three data points, zero reading required.

---

## 2. User Goals and Priorities

The user has a hierarchy of in-session needs. Design serves them in this order:

| Priority | Goal | Failure mode if unmet |
|----------|------|----------------------|
| 1 | Confirm the vehicle is charging | User unplugs prematurely; vehicle not charged |
| 2 | Know how much energy has been delivered | Billing distrust |
| 3 | Know the current cost | Budget anxiety; session abandonment |
| 4 | Know how long the session has run | No sense of progress |
| 5 | Know the current power level | Can't detect underperforming charger |
| 6 | Stop the session when ready | Stuck at charger; charging continues |
| 7 | React to faults or problems | Vehicle damage; stranded |
| 8 | Contact support if needed | Unresolved billing dispute |

The screen layout is organized exactly in this priority order, top to bottom.

---

## 3. Information Hierarchy

### What the screen must communicate at a glance (no interaction)

From 1 meter away, on a device held in hand:
- **Session health:** Is it charging, paused, or faulted? (color + animation)
- **Primary metric:** Current energy delivered, cost, or time — whichever the user last selected (large numeric display)
- **Stop availability:** The stop action is visually present (button always in viewport)

### What the screen communicates on close inspection (reading)

- All four live metrics simultaneously (energy, cost, power, duration)
- Current power delivery level (kW)
- Session status label with plain-English explanation
- Station name and connector type
- Session ID (for support)
- Tariff basis for the running cost

### What the screen reveals on interaction (tap)

- Tap ring center → cycle through Energy / Cost / Time center modes
- Tap "Stop Charging" → confirmation sheet with full session summary
- Tap station info card → navigate to station detail (pushes station detail sheet)
- Long-press any metric → copy raw value to clipboard

---

## 4. Layout Anatomy

The screen uses a dark, focused layout. Unlike every other screen, this screen defaults to a dark visual theme regardless of the device's system appearance setting. The rationale: the glow animations of the session ring read poorly on light backgrounds; the dark navy provides the best contrast for the electric blue/green gradient. This is not a user-facing dark mode toggle — it is a screen-level design override.

**Background:** `#0A0F1E` (deep navy, Design System §1 dark mode background). Always. In both light and dark system mode.

**Foreground text:** All text on this screen uses the dark-mode token set.

### Layer stack (bottom → top)

```
┌──────────────────────────────────────────────────────┐
│  Layer 5  │  Stop confirmation sheet (conditional)   │
│  Layer 4  │  Session summary on completion           │
│  Layer 3  │  Network loss banner                     │
│  Layer 2  │  All screen content (scrollable)         │
│  Layer 1  │  Ambient radial glow (behind ring)       │
│  Layer 0  │  Background (#0A0F1E)                    │
└──────────────────────────────────────────────────────┘
```

### Ambient glow

A radial gradient fills the upper half of the screen, centered where the ring center will be:
- Center: `color.primary` (#0F5EFF) at 12% opacity
- Edge: transparent, radius 60% of screen width
- This is purely decorative — it gives depth to the navy background and reinforces the "energy is active" feeling. When the session is faulted or paused, the glow dimishes to 4% opacity (200ms transition).

### Fixed position elements

| Element | Position |
|---------|----------|
| Navigation bar (top) | top: status bar height; height: 56dp |
| Ring container | vertically centered in upper 55% of screen |
| Metric grid | immediately below ring container, 24dp gap |
| Station info card | below metric grid, 16dp gap |
| Stop button | bottom of scroll content, 24dp top margin |
| Network loss banner | top: nav bar bottom |

---

## 5. The Session Ring — Hero Visualization

The session ring is the primary visual element. It must communicate session state immediately and viscerally — before any text is read.

### Ring geometry

| Property | Value |
|---------|-------|
| Outer diameter | 220dp |
| Stroke width | 12dp |
| Inner diameter (hole) | 196dp |
| Track (background arc) | Full circle, `color.outline` at 15% opacity, 12dp stroke |
| Start angle | 225° (bottom-left, 7 o'clock position) in LTR |
| Sweep direction | Clockwise in LTR, counter-clockwise in RTL |
| Fill gradient | `color.primary` (#0F5EFF) → `color.secondary` (#00D68F) |
| Gradient direction | Follows the arc sweep direction |
| Cap style | Round caps on both ends of the filled arc |

### Ring fill logic

The ring fill represents progress toward a target. Fill behavior depends on whether a charging target has been set:

**No target set (free charge):**
The ring fills as a function of elapsed time, completing a full circle at 60 minutes. If the session exceeds 60 minutes, the ring resets and fills again, completing a full circle at each additional 60-minute interval. A small numerical "laps" indicator (e.g., "×2") appears at the 3 o'clock position in `type.label.small`, `color.text.tertiary` — this shows the ring has lapped. This design communicates progress without implying a known endpoint.

**kWh target set:**
The ring fills from 0% to 100% as energy delivered approaches the target. The fill stops growing when the target is met but the session may continue (the ring stays at 100%, fully filled).

**Time target set:**
The ring fills as a function of target duration. Completion at target time.

**No fill (static states):**
In Preparing, Authorizing, and Faulted states, the ring does not fill — it uses the state-specific indicator described in Sections 10, 11, and 17.

### Ring fill animation

The fill arc grows continuously and smoothly when energy is flowing. It does not jump discretely on each meter value — it interpolates between the last known value and the projected next value based on the current power rate, advancing frame by frame. The result is a continuously growing arc that matches the meter reading.

When a new meter value arrives via WebSocket, the animation target updates and the fill catches up to the actual value within 500ms using an ease-in-out curve. This prevents visual "snapping" while remaining accurate.

### Outer glow

A soft glow rings the outside of the filled arc:
- Blur: 4dp
- Color: `color.secondary` (#00D68F)
- Opacity: oscillates between 20% and 38% over 2.2 seconds, sinusoidal curve, continuous repeat
- Glow follows the arc endpoint (the leading cap of the filled arc)

In suspended, interrupted, and offline states: glow fades to 0% opacity (300ms ease). The arc endpoint dot (see below) remains visible.

### Arc endpoint indicator

At the leading edge of the filled arc, a 16dp filled circle in `color.secondary` with a 2dp white ring outline. This dot "travels" along the arc as energy accumulates. It is the most kinetic point in the visualization and draws the eye to confirm active progress.

In Paused states: the dot becomes a static amber dot (`color.warning`) in place of `color.secondary`.

### Ring center content — three modes

The ring center (196dp circle) displays one metric at a time. The user taps anywhere in the center circle to cycle through three modes. The transition between modes is a vertical fade-through (200ms).

**Mode 1 — Energy (default)**
```
        ┌─────────────────┐
        │                 │
        │   24.7          │  ← type.numeric.display (48sp/700)
        │   kWh           │  ← type.label.medium (14sp/500), color.text.secondary
        │                 │
        │   ENERGY        │  ← type.label.small (11sp/500), letter-spaced, color.text.tertiary
        └─────────────────┘
```
Energy updates on every meter value. Displayed with 2 decimal places. No rounding.

**Mode 2 — Cost**
```
        ┌─────────────────┐
        │                 │
        │   ¥1,847        │  ← type.numeric.display (48sp/700)
        │   tomans        │  ← type.label.medium, color.text.secondary
        │                 │
        │   RUNNING COST  │  ← type.label.small, color.text.tertiary
        └─────────────────┘
```
Cost calculated as: `energy_kwh × tariff_rate` (from the TariffSnapshot frozen at session start). Updates on every meter value. Always shows the exact calculated value — never rounded. Currency label in the user's locale.

**Mode 3 — Time**
```
        ┌─────────────────┐
        │                 │
        │   00:47:23      │  ← type.numeric.display (48sp/700), tabular figures
        │                 │
        │   ELAPSED       │  ← type.label.small, color.text.tertiary
        └─────────────────┘
```
Timer increments every second, client-side. Synced to the `session.startedAt` timestamp from the server — not a stopwatch started on screen open. If the user navigates away and returns, the elapsed time is correct.

**Mode indicator (below ring center):**
Three 6dp dots, horizontally centered, 8dp below the ring center's bottom edge.
- Active mode dot: 8dp, `color.primary`, `radius.full`
- Inactive mode dots: 6dp, `color.outline`, `radius.full`
- 8dp gap between dots

Transition animation between modes: the outgoing content slides up and fades out (150ms ease-in), the incoming content slides up and fades in from below (150ms ease-out). The dots transition immediately on tap.

### Ring state variants

| Session state | Arc color | Glow | Endpoint dot | Track opacity |
|--------------|-----------|------|-------------|--------------|
| Charging | primary → secondary gradient | Green pulse | `color.secondary` | 15% |
| SuspendedByVehicle | gradient (frozen) | Off | `color.warning` (amber) | 15% |
| SuspendedByCharger | gradient (frozen) | Off | `color.warning` (amber) | 15% |
| Interrupted | gradient (frozen, dashed) | Off | None | 15% |
| Finishing | gradient (frozen at final value) | Off → fade | `color.primary` (static) | 15% |
| Faulted | `color.error` (#DC2626) | Off | None | 20% (error) |
| Preparing | No fill (animated sweep, see §10) | Off | None | 15% |
| Authorizing | No fill (animated sweep, see §11) | Off | None | 15% |
| Completed | Full fill (100% of target, or 60-min equivalent) | Off | `color.secondary` (static) | 15% |

**Dashed arc (Interrupted / Offline):**
The arc becomes a dashed stroke — 8dp dash, 8dp gap, repeating — instead of a solid stroke. This visually communicates discontinuity. The dash pattern is fixed (it does not animate or rotate).

---

## 6. Metric Grid — Real-Time Data Presentation

Four metrics are displayed in a 2×2 card grid below the ring. These are always visible regardless of which center mode is active. The grid is the most data-dense area of the screen, but each card is individually glanceable.

### Grid layout

```
  ┌─────────────────────┬─────────────────────┐
  │     ENERGY          │     POWER           │
  │   24.7 kWh          │   47.3 kW           │
  └─────────────────────┴─────────────────────┘
  ┌─────────────────────┬─────────────────────┐
  │     COST            │     DURATION        │
  │   ¥1,847            │   00:47:23          │
  └─────────────────────┴─────────────────────┘
```

**Grid container:**
- Horizontal padding: 24dp from screen edges
- Horizontal gap between cards: 12dp
- Vertical gap between rows: 12dp

**Each metric card:**
- Background: `color.surface` at 60% opacity (translucent dark surface, creates depth against the navy background)
- Border: 1dp `color.outline` at 30% opacity
- Border radius: `radius.md` (12dp)
- Padding: 16dp all sides
- Height: 80dp

**Card content:**
- Label: metric name, `type.label.small` (11sp/500), letter-spaced, `color.text.tertiary`, top-aligned
- Value: metric value, `type.numeric.large` (32sp/700), tabular figures, `color.text.primary`, 4dp below label
- Unit: unit string, `type.label.medium` (14sp), `color.text.secondary`, inline after value with 4dp gap

### Individual metric specifications

**Energy card (top-left):**
- Value: kWh delivered, 2 decimal places. Example: "24.71 kWh"
- Updates on every MeterValues OCPP message
- When active: value fades momentarily to 70% opacity for 100ms on each update, then returns to full opacity — a subtle "tick" that confirms live data is arriving

**Power card (top-right):**
- Value: current power in kW, 1 decimal place. Example: "47.3 kW"
- Source: `measurand: Power.Active.Import` from OCPP MeterValues
- This value fluctuates as the vehicle's BMS negotiates with the charger. Show the latest reading, not an average.
- When power drops to 0 (SuspendedByVehicle or SuspendedByCharger): value shows "0.0 kW" in `color.warning` text (not `color.text.primary`)
- If the charger does not report power (some 1.6J chargers): show "— kW" with a tooltip on tap: "This charger doesn't report live power"

**Cost card (bottom-left):**
- Value: running cost, local currency, no rounding
- Format: `CurrencyFormatter.format(cents, locale)` — Persian locale shows Tomans with Persian-Indic digits
- Sub-label below value: tariff basis, `type.label.small`, `color.text.tertiary`. Example: "¥60/kWh (fixed)" or "Time-based"
- If the session tariff is time-based or mixed: shows the formula basis rather than a per-kWh rate

**Duration card (bottom-right):**
- Value: `HH:MM:SS` format (e.g., "00:47:23"), tabular figures
- Client-side timer, increments every second
- Synced to server `session.startedAt` on every WebSocket message (drift correction: if client timer differs from server time by >2 seconds, silently re-sync — no visible jump)

### Live update animation

On each MeterValues update arriving via WebSocket, all four cards perform a simultaneous subtle update indicator:
- The card's border briefly brightens: `color.secondary` at 50% opacity, 150ms ease-out, then fades back
- Values update within this 150ms window so the border flash coincides with the new number

This creates a "heartbeat" sensation — the screen confirms data is arriving even if the numbers haven't changed much.

---

## 7. Status Bar — Session Health and Context

A horizontal status bar sits between the navigation bar and the ring. It is 36dp tall and contains the session's current health state in plain English.

### Status bar layout

```
  ●  Charging  ·  Type 2 AC  ·  22 kW max           [?]
```

- Leading: status dot, 8dp, `radius.full`, status color — matches the session state color
- Status label: plain-English session state, `type.label.large` (14sp/500), status color text
- Separator: "·" in `color.text.tertiary`
- Connector info: connector type + max power, `type.label.large`, `color.text.secondary`
- Trailing: "?" help icon, 20dp, `color.text.tertiary` — tapping opens a contextual tooltip explaining the current status state in detail

**Status dot animation:**
- **Charging:** dot pulses (scale 1.0 → 1.3 → 1.0, 1.5s repeat), `color.secondary`
- **Suspended:** dot is static, `color.warning`
- **Interrupted:** dot flashes (opacity 100% → 30% → 100%, 0.8s repeat), `color.warning`
- **Faulted:** dot is static, `color.error`
- **Finishing:** dot is static, `color.primary`
- **All other states:** dot is static, appropriate color

### Status labels by state

| OCPP state | Status label | Dot color | Text color |
|-----------|-------------|-----------|-----------|
| Preparing | "Preparing to charge" | `color.primary` (static) | `color.primary` |
| Authorizing | "Authorizing…" | `color.primary` (static) | `color.primary` |
| Charging | "Charging" | `color.secondary` (pulse) | `color.secondary` |
| SuspendedByVehicle | "Paused by vehicle" | `color.warning` (static) | `color.warning` |
| SuspendedByCharger | "Paused by charger" | `color.warning` (static) | `color.warning` |
| Interrupted | "Connection interrupted" | `color.warning` (flash) | `color.warning` |
| Finishing | "Stopping…" | `color.primary` (static) | `color.primary` |
| Faulted | "Fault detected" | `color.error` (static) | `color.error` |
| Completed | "Session complete" | `color.secondary` (static) | `color.secondary` |
| Cancelled | "Session cancelled" | `color.text.tertiary` | `color.text.secondary` |
| Unknown | "Status unknown" | `color.text.tertiary` | `color.text.secondary` |

---

## 8. Station Info Card

A compact card below the metric grid identifies where the session is taking place. It is the lowest-priority information on the screen — the user already knows where they parked.

### Card layout (72dp height)

```
  ┌──────────────────────────────────────────────────┐
  │  [Station icon]   Elm Street Charging Hub   ↗   │
  │                   Connector 3 · Session #4821K   │
  └──────────────────────────────────────────────────┘
```

- Background: `color.surface` at 60% opacity
- Border: 1dp `color.outline` at 30% opacity
- Border radius: `radius.lg` (16dp)
- Padding: 16dp horizontal, 12dp vertical
- Station icon: 40dp circle; background `color.primary` at 15%; bolt icon 20dp, `color.primary`
- Station name: `type.title.medium`, `color.text.primary`, 1 line ellipsis
- Sub-row: "Connector [N] · Session #[shortId]", `type.body.small`, `color.text.secondary`
- Trailing ↗ icon: 20dp, `color.text.tertiary` — tapping pushes the station detail bottom sheet over this screen (same sheet from Home Screen). The session screen remains underneath.

**Session ID display:**
The session ID is shortened for display: the first 5 characters of the UUID, uppercase. Full ID is copied to clipboard on long-press. The short ID is for quick support reference ("I have session ID 4821K").

---

## 9. OCPP State Mapping to UI States

OCPP 1.6J defines `ChargePointStatus` at the connector level. The app's `SessionStatus` domain model is a superset that maps OCPP states to user-meaningful states.

| OCPP 1.6J ChargePointStatus | Domain SessionStatus | App UI State |
|---------------------------|---------------------|-------------|
| `Preparing` | `Preparing` | State 1 |
| `Preparing` → (auth in progress) | `Authorizing` | State 2 |
| `Charging` | `Charging` | State 3 |
| `SuspendedEV` | `SuspendedByVehicle` | State 4 |
| `SuspendedEVSE` | `SuspendedByCharger` | State 5 |
| `Preparing` → `Charging` oscillation | `Interrupted` | State 6 |
| `Finishing` | `Finishing` | State 7 |
| `Faulted` | `Faulted` | State 8 |
| `Available` (after session) | `Completed` | State 9 |
| Cancelled before `Charging` | `Cancelled` | State 10 |
| PAL parse error | `Unknown` | State 11 |

**202 Accepted pattern — stop command:**
When the user sends a stop request, the app receives 202 Accepted immediately. The domain session status does not change to `Finishing` based on the 202 response — it changes only when the WebSocket delivers the actual OCPP `StopTransaction.req` confirmation from the charger. Between the 202 response and the OCPP confirmation, the UI is in the "stop pending" sub-state of State 7 (see §16).

**Meter value reporting:**
Not all OCPP 1.6J chargers send MeterValues at the same interval. Some send every 60 seconds; others every 5 seconds. The app must handle both gracefully. If no MeterValues have arrived in >90 seconds (while in Charging state), a subtle indicator appears in the Power card: "Last update [N]s ago", `type.label.small`, `color.warning`.

---

## 10. State 1 — Preparing

### Trigger
Session record created in the system. The user has physically connected the charging cable. The charger is in `Preparing` status, awaiting authorization.

### When this state is seen
Primarily visible for ISO 15118 / Plug & Charge flows (future). In current OCPP 1.6J flows, the app initiates the start command before the cable is connected, so this state may appear briefly. For walk-up sessions (user taps "Start" before plugging in), this is where the user sees "Please plug in your cable."

### Visual specification

**Ring:** No fill. A rotating sweep animation: a 60° arc in `color.primary` at 40% opacity rotates clockwise around the full track, one revolution per 1.8 seconds. This is distinct from the progress fill arc — it does not originate from the start angle, it orbits continuously.

**Ring center:**
```
     [plug icon 40dp, color.primary]
     Connect cable
     type.body.medium, color.text.secondary
```

**Metric grid:** All four cards show "—" as the value, `color.text.tertiary`. Labels are shown normally.

**Status bar:** "Preparing to charge" · Connector info

**Instruction card (replaces Station info card, 96dp):**
A full-width card with a step indicator:
```
  ┌──────────────────────────────────────────────────┐
  │   1. Connect the charging cable to your vehicle  │
  │   2. Wait for the charger to authorize           │
  │   3. Charging will begin automatically           │
  └──────────────────────────────────────────────────┘
```
`type.body.medium`, `color.text.secondary`, `color.surfaceVariant` background, `radius.md`.

**Stop button:** Replaced by "Cancel Session" — Tertiary, `color.error` text, not a filled button. Tapping goes directly to cancellation (no confirmation sheet required, since no energy has been delivered).

### Auto-transition
When OCPP `Charging` status received → transitions to State 3 (skips State 2 for non-KYC flows). When `Faulted` received → transitions to State 8.

---

## 11. State 2 — Authorizing

### Trigger
App has sent an authorization request to the backend; awaiting confirmation before the charger begins energy delivery.

### Visual specification

**Ring:** Same rotating sweep animation as Preparing, but at 60% opacity (slightly more urgent feel).

**Ring center:**
```
     [spinning indicator 28dp, color.primary]
     Authorizing
     type.body.medium, color.text.secondary
```

**Status bar:** "Authorizing…" with the status dot pulsing.

**Metric grid:** Same as Preparing — all "—".

**Timeout behavior:** If authorization has not completed after 30 seconds, the center content changes to:
```
     [warning icon 28dp, color.warning]
     Taking longer than expected
     Tap to retry authorization
     type.body.small, color.text.secondary
```
"Tap to retry" is a Tertiary button within the ring center area. This is unusual — a CTA inside the ring — but authorization failure is a critical path and must be handled clearly.

---

## 12. State 3 — Charging (Primary Active State)

This is the state the user will spend the vast majority of their time in. All other states are deviations from this baseline.

### Visual specification

**Ring:** Progress arc, active fill, glow pulsing, endpoint dot traveling clockwise (LTR).

**Ring center:** Displays the last user-selected mode (Energy by default on first session; persists across mode taps until screen dismissal).

**Metric grid:** All four cards showing live values. Energy and Power update on each MeterValues message. Cost updates derived from energy. Duration increments every second.

**Status bar:** "Charging" with the secondary-color pulsing dot.

**Stop button:** "Stop Charging" — Destructive Outlined, Large, full-width.
- Height: 56dp
- Background: transparent
- Border: 1.5dp `color.error`
- Text: `type.label.large`, `color.error`
- Icon: stop square, 20dp, `color.error`, leading

A deliberate choice: the stop button is outlined (not filled) to be clearly visible without dominating the screen or creating anxiety. The destructive styling signals consequence without triggering urgency.

**Ambient glow:** Full brightness (12% opacity). This is the reference state.

### Mid-session layout (full scroll)

```
┌──────────────────────────────────────────────────┐
│  [Nav bar: ← Back  ·  Session Active]            │
├──────────────────────────────────────────────────┤
│                                                  │  ← ambient glow behind ring
│         ●─────────────────────●                  │
│        / [  24.71 kWh      ]   \                 │
│       /  [  kkkkkkWh        ]   \                │
│      |   [  ENERGY          ]    |               │
│       \                         /                │
│        ●─────────────────────●                   │  ← ring 220dp diameter
│              ○  ●  ○                             │  ← mode dots
│                                                  │
│  ┌──────────────┬──────────────┐                 │
│  │ ENERGY       │ POWER        │                 │
│  │ 24.71 kWh    │ 47.3 kW      │                 │
│  └──────────────┴──────────────┘                 │
│  ┌──────────────┬──────────────┐                 │
│  │ COST         │ DURATION     │                 │
│  │ ¥1,847       │ 00:47:23     │                 │
│  └──────────────┴──────────────┘                 │
│                                                  │
│  ┌──────────────────────────────────────────┐   │
│  │  ⚡  Elm Street Charging Hub         ↗   │   │
│  │      Connector 3 · Session #4821K        │   │
│  └──────────────────────────────────────────┘   │
│                                                  │
│  ┌──────────────────────────────────────────┐   │
│  │  ■  Stop Charging                        │   │
│  └──────────────────────────────────────────┘   │
│                                                  │
└──────────────────────────────────────────────────┘
```

The screen fits all content without scrolling on standard devices (≥390dp width, ≥700dp visible height). On very small devices (compact height), the station info card may be reached by scrolling. The Stop button is always pinned to the visible area — it is not in the scroll content; it is a persistent footer element.

**Stop button pinning:** The Stop button is positioned using a sticky footer pattern:
- The ring, metric grid, and station card are in a scrollable column
- The Stop button is outside the scroll view, pinned at the bottom with 24dp top padding, 24dp bottom padding above safe area inset
- This ensures the Stop button is always at the thumb-reachable bottom of the screen, regardless of scroll position

---

## 13. State 4 — Suspended by Vehicle

### Trigger
`SuspendedEV` status received from OCPP. The vehicle's Battery Management System has temporarily paused energy intake — this is normal during fast charging (thermal management, cell balancing). The cable is still connected. The charger is still authorized.

### Key UX constraint
**This is not an error.** The vast majority of users have never seen this status and will panic. The screen must immediately reassure them.

### Visual specification

**Ring:** Arc frozen at the current fill value. The endpoint dot changes from `color.secondary` to `color.warning`. The glow fades to 0% opacity.

**Ring center:**
```
     [vehicle icon 32dp, color.warning]
     Paused
     by vehicle
     type.body.medium, color.text.secondary
```

**Status bar:** "Paused by vehicle" in `color.warning` text.

**Explanation card (appears below metric grid, above station info):**
- 88dp height, `color.warningContainer` background, `radius.md`
- Leading: info icon 20dp, `color.warning`
- Text: "Your vehicle is managing its battery. Charging will resume automatically — this is normal." `type.body.medium`, `color.text.primary`
- No dismiss button. Card remains until status changes.

**Power card:** Shows "0.0 kW" in `color.warning`.

**Energy, Cost, Duration:** All continue to show their last-known values (frozen). Energy and cost do not change while no power flows.

**Stop button:** Remains visible. Same design as Charging state.

**Duration timer:** Continues incrementing (elapsed time includes suspended time — this is what the user was billed for from the session start, not just active charging time).

---

## 14. State 5 — Suspended by Charger

### Trigger
`SuspendedEVSE` status from OCPP. The charger itself has paused energy delivery — can be load management, grid signal, or a software hold. Cable still connected, authorization still valid.

### Key UX distinction from State 4
State 4 (by vehicle): normal, expected, user should wait.
State 5 (by charger): may be temporary (grid management), may indicate a problem. The user should be informed that the charger — not their vehicle — has paused, and given guidance.

### Visual specification

Same as State 4 visually, with one text change:

**Ring center:**
```
     [charger icon 32dp, color.warning]
     Paused
     by charger
     type.body.medium, color.text.secondary
```

**Explanation card:**
- Text: "The charger has paused energy delivery. This may be due to grid load management. Charging should resume automatically. If this continues for more than 5 minutes, contact the operator."
- Trailing: "Contact Operator" Tertiary button, `color.primary`, 32dp Small size — opens the operator's support contact (phone or in-app chat, if available)

**Auto-resume timer:** If the suspension exceeds 5 minutes, the explanation card gains a small timer: "Paused for 5:23" in `type.label.small`, `color.warning`. At 10 minutes, the timer turns `color.error` and the explanation text changes to "Contact the charger operator if this continues."

---

## 15. State 6 — Interrupted

### Trigger
Unexpected oscillation or momentary disconnection in the OCPP connection or cable. Not a full fault — the session record is still open. The charger has not sent a `StopTransaction`.

This state is a brief, transient state — the app should only display it if the interruption persists beyond 5 seconds (to avoid flickering during sub-second OCPP hiccups).

### Visual specification

**Ring:** Dashed arc (8dp dash, 8dp gap) in `color.warning`. The endpoint dot disappears. No glow.

**Ring center:**
```
     [disconnected-icon 32dp, color.warning]
     Interrupted
     type.body.medium, color.warning
```

**Status bar:** "Connection interrupted" with flashing `color.warning` dot.

**Interruption card:**
- `color.warningContainer` background
- Text: "The connection was interrupted. Do not unplug the cable. Charging may resume automatically."
- Sub-text: "If your cable is still connected, the session will recover." `type.body.small`, `color.text.secondary`

**Metric values:** Frozen at last-known values with a 🕐 icon (14dp, `color.warning`) appearing next to each value, signaling staleness.

### Auto-recovery
When `Charging` status returns → ring un-dashes, glow returns, state returns to State 3 (300ms transition). The interruption card slides away (200ms ease-in). No user action needed.

If interrupted for >60 seconds without recovery → transition to State 8 (Faulted) UI treatment with "the session may not recover" messaging.

---

## 16. State 7 — Finishing

### Sub-state A: Stop command sent, awaiting charger confirmation (202 pending)

This is the gap between the user confirming "Stop" and the OCPP `StopTransaction` acknowledgment arriving. Duration is typically 2–10 seconds.

**Ring:** Frozen at the current fill. No glow. Endpoint dot static at `color.primary`.

**Ring center:**
```
     [spinning indicator 24dp, color.primary]
     Stopping…
     type.body.medium, color.text.secondary
```

**Status bar:** "Stopping…" `color.primary` static dot.

**Metric grid:** All values frozen. No update animation.

**Stop button:** Replaced by a disabled state:
```
  ┌──────────────────────────────────────────────────┐
  │  [spinner 20dp]  Sending stop command…           │
  └──────────────────────────────────────────────────┘
```
`color.text.tertiary` text, `color.surface` background, not interactive.

**202 timeout (charger does not acknowledge within 15 seconds):**
The ring center changes to:
```
     [warning icon 28dp, color.warning]
     Stop command sent
     Waiting for charger
     type.body.small, color.text.secondary
```
A note appears below the metric grid: "If your charger does not stop, use the physical stop button on the charging unit." `type.body.small`, `color.warning`.

### Sub-state B: OCPP StopTransaction confirmed, wrapping up

The charger has acknowledged the stop. The session is computing the final energy total.

**Ring center:**
```
     ✓  (checkmark, 36dp, color.secondary)
     Finishing
     type.body.medium, color.text.secondary
```

Transition to Completed (State 9) happens automatically when the session record is finalized.

---

## 17. State 8 — Faulted

The highest severity state. A hardware or software fault has been detected. Energy delivery has stopped or is unreliable.

### Visual specification

**Background ambient glow:** Fades from `color.primary` to `color.error` at 8% opacity (1 second transition). Subtle but signals danger.

**Ring:** Full-ring in `color.error` (#DC2626). No fill progress — the entire track is `color.error` at 40% opacity, and a non-progressing arc in solid `color.error` covers 270° of the ring (three-quarter fill, static). This communicates "something happened" without implying progress.

**Ring center:**
```
     [fault icon 40dp, color.error]
     Fault detected
     type.title.medium, color.error

     Session ID: 4821K
     type.body.small, color.text.tertiary
```

**Status bar:** "Fault detected" with static `color.error` dot.

**Fault detail card (replaces explanation card):**
- Background: `color.errorContainer`, `radius.md`
- Leading: ⚠ icon 20dp, `color.error`
- Primary text: "The charger has reported a fault and cannot continue." `type.body.medium`, `color.text.primary`
- Secondary text: "Your session has been paused. Energy delivered up to the fault will be billed." `type.body.small`, `color.text.secondary`
- Two CTAs stacked:
  - "Contact Operator" — Secondary, `color.primary`, full-width
  - "Report This Issue" — Tertiary, `color.text.secondary`, full-width

**Metric grid:** Frozen at last-known values. All card borders dim to `color.outline` at 15% (lower contrast, signaling stale data).

**Stop / Close button:** The "Stop Charging" button is replaced by:
```
  ┌──────────────────────────────────────────────────┐
  │  Close Session                                   │
  └──────────────────────────────────────────────────┘
```
Primary Large, full-width. Tapping this:
1. Sends a session close request to the backend
2. The backend finalizes the session with the last-known meter reading
3. Transitions to a modified Completed screen showing the fault context

**Physical emergency guidance (always shown in Faulted state):**
A 40dp footer below the Close button, outside the scrollable area:
- Text: "If you see sparks, smoke, or fire — use the physical emergency stop button on the charger and call emergency services." `type.body.small`, `color.text.tertiary`, centered.
- This text is never hidden and cannot be dismissed.

---

## 18. State 9 — Completed

The session has ended successfully. All energy data has been confirmed by the final meter reading.

### Design intent
The Completed state should feel like a receipt being printed — clean, final, satisfying. The ring visualization transitions from progress to a celebration of the session outcome.

### Visual specification

**Ring:** Fully filled (or at target fill). Glow fades out (500ms). The gradient shifts slightly: the arc brightens to `color.secondary` on the leading end. A brief completion burst animation: the outer glow flares from 38% → 0% opacity in a single 600ms ease-out pulse (a single "pop" of light, not a repeating animation). After this burst, the ring is static.

**Ring center (post-burst):**
```
     ✓  (checkmark, 48dp, color.secondary, appears with scale 0.5 → 1.0 spring, 300ms)
     type.numeric.display (energy delivered)
     kWh delivered
```

**Status bar:** "Session complete" with static `color.secondary` dot.

**Session Summary Card (full-width, replaces metric grid):**

The four individual metric cards merge into a single summary card on completion:

```
  ┌──────────────────────────────────────────────────┐
  │  Session Summary                                 │  ← type.title.medium
  │  ─────────────────────────────────────────────   │
  │  Energy delivered      24.71 kWh                 │
  │  Total cost            ¥1,847                    │
  │  Duration              00:47:23                  │
  │  Peak power            50.0 kW                   │
  │  ─────────────────────────────────────────────   │
  │  Tariff applied        ¥60/kWh (fixed)           │
  │  Charged from wallet   ¥1,847                    │
  │  Wallet balance after  ¥48,153                   │
  └──────────────────────────────────────────────────┘
```

Row format: label left (`type.body.medium`, `color.text.secondary`), value right (`type.body.medium` for most, `type.title.medium` for energy and cost, `color.text.primary`).

**Primary CTA:** "Done" — Primary Large, full-width. Tapping dismisses this screen and returns to the Map (Home) screen. The session mini-card above the nav bar disappears simultaneously.

**Secondary CTA:** "View Receipt" — Secondary, full-width, below "Done". Navigates to the wallet transaction detail screen for this session.

**Auto-dismiss:** If the user does not interact for 90 seconds after completion, a countdown appears in the Done button: "Done (closing in 15s)". At 0, the screen auto-dismisses. The user can tap anywhere to cancel the auto-dismiss.

---

## 19. State 10 — Cancelled

The session was cancelled before any energy was delivered (during Preparing or Authorizing).

### Visual specification

**Ring:** No fill (same as Preparing). Static, no animation.

**Ring center:**
```
     [X icon 40dp, color.text.tertiary]
     Session cancelled
     type.body.medium, color.text.secondary
```

**Status bar:** "Session cancelled" with static neutral dot.

**Cancellation card:**
- `color.surfaceVariant` background
- "No energy was delivered. You have not been charged." `type.body.medium`, `color.text.primary`
- "Wallet balance: ¥50,000 (unchanged)" `type.body.small`, `color.text.secondary`

**Primary CTA:** "Back to Map" — Primary Large, full-width.

---

## 20. State 11 — Unknown

PAL parse failure or unrecognized OCPP message. The session status cannot be determined.

### Visual specification

**Ring:** Dashed full circle in `color.outline`. No fill. No animation.

**Ring center:**
```
     [question mark icon 40dp, color.text.tertiary]
     Status unknown
     type.body.medium, color.text.secondary
```

**Status bar:** "Status unknown" with neutral static dot.

**Unknown state card:**
- "We can't read the charger's status right now. Your session may still be active."
- "Do not unplug the cable."
- Sub-text: "If your vehicle shows it is not charging, contact the operator." `type.body.small`

**Stop button:** Shown as "Request Stop" — attempts a stop command even without confirmed status. On tap, goes through the normal confirmation sheet.

---

## 21. Stop Charging Flow

The stop flow is a deliberate, multi-step interaction. Accidental stops during a long session are frustrating and can leave vehicles undercharged. The design prevents them while keeping the stop action reachable.

### Step 1 — Stop button tap

The "Stop Charging" button is tapped. No immediate action. A confirmation bottom sheet slides up.

### Step 2 — Confirmation sheet

**Sheet height:** 420dp + safe area. Slides up 280ms, cubic Bézier (0.4, 0, 0.2, 1). Standard handle at top.

**Sheet content:**

```
  ──── (handle)

  Stop Charging?
  type.headline.small, color.text.primary

  ─── Session so far ──────────────────────────────

  ┌─────────────────────┬─────────────────────────┐
  │ 24.71 kWh           │ 00:47:23                │
  │ Energy delivered    │ Duration                │
  └─────────────────────┴─────────────────────────┘

  Running cost: ¥1,847   (¥60/kWh)
  type.title.medium aligned right

  ─── Reminder ────────────────────────────────────

  ⚠  Your vehicle may not be fully charged.
     Check your vehicle's display before stopping.
     type.body.small, color.text.secondary

  ─── ─────────────────────────────────────────────

  [ Stop Charging ]  ← Primary Large, color.error background
  [ Keep Charging ]  ← Tertiary, color.primary text
```

**"Stop Charging" in sheet:** This is the ONLY place in the UI where the stop button is filled red (Destructive Filled). The filled red here communicates irreversibility. This is the final decision point.

**"Keep Charging":** Dismisses the sheet with a swipe-down animation. No action taken.

### Step 3 — Stop command in flight (202 pending)

On "Stop Charging" confirmation tap:
- Sheet closes (dismisses downward, 220ms)
- Session transitions to State 7 (Finishing, Sub-state A)
- POST /sessions/:id/stop → 202 Accepted
- The main screen's Stop button becomes disabled loading state

### Step 4 — OCPP confirmation

When the WebSocket delivers the stop confirmation:
- Session transitions to State 7 (Finishing, Sub-state B)
- Brief 1–2 second "Finishing" display
- Transitions to State 9 (Completed)

### Stop flow unavailability

The Stop button is replaced with an informational message in these cases:
- **Offline:** "Reconnect to stop the session. Use the physical stop button on the charger if urgent." Stop button disabled, `color.text.tertiary`.
- **Faulted:** Stop button replaced by "Close Session" (see §17).
- **Already Finishing:** Button disabled with loading state (see §16).
- **Completed / Cancelled:** Stop button not shown at all.

---

## 22. Emergency and Fault Scenarios

### Scenario A: Charger reports fault mid-session

OCPP sends `Faulted` status → screen transitions to State 8 (§17). User sees fault messaging, operator contact, and "Close Session" CTA.

### Scenario B: App receives no heartbeat for >3 minutes

The OCPP heartbeat or session WebSocket has gone silent. The session may be alive on the charger but the app cannot confirm.

**Degraded state trigger:** 3 minutes of silence (configurable per deployment).

**UI:**
- Ring center shows: warning icon + "Session status uncertain" + "Last update [N] min ago"
- Power card: "Last known: 47.3 kW" in `color.warning`
- An inline banner above the metric grid: "We haven't heard from the charger. Your vehicle may still be charging — check the charger display."
- Stop button remains active (attempt stop even in degraded state)

### Scenario C: Physical cable pull during session

Detected when OCPP sends an abrupt session close without a user stop command. The app navigates from this screen to a modified Completed screen with an alert:

- Title: "Session ended unexpectedly"
- Body: "The cable was disconnected. Your session has been finalized with the last meter reading."
- The session summary shows the final values.

### Scenario D: Double billing concern (user stops, session re-opens)

If a session enters Completed state and then a new session appears on the same connector within 60 seconds: the app checks if it's a new session (different session ID) or a re-open of the same session (same ID, server correction).

- Same ID (correction): existing Completed screen updates its totals with a brief "Session updated" notification
- Different ID: new session screen appears with a banner: "A new session has started on this connector. If this was not you, contact support immediately."

---

## 23. Network Loss Behavior

Per ARCHITECTURE_FINAL.md §21: an active charging session continues when the app loses network connectivity. The OCPP commands were already sent to the charger. The session progresses on the charger side regardless of app state.

### Immediate network loss (WS disconnect)

**Ring:**
- Arc becomes dashed (8dp dash, 8dp gap), `color.warning`
- Glow fades out (300ms)
- Endpoint dot disappears

**Network loss banner (slides down from below nav bar, 36dp):**
```
  [cloud-offline icon]  Offline — session data may be outdated
```
`color.surfaceVariant` background, `color.text.secondary` text.

**Ring center:**
```
     [cloud-offline icon 28dp, color.warning]
     Offline
     Last update: [timestamp]
     type.body.small, color.text.tertiary
```

**Metric grid:** All values frozen. Each card's value is displayed in `color.text.secondary` (slightly dimmed) with a small 🕐 icon appended.

**Stop button behavior:**
The Stop button changes to:
```
  ┌──────────────────────────────────────────────────┐
  │  ■  Stop Charging (reconnecting…)               │
  └──────────────────────────────────────────────────┘
```
The button is visually present but disabled (shown in `color.error` at 50% opacity). Below the button, a line reads: "Stop unavailable while offline. Use the physical stop button on the charger if urgent." `type.body.small`, `color.text.tertiary`.

The physical stop guidance is shown explicitly because a user who must stop their session now — for safety or convenience — needs to know where to look.

### Reconnection

On network restoration (WS reconnects):
- Offline banner fades out (200ms)
- Ring arc returns to solid (300ms)
- Glow returns (500ms)
- App fetches the latest session state and meter values from the server
- Metric grid updates to current values with the "heartbeat" border flash animation
- If the session completed while offline: app detects the session is in Completed state and transitions the screen directly to State 9 (Completed), showing a banner: "Your session completed while offline. Here's the final summary."

### Extended offline (>30 minutes)

If offline for >30 minutes and the user opens the app:
- The session screen may not be reachable (app may have been killed by OS)
- On app resume: the `ActiveSessionGuard` detects an open session in local cache and navigates to the session screen
- The screen loads in offline mode immediately, showing cached last-known values

---

## 24. Loading and Entry States

### Entry from Session Start (new session)

The session screen is pushed as the session start API call returns 202 Accepted. At this moment, the session ID is known but no meter data has arrived.

**Entry animation:** The screen slides up from the bottom (not a standard horizontal page transition — the upward motion reinforces "starting something").

**Initial loading state (0 to first MeterValues):**
- Ring: Preparing animation (rotating sweep, State 1 or 2 styling)
- Metric grid: skeleton placeholders — 3 skeleton rectangles per card (label, value, unit), shimmer animation
- Status bar: "Starting session…"
- Station info card: loaded immediately from route parameters (no fetch needed)
- Stop button: shown immediately, in case the user changes their mind

**Transition to live data:** When the first MeterValues message arrives:
- Skeleton placeholders animate out (80ms fade)
- Live values animate in (100ms fade-up)
- Ring transitions from Preparing animation to first fill increment (300ms)

### Entry from Deep Link / Resume

If the user navigates to `/charging/:sessionId` directly (e.g., from a notification) and the session is already in progress:
- Screen enters with a 500ms full-screen skeleton
- Data is fetched from `GET /sessions/:id`
- On data arrival: skeleton fades out, ring jumps to current fill value (no animation — instant — the arc does not animate from 0% to current; it starts at the correct current position)
- Metric grid populates with real values
- Timer is initialized from `session.startedAt`, so elapsed time is accurate

---

## 25. Transitions and Animations

### Screen entry and exit

| Action | Animation | Duration |
|--------|-----------|----------|
| Session start → screen enter | Slide up from bottom | 350ms, ease-out |
| Completed → dismiss | Slide down to bottom | 300ms, ease-in |
| Cancelled → dismiss | Fade out | 250ms, ease-in |
| Faulted "Close Session" → dismiss | Slide down | 300ms, ease-in |
| Back gesture (during active session) | Sheet slides down asking "Leave session?" | — |

### Ring animations

| Event | Animation |
|-------|-----------|
| Energy update | Arc extends by delta amount over 500ms, ease-in-out |
| State → Faulted | Arc color transitions from gradient to `color.error`, 400ms |
| State → Completed | Final arc value + 600ms glow burst |
| State → Suspended | Glow fades to 0%, endpoint dot changes color, 300ms |
| State → Interrupted | Arc becomes dashed, 300ms |
| Offline | Arc dashes, glow fades, 300ms |
| Online restore | Arc un-dashes, glow returns, 500ms |
| Center mode tap | Fade-through: out 150ms, in 150ms |

### Status bar state changes

All status bar changes use a cross-fade: outgoing content fades to 0% opacity (100ms), incoming content fades in (100ms). The dot color transitions over 200ms ease-in-out.

### Confirmation sheet

| Action | Animation |
|--------|-----------|
| Stop tap → sheet appears | Slide up, 280ms, cubic Bézier (0.4, 0, 0.2, 1) |
| Keep Charging → sheet dismisses | Slide down, 220ms, ease-in |
| Stop confirmed → sheet dismisses | Slide down, 180ms (faster — action taken) |

### Metric card update heartbeat

Duration: 150ms per cycle. The border color briefly shifts to `color.secondary` at 50% opacity then returns to `color.outline` at 30%. This runs on every MeterValues event across all four cards simultaneously.

### Reduced motion

Under `AccessibilityFeatures.reduceMotion`:
- Ring fill: instant position update (no interpolation, no smooth growth)
- Glow: opacity toggles (no pulsing animation)
- Status bar: instant cross-fade removed (instant change)
- Sheet: instant appear/disappear (no slide)
- Metric heartbeat: removed entirely
- Completion burst: removed; checkmark appears instantly

---

## 26. RTL Behavior (Persian / Farsi)

### Ring direction

**Critical:** The session ring sweep direction reverses in RTL. In LTR, the arc sweeps clockwise from the 7 o'clock position. In RTL, the arc sweeps counter-clockwise from the 5 o'clock position (mirrored). The starting point is visually mirrored, and the glow endpoint dot travels in the opposite direction.

The ring center content is locale-independent (numbers and icons) — no directional adjustment needed.

### Metric grid

The grid remains a 2×2 layout. In RTL:
- Top row: Power (right cell) | Energy (left cell)
- Bottom row: Duration (right cell) | Cost (left cell)

Cards swap position but their internal content (label top, value bottom) mirrors normally within each card.

### Session Summary Card (Completed state)

Row layout:
- In LTR: label left, value right-aligned
- In RTL: value left-aligned, label right

### Status bar

In RTL: dot appears on the right, text aligns right, connector info appears at the start (right side).

### Stop Confirmation Sheet

In RTL:
- Session summary metrics swap positions (mirror of the 2-column layout)
- "Stop Charging" remains the full-width destructive button — no positional change needed
- All text uses Persian-Indic digits for values

### Numeric formatting in RTL

| Value | LTR display | RTL display (fa locale) |
|-------|------------|------------------------|
| Energy | "24.71 kWh" | "۲۴٫۷۱ کیلووات‌ساعت" |
| Cost | "¥1,847" | "۱٬۸۴۷ تومان" |
| Duration | "00:47:23" | "۰۰:۴۷:۲۳" (always LTR direction, in explicit LTR container) |
| Power | "47.3 kW" | "۴۷٫۳ کیلووات" |
| Session ID | "#4821K" | "#4821K" (always LTR, Latin, monospace) |

Duration is always rendered LTR (explicit LTR container, Inter font) because HH:MM:SS is a positional format — reversing it would make it unreadable.

Session ID is always Latin, always LTR, always monospace Inter — it is a machine identifier, not a user-facing word.

---

## 27. Accessibility Requirements

### Screen reader session status

On screen load, the accessibility announcement is: "Charging session active. [Energy] kilowatt-hours delivered. [Duration] elapsed. [Cost] total cost. Session is [StatusLabel]."

This announcement fires once on screen entry. Subsequent announcements are limited:
- Status state changes: announced immediately. Example: "Session paused by vehicle."
- Completion: "Charging session complete. [Energy] kilowatt-hours delivered. Total cost: [Cost]."
- Fault: "Alert. Fault detected. Session has stopped. Use the Stop button to close the session."

Live metric updates are NOT continuously announced (this would be unusable — updates arrive every few seconds). The user can navigate to any metric card to hear its current value.

### Semantic labels

**Ring (as a widget):** Accessibility label: "Charging progress ring. [X]% of [target] charged." or "Charging progress ring. [Duration] elapsed." (depending on fill mode). Role: image (decorative progress indicator). Not interactive — center is the interactive element.

**Ring center (tap target):** Label: "Current metric: [mode name]. [Value]. Tap to switch metric." Hint: "Tap to cycle between Energy, Cost, and Time displays."

**Energy card:** "Energy delivered: [value] kilowatt-hours."

**Power card:** "Current power: [value] kilowatts." or "Power unavailable — charger is not reporting." or "No power flowing — session paused."

**Cost card:** "Running cost: [value]."

**Duration card:** "Session duration: [hours] hours, [minutes] minutes, [seconds] seconds."

**Stop button:** "Stop charging session. Double-tap to open confirmation." This label is intentional — it pre-informs screen reader users that a confirmation follows, so they don't expect immediate action.

**Stop button (disabled/Finishing state):** "Stop command sent. Waiting for charger response."

**Fault card "Contact Operator" button:** "Contact operator about charger fault. Opens contact options."

### Focus management

- On session screen entry: focus is set to the status bar (first meaningful semantic element)
- On stop confirmation sheet open: focus moves to the sheet title ("Stop Charging?")
- On sheet dismiss: focus returns to the Stop Charging button
- On completion: focus moves to the Session Summary Card header
- On fault: focus moves to the fault detail card, and a high-priority accessibility announcement fires

### Minimum touch targets

All interactive elements meet 44×44dp minimum:
- Ring center: 196dp diameter (far exceeds minimum)
- Stop button: 56dp height × full width
- Metric cards (long-press for clipboard): 80dp height (exceeds minimum)
- Station info card: 72dp height (exceeds minimum)

### Color independence

Every state change uses both color AND a structural change (icon, label, dashed vs. solid arc, text) so users with color vision deficiencies can distinguish all states without relying on color alone.

State differentiation without color:
- Charging vs. Suspended: animated glow vs. no glow; moving endpoint vs. amber static dot; "Charging" vs. "Paused" label
- Fault vs. Suspended: full-ring red fill vs. partial frozen fill; ⚠ fault icon vs. vehicle/charger icon; "Fault detected" vs. "Paused"
- Offline: dashed arc (structural) vs. solid arc; cloud-offline icon in center

---

## 28. Edge Cases

### Session started for a different user's account on the same device

If the device receives a WebSocket event for a session that does not match the authenticated user's ID: the session event is silently discarded. The screen shows the session belonging to the authenticated user. No cross-contamination.

### User opens app mid-session from cold start

`AppStartGuard` checks for an open session in local cache on cold start. If found:
- App navigates to the session screen after the normal auth/KYC guards pass
- Session screen opens in loading state, fetches current session status
- If session has already ended while app was closed: app detects Completed/Cancelled state from the server and shows the Completed/Cancelled UI immediately
- A banner on the Completed screen: "Your session ended while the app was closed."

### Two rapid "Stop" taps

If the user taps "Stop Charging" in the confirmation sheet and then taps again before the 202 response arrives:
- The second tap is ignored — the button is in loading state and not interactive
- The POST is sent exactly once (idempotency guaranteed by the backend, but the UI also prevents double-submission)

### Session ID not found (404 on entry)

If the session ID in the route does not exist (invalid deep link, expired session):
- Screen shows a full-screen error state: session-not-found illustration, "This session could not be found", "Back to Map" Primary button

### Meter value overflow (rare, long sessions >24h)

If elapsed duration exceeds 23:59:59 (never in normal use, but defensively handled):
Duration display changes to `[N]d [HH:MM]` format. Example: "1d 01:23".

### Charging cost exceeds wallet balance mid-session

The backend processes the final charge on session end, not in real-time. However, if a session estimate exceeds the wallet balance (detected by the tariff notifier), an inline warning appears in the Cost card:
- Card border changes to `color.warning`
- Sub-text below the cost: "Approaching wallet limit" in `color.warning`
- At estimated overdraft: "Session may be auto-stopped when limit reached" — this is a backend-configurable behavior, shown only if the deployment config has it enabled

### Session in multiple WS subscriptions (reconnect race)

On WebSocket reconnect, the app re-subscribes to the session topic. If two events arrive in rapid succession (race condition on reconnect), the state machine processes them in order using the event `timestamp` field — not arrival order. The UI shows the latest chronological state.

---

## 29. Future Feature Design Surfaces

These design surfaces are not implemented in MVP. They are specified here as reserved placeholders so that adding them later does not require screen redesign. Each is a discrete, additive component with a defined visual location.

### Smart Charging

**When active:** An OCPP 2.x Smart Charging profile has been applied, scheduling power delivery over time rather than charging at maximum rate.

**Visual changes:**
- A new section between the metric grid and station info card: "Charging Schedule"
- 64dp height card showing a mini timeline chart: a horizontal bar from now to estimated completion, with power level bands color-coded (high power: `color.primary`; reduced power: `color.primary` at 40%; paused window: `color.outline`)
- Below the chart: "Peak charging until 22:30 · Off-peak from 22:30"
- Current power card label changes to: "CURRENT POWER (scheduled)"

**Ring behavior change:** The ring fill speed varies with the scheduled power delivery rate rather than real-time meter values — it fills faster during high-power windows and slows during reduced windows. The ring endpoint dot moves at variable speed.

### Dynamic Pricing

**When active:** The tariff per kWh changes over time (e.g., grid price integration).

**Visual changes:**
- Cost card gains a trend indicator: a small arrow (↑ or ↓) next to the running cost showing whether the current rate is higher or lower than the session-start rate
- A "Price changed" badge appears on the Cost card if the rate has changed during this session: "Rate: ¥72/kWh (was ¥60)" in `type.label.small`, `color.warning`
- The stop confirmation sheet adds a "Price note" row: "Current rate is [X]% higher/lower than session start"

### Plug & Charge (ISO 15118)

**When active:** The vehicle authenticates directly via the cable without user intervention.

**Visual changes in Preparing/Authorizing states:**
- Ring center shows: vehicle certificate icon + "Authenticating via Plug & Charge" instead of standard preparing text
- No manual "retry authorization" option is shown (authentication is between vehicle and EVSE, not user-triggered)
- On successful auth, the transition to Charging is seamless with no visual interruption

**Completed state addition:**
- Session summary card adds a row: "Authenticated via Plug & Charge ✓"

### V2G / V2X (Vehicle to Grid)

**When active:** Energy flows from vehicle to grid (or to a local building). The vehicle is exporting, not importing.

**Ring direction reversal:** In V2G mode, the ring sweeps in the opposite direction from charging (counter-clockwise in LTR, clockwise in RTL). This visually reverses the normal charging motion.

**Ring gradient reversal:** `color.secondary` → `color.primary` (reversed from charging mode). The green-to-blue gradient communicates "exporting" vs. importing.

**Metric grid label changes:**
- "ENERGY" → "ENERGY EXPORTED"
- "COST" → "EARNINGS"
- "POWER" → "EXPORT POWER"
- "DURATION" → "DURATION"

**Ring center (Energy mode):**
```
     [up-arrow icon, color.secondary]
     12.4 kWh
     exported
```

**Status bar:** "Exporting to grid" with `color.secondary` pulsing dot.

**Stop button:** "Stop Exporting" — same outlined destructive style.

**Earnings display:** The Cost card becomes the Earnings card. Values are formatted with a "+" prefix and `color.secondary` text color. The running total is a credit, not a charge.

---

*This document specifies the complete design of the Active Charging Session screen. No implementation proceeds without alignment on every state, edge case, and transition defined here. This screen is the contract between the user's trust and the platform's accuracy.*