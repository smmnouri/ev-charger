# Reservation Flow

**Primary routes:**  
`/reservations` — Reservation list (Tab 2)  
`/reservations/new` — Reservation creation flow  
`/reservations/:id` — Reservation detail  
`/reservations/:id/cancel` — Cancellation flow (sheet, not full-screen)  
`/reservations/:id/extend` — Extension flow (sheet, not full-screen)  

**Tab:** Tab 2 (Reservations) hosts the list. Creation and detail screens push over the shell.  
**Last Updated:** 2026-06-11  
**References:** DESIGN_SYSTEM.md · ARCHITECTURE_FINAL.md §15 · STATION_DETAILS_SCREEN.md §16 · CHARGING_SESSION_SCREEN.md

A reservation is a promise between the user and the platform: "That connector will be yours at that time." The entire reservation system is built on the credibility of that promise. A reservation that expires silently, or that cannot be converted to a session smoothly, destroys the promise. Every design decision in this document serves the reliability and clarity of that commitment.

---

## Table of Contents

1. [Reservation System Goals](#1-reservation-system-goals)
2. [User Journey](#2-user-journey)
3. [Reservation Architecture](#3-reservation-architecture)
4. [Reservation Creation Flow](#4-reservation-creation-flow)
5. [Reservation Confirmation Screen](#5-reservation-confirmation-screen)
6. [Reservation Success Screen](#6-reservation-success-screen)
7. [Reservations List Screen (Tab 2)](#7-reservations-list-screen-tab-2)
8. [Reservation Detail Screen](#8-reservation-detail-screen)
9. [Reservation Countdown Behavior](#9-reservation-countdown-behavior)
10. [Reservation Expiry Behavior](#10-reservation-expiry-behavior)
11. [Reservation Cancellation Flow](#11-reservation-cancellation-flow)
12. [Reservation Modification and Extension Flow](#12-reservation-modification-and-extension-flow)
13. [Reservation Fees and Policies](#13-reservation-fees-and-policies)
14. [Wallet Interaction](#14-wallet-interaction)
15. [Push Notification Strategy](#15-push-notification-strategy)
16. [Reminder Schedule](#16-reminder-schedule)
17. [Check-In Process at Station](#17-check-in-process-at-station)
18. [Reservation-to-Session Handoff](#18-reservation-to-session-handoff)
19. [Multiple Reservation Rules](#19-multiple-reservation-rules)
20. [KYC Requirements](#20-kyc-requirements)
21. [Offline Behavior](#21-offline-behavior)
22. [Loading States](#22-loading-states)
23. [Empty States](#23-empty-states)
24. [Error States](#24-error-states)
25. [Accessibility Requirements](#25-accessibility-requirements)
26. [RTL Behavior (Persian / Farsi)](#26-rtl-behavior-persian--farsi)
27. [Edge Cases](#27-edge-cases)
28. [Future Expansion Opportunities](#28-future-expansion-opportunities)

---

## 1. Reservation System Goals

**Platform goal:** Reduce uncertainty for users who are planning a charge. A user who knows a connector will be available when they arrive can manage their schedule around charging, not the other way around.

**Business goal:** Increase session conversion rates by pre-committing users before they reach the station. A user with an active reservation is far more likely to complete a session than one browsing for walk-up availability.

**Operator goal:** Maximize connector utilization by eliminating speculative no-shows through auto-release policies and intelligent expiry handling.

**Design goals, in priority order:**

1. **Creation must be fast.** A reservation that takes more than 60 seconds to create will be abandoned. The creation flow is 2 steps maximum; the critical path (date, time, confirm) must be reachable within 3 taps from the Station Details screen.

2. **Countdown must be ambient.** The user does not need to check the app to know how much time they have. Push notifications carry the countdown to the lock screen. When they do open the app, the time remaining is the first thing they see.

3. **Check-in must be zero-friction.** When the user arrives at the station, converting their reservation to a charging session must take a single deliberate tap. Any additional step between "I'm here" and "charging has started" is a failure.

4. **Expiry must be honest and early.** If the user is not going to make it, the app should help them cancel rather than let the reservation expire silently. An expired reservation with no prior warning is a frustrating experience, even if the user is at fault.

5. **Policies must be transparent before commitment.** Cancellation fees, no-show policies, and extension costs must be visible during creation — not discovered in the moment of cancellation.

---

## 2. User Journey

### Journey A — Same-day reservation (most common)

```
  2:00 PM  User discovers station on map while driving
           ↓
  2:01 PM  Taps pin, views station detail sheet
           ↓
  2:02 PM  Taps "Reserve" on an available CCS connector
           ↓
           [Reservation creation: selects 3:30 PM start]
           ↓
  2:03 PM  Reservation confirmed — countdown begins (1h 27min)
           ↓
  2:55 PM  Push notification: "Your reservation starts in 35 minutes"
           ↓
  3:20 PM  Push notification: "Your reservation starts in 10 minutes"
           ↓
  3:30 PM  Reservation window opens — check-in available
           Push: "Your reservation is active. You have 30 minutes to check in."
           ↓
  3:38 PM  User arrives, opens app, taps "Start Charging"
           ↓
  3:38 PM  Session starts — reservation status: Completed
           Charging Session screen replaces reservation detail
```

### Journey B — Advance planning (weekend trip)

```
  Monday   User plans a road trip for Saturday
           ↓
           Finds a station on route, reserves 11:00 AM Saturday
           ↓
  Friday   Push notification: "Tomorrow: Your reservation at Elm St"
  Saturday Push: "Your reservation starts in 1 hour"
           ↓
  Saturday Reservation window opens, check-in flow, session starts
```

### Journey C — Reservation not used (expiry path)

```
  User reserves for 4:00 PM
           ↓
  4:00 PM  Reservation window opens
  4:05 PM  Push: "Check in soon — 25 minutes remaining"
  4:15 PM  Push: "Only 15 minutes left on your reservation"
           ↓
  4:25 PM  Push: "5 minutes remaining. If you can't make it, cancel now."
           ↓
  4:30 PM  Reservation expires — NoShow state
           Push: "Your reservation expired. Connector released."
           In-app: Expired reservation card in list
```

### Journey D — Cancellation path

```
  User has reservation for 6:00 PM
           ↓
  3:00 PM  User cancels (>2h before start — free cancellation)
           ↓
           Cancellation confirmed, wallet refunded if paid
           Push: "Reservation cancelled. Refund processed."
```

---

## 3. Reservation Architecture

### State machine

The reservation lifecycle follows a strict state machine. Each state has defined entry conditions, exit conditions, and UI representations.

```
                    ┌──────────┐
            create  │         │  system confirms
       ─────────────▶ Pending ├──────────────────────▶ Confirmed
                    │         │                            │
                    └──────────┘                           │ window opens
                         │                                 ▼
                    system rejects                     ┌────────┐
                         │                             │        │
                         ▼                             │ Active │
                      Failed                           │        │
                    (Error state)                      └────────┘
                                                           │
                          ┌────────────────────────────────┤
                          │                 │              │
                          ▼                 ▼              ▼
                      Completed         Expired         Cancelled
                  (session started)   (no-show)     (user/operator)
```

**State definitions:**

| State | Duration | User-facing label | Color |
|-------|----------|------------------|-------|
| Pending | Seconds to minutes | "Confirming…" | `color.primary` |
| Confirmed | Hours to days | "Upcoming" | `color.tertiary` |
| Active | Duration of window | "Check in now" | `color.secondary` |
| Completed | Terminal | "Charged" | `color.secondary` (dimmed) |
| Expired | Terminal | "Expired" | `color.warning` |
| Cancelled | Terminal | "Cancelled" | `color.text.tertiary` |

### Two reservation modes

**Mode A — Connector-specific**
The reservation is for a named connector (e.g., "Connector 3 at Elm Street Hub"). The user selects a specific connector from the Station Details screen. That exact connector is held for the user — no other user can use it during the window. The station detail pin color changes to `status.reserved` for that connector specifically.

**Mode B — Connector-type**
The reservation is for a connector type at a station (e.g., "Any CCS connector at Elm Street Hub"). The system assigns a specific connector when the user checks in. The station must have at least one available connector of the requested type at check-in time. This mode allows operators to offer reservations even during high occupancy, at the cost of less certainty for the user.

**Mode determination:** Set by the station's operator configuration (`reservationMode: specific | type | both`). When `both`, the user sees a toggle in the creation flow. Most stations in MVP will be `specific`.

### TariffSnapshot at creation

At the moment a reservation is created, the current tariff for the reserved connector is captured as an immutable `TariffSnapshot`. This snapshot travels with the reservation and is used when the session converts (the price the user sees during reservation is the price they pay, even if the operator changes the tariff before they check in). This is a non-negotiable contractual commitment to the user.

**Exception:** The snapshot is invalidated if:
1. The operator explicitly marks a snapshot as superseded (rare, with proper notification)
2. The connector is upgraded/replaced (new hardware, new connector ID — effectively a new connector)

### Auto-release policy

Operator-configured per station. Common settings:
- **Window duration:** How long the user has to check in (15, 30, 45, or 60 minutes; default: 30 minutes)
- **Grace period:** Additional time after window expiry before marking NoShow (default: 0 — no grace, immediate release)
- **No-show fee:** Optional penalty deducted from wallet on NoShow (operator-configured; default: no fee)
- **Extension policy:** Whether users can extend their reservation, and at what cost

---

## 4. Reservation Creation Flow

### Entry point

Navigation arrives from the Station Details screen (§16), after the user has confirmed the connector selection in the inline pre-confirmation sheet. The creation screen receives via route parameters:
- `stationId`, `stationName`, `stationAddress`
- `connectorId` (Mode A) or `connectorType` (Mode B)
- `connectorPower` (kW max)
- `tariffSummary` (from pre-loaded station data)
- `reservationWindow` (minutes, operator-configured)
- `cancellationPolicy` (free cut-off hours)

Because these parameters are passed from the Station Details screen, the creation screen renders its header instantly — no loading skeleton for the station/connector information.

### Creation flow structure

The creation flow is two steps presented as a single scrollable screen, not a multi-page wizard. The user sees the full form at once; scrolling reveals the confirm button. This eliminates "how many steps are left?" confusion and allows the user to review all inputs before committing.

**Top of screen:** Progress context, not a step indicator — "Reserving at [Station Name]". This is not a progress bar; it is a reminder of the commitment being made.

### Full creation screen layout

```
┌────────────────────────────────────────────────────────────┐
│  ← Back                                                    │  ← Nav bar
│  New Reservation                                           │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌────────────────────────────────────────────────────┐   │  ← Station context card
│  │  [⚡ icon]  Elm Street Charging Hub                 │   │
│  │             CCS DC Fast · 150 kW · Connector 3     │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  ─── When? ──────────────────────────────────────────      │  ← Section 1
│                                                            │
│  ┌────────────────────────────────────────────────────┐   │
│  │   Today  /  Tomorrow  /  [Date picker ▼]           │   │  ← Day selector
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  ┌──────────────────────────────────────────────────── ┐  │
│  │  [Time slots grid]                                  │  │  ← Time slot grid
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  ─── Reservation details ────────────────────────────      │  ← Section 2
│                                                            │
│  Check-in window          30 minutes                      │  ← Policy display
│  Cancellation             Free if cancelled 2h+ before    │
│                                                            │
│  ─── Pricing ────────────────────────────────────────      │  ← Section 3
│                                                            │
│  Reservation fee          Free                            │
│  Charging rate            ¥60/kWh (locked at booking)    │
│  Your wallet              ¥50,000          ✓              │
│                                                            │
│  ─── ─────────────────────────────────────────────────     │
│                                                            │
│  ┌────────────────────────────────────────────────────┐   │  ← Summary before confirm
│  │  CCS · Connector 3                 Today, 3:30 PM  │   │
│  │  30-min window · ¥60/kWh · Free cancellation       │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  ┌────────────────────────────────────────────────────┐   │
│  │          Confirm Reservation                       │   │  ← Primary CTA
│  └────────────────────────────────────────────────────┘   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Station context card

- Height: 72dp
- Background: `color.surfaceVariant`
- Border radius: `radius.lg` (16dp)
- Left: 40dp connector icon circle, `color.primary` background at 15%, connector type icon `color.primary`
- Right: Station name `type.title.medium`, sub-row: connector type + power + connector number `type.body.small`, `color.text.secondary`
- Not tappable — it is a static context reminder, not a navigation element

### Day selector

Three segmented options: "Today", "Tomorrow", and a calendar trigger.

**Segment control design:**
- Height: 44dp, `radius.lg`
- Background container: `color.surfaceVariant`
- Active segment: `color.surface`, `radius.md`, elevation 1 — slides between segments
- Text: `type.label.large` (14sp/500)
- Active text: `color.text.primary`; inactive: `color.text.secondary`
- 4dp inset padding within the container

**Calendar trigger (third segment):** Shows "Pick date" with a calendar icon. When tapped, a bottom sheet calendar picker appears:

**Calendar picker sheet (480dp height + safe area):**
- Standard handle
- Month navigation: "‹ [Month Year] ›" row, 48dp
- 7-column day grid (Mon–Sun headers in `type.label.small`, `color.text.tertiary`)
- Each day cell: 40dp × 40dp
- Today: bold text, `color.primary` underline
- Selected date: `color.primary` filled circle, white text
- Past dates: `color.text.disabled` (40% opacity), not tappable
- Dates with known low availability at this station (if data available): amber dot below day number
- Dates more than 30 days out: grayed and not tappable (operator-configured max advance booking window)
- "Confirm" Primary Large at bottom of sheet

### Time slot grid

A scrollable horizontal grid of 30-minute time slots across the selected day. This is the single most important input in the creation flow — it must be clear and efficient.

**Grid container:**
- Height: 112dp (two visible rows of slots)
- Horizontal scroll enabled
- Fade gradient at both edges (32dp, `color.background` to transparent)

**Each time slot (72dp wide × 48dp tall):**
- Label: time in locale-appropriate format (e.g., "3:30 PM" or "15:30"), `type.label.large`, centered
- Sub-label: connector availability indicator (12dp dot)
- Border radius: `radius.md`
- 6dp horizontal gap between slots

**Slot states:**

| State | Background | Border | Text | Sub-dot | Tappable |
|-------|-----------|--------|------|---------|---------|
| Available | `color.surface` | 1dp `color.outline` | `color.text.primary` | `color.secondary` (green) | Yes |
| Selected | `color.primary` | None | White | White | Yes (deselect) |
| Now (current 30-min block) | `color.primaryContainer` | 1.5dp `color.primary` | `color.primary` | `color.secondary` | Yes (reserve now) |
| Soon available (within 30min) | `color.surface` | 1dp `color.warning` | `color.warning` | `color.warning` | Yes |
| Unavailable | `color.surfaceVariant` | None | `color.text.disabled` | `color.outline` | No |
| Past | `color.background` | None | `color.text.disabled` | None | No |

**"Now" slot:** The current 30-minute block is always shown as the leftmost visible slot, even when the user selects a future date that then becomes "today". Label: "Now" instead of the time. This allows users to create immediate reservations quickly.

**Availability data source:** The time slot grid fetches future connector availability from the API — a forecast of when the connector is likely to be free, based on existing reservations and historical occupancy. This is best-effort, not guaranteed. A note below the grid: "Availability estimates are based on current bookings and may change." `type.body.small`, `color.text.tertiary`.

**No availability data:** If the API has not returned availability data within 2 seconds, all slots show as "Available" with a footnote: "Live availability not loaded — all slots shown as available." Slots remain selectable.

**Selected time slot:** When the user taps a slot, it becomes Selected. Only one slot can be selected at a time. The summary block at the bottom of the screen immediately updates to reflect the selected time.

### Reservation details section

Non-editable display of operator-configured parameters:

**Check-in window row:**
- Label: "Check-in window", `type.body.medium`, `color.text.secondary`
- Value: "[N] minutes", `type.title.medium`, `color.text.primary`
- Info icon: 16dp, `color.text.tertiary`. Tap expands an inline tooltip: "You have [N] minutes from your reserved start time to connect the cable and begin charging. After this window, the connector is released."

**Cancellation policy row:**
- Label: "Cancellation", `type.body.medium`, `color.text.secondary`
- Value: policy string (e.g., "Free if cancelled [N]+ hours before start" or "¥500 fee within [N] hours" or "Non-refundable")
- Policy string uses plain language — no legalese
- If there is a no-show fee: "No-show fee: ¥[amount]" appears as a separate row in amber `color.warning` text

### Pricing section

**Reservation fee row:**
- "Reservation fee" / "Free" or "¥[amount] (deducted now)"
- If paid: wallet balance check runs on screen load. If insufficient, the row shows "⚠ Insufficient wallet balance" in `color.error` with a "Top Up" Tertiary link

**Charging rate row:**
- "Charging rate" / tariff summary from the TariffSnapshot (e.g., "¥60/kWh, locked at booking")
- "(locked at booking)" is critical — it communicates the price guarantee

**Wallet balance row:**
- Only shown if there is a reservation fee or a minimum charge deposit required
- "Your wallet" / balance / ✓ (sufficient) or ⚠ (insufficient)

### Summary block (sticky-ish pre-confirm card)

The summary block sits just above the Confirm button. It condenses the key parameters into a single scannable row, giving the user one final chance to verify before tapping Confirm.

```
  ┌──────────────────────────────────────────────────────┐
  │  CCS · Connector 3              Today, 3:30 PM       │
  │  30-min window · ¥60/kWh · Free cancellation         │
  └──────────────────────────────────────────────────────┘
```

**Disabled state (no time slot selected):**
- Summary shows "Select a time above to continue", `type.body.medium`, `color.text.tertiary`, centered
- Confirm button is disabled (opacity 40%, not interactive)

**Enabled state:** Summary shows parameters, Confirm button is fully interactive.

### Confirm button

"Confirm Reservation" — Primary Large, full-width.

**On tap:**
1. Button enters loading state (spinner replaces label, 16dp spinner + "Confirming…")
2. `POST /reservations` fires
3. Navigation waits for response (or 202 Accepted — see §5)

**Button disabled conditions:**
- No time slot selected
- Wallet balance insufficient (if reservation fee applies)
- KYC not approved (button disabled, replaced with "Complete Identity Verification First" — see §20)

---

## 5. Reservation Confirmation Screen

### Design intent

The confirmation screen bridges the gap between "I tapped Confirm" and "the reservation is locked in." Because `POST /reservations` may return 202 Accepted before the reservation is fully processed, the user needs a loading state that feels purposeful — not a blank screen with a spinner.

### Entry

The creation screen's Confirm button transitions to loading, and the screen navigates (push) to the Confirmation screen simultaneously. The creation screen slides left (LTR) and the confirmation screen slides in from the right.

### Pending state layout (202 received, processing)

```
┌────────────────────────────────────────────────────────────┐
│  ← Back                                                    │
│  Confirming Reservation                                    │
├────────────────────────────────────────────────────────────┤
│                                                            │
│               [Animated confirmation graphic]              │
│                                                            │
│           Three arcing dots converging to a center         │
│           point, `color.primary`, 120dp container          │
│           Animation: 1.8s loop, ease-in-out                │
│                                                            │
│                Reserving your spot…                        │
│          type.headline.small, color.text.primary           │
│                                                            │
│                Elm Street Charging Hub                     │
│          type.body.medium, color.text.secondary            │
│                CCS DC Fast · 3:30 PM today                 │
│          type.body.medium, color.text.secondary            │
│                                                            │
│  ─────────────────────────────────────────────────────     │
│                                                            │
│  This usually takes a few seconds.                         │
│  type.body.small, color.text.tertiary, centered            │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

**The "Back" button on this screen:** Present but with a warning tooltip on tap: "Going back will not cancel your reservation request. It may still be confirmed." This communicates that the request is in-flight and cannot be recalled by navigating back.

### Confirmed state (Pending → Confirmed)

On receiving the confirmation WebSocket event (or polling response):

The animated graphic transitions (600ms):
- Three dots merge into a single ✓ checkmark, `color.secondary` (#00D68F)
- Scale animation: 0.5 → 1.0, spring physics, 300ms
- Ripple: a circle expands from the checkmark, `color.secondary` at 20% opacity, radius 0 → 48dp, 400ms ease-out

Text updates (cross-fade, 200ms):
- Title: "Reservation Confirmed" `type.headline.small`, `color.text.primary`
- Station details remain unchanged

After 800ms dwell time on the confirmed state: automatically navigates forward to the Reservation Success screen (§6). The user is not required to tap anything.

### Conflict state (connector taken during processing)

If the server responds with a conflict (the connector was taken by another user between the pre-confirmation sheet and the POST arriving):

Graphic: three dots stop, one fades — visual interruption.

```
  [Warning icon 48dp, color.warning]

  Connector just reserved by someone else
  type.headline.small

  The CCS connector at Elm Street was taken
  while we were confirming. Choose another.
  type.body.medium, color.text.secondary

  [  Select Different Connector  ]  ← Primary Large
  [  View Available Stations    ]  ← Secondary
```

"Select Different Connector" pops back to the Station Details screen with the connector cards refreshed.

---

## 6. Reservation Success Screen

### Design intent

The success screen is the moment of committed delight — the user has secured a connector. The design must communicate three things instantly: "You're confirmed, here's what you reserved, and here's how to track it."

### Layout

```
┌────────────────────────────────────────────────────────────┐
│  ✕ (close, ends the creation flow, returns to Tab 2)       │  ← Nav bar
├────────────────────────────────────────────────────────────┤
│                                                            │
│              ✓                                             │
│        (64dp, color.secondary)                             │
│        Scale animation on enter: 0.3 → 1.0, spring 400ms  │
│                                                            │
│           Reservation confirmed!                           │
│        type.headline.large, color.text.primary, centered   │
│                                                            │
│                                                 ┌──────┐   │
│  ┌────────────────────────────────────────────┐ │ Add  │   │
│  │  Elm Street Charging Hub                   │ │ to   │   │
│  │  CCS DC Fast · Connector 3                 │ │ Cal. │   │  ← Reservation card
│  │  ─────────────────────────────────────────  │ └──────┘   │
│  │  ⏰  Today, 3:30 PM – 4:00 PM              │            │
│  │  ⏱  30-min check-in window                 │            │
│  │  💳  ¥60/kWh (locked)  ·  Free to cancel   │            │
│  └────────────────────────────────────────────┘            │
│                                                            │
│  ─── You'll be notified ────────────────────────────────   │
│                                                            │
│  🔔  35 min before — "Head to the station"                 │
│  🔔  10 min before — "Almost time"                         │
│  🔔  When window opens — "Check in now"                    │
│  🔔  15 min into window — "Don't forget to check in"       │
│                                                            │
│  ─────────────────────────────────────────────────────     │
│                                                            │
│  ┌────────────────────────────────────────────────────┐   │
│  │          View Reservation                          │   │  ← Primary
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │          Back to Map                               │   │  ← Secondary
│  └────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────┘
```

### Reservation summary card

This card is the anchor of the success screen. It must be immediately scannable.

- Background: `color.surface`, `radius.xl` (20dp)
- Border: 1.5dp `color.tertiary` (reservation purple — the first time this screen uses the reservation color)
- Elevation: 2

**Station identity row:** Station name, `type.headline.small`. Connector type + number, `type.body.medium`, `color.text.secondary`.

**Date/time row:** ⏰ icon (16dp, `color.tertiary`) + formatted date/time range: "Today, 3:30 PM – 4:00 PM" (start time + start time + window duration). `type.title.medium`, `color.text.primary`.

**Window row:** ⏱ icon + "[N]-min check-in window". `type.body.medium`, `color.text.secondary`.

**Policy row:** 💳 icon + price + separator dot + cancellation policy summary. `type.body.medium`, `color.text.secondary`.

**"Add to Calendar" icon button (top-right corner of card):**
- 44dp × 44dp, `radius.md`
- Calendar icon 20dp, `color.primary`
- Tapping exports an ICS calendar event via the system share sheet
- Calendar event title: "Charge at [Station Name]"
- Calendar event details include address, time, connector type

### Notification preview list

A non-interactive list showing the push notifications the user will receive. This builds confidence that the app will remind them. Each row: 🔔 icon + notification description, `type.body.medium`, `color.text.secondary`.

**Push notification permission check:** If the user has denied push notification permission, this list is replaced with an amber banner:
- "Enable notifications to get reminders" `type.body.medium`
- "Enable" Tertiary button → opens device notification permission settings
- Without notifications, the user must rely on manually checking the app

### CTA buttons

"View Reservation" → navigates to the Reservation Detail screen for this reservation.
"Back to Map" → pops the entire creation stack and returns to Tab 1 (Map/Home).

The ✕ in the nav bar does the same as "Back to Map" — it closes the creation flow without opening the detail.

---

## 7. Reservations List Screen (Tab 2)

This screen is the home for all of the user's reservations across all states. It is the second tab of the bottom navigation.

### Tab badge behavior

The Reservations tab badge (see Design System §9):
- Shows a count badge (red, numbered) when there are ≥1 upcoming confirmed reservations
- Shows a pulsing amber dot (no count) when a reservation is in Active state (window is open, check-in required)
- Shows no badge when all reservations are historical (Completed/Cancelled/Expired)

The amber pulse badge takes priority over the red count badge — an open check-in window is more urgent than an upcoming count.

### Screen layout

```
┌────────────────────────────────────────────────────────────┐
│  Reservations                              [+ New]         │  ← Nav bar
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [Active · Upcoming · Past] (segment control)              │  ← Filter
│                                                            │
│  ── ACTIVE ────────────────────────────────────────────    │  ← Section (if any)
│  ┌──────────────────────────────────────────────────────┐  │
│  │  URGENT  ⏰ 18:24 remaining                 [↗ Go]  │  │  ← Active reservation card
│  │  Elm Street Charging Hub · CCS · Connector 3         │  │
│  │  [Check In Now]                                      │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
│  ── UPCOMING ──────────────────────────────────────────    │  ← Section (if any)
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Today  3:30 PM                           1h 12m →  │  │  ← Upcoming card
│  │  City Center Charge Hub · Type 2 · Connector 7       │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Sat 14 Jun  11:00 AM                     3d 5h →   │  │
│  │  Highway Stop A4 · CCS · Any connector              │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
│  ── PAST ──────────────────────────────────────────────    │  ← Section (if any)
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Yesterday  2:15 PM  ✓ Charged                      │  │  ← Past card (Completed)
│  │  Elm Street Charging Hub · CCS                       │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Mon 9 Jun  5:00 PM  ✗ Expired                      │  │  ← Past card (Expired)
│  │  North District Park · Type 2                        │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

### Segment control (filter)

Three segments: "Active & Upcoming" (default tab) · "Past". The "Active & Upcoming" segment combines both active and upcoming reservations into a single scrollable list, sectioned as shown above. "Past" shows only historical (Completed, Cancelled, Expired, NoShow).

The segment control is not shown at all when there are no reservations of any kind (empty state shown instead — see §23).

**"+ New" button:** Tertiary, `color.primary`, top-right. Navigates to station selection for a new reservation. In MVP, this opens the Map/Home screen so the user can find a station. A tooltip on first tap: "Find a station on the map to reserve a connector."

### Active reservation card (window is open — urgent)

This card has a distinct visual treatment to communicate urgency:

```
  ┌──────────────────────────────────────────────────────┐
  │  [amber left accent bar]                             │
  │  ⚡ CHECK IN NOW             ⏰ 18:24 remaining      │
  │  Elm Street Charging Hub                      [↗]   │
  │  CCS DC Fast · Connector 3                           │
  │  ─────────────────────────────────────────────────   │
  │  [Check In Now]     [Cancel Reservation]             │
  └──────────────────────────────────────────────────────┘
```

- Background: `color.warningContainer` (amber tint)
- Left accent bar: 4dp wide, full card height, `color.warning`
- Border: 1.5dp `color.warning`
- Countdown: live, ticking, `type.numeric.large`, `color.warning`
- "CHECK IN NOW" label: `type.label.small`, letter-spaced, `color.warning`
- Station + connector: `type.title.medium` + `type.body.medium`
- ↗ Navigate icon: 28dp circle button, `color.surface`, shadow elevation 2
- "Check In Now" → Primary Medium, `color.secondary` background (green — positive action)
- "Cancel Reservation" → Tertiary, `color.error` text, 32dp Small

**Under 15 minutes remaining:** The card becomes more urgent:
- Background transitions to `color.errorContainer`
- Left accent bar: `color.error`
- Border: `color.error`
- Countdown color: `color.error`

### Upcoming reservation card (window not yet open)

```
  ┌──────────────────────────────────────────────────────┐
  │  Today  3:30 PM                            in 1h 12m │
  │  City Center Charge Hub                         [↗]  │
  │  Type 2 AC · Connector 7 · ¥45/kWh                   │
  └──────────────────────────────────────────────────────┘
```

- Background: `color.surface`
- Border: 1dp `color.outline` at 30% opacity
- Top-left: day + date, `type.label.large`, `color.tertiary` (reservation purple)
- Trailing: "in [time]" countdown, `type.label.large`, `color.text.secondary` (not live-ticking — updates on screen resume, not every second; the countdown on the list is non-live except for Active cards)
- Station name: `type.title.medium`, `color.text.primary`
- Connector info: `type.body.small`, `color.text.secondary`
- ↗ Navigate icon: 28dp circle button, `color.surface`, shadow elevation 2

Tap anywhere on the card (except ↗): navigates to Reservation Detail screen.
Tap ↗: opens native maps to the station address.

### Past reservation cards

**Completed:**
- Background: `color.surface`
- Status badge: ✓ (16dp, `color.secondary`) + "Charged" `type.label.large`, `color.secondary`
- Date, station, connector: standard text hierarchy
- No CTA on the card

**Expired / NoShow:**
- Background: `color.surface`
- Status badge: ✗ (16dp, `color.warning`) + "Expired" `type.label.large`, `color.warning`
- Dimmed content: station and connector text at 70% opacity

**Cancelled:**
- Background: `color.surface`
- Status badge: ✗ (16dp, `color.text.tertiary`) + "Cancelled" `type.label.large`, `color.text.tertiary`
- All content at 70% opacity

---

## 8. Reservation Detail Screen

The detail screen shows a single reservation in full. It is the primary management surface for an individual reservation.

### Route

`/reservations/:id` — pushed from the list, from the success screen, or from a notification tap.

### Header

Collapsing header, same pattern as Station Details screen (§5 of STATION_DETAILS_SCREEN.md).

At scroll position 0: transparent, station name in title hidden. At scroll 120dp+: fully opaque, station name in title.

The gallery section from Station Details is replaced with a **status hero** — a full-width, 200dp tall block whose design varies per state.

### Status hero designs

**Confirmed (upcoming):**
- Background: gradient from `color.tertiaryContainer` to `color.surface`, top to bottom
- Large `color.tertiary` calendar icon (64dp) centered
- "[Time remaining]" countdown, `type.numeric.large`, `color.tertiary` (not live-ticking — updates on resume)
- "[Date], [time]" below in `type.title.medium`, `color.text.primary`

**Active (window open):**
- Background: gradient from `color.warningContainer` to `color.surface`
- Animated ⏰ icon (64dp), `color.warning`, with a gentle shake animation (3° left-right, 1.5s period)
- Live countdown in `type.numeric.display` (48sp), `color.warning` — ticking every second
- "Check in before [expiry time]" in `type.body.medium`, `color.text.secondary`

**Completed:**
- Background: gradient from `color.secondaryContainer` to `color.surface`
- ✓ checkmark (64dp), `color.secondary`
- "Charged successfully" `type.headline.small`, `color.text.primary`

**Expired/NoShow:**
- Background: gradient from `color.warningContainer` to `color.surface`
- ✗ icon (64dp), `color.warning`
- "Reservation expired" `type.headline.small`, `color.warning`
- If no-show fee applied: "¥[amount] no-show fee deducted" `type.body.medium`, `color.error`

**Cancelled:**
- Background: `color.surfaceVariant`
- ✕ icon (64dp), `color.text.tertiary`
- "Reservation cancelled" `type.headline.small`, `color.text.secondary`
- If refund applied: "¥[amount] refunded to wallet" `type.body.medium`, `color.secondary`

### Scrollable content sections

**Station information block (80dp):**
Same as Station Details station info card (§8 of STATION_DETAILS_SCREEN.md) — station name, address, operator, distance, navigate button.

**Reservation parameters block:**
Grid of key-value rows:

| Key | Value |
|-----|-------|
| Date & time | [Formatted date], [start time] |
| Check-in window | [N] minutes (until [expiry time]) |
| Connector | [Type] · Connector [N] · [Power] kW |
| Booked charging rate | ¥[rate]/kWh (locked at booking) |
| Reservation fee | Free / ¥[amount] (paid) |
| Reservation ID | [Short ID] (long-press to copy) |
| Created | [Date and time of creation] |

**Active-state action block (only shown when state is Confirmed or Active):**

For Confirmed:
- "Cancel Reservation" — Secondary, full-width, `color.error` border + text
- "Extend Reservation" — Tertiary (only if operator allows extensions)

For Active:
- "Check In Now" — Primary Large, full-width, `color.secondary` background
- "I Can't Make It — Cancel" — Tertiary, `color.error` text, below

**Completed-state block:**
- "View Charging Session" — Secondary, links to the Charging Session screen for the resulting session
- "View Receipt" — Tertiary, links to wallet transaction detail

**Expired-state block:**
- "Find Nearby Station" — Secondary, opens Map tab
- "Contact Support" — Tertiary, for billing disputes

---

## 9. Reservation Countdown Behavior

### Countdown types

Three distinct countdown displays appear at different points in the reservation lifecycle:

| Context | Countdown subject | Update frequency | Format |
|---------|------------------|-----------------|--------|
| Success screen | Time until reservation start | On screen resume (not live) | "in 1h 27m" |
| List screen (upcoming cards) | Time until reservation start | On screen resume | "in 1h 27m" |
| List screen (active card) | Time remaining in window | Every second (live) | "27:43" |
| Detail screen (confirmed) | Time until reservation start | Every minute (live) | "1h 27m" |
| Detail screen (active) | Time remaining in window | Every second (live) | "27:43" |
| App nav badge | Active state presence | Event-driven | Pulse dot |

### Live countdown implementation contract

The live countdown (active state, ticking per second) is **client-side only** — it is not server-pushed. The expiry time (`reservation.windowExpiresAt`) is received from the server. The client calculates remaining seconds as `windowExpiresAt − now` and decrements every second.

**Drift correction:** On every WebSocket message pertaining to this reservation, the expiry time is re-confirmed against the server timestamp. If the client clock has drifted by >5 seconds from the server, the countdown silently re-syncs. No visible jump — the correction is absorbed into the next second's decrement.

### Countdown display format

**More than 60 minutes remaining:**  
Format: "1h 27m" — hours and minutes only. No seconds. `type.numeric.large` (32sp/700), `color.tertiary`.

**15–60 minutes remaining:**  
Format: "27:43" — MM:SS. `type.numeric.large`, `color.tertiary`.

**Under 15 minutes remaining:**  
Format: "12:34" — MM:SS. `type.numeric.large`, `color.warning`. This color change signals urgency without text.

**Under 5 minutes remaining:**  
Format: "4:12" — MM:SS. `type.numeric.display` (48sp/700), `color.error`. The font size increases — the urgency intensifies. The countdown on the detail screen's status hero begins a slow pulse animation: opacity 100% → 75% → 100%, 1.5s period.

**Expired (00:00):**  
The countdown shows "0:00" for exactly 2 seconds, then transitions to the Expired state UI (§10).

### Countdown on the lock screen (via notification)

The push notification at window-open time includes a live countdown in the notification content. On iOS (via `NSUserActivity` / Live Activities) and Android (via `LiveData` notifications), the lock-screen notification updates the remaining time every minute without requiring an additional push. This is the most ambient form of countdown — the user sees it without opening the app.

On platforms that do not support live notification updates, the notification body shows a static: "You have until [HH:MM] to check in."

---

## 10. Reservation Expiry Behavior

### Expiry trigger

The reservation window expires at `reservation.windowExpiresAt`, which equals `reservation.startTime + window.durationMinutes`. This is a server-side event — the server transitions the reservation to `Expired` (or `NoShow`) and fires a WebSocket event.

### UI transition on expiry

If the user is on the Reservation Detail screen when the expiry occurs:

1. Countdown hits "0:00", holds for 2 seconds
2. The status hero animates a transition (300ms):
   - The warning amber background transitions to `color.warningContainer`
   - The ⏰ icon transitions to a ✗ icon, same size
   - Countdown fades out (200ms), replaced by "Expired" label (200ms fade-in)
3. The action block below changes: "Check In Now" and "Cancel" are replaced by the Expired action block (Find Nearby Station, Contact Support)
4. An in-app toast appears (not a blocking modal): "Your reservation has expired. Connector released back to available." — auto-dismisses 5s.

If the user is **not** on the Reservation Detail screen:
- Push notification fires: "Your reservation at [Station] has expired. The connector has been released." (see §15 for full notification spec)
- Tab badge updates: removes the active-state amber pulse dot
- List card transitions to Expired state on next resume

### Expiry with no-show fee

If the operator has configured a no-show fee and the reservation expires without check-in:
- The server deducts the fee from the wallet atomically (wallet append-only ledger, idempotent)
- A push notification fires immediately on expiry: "Reservation expired. ¥[amount] no-show fee deducted."
- The Expired state hero shows the fee deduction prominently
- The wallet shows a transaction: "No-show fee — [Station] reservation"

**If wallet balance is insufficient for the no-show fee:**
- The deduction fails gracefully: the reservation is expired but the fee is not collected
- No negative wallet balance is created
- A note in the expired state: "No-show fee could not be charged (insufficient balance)" in `color.warning`

### Expiry on a past reservation (app was closed)

When the user opens the app after a reservation has expired while offline or app-closed:
1. The `AppStartGuard` detects no active session, no active window
2. The reservation state shows as Expired from the server response
3. If a no-show fee was deducted, the wallet balance has already been updated
4. The user lands on their default tab and sees the reservation list showing the expired card

---

## 11. Reservation Cancellation Flow

### Cancellation entry points

1. "Cancel Reservation" button on the Reservation Detail screen
2. "I Can't Make It — Cancel" button on the Reservation Detail screen (Active state)
3. Long-press on a reservation card in the list → context menu → "Cancel"
4. The cancellation banner in the 5-minute warning notification

### Cancellation confirmation sheet

A bottom sheet — not a full-screen navigation — confirms the cancellation. The sheet must prevent accidental cancellations while making intentional cancellations fast.

**Sheet height:** 380dp + safe area.

```
  ──── (handle)

  Cancel reservation?
  type.headline.small

  ─── What you're cancelling ───────────────────────────

  Elm Street Charging Hub
  type.title.medium

  CCS DC Fast · Today, 3:30 PM – 4:00 PM
  type.body.medium, color.text.secondary

  ─── Cancellation policy ──────────────────────────────

  [Policy display — see policy variants below]

  ──────────────────────────────────────────────────────

  [  Yes, Cancel Reservation  ]  ← Primary (color depends on policy)
  [  Keep My Reservation     ]  ← Tertiary
```

### Policy display variants within the sheet

**Free cancellation (>N hours before start):**
```
  ✓ Free cancellation                color.secondary
  No charge applies.
  type.body.medium, color.text.secondary
```
Primary button: `color.primary` background. The action feels safe.

**Cancellation fee applies:**
```
  ⚠ Cancellation fee                 color.warning
  ¥500 will be deducted from your wallet.
  Remaining balance after: ¥49,500
  type.body.medium, color.text.secondary
```
Primary button: `color.error` background (Destructive Filled). The action has cost.

**Non-refundable (paid reservation fee, now within no-refund window):**
```
  ⚠ No refund                        color.error
  Your ¥1,000 reservation fee is non-refundable.
  Cancelling will forfeit this payment.
  type.body.medium, color.text.secondary
```
Primary button: `color.error` background. Additionally, an inline "Are you sure?" secondary confirmation is required — after tapping the red button, it changes to: "Tap again to confirm" for 2 seconds, then returns to its original label. This two-tap confirmation only applies when the user is forfeiting a paid amount.

**Active window (within check-in window, cancelling with time remaining):**
```
  ⚠ Window is open                   color.warning
  Your reservation is active right now.
  The connector will be released immediately.
  type.body.medium, color.text.secondary
```
+ A note: "If you're at the station, use the physical connector or tap Check In instead."

### After cancellation confirmed

On "Yes, Cancel Reservation":
1. Sheet primary button enters loading state (spinner)
2. `PATCH /reservations/:id/cancel` fires
3. On success (200 OK):
   - Sheet slides down (220ms)
   - Reservation Detail hero transitions to Cancelled state (300ms)
   - If cancellation fee was applied: wallet balance updates; a brief toast confirms "¥[amount] deducted"
   - If reservation fee refund: "¥[amount] refunded to wallet" toast
4. On failure:
   - Sheet remains open
   - Error banner within sheet: "Cancellation failed. Please try again." with "Retry" Tertiary button

### Operator-initiated cancellation

If the station reports a fault or the operator cancels the reservation from their system, a push notification fires: "Your reservation at [Station] was cancelled by the operator. [No fee applied / ¥X refunded]."

The reservation detail transitions to Cancelled state. The Cancelled hero includes: "Cancelled by operator — no charge applied to you." `type.body.medium`, `color.text.secondary`.

---

## 12. Reservation Modification and Extension Flow

### Extension eligibility

Extensions are only available if:
1. The reservation is in Confirmed state (not Active, not within the window)
2. The operator has enabled extensions (`extensionPolicy: allowed`)
3. The new end time does not conflict with another reservation in the slot
4. The user has not already extended this reservation (operators may limit to one extension per reservation)

### Extension entry point

"Extend Reservation" Tertiary button on the Reservation Detail screen. Only visible when extension is eligible.

### Extension sheet (320dp height)

```
  ──── (handle)

  Extend reservation
  type.headline.small

  Current end time:      Today, 4:00 PM
  New end time:          Today, 4:30 PM     (+30 min)

  ─── Extension options ────────────────────────────────

  [  +15 min  ] [  +30 min ●  ] [  +60 min  ]
                (selected, 44dp toggle)

  ─── Cost ─────────────────────────────────────────────

  Extension fee          Free / ¥[amount]
  New charging rate      ¥60/kWh (unchanged — locked)

  ──────────────────────────────────────────────────────

  [  Confirm Extension  ]  ← Primary Large
  [  Cancel            ]  ← Tertiary
```

**Extension time options:** Operator-configured. Common options: +15 min, +30 min, +60 min. The 30-min option is pre-selected as the default. Options that would conflict with existing reservations are greyed out.

**Price:** If the operator charges for extensions, the fee is shown per option (e.g., "+30 min — ¥200"). If extensions are free, "Free" is displayed for all options.

**Confirm button behavior:** Same pattern as the reservation creation confirm — enters loading on tap, `PATCH /reservations/:id/extend` fires. On success: sheet closes, Reservation Detail screen updates the time and countdown.

### Direct date/time change (not supported in MVP)

Full rescheduling (changing the date or start time, not just extending the window) is not supported in MVP. The user must cancel and re-reserve. The cancellation sheet includes a note when this scenario is likely: "To change your time, cancel this reservation and create a new one. Cancellation is free until [time]."

---

## 13. Reservation Fees and Policies

This section defines how all fee-related information is communicated across every screen where it appears.

### Fee types

| Fee type | Description | When deducted |
|----------|-------------|--------------|
| Reservation fee | Flat fee to hold a connector | At confirmation (if paid reservation) |
| Cancellation fee | Penalty for late cancellation | At cancellation confirmation |
| No-show fee | Penalty for expiry without check-in | At window expiry |
| Extension fee | Cost of extending the window | At extension confirmation |
| Session charges | Energy + time fees from charging | At session end (from TariffSnapshot) |

### Policy transparency rules

1. **Every fee must appear before it is charged.** No fee surprises. The creation screen shows the reservation fee and cancellation policy. The cancellation sheet shows any cancellation fee before it is deducted. The expired screen shows any no-show fee immediately.

2. **Policy language is plain and specific.** Not "standard cancellation policy applies" — always the specific amount and threshold: "Free if cancelled before 1:30 PM · ¥500 fee after 1:30 PM · ¥1,000 no-show fee."

3. **The tariff is locked.** The creation screen shows: "¥60/kWh (locked at booking)" with a visual lock icon (12dp) next to the rate. This guarantees the price does not change between booking and charging.

4. **Refunds are confirmed in the UI.** If a cancellation or operator action results in a wallet credit, the amount is shown prominently on the cancellation/expired screen and in a toast. The user is never left wondering whether they were refunded.

### Policy display format

Used wherever cancellation policy appears (creation screen, success screen, detail screen, cancellation sheet):

| Scenario | Display |
|---------|---------|
| Always free | "Free cancellation anytime" |
| Free until threshold | "Free cancellation until [time] · ¥[amount] fee after" |
| Always paid | "Non-refundable · ¥[fee] reservation fee" |
| No-show fee only | "Free cancellation · ¥[amount] no-show fee if missed" |
| Full policy | "Free until [time] · ¥[cancel fee] after · ¥[no-show fee] if missed" |

---

## 14. Wallet Interaction

### Wallet checks during reservation lifecycle

**At creation (before Confirm tap):**
- If reservation fee > ¥0: check wallet balance ≥ reservation fee. Warn if insufficient.
- If no reservation fee: no check at creation. The wallet is only debited at session end.

**At session start (from reservation check-in):**
- Check wallet balance ≥ minimum session amount (operator-configured, typically ¥1,000–¥2,000)
- If insufficient: session cannot start. Show: "Insufficient wallet balance to start charging. Top up ¥[amount] to begin." with "Top Up" Primary button.

**At expiry (no-show fee):**
- Server deducts atomically if balance sufficient
- If insufficient: fee not collected (no overdraft)

**At cancellation (cancellation fee):**
- Server deducts atomically before confirming cancellation
- If insufficient: cancellation cannot proceed — show error: "Cannot cancel: insufficient balance for the ¥[amount] cancellation fee. Add funds or wait for the reservation to expire (no-show fee: ¥[amount])."
- Note: this creates a difficult UX situation (the user cannot cancel without funds). The design must present both options honestly.

### Wallet integration display rules

Wallet balance is shown on:
- Reservation creation screen (pricing section, if any fee applies)
- Cancellation confirmation sheet (if cancellation fee applies)
- Extension sheet (if extension fee applies)
- Session start confirmation sheet (§17 for minimum balance check)

Wallet balance is **not** shown on:
- Reservation list cards (no room; not relevant to list-level decisions)
- Countdown display (not relevant during countdown)

Wallet balance format: `CurrencyFormatter.format(balanceCents, locale)` — always uses the full formatter, never a raw number.

---

## 15. Push Notification Strategy

Notifications are the off-screen arm of the reservation system. They carry the countdown and urgency to the user's lock screen and wrist.

### Notification channels

Two channels (configurable in device settings):
1. **Reservation reminders** — non-urgent, dismissable, standard sound
2. **Reservation urgent** — urgent, louder/vibration, used for window-open and under-5-min alerts

### Notification catalog

| ID | Trigger | Channel | Title | Body |
|----|---------|---------|-------|------|
| `res.created` | Reservation confirmed | Reminders | "Reservation confirmed" | "CCS at Elm St · Today, 3:30 PM · 30-min window" |
| `res.reminder.24h` | T−24 hours | Reminders | "Charging tomorrow" | "[Station] at [time]. Wallet balance: ¥[amount]" |
| `res.reminder.1h` | T−60 min | Reminders | "1 hour until your charge" | "[Station] at [time]. Leave with enough time." |
| `res.reminder.35min` | T−35 min | Reminders | "Head to the station" | "Your reservation at [Station] starts in 35 min" |
| `res.reminder.10min` | T−10 min | Urgent | "Almost time" | "[Station] reservation in 10 minutes" |
| `res.window.open` | T+0 (window opens) | Urgent | "Check in now" | "Your [connector] reservation is active. 30 min to check in." |
| `res.window.15min` | T+15 min (mid-window) | Urgent | "15 minutes left" | "Check in at [Station] before [expiry time]" |
| `res.window.5min` | T+25 min (5 min left) | Urgent | "5 minutes! Cancel if needed" | "Last chance — or cancel to avoid no-show fee" |
| `res.expired` | Window expires | Urgent | "Reservation expired" | "Connector released. [No-show fee: ¥X applied]" |
| `res.cancelled.user` | User cancels | Reminders | "Reservation cancelled" | "Refund: ¥[amount]" or "No charge" |
| `res.cancelled.operator` | Operator cancels | Urgent | "Operator cancelled your reservation" | "[Station] cancelled your booking. Refund: ¥[amount]" |
| `res.extended` | Extension confirmed | Reminders | "Reservation extended" | "New window end: [time]" |

### Notification actions (deep-link taps)

All reservation notifications deep-link to the Reservation Detail screen on tap. The notification body itself contains enough context to inform the user without opening the app.

**Action buttons on notifications (OS-supported):**

`res.window.open` notification: "Check In →" action button (foreground app action) + "Cancel" action button (background).

`res.window.5min` notification: "Open App" + "Cancel Reservation" (background).

`res.expired` notification: "Find Nearby Station" (opens Map tab).

### Notification opt-out

Individual notification types can be disabled in the app's Settings screen (not designed in this document). The minimum set that should strongly be recommended as enabled: `res.window.open`, `res.window.5min`, `res.expired`. The app prompts to enable at least these three when a reservation is confirmed (via the success screen's notification preview section, §6).

---

## 16. Reminder Schedule

The full reminder timeline for a reservation with a 3:30 PM start time and 30-minute window:

```
   CREATION
   2:03 PM  ─── res.created notification

   ADVANCE REMINDERS (if >24h ahead, else skip to same-day)
   Previous day 3:30 PM  ─── res.reminder.24h

   SAME-DAY APPROACH
   2:30 PM  ─── res.reminder.1h  (T−60 min)
   2:55 PM  ─── res.reminder.35min (T−35 min)
   3:20 PM  ─── res.reminder.10min (T−10 min)

   WINDOW OPEN
   3:30 PM  ─── res.window.open  → countdown starts
   3:45 PM  ─── res.window.15min (T+15)
   3:55 PM  ─── res.window.5min  (T+25)

   EXPIRY
   4:00 PM  ─── res.expired
```

**Adaptive scheduling:** If the reservation is created with less than 35 minutes before start time, the 1h and 35-min reminders are skipped. If created with less than 10 minutes: only the window-open notification fires.

**User-in-app suppression:** If the user is actively viewing the Reservation Detail screen when a notification would fire, the notification is suppressed (the countdown on screen is sufficient). The badge count still updates.

---

## 17. Check-In Process at Station

Check-in is the physical-digital handoff — the moment the user's digital reservation becomes a physical charging session.

### Check-in trigger options

The user initiates check-in through one of three paths:
1. **"Check In Now" button** — on the Reservation Detail screen or the active card in the list
2. **Notification action** — "Check In →" action on the `res.window.open` notification
3. **Automatic (cable-triggered, future)** — via OCPP 2.x / ISO 15118 Plug & Charge (see §28)

In MVP, all check-in is user-initiated from the app (paths 1 and 2).

### Check-in confirmation sheet (on "Check In Now" tap)

A bottom sheet appears before the session is started — giving the user one final moment to confirm they are physically at the station with the cable ready.

**Sheet height:** 360dp + safe area.

```
  ──── (handle)

  Ready to charge?
  type.headline.small

  ─── Confirm you're at the station ───────────────────

  [Station icon 48dp, color.primary]

  Elm Street Charging Hub
  type.title.medium, centered

  Connector 3 · CCS DC Fast · 150 kW
  type.body.medium, color.text.secondary, centered

  ─── Before you start ────────────────────────────────

  ✓ Connect the charging cable to your vehicle
  ✓ Ensure the connector is seated securely

  type.body.medium, color.text.secondary (checklist style)

  ─── Pricing confirmed ───────────────────────────────

  ¥60/kWh (booked rate — locked)
  Wallet balance: ¥50,000 ✓ Sufficient
  type.body.small, color.text.secondary

  ──────────────────────────────────────────────────────

  [  Start Charging  ]  ← Primary Large (color.secondary background, bold)
  [  Not Ready Yet  ]  ← Tertiary
```

**"Start Charging" button:** Uses `color.secondary` (#00D68F) background — the charging-positive green, not the generic blue. This reinforces "I am starting to charge" rather than just "I am confirming."

**"Not Ready Yet":** Dismisses the sheet. The reservation remains Active. The countdown continues. The user can tap "Check In Now" again when ready.

### Check-in when wallet balance is insufficient

If the wallet balance is below the minimum session amount when the check-in sheet opens:

```
  ⚠ Wallet balance insufficient                color.error

  You need ¥2,000 minimum to start a session.
  Current balance: ¥1,200

  [  Top Up Wallet  ]  ← Primary Large
  [  Not Now       ]  ← Tertiary
```

The "Start Charging" button is hidden entirely — not disabled. The wallet top-up CTA is primary. On top-up success: the sheet refreshes and shows the normal check-in confirmation.

### Check-in window boundary

If the user taps "Check In Now" with less than 5 minutes remaining in the window:
- The check-in sheet includes a prominent warning: "⚠ 4:12 remaining — act quickly", `color.error`, above the "Start Charging" button
- The reservation window countdown is still visible in a mini-format within the sheet header

If the window expires while the check-in sheet is open:
- Sheet transitions in-place to an expiry state: "The reservation window has just expired." with "Close" CTA
- No charge is made; the session did not start

---

## 18. Reservation-to-Session Handoff

The handoff is the moment the reservation record closes and the charging session record opens. The UI must make this transition invisible to the user — they tap "Start Charging", and the next thing they see is the Charging Session screen with the session already beginning.

### Handoff sequence

1. User taps "Start Charging" in the check-in sheet
2. Button enters loading state (spinner)
3. `POST /sessions/start` fires with `reservationId` in the request body
4. Server creates the session, closes the reservation (status → Completed), sends OCPP RemoteStartTransaction
5. Server returns 202 Accepted with `sessionId`
6. App receives 202: navigates to `/charging/:sessionId` (the Charging Session screen)
7. Check-in sheet slides down (220ms) simultaneously with the Charging Session screen sliding up from the bottom
8. The reservation is now Completed; the Charging Session screen is in Preparing/Authorizing state (§10, §11 of CHARGING_SESSION_SCREEN.md)

**The Reservation Detail screen is no longer in the navigation stack after handoff.** If the user presses back from the Charging Session screen, they return to the Reservations List (Tab 2), not the Reservation Detail.

### Reservation visibility after handoff

The completed reservation is still accessible from:
- The Reservations List "Past" section
- A "View Reservation" link on the Charging Session completed screen
- A "View Receipt" link in the wallet

The Reservation Detail screen in its Completed state (§8) includes a "View Charging Session" Secondary button that links to the resulting session.

### Handoff failure (session start fails)

If `POST /sessions/start` returns an error:
- Check-in sheet remains open
- "Start Charging" button returns to its normal state
- Error banner appears within the sheet (above the button):
  - "Connector is no longer available — it may have been taken." → redirect to Station Details
  - "Charging station is offline." → retry guidance + operator contact
  - "Session already active on your account." → "View Session" button
  - Generic: "Something went wrong. Please try again."

The reservation remains in Active state until the window expires, giving the user time to retry or cancel.

---

## 19. Multiple Reservation Rules

### Concurrent reservation limits

In MVP: a user may hold a maximum of 1 active or upcoming reservation at any time. This limit is operator-network configurable — some premium network tiers may allow 2–3 concurrent reservations.

**UI enforcement:** When a user attempts to create a second reservation while one is already Confirmed or Active:
- The creation screen, at the point of tapping Confirm, shows a conflict sheet (not a full-screen error):

```
  ──── (handle)

  You already have a reservation
  type.headline.small

  [Station name] · [Time]   [View →]

  You can have 1 active reservation at a time.
  Cancel your existing reservation to book this one.
  type.body.medium, color.text.secondary

  [  Cancel Existing & Reserve New  ]  ← Primary (Destructive)
  [  Keep Existing Reservation     ]  ← Tertiary
```

"Cancel Existing & Reserve New" shows the cancellation policy for the existing reservation inline (the cancellation fee, if any) before the user proceeds. It then atomically cancels the old and creates the new.

### Reservation at the same station as an active session

A user with an active charging session may create a reservation at a different station. A user may not reserve a connector at the station where they currently have an active session — the check prevents the logical impossibility.

### Reservation at a different station from an active reservation

Blocked (per the 1-reservation limit). See above.

### Past-due reservation + new reservation

A reservation that has entered Expired or NoShow status but where the no-show fee has not yet been collected (insufficient wallet) does not block a new reservation creation. However, the creation screen displays a warning: "You have an unpaid no-show fee of ¥[amount]. This will be deducted when your wallet is topped up."

---

## 20. KYC Requirements

Reservations require an Approved KYC state. The creation flow's Confirm button is the guard point.

### KYC check on confirm

When the user taps "Confirm Reservation":
1. App checks the current `kycStatus` from `VerifiedJwtClaims` (the same guard used throughout the app — see ARCHITECTURE_FINAL.md §12)
2. If `Approved`: proceeds normally
3. If `Pending`, `NotStarted`, or `Rejected`: KYC sheet appears (same as Station Details §18)

The check happens at Confirm, not at screen entry. This allows the user to browse, explore the creation form, and understand the reservation before being prompted for KYC. The prompt at the moment of intent (tapping Confirm) is more contextually meaningful than a wall on entry.

### KYC sheet text customization for reservation context

The KYC prompt sheet text is slightly different from the charging context:

```
  [Shield icon 48dp, color.primary]

  Verify your identity to reserve
  type.headline.small, centered

  We verify your identity to ensure fair access
  to charging reservations. It takes about 2 minutes.
  type.body.medium, color.text.secondary, centered

  [  Verify Identity  ]  ← Primary Large
  [  Not now         ]  ← Tertiary
```

"Not now" returns focus to the creation screen. The form data the user entered (selected date, time slot) is preserved — when the user completes KYC and returns, the form is not reset.

---

## 21. Offline Behavior

### What the reservation system does offline

| Action | Offline behavior |
|--------|-----------------|
| View reservation list | Available from Hive cache; staleness indicator shown |
| View reservation detail | Available from cache |
| Countdown (upcoming) | Cannot show live countdown (no server time sync); shows "Check app when online" |
| Countdown (active window) | Client-side timer continues from cached expiry time |
| Create reservation | Not possible; creation tapped → error sheet |
| Cancel reservation | Not possible; cancellation tapped → error sheet |
| Check in (start session) | Not possible; "Start Charging" → error sheet |
| Receive notifications | Delivered by OS regardless of app state |

### Offline indicator

The same offline banner as used in Station Details (§22 offline behavior): 36dp bar, `color.surfaceVariant`, "Offline — showing cached data."

**On the active reservation countdown:** When offline during the window, the client-side timer continues ticking. A note appears below the countdown: "Timer may be slightly inaccurate while offline." The timer uses `windowExpiresAt` from cache — if the server has extended or modified the reservation while offline, the timer will be wrong. On reconnect, the timer re-syncs immediately.

**Critical offline scenario:** User is at the station, within the check-in window, and the app is offline. The "Check In Now" button shows: "Cannot check in while offline. Try connecting to the station's Wi-Fi or moving to a better signal area." Below: "If you have the physical card or app credentials, you may be able to start manually at the charger."

### Offline reservation creation attempt

```
  ──── (sheet triggered by Confirm tap)

  [cloud-offline icon 48dp, color.text.tertiary]

  No internet connection
  type.headline.small

  You need to be online to create a reservation.
  type.body.medium, color.text.secondary

  [  Try Again  ]  ← Primary Large
  [  Close     ]  ← Tertiary
```

---

## 22. Loading States

### Reservation list loading

Full skeleton: 3 card skeletons (stacked, each 80dp height, full border radius). Standard shimmer animation (LTR → RTL in fa locale). Resolves to real content or empty state within 2 seconds.

### Reservation detail loading

Top section skeleton: status hero (200dp gray block). Parameter rows: 6 skeleton key-value rows. No action buttons shown during load (they appear when state is known).

### Time slot grid loading

While the availability API is fetching: all slots shown with a neutral `color.surfaceVariant` background + shimmer. Slots are not tappable during load. A note below the grid: "Loading available times…" `type.body.small`, `color.text.tertiary`.

If the API does not respond within 3 seconds: slots default to "Available" appearance with a note: "Times shown as available — live data unavailable." `color.warning`.

### Confirm button loading

On Confirm tap: `type.label.large` label replaces with a 20dp spinner + "Confirming…" text. Button remains full-width, same height.

### Check-in loading (post-"Start Charging" tap)

"Start Charging" button: spinner + "Starting session…". Sheet remains open and non-interactive. If the server takes >3 seconds: add below the button: "Connecting to charger…" `type.body.small`, `color.text.tertiary`.

---

## 23. Empty States

### Reservations tab — no reservations ever

```
  [Illustration: EV with a calendar, 120dp, color.primary at 20%]

  No reservations yet
  type.headline.small, centered

  Reserve a connector in advance to guarantee
  your spot at any station.
  type.body.medium, color.text.secondary, centered

  [  Find a Station  ]  ← Primary Large
```

"Find a Station" → navigates to Tab 1 (Map/Home).

### Reservations tab — all reservations are past (no upcoming)

```
  [Illustration: checkmark calendar, 120dp, color.secondary at 20%]

  No upcoming reservations
  type.headline.small, centered

  Your past reservations are in the Past tab.
  Make a new reservation from any station.
  type.body.medium, color.text.secondary, centered

  [  Reserve at a Station  ]  ← Primary Large
```

### Reservations tab "Past" — no past reservations

```
  No past reservations
  type.title.medium, color.text.secondary, centered
  (simple text, no illustration — past empty is low-value context)
```

### Time slot grid — no available slots on a date

```
  [Within the grid container]

  No available slots on this day.
  All connectors are reserved for [Date].

  type.body.medium, color.text.secondary, centered (within grid area)
```

Below the grid, an affordance: "Try the next available day →" Tertiary link that advances the day selector and reloads the grid.

---

## 24. Error States

### Reservation creation — server error

If `POST /reservations` returns a server error (5xx):

```
  [Error icon 48dp, color.error]

  Reservation failed
  type.headline.small

  Something went wrong on our end.
  Please try again in a moment.
  type.body.medium, color.text.secondary

  [  Try Again  ]  ← Primary Large
  [  Back      ]  ← Tertiary
```

Shown on the Confirmation screen (§5), replacing the pending animation. The creation screen stack is preserved — "Back" returns to the creation screen with all form data intact.

### Reservation creation — slot taken (race condition)

If the time slot was taken between availability check and confirmation:

```
  The time slot was just reserved by someone else.
  type.headline.small

  Connector 3 at Elm Street Hub — 3:30 PM is now taken.
  type.body.medium, color.text.secondary

  [  Choose Another Time  ]  ← Primary Large
  [  Find Another Station ]  ← Secondary
```

"Choose Another Time" returns to the creation screen with the time grid refreshed and the conflicting slot now shown as Unavailable.

### Reservation detail — cannot load

Full-screen error matching the Station Details pattern (§21 of STATION_DETAILS_SCREEN.md). "Try Again" + "Back" CTAs.

### Cancellation error

Error banner within the cancellation sheet: "Cancellation failed. The reservation may have already expired. Refresh and try again." — "Refresh" Tertiary link that re-fetches the reservation state before re-showing the sheet.

### Wallet deduction error

When a reservation fee, cancellation fee, or no-show fee deduction fails on the server side, the user sees a generic notification: "Payment failed — please top up your wallet and try again." A push notification fires for wallet-related failures that occur in the background (no-show fee). The user is directed to the wallet screen to resolve.

---

## 25. Accessibility Requirements

### Screen reader structure

**Reservation list:** Announced as a list. Each card is a single focusable element with a comprehensive label before any individual sub-element focus.

Active card label: "Urgent. Reservation at Elm Street Charging Hub. Check-in window closes in 18 minutes 24 seconds. CCS DC Fast, Connector 3. Double-tap to view details or check in."

Upcoming card label: "Upcoming reservation. Today at 3:30 PM, in 1 hour 12 minutes. City Center Charge Hub, Type 2, Connector 7. Double-tap to view details."

Past card labels include status: "Completed reservation. Yesterday at 2:15 PM. Elm Street Charging Hub. Double-tap for details." or "Expired reservation. Monday June 9 at 5:00 PM. North District Park. Double-tap for details."

**Reservation detail:** Heading hierarchy — screen title (h1), section headers (h2), individual field labels (not headings — plain text).

**Countdown (live, active state):** The countdown is marked as a `LiveRegion` with `polite` priority. Every 60 seconds (not every second), the screen reader announces "Reservation time remaining: [MM:SS]." Every-second announcements would be unusable — the polite 60-second cadence gives the user time awareness without dominating the audio output.

**At under 5 minutes:** The LiveRegion priority changes to `assertive`. The announcement fires at each minute mark and at 60s, 30s, 10s.

**Check-in sheet:** Focus moves to sheet title on open. Checklist items ("Connect the charging cable") are read as static text, not interactive elements. "Start Charging" button label: "Start charging session at Elm Street Charging Hub, Connector 3." Focus returns to "Check In Now" button on sheet dismiss.

### Touch targets

All interactive elements: 44×44dp minimum.
- Time slot cells: 48dp height, minimum 72dp width — exceeds minimum in both dimensions
- Segment control segments: 44dp height
- Reservation list cards: 80dp minimum height — far exceeds minimum
- "Add to Calendar" icon button: 44dp circle explicitly

### Color independence

Every status uses both color AND a symbol:
- Active state: amber color + ⏰ icon + "CHECK IN NOW" text label
- Upcoming: tertiary/purple color + no urgency icon (absence is the signal)
- Completed: green color + ✓ symbol
- Expired: amber color + ✗ symbol
- Cancelled: grey color + ✕ symbol

No status is communicated by color alone.

### Focus management

- List → Detail: focus moves to the status hero heading on Detail screen entry
- Detail → Cancellation sheet: focus moves to sheet title
- Sheet dismiss (Cancel): focus returns to the "Cancel Reservation" button on Detail
- Sheet dismiss (Confirmed action): focus moves to the updated status (hero heading)
- Creation → Confirmation screen: focus moves to the in-progress status heading
- Confirmation → Success screen: focus moves to the ✓ checkmark region, announced as "Reservation confirmed" heading

---

## 26. RTL Behavior (Persian / Farsi)

### Navigation

Back arrow: right side (start of reading direction in RTL).
"+ New" button: left side (end of reading direction).

### Reservation list cards

All card rows mirror:
- Date/time: right-aligned (start)
- Station name: right-aligned
- "in 1h 27m" countdown: left-aligned (end)
- ↗ Navigate button: left side (end)
- Status badges: left side (end of reading direction)

### Time slot grid in creation screen

In RTL, the time slot grid scrolls **right-to-left** — earlier times are to the right (start), later times scroll to the left (end). The "Now" slot appears at the rightmost (start) position. Fade gradients mirror: right side is opaque-transparent fade; left side is the continuation direction.

### Calendar picker

Day column headers reorder in RTL: Friday and Saturday (weekend in Iran) may appear first depending on locale configuration. The month navigation arrows mirror: ‹ (previous month) is on the left (end); › (next month) is on the right (start). Month name remains centered.

### Countdown display

Time remaining in "HH:MM:SS" format is always rendered in an explicit LTR container with Inter font, regardless of locale. Time notation is positional (hours : minutes : seconds from left to right) and would be unreadable reversed.

However, surrounding text changes:

| LTR | RTL (fa) |
|-----|---------|
| "in 1h 27m" | "تا ۱ ساعت ۲۷ دقیقه" |
| "30 minutes remaining" | "۳۰ دقیقه باقی‌مانده" |
| "Window closes at 4:00 PM" | "پنجره تا ساعت ۱۶:۰۰ باز است" |
| "Check-in window: 30 min" | "مهلت ورود: ۳۰ دقیقه" |
| "Today, 3:30 PM" | "امروز، ساعت ۱۵:۳۰" |

Time values (HH:MM) in body text: rendered LTR in explicit container. The surrounding Persian sentence wraps the LTR island naturally.

### Pricing in RTL

Same rules as Station Details §24:
- Persian-Indic digits for all numeric values
- Currency unit follows the number: "۶۰ تومان" (not "تومان ۶۰")
- "kWh" → "کیلووات‌ساعت"
- Per separator: "/" becomes "به‌ازای" or "/" in isolated context

### Notification content in RTL

Notifications are sent in the user's locale (Accept-Language header sent to notification template service). Persian notification templates are stored server-side as ARB-equivalent templates. The `locale_interceptor.dart` ensures the server knows the user's current locale on all requests, including notification subscription endpoints.

Persian push notification example:
```
  Title: "همین الان ورود کنید"
  Body:  "رزرو شما در ایستگاه خیابان نلسون فعال است. ۲۸ دقیقه تا پایان مهلت"
```

---

## 27. Edge Cases

### Station reports fault between booking and check-in

If the station sends a `Faulted` OCPP status for the reserved connector before the user checks in:

1. Push notification fires immediately: "⚠ Charger fault at [Station]. Your reservation may be affected."
2. Reservation Detail screen shows an alert banner below the status hero: "The charger at this station has reported a fault. Your reservation has been placed on hold." in `color.errorContainer`.
3. The "Check In Now" button is disabled (spinner icon + "Charger unavailable").
4. Two CTAs added: "Contact Operator" and "Cancel Reservation (free, due to fault)".
5. If the fault clears before window expiry: alert banner disappears, "Check In Now" re-enables.
6. If the fault persists until window expiry: reservation auto-cancels with a full refund of any reservation fee, no no-show fee applied.

### Connector reassigned (Mode B reservation, type-level, no connector available at check-in)

In connector-type reservations (Mode B), the specific connector is assigned at check-in. If all connectors of the reserved type are occupied at check-in time:

1. Check-in sheet shows: "No [connector type] connectors are currently available. This is unusual and shouldn't have happened." in `color.error`.
2. Two options:
   - "Wait — check availability every 2 minutes" (auto-retry, shown as a countdown to next check)
   - "Cancel (free, operator fault)" — free cancellation regardless of normal policy

### User taps "Check In Now" and session creation succeeds but OCPP timeout

The app receives 202 Accepted and navigates to the Charging Session screen. The session is in Preparing state. OCPP authorization is taking too long (see CHARGING_SESSION_SCREEN.md §10 for the 30-second timeout handling). The reservation is now Completed; the session is in Preparing. If the session ultimately fails to start, the session record is marked as Cancelled (not the reservation — the reservation is already Completed). The user is returned to the Station Details screen with an error: "Could not start the charging session. Please try connecting again."

### Extension granted but new end time conflicts with another reservation

If a user attempts to extend their reservation and another user's reservation starts exactly when the extension would end, the server rejects the extension with a 409 Conflict. The extension sheet shows: "Extension not available — this slot is reserved by another user. Try the +15 min option instead." The conflicting extension option is then marked unavailable in the sheet.

### Time zone change (user crosses time zones mid-reservation)

The reservation's `startTime` and `windowExpiresAt` are stored as UTC timestamps. The app displays them in the device's current time zone. If the device time zone changes (e.g., the user is traveling), all displayed times automatically update to the new local zone. The countdown is unaffected — it is based on UTC time difference from now.

**Display update on timezone change:** On `WidgetsBinding.instance.addObserver` (AppLifecycle resume), the app re-formats all displayed times against the current device timezone. No reload needed.

### Reservation created on behalf of someone else

Not supported in MVP. Reservations are always for the authenticated user. This is enforced on the server (the reservation's `userId` is always the authenticated user from the JWT). In the future (fleet management), fleet coordinators can create reservations for drivers — see §28.

### User deletes app with active reservation

The reservation persists on the server. Push notifications continue to fire. When the user reinstalls and logs in, the reservation appears in their list in its current state.

### Very long station name (affects countdown display on list)

The countdown label in the list card ("in 1h 27m") is right-aligned and has a fixed minimum width of 72dp. The station name is truncated at 1 line with ellipsis. This prevents the countdown from being squeezed or hidden by long names.

### Two tabs open (theoretical, handled by state management)

Flutter does not support multiple app windows on mobile, but Riverpod's single-writer rule (ARCHITECTURE_FINAL.md §19) ensures that concurrent state mutations from WebSocket events and user actions are serialized correctly. No edge case here — design note only.

---

## 28. Future Expansion Opportunities

These surfaces are reserved in the current design. Adding them is additive.

### Smart Scheduling

**Description:** The user specifies a departure time and desired SoC. The app recommends reservation times based on historical availability patterns and off-peak pricing windows.

**UI location:** A "Smart Schedule" toggle in the creation screen below the day selector. When activated, the time slot grid is replaced by a simplified input: "I need to leave by [time]" + "[slider] charge to [N]% / [N] kWh". The app selects the optimal slot and pre-selects it.

### Fleet Reservation Management

**Description:** Fleet operators can create, view, and cancel reservations for multiple drivers from a single account.

**UI changes:** The Reservations list gains a "Fleet" toggle at the top. Fleet view shows all driver reservations in a grouped-by-driver list. "Create for driver" adds a driver selector step to the creation flow.

### Recurring Reservations

**Description:** The user reserves the same connector at the same time on a recurring schedule (e.g., every weekday at 8:00 AM).

**UI location:** A "Repeat" option in the creation screen. Options: None (default), Daily, Weekdays, Weekly. Each recurrence is a separate reservation record on the server; the UI groups them visually with a "recurring" badge.

### Shared Reservations (carpool)

**Description:** A reservation can be shared with another user who can check in on behalf of the creator.

**UI location:** A "Share reservation" action on the detail screen. Opens a share sheet generating a deep link. The recipient taps the link and the reservation appears in their list as "Shared with you by [name]."

### Waitlist

**Description:** When no time slots are available on a given day, the user can join a waitlist. If a cancellation creates an opening, the waitlist user receives a notification and has 5 minutes to confirm.

**UI location:** When the time slot grid shows all slots as Unavailable, a "Join waitlist for this day" Primary button replaces the Confirm button. Waitlist card appears in the Reservations list with a distinct "Waitlisted" status treatment (grey, with clock icon).

### Automatic check-in (Plug & Charge, ISO 15118)

**Description:** When the user plugs in at a station that supports ISO 15118, the vehicle communicates the user's credentials automatically. The reservation check-in happens without any app interaction.

**UI changes:** The check-in sheet is not shown. Instead, a push notification fires: "Charging started automatically at [Station] via your reservation." The Charging Session screen opens (or updates if already open). The Reservation status transitions to Completed silently.

### Real-time occupancy forecast

**Description:** The time slot grid currently shows best-effort availability estimates. In the future, historical charging patterns can produce higher-accuracy forecasts with confidence intervals.

**UI location:** Each time slot displays an additional sub-label below the dot: "Usually 90% free" or "Often busy" in `type.label.small`, replacing the simple dot.

### On-arrival geofence trigger

**Description:** When the user enters a geofence around the reserved station (e.g., 500 meters), the app displays a proactive check-in notification: "You're near [Station]. Open the app to check in."

**UI addition:** An OS geofence subscription is registered at reservation confirmation, removed at check-in or expiry. No persistent background location is used — the geofence is a point-in-time trigger.

---

*This document specifies the complete reservation experience — creation, lifecycle management, check-in, expiry, cancellation, and all connecting notification flows. The reservation system is only as trustworthy as its clarity: every policy, every fee, every countdown must be honest, visible, and timed appropriately. No implementation proceeds without alignment on every state, transition, and edge case defined here.*