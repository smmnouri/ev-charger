# Charging Summary Screen

**Screen route:** `/charging/:sessionId/summary`  
**Entry points:** Auto-transition from Charging Session screen on completion · Wallet transaction detail "View Session" link · Push notification (session ended while app in background) · Deep link from email receipt  
**Navigation context:** Pushes over the tab shell; "Done" returns to the originating tab  
**Last Updated:** 2026-06-11  
**References:** DESIGN_SYSTEM.md · ARCHITECTURE_FINAL.md §13, §16 · CHARGING_SESSION_SCREEN.md · RESERVATION_FLOW.md §18

The Charging Summary screen is the final moment of truth in the charging experience. It is simultaneously a receipt, a billing confirmation, a consumption report, and a trust signal. Everything the user does on this screen is downstream of one implicit question they ask the moment they see it: "Is this right?" The design must answer that question before they finish reading the first line.

---

## Table of Contents

1. [Screen Purpose](#1-screen-purpose)
2. [User Goals](#2-user-goals)
3. [Business Goals](#3-business-goals)
4. [Information Hierarchy](#4-information-hierarchy)
5. [Session Completion Flow](#5-session-completion-flow)
6. [Success State Design](#6-success-state-design)
7. [Cost Breakdown Design](#7-cost-breakdown-design)
8. [Energy Consumption Summary](#8-energy-consumption-summary)
9. [Charging Duration Summary](#9-charging-duration-summary)
10. [Average and Peak Charging Power](#10-average-and-peak-charging-power)
11. [Tariff Presentation](#11-tariff-presentation)
12. [Reservation-to-Session Summary](#12-reservation-to-session-summary)
13. [Wallet Deduction Presentation](#13-wallet-deduction-presentation)
14. [Payment Confirmation](#14-payment-confirmation)
15. [Receipt Preview](#15-receipt-preview)
16. [Download Receipt Flow](#16-download-receipt-flow)
17. [Share Receipt Flow](#17-share-receipt-flow)
18. [Tax Invoice Considerations](#18-tax-invoice-considerations)
19. [Carbon Savings Presentation](#19-carbon-savings-presentation)
20. [Charging Statistics Presentation](#20-charging-statistics-presentation)
21. [Station Information Recap](#21-station-information-recap)
22. [Vehicle Information Recap](#22-vehicle-information-recap)
23. [Session Timeline Visualization](#23-session-timeline-visualization)
24. [Session Stop Reason Presentation](#24-session-stop-reason-presentation)
25. [Error and Interrupted-Session Summaries](#25-error-and-interrupted-session-summaries)
26. [Offline Behavior](#26-offline-behavior)
27. [Loading States](#27-loading-states)
28. [Empty States](#28-empty-states)
29. [Error States](#29-error-states)
30. [Accessibility Requirements](#30-accessibility-requirements)
31. [RTL Behavior (Persian / Farsi)](#31-rtl-behavior-persian--farsi)
32. [Analytics Events](#32-analytics-events)
33. [Future Expansion Opportunities](#33-future-expansion-opportunities)
34. [Transitions and Animations](#34-transitions-and-animations)

---

## 1. Screen Purpose

**One sentence:** Confirm to the user — with receipts-grade precision and human clarity — exactly what happened during their charging session, what was charged to their wallet, and why.

This screen is the platform's legal and emotional commitment to the user. It is:

- **A receipt.** Every amount must be traceable to a line item. No unexplained totals.
- **A meter certificate.** Energy delivered is the authoritative figure the charging session produced. If this number looks wrong, the user has a basis to dispute.
- **A debrief.** Duration, power curve, stop reason — these tell the story of what the charger and vehicle negotiated over the session.
- **An archive.** The user must be able to retrieve, download, and share this information at any time in the future, not just now.

The screen is not a marketing surface. No upsell, no gamification. Every pixel earns its place by helping the user understand what just happened to their vehicle and their wallet.

---

## 2. User Goals

Users arrive at this screen in one of two mental states: **satisfied** (vehicle charged, ready to go) or **concerned** (something went wrong, how much did it cost, was it billed correctly). The design serves both.

| Priority | Goal | Scenario |
|----------|------|----------|
| 1 | Confirm the total amount charged is accurate | Always |
| 2 | Understand what each charge component is | When total looks higher than expected |
| 3 | Verify the energy delivered matches their vehicle's indicator | When reconciling with dashboard |
| 4 | Know the session ended in a normal state | When session ended unexpectedly |
| 5 | Download or share the receipt for reimbursement | Business users, fleet drivers |
| 6 | Get a tax invoice for accounting purposes | Business users |
| 7 | Understand why the session ended the way it did | Fault, timeout, or charger-initiated stop |
| 8 | Know their current wallet balance | Before their next drive |
| 9 | Rate the station for future users | Engaged community users |
| 10 | Return to the map and move on | When everything was fine |

---

## 3. Business Goals

| Goal | Design implication |
|------|-------------------|
| Reduce billing disputes | Show every line item; show wallet before/after; match the wallet transaction exactly |
| Build trust after faults | Fault summaries must be honest, explain partial billing, and offer clear support paths |
| Increase receipt engagement | Receipt download and share are prominent CTAs — users who archive receipts are more likely to reuse the platform |
| Capture business expense users | Tax invoice flow must be low-friction and correctly formatted |
| Improve station data quality | Station rating CTA channels feedback without being intrusive |
| Reduce support contacts | The screen must answer "why was I charged X?" before the user needs to contact support |

---

## 4. Information Hierarchy

### Tier 1 — Visible within 1 second, no scrolling

- Session status (Completed / Interrupted / Faulted)
- Total amount charged (the most important number on the screen)
- Energy delivered (the physical unit the user understands)
- Duration

### Tier 2 — Visible within one scroll, no tapping

- Cost breakdown (line items)
- Wallet balance before and after
- Tariff applied
- Stop reason (if non-standard)
- Session timeline chart

### Tier 3 — Visible by tapping (expand)

- Full pricing formula
- Tax breakdown
- Charging efficiency metrics
- Carbon savings detail
- Station details
- Session ID and timestamps

### Tier 4 — Triggered by explicit CTA

- Receipt PDF download
- Share sheet
- Tax invoice request
- Station rating
- Wallet transaction detail

---

## 5. Session Completion Flow

### How the screen is reached

**Path A — Auto-transition from live session (primary path):**

When the Charging Session screen receives a session-completion event via WebSocket (`SessionStatus → Completed`):

1. The session ring on the Charging Session screen completes its burst animation (600ms — per CHARGING_SESSION_SCREEN.md §18)
2. The checkmark appears in the ring center
3. The Session Summary Card on the Charging Session screen expands (its "Done" button becomes "View Summary")
4. After 3 seconds of dwell OR on "View Summary" tap: the Charging Summary screen animates in

**Path B — Background completion (app was not open during session end):**

The user receives a push notification: "Session complete — ¥2,032 charged · 24.71 kWh delivered." Tapping the notification navigates directly to this screen. If the app is cold-starting, auth and KYC guards pass before routing to this screen.

**Path C — Historical access (revisiting a past session):**

From the Wallet screen: a transaction card for a completed session has a "View Session Details" link. From the Reservations list: a completed reservation card links here. This path loads the screen in a static (non-fresh) state — no animations; data loaded from the `GET /sessions/:id` endpoint.

### Entry animation

The transition from the Charging Session screen is a coordinated shared-element animation:

1. The session ring (220dp) on the Charging Session screen contracts — 400ms spring animation — to an 80dp completion medallion that settles into the hero area of the Summary screen
2. The Summary screen's dark background (#0A0F1E) simultaneously fades to the light summary background (`color.background`) — 400ms
3. The ring residue (the contracted medallion) is already at its final position in the summary hero before the fade completes

The net effect: the user perceives the charging session transforming into a receipt — the dark, live, urgent charging environment becomes a clean, light, archival summary. The color temperature shift reinforces the mode change.

**For Path C (historical):** Standard horizontal slide-in. No completion animation. The medallion is static from frame one.

### What "session complete" means in the data model

The `ChargingRecord` (immutable historical entity, distinct from `ChargingSession`) is what this screen reads. The `ChargingRecord` is created by the backend when the session is finalized and contains:
- `totalEnergyKwh` (authoritative, from the OCPP final meter reading)
- `totalCostCents` (from the `TariffSnapshot` × energy, computed server-side)
- `durationSeconds`
- `peakPowerKw`
- `averagePowerKw`
- `meterValues[]` (array of power readings over time, for the timeline chart)
- `stopReason` (sealed enum)
- `walletTransactionId` (link to the ledger entry)
- `tariffSnapshotId` (link to the tariff that was applied)

The UI must only display values from the `ChargingRecord`. If the record is not yet finalized (a brief window after session end while the server computes totals), a loading state is shown (§27).

---

## 6. Success State Design

The success state is the primary design — the happy path. It applies when `stopReason` is `UserStopped`, `VehicleFull`, `VehicleRequested`, or `ChargerInitiated` (without a fault code).

### Visual language

The screen is the inverse of the Charging Session screen in every visual dimension:
- Background: `color.background` (light, warm off-white) — not the dark navy
- Text: `color.text.primary` (dark) on light background
- The energy color (`color.secondary`, green) is the dominant accent — it communicates success, environmental positivity, and completion simultaneously

### Full screen layout (success state, top to bottom)

```
┌──────────────────────────────────────────────────────────────┐
│  ← Back                            [Share ↗]  [···]          │  ← Nav bar, 56dp
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │  ← Hero card
│  │                                                     │    │
│  │   [✓ medallion 80dp]  Session Complete              │    │
│  │   [Stop reason badge]                               │    │
│  │                                                     │    │
│  │   ┌───────────┬───────────┬───────────┐             │    │
│  │   │  24.71    │ 01:47:23  │  13.8 kW  │             │    │
│  │   │   kWh     │ Duration  │  Avg pwr  │             │    │
│  │   └───────────┴───────────┴───────────┘             │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │  ← Total cost card
│  │  TOTAL CHARGED                                      │    │
│  │  ¥2,032.60                                          │    │
│  │  Deducted from wallet                               │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │  ← Cost breakdown
│  │  BILLING BREAKDOWN                                  │    │
│  │  Session fee            ¥500.00                     │    │
│  │  Energy (24.71 × ¥60)   ¥1,482.60                   │    │
│  │  Idle fee (5 min)         ¥50.00                    │    │
│  │  ─────────────────────────────────────────────      │    │
│  │  Total                  ¥2,032.60                   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │  ← Wallet card
│  │  Wallet before   ¥50,000.00                         │    │
│  │  Charged          −¥2,032.60                        │    │
│  │  ─────────────────────────────────                  │    │
│  │  Wallet now      ¥47,967.40                         │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ─── Session details ─────────────────────────────────      │  ← Collapsed sections
│  ─── Carbon impact ───────────────────────────────────      │
│  ─── Your stats ──────────────────────────────────────      │
│  ─── Station info ────────────────────────────────────      │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │           Download Receipt                         │    │  ← Primary CTA
│  └────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────┬──────────────────────────┐    │
│  │    ★ Rate Station       │        Back to Map        │    │  ← Secondary CTAs
│  └─────────────────────────┴──────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
```

### Navigation bar

- **Back / ← :** Navigates to the screen that launched the summary (Map tab for live-session path; Wallet for history path). Not "close" — the stack is preserved.
- **Share ↗ :** Opens the OS share sheet with the session summary as a preformatted text block (no PDF — that is the "Download Receipt" flow). Tapping ↗ is the fast path for users who want to text or email the summary without generating a PDF.
- **··· (overflow menu):** Contains: "Download Receipt", "Tax Invoice", "Report Billing Issue", "View in Wallet". This is the secondary action menu — actions the user needs occasionally but not every session.

---

## 7. Cost Breakdown Design

The cost breakdown is the most scrutinized section of the screen for users who believe their charge is incorrect. It must be forensically clear.

### Hero total cost card

The total cost card sits immediately below the hero section, before the breakdown. It contains the single most important number on the screen.

**Card design:**
- Background: `color.secondaryContainer` (light green tint — confirms successful payment, not alarming)
- Border radius: `radius.xl` (20dp)
- Padding: 24dp
- No border, no shadow — it is the background color that distinguishes it

```
  TOTAL CHARGED                             type.label.small, letter-spaced, color.secondary
  ¥2,032.60                                 type.numeric.display (48sp/700), color.text.primary
  Deducted from wallet · [Date, Time]       type.body.small, color.text.secondary
```

The date/time is the confirmation timestamp of the wallet deduction — not the session end time. If these differ by more than 60 seconds, both are shown: "Session ended [time] · Billed [time]". For free sessions: "No charge — free session" replaces the amount.

### Billing breakdown card

Immediately below the total cost card. This is the detailed receipt section.

**Card design:**
- Background: `color.surface`
- Border radius: `radius.lg` (16dp)
- Border: 1dp `color.outline` at 30% opacity
- Padding: 20dp
- Horizontal margin: 16dp from screen edges

**Section header:** "BILLING BREAKDOWN", `type.label.small`, letter-spaced, `color.text.tertiary`

**Line items (one per component):**

Each line item row (48dp height):
- Start: component label, `type.body.large`, `color.text.primary`
- Sub-label (optional): calculation basis, `type.body.small`, `color.text.tertiary` (e.g., "24.71 kWh × ¥60/kWh")
- End: formatted amount, `type.numeric.medium` (24sp/600), right-aligned, `color.text.primary`

**Line item types and their formulas:**

| Component | Label | Sub-label | Condition |
|-----------|-------|-----------|-----------|
| Session fee | "Session fee" | "One-time connection fee" | If `tariff.sessionFee > 0` |
| Energy cost | "Energy" | "[kWh] × ¥[rate]/kWh" | Always (if energy-based tariff) |
| Time cost | "Time" | "[min] min × ¥[rate]/min" | If time-based tariff |
| Idle fee | "Idle fee" | "[min] min after session ended" | If `idleMinutes > 0` |
| Reservation fee | "Reservation (paid at booking)" | — | If originated from paid reservation; shows ¥0 or "(already paid ¥[amount])" |
| Discount | "Discount applied" | Discount code or loyalty program | If applicable |
| Tax | "Tax (VAT [rate]%)" | — | If tax is included; see §18 |

**Divider between items and total:**
- 1dp `color.outline`, full width of card (minus padding)

**Total row (56dp height):**
- Start: "Total", `type.title.medium`, `color.text.primary`
- End: total amount, `type.numeric.large` (32sp/700), `color.text.primary`
- This row has a slightly heavier visual weight than the line items — the divider above it draws the eye here

**Expand for formula (tap on any energy or time line item):**

Tapping the energy line item inline-expands a detail block below it (200ms ease-out height animation):

```
  24.71 kWh × ¥60 / kWh = ¥1,482.60

  Rate source: TariffSnapshot captured at session start
  Rate locked at: [timestamp]
  Current rate:   ¥65/kWh (you saved ¥5/kWh by reserving)
  (or: same as live rate)
```

This level of transparency pre-empts "why was I charged more than the posted rate" questions.

### Free session cost section

When `totalCostCents = 0`:

The hero total cost card becomes:
```
  FREE SESSION                              type.label.small, color.secondary
  ¥0.00                                     type.numeric.display, color.text.primary
  No charge · Complimentary charging        type.body.small, color.text.secondary
```

Background: `color.secondaryContainer` (same green tint — free is also a success).

The billing breakdown card shows: "No charge applies to this session." `type.body.medium`, `color.text.secondary`, centered. No line items.

The wallet card is absent (no deduction occurred).

---

## 8. Energy Consumption Summary

The energy figure is the single physical measurement the user can independently verify (against their vehicle's dashboard indicator). It must be displayed with precision and context.

### Primary energy display

The energy figure appears in two places:
1. Hero section metric column (large, primary) — "24.71 kWh"
2. Billing breakdown sub-label — "24.71 kWh × ¥60/kWh"

**Format:** Always 2 decimal places. `type.numeric.large`, `color.text.primary`. Unit "kWh" immediately follows in `type.label.medium`, `color.text.secondary`.

### Energy detail card (within "Session Details" collapsible section)

Expanded from the collapsible "Session Details" row:

| Metric | Value | Source |
|--------|-------|--------|
| Energy delivered | 24.71 kWh | Final OCPP meter reading |
| Meter start | 1,204.50 kWh | Charger's cumulative meter (EVSE odometer) |
| Meter end | 1,229.21 kWh | Charger's cumulative meter |
| Meter difference | 24.71 kWh | End − Start (verification figure) |
| Energy source | Grid (standard) | Operator-provided; "Renewable" if certified |

**Meter start/end values:** Displayed for advanced users and for dispute purposes. Most users will not understand these figures but they are critical for a billing dispute. The format: "EVSE meter [start] → [end] kWh (net: [delta] kWh)".

**Energy source certification:**
If the operator certifies renewable energy supply: a small "🌱 Certified renewable energy" badge next to the energy figure. Badge: 24dp height, `radius.full`, `color.secondaryContainer`, leaf icon 12dp + label `type.label.small`, `color.secondary`. Not shown if uncertified (absence is not a negative signal).

### Energy reconciliation note

If the metered energy differs from the billed energy by more than 0.1 kWh (a discrepancy indicator — this should never happen but is caught defensively):

An amber banner below the energy breakdown: "⚠ Energy metered and energy billed differ. Please contact support if you believe this is incorrect." + "Contact Support" Tertiary link. `color.warning`.

---

## 9. Charging Duration Summary

### Primary duration display

"01:47:23" — HH:MM:SS format — displayed in the hero section metric column. `type.numeric.large`, tabular figures, `color.text.primary`.

### Duration components (within Session Details)

| Metric | Value | Explanation |
|--------|-------|-------------|
| Total session time | 01:47:23 | From session start to session end |
| Active charging time | 01:41:05 | Time with power > 0 kW flowing |
| Suspended time | 00:06:18 | Time with `SuspendedByVehicle` or `SuspendedByCharger` status |
| Idle time after session | 00:05:00 | Time between session end and cable unplug (if tracked) |

**Suspended time display:**
If `suspendedSeconds > 0`: shown as a separate row with an info icon. Tooltip: "Your vehicle's battery management system paused charging for [N] minutes. This is normal — the vehicle is protecting its battery."

**Idle time and idle fees:**
If idle time is tracked and an idle fee applies: "Cable remained connected for [N] minutes after charging ended. Idle fee: ¥[amount]." This appears as a line item in the billing breakdown and is explained here.

---

## 10. Average and Peak Charging Power

### Hero metric: average power

The third metric in the hero section: average power, `type.numeric.large`, "13.8 kW".

**Calculation:** `totalEnergyKwh / (activeChargingSeconds / 3600)`. Server-computed and stored in `ChargingRecord.averagePowerKw`.

### Peak power (within Session Details)

| Metric | Value |
|--------|-------|
| Peak power | 50.0 kW |
| Time of peak | 8:04 AM (first 4 minutes) |
| Average power | 13.8 kW |
| Charging efficiency | 94.2% (energy in / connector rated power × session time) |

**Charging efficiency note:** Only shown if the charger reports rated power in its OCPP data. Formula: `(totalEnergyKwh / (peakPowerKw × (activeChargingSeconds/3600))) × 100`. If efficiency is unexpectedly low (< 70%), an amber info tooltip: "Lower efficiency may indicate the charger or vehicle did not reach full rated power." This is informational, not alarming.

**Peak power context:**
A sub-label below peak power: "of [connector max kW] kW connector max" — e.g., "50.0 kW of 150 kW max". This contextualizes the peak: a 50 kW peak on a 150 kW charger tells the user their vehicle limited the charge rate, not the charger. Phrased as a fact, not a problem.

---

## 11. Tariff Presentation

The tariff section answers: "what rate was I charged at, and was it the rate I agreed to?"

### Tariff summary row (in billing breakdown card)

Below the line items, above the total divider:

```
  Rate applied             ¥60/kWh (fixed)           [Locked at booking ↓]
```

"Locked at booking" is a tappable Tertiary link that expands the tariff detail inline.

### Tariff detail (expandable, within breakdown card)

```
  Rate source:      Tariff snapshot (reserved rate)
  Rate locked at:   14 Jun 2026, 2:03 PM
  Rate expired at:  (not applicable — fixed tariff)
  Current rate:     ¥65/kWh (you saved ¥5/kWh)
```

If the session was not from a reservation (walk-up): "Rate source: Live tariff at session start. Tariff ID: [ID]. Current rate: [same / different]."

### Dynamic pricing tariff presentation

For sessions where the tariff changed during the session (time-of-use pricing):

The energy line item in the billing breakdown expands into multiple sub-items:

```
  Energy (time-of-use)                              ¥1,350.00
    08:00 – 09:00   16.50 kWh × ¥45/kWh   ¥742.50
    09:00 – 09:47    8.21 kWh × ¥74/kWh   ¥607.54
```

Sub-items use `type.body.small`, `color.text.secondary` for the formula, `type.label.large` for the sub-total. Indented 16dp from the parent line item.

A note below the breakdown: "⚡ Dynamic pricing was active during this session. Rates changed as shown above." `type.body.small`, `color.warning`, with the ⚡ bolt icon 14dp.

---

## 12. Reservation-to-Session Summary

When the session originated from a confirmed reservation, a dedicated context block appears between the billing breakdown and the wallet card.

### Reservation context card

```
  ┌─────────────────────────────────────────────────────┐
  │  ORIGINATED FROM RESERVATION                        │
  │                                                     │
  │  Reservation ID     #R4821K                         │
  │  Reserved at        14 Jun 2026, 2:03 PM            │
  │  Reserved rate      ¥60/kWh ✓ (applied)             │
  │  Current live rate  ¥65/kWh                         │
  │  You saved          ¥5/kWh · ¥123.55 on this session│
  │                                                     │
  │  Reservation fee    Free (no charge)                │
  │  (or)                                               │
  │  Reservation fee    ¥500 (paid at booking)          │
  └─────────────────────────────────────────────────────┘
```

**Card design:** `color.tertiaryContainer` (light purple tint — the reservation color), `radius.lg`, 16dp padding. The purple tint connects this card to the reservation system's visual language.

**"You saved" row:** Only shown if the booked rate was lower than the live rate at session start. If the booked rate was higher (user did not save), this row is absent — no need to highlight an unfavorable outcome. The tariff snapshot protects the user in either direction, but only the favorable outcome is highlighted.

**Reservation fee line item in billing breakdown:**
If the reservation fee was paid at booking:
- Line item: "Reservation fee" / "(paid at booking)" / ¥500.00 shown in parentheses with a note: "This was charged when you made the reservation and is included in your total."
- The total in the breakdown does NOT double-count this fee — if it was already paid from the wallet at booking time, it is shown as a memo item with ¥0 in the current billing column, and a footnote: "¥500 was charged at reservation — not included in today's session total."

This distinction requires careful handling. The `ChargingRecord` must explicitly carry a flag: `reservationFeeAlreadyPaid: true/false` and the amount, so the UI can present it correctly without double-counting.

---

## 13. Wallet Deduction Presentation

The wallet card is the financial ledger entry in visual form. It must exactly match what the user would see in the Wallet tab for this transaction.

### Wallet card design

```
  ┌─────────────────────────────────────────────────────┐
  │  WALLET                              [View in Wallet →]
  │                                                     │
  │  Balance before     ¥50,000.00                      │
  │  Session charge     − ¥2,032.60      color.error    │
  │  ───────────────────────────                        │
  │  Balance now        ¥47,967.40       bold           │
  └─────────────────────────────────────────────────────┘
```

**Card design:**
- Background: `color.surface`
- Border radius: `radius.lg`
- Border: 1dp `color.outline` at 30% opacity

**"Balance before" row:** `type.body.large`, `color.text.secondary` label; `type.numeric.medium`, `color.text.secondary` value (the past balance reads in secondary — it is historical)

**"Session charge" row:** `type.body.large`, `color.text.primary` label; `type.numeric.medium`, `color.error` value with a leading "−" (the deduction is in red — a cost, not an error state)

**Divider:** 1dp `color.outline`

**"Balance now" row:** `type.title.medium`, `color.text.primary` label; `type.numeric.large` (32sp/700), `color.text.primary` value — the current balance is the most important row in this card and gets the most visual weight

**"View in Wallet →" link (top-right of card):** Tertiary, `color.primary`, `type.label.large`. Navigates to the Wallet screen, scrolled to this transaction. The wallet transaction is already created at the time this screen appears — no loading state needed for this navigation.

### Low balance warning

If `walletNow < minimumSessionThreshold` (operator-configured, typically ¥2,000–¥5,000):

An amber banner below the wallet card:
- "⚠ Your wallet balance is low. Top up before your next charge."
- "Top Up Now →" Tertiary link → navigates to wallet top-up flow
- 44dp height, `color.warningContainer`, `radius.md`
- Dismissed permanently by swiping the banner off-screen (preference saved to `SharedPreferences`)

---

## 14. Payment Confirmation

The payment confirmation is a trust element — it tells the user that the billing is not pending, not processing, but done.

### Confirmation badge (within total cost card)

Below the "Deducted from wallet" sub-label: a small inline confirmation badge:

```
  ✓ Payment confirmed · [Date] [Time]    type.label.small, color.secondary
```

The timestamp is the server-side `walletTransaction.confirmedAt` — the moment the ledger entry was committed, not the moment the session ended. This is the authoritative billing timestamp.

**What "confirmed" means:** The wallet ledger entry is append-only and immutable. Once confirmed, it cannot be reversed unilaterally. The payment confirmation badge communicates this finality — the transaction is real, not a hold.

### Transaction reference

Below the payment confirmation badge:

```
  Transaction ID: TXN-20260614-4821K    type.label.small, color.text.tertiary
  Long-press to copy
```

The Transaction ID is the reference the user provides to support for any billing dispute. It is different from the Session ID — it is the wallet ledger entry reference.

**Long-press to copy:** On long-press of the transaction ID: copy to clipboard + haptic feedback + brief "Copied" toast (1s, bottom of screen). The transaction ID is always displayed in Latin characters in an explicit LTR container regardless of locale.

---

## 15. Receipt Preview

The receipt preview is a visual representation of the downloadable receipt document, shown inline before the user downloads or shares it.

### Preview section placement

Below the wallet card, before the collapsed detail sections. The receipt preview is a 200dp tall, horizontally scrollable card that shows a miniaturized but legible representation of the receipt.

### Preview card design

```
  ┌────────────────────────────────────────────────────────────┐
  │  [App logo 24dp]  Official Charging Receipt                │
  │  ─────────────────────────────────────────────────────     │
  │  Elm Street Charging Hub · 14 Jun 2026                    │
  │  CCS DC Fast · Connector 3 · Session #4821K               │
  │  ─────────────────────────────────────────────────────     │
  │  Energy        24.71 kWh      Duration   01:47:23         │
  │  Session fee   ¥500.00                                     │
  │  Energy cost   ¥1,482.60      (24.71 × ¥60)               │
  │  Idle fee      ¥50.00         (5 min)                      │
  │  ─────────────────────────────────────────────────────     │
  │  TOTAL         ¥2,032.60                                   │
  │                                                            │
  │  [QR code 32dp]  Transaction: TXN-20260614-4821K           │
  └────────────────────────────────────────────────────────────┘
```

**Preview styling:**
- White background (always, even in dark mode — the receipt is a document, not a UI screen)
- `radius.lg` (16dp), elevation 3
- Text at 70% of normal screen sizes (it's a preview, not the document)
- All text in `color.text.primary` black — document standard
- A subtle "PREVIEW" watermark diagonal text in the background: `color.text.disabled` at 8% opacity

**Tapping the preview:** Expands to a full-screen receipt preview with zooming. The full-screen preview has a "Download" button in the top-right corner. The full-screen is a read-only, scrollable document view — not the download sheet.

### QR code

The QR code in the preview encodes the `sessionId` and `transactionId` as a URL: `{baseUrl}/receipts/{sessionId}?txn={transactionId}`. This URL resolves to a web-accessible version of the receipt (future — in MVP, the QR code is generated but the URL shows a "receipt display coming soon" page).

---

## 16. Download Receipt Flow

The primary CTA "Download Receipt" opens a focused download sheet, not a new screen.

### Download sheet (340dp height + safe area)

```
  ──── (handle)

  Download Receipt
  type.headline.small

  ─── Format ────────────────────────────────────────────

  [○ PDF receipt]   [○ Image (PNG)]
   (selected)
   Standard receipt  Share as image,
   document format   works anywhere

  ─── Options ───────────────────────────────────────────

  □ Include tax invoice (VAT breakdown)  [? tooltip]
  □ Include session timeline chart

  ─── Preview ───────────────────────────────────────────

  [Mini receipt preview, 120dp]

  ──────────────────────────────────────────────────────

  [  Download PDF  ]  ← Primary Large
  [  Cancel        ]  ← Tertiary
```

**Format selector:**
Two segmented options: "PDF receipt" and "Image (PNG)". PDF is selected by default. PDF produces a proper document with selectable text. PNG produces a shareable image suitable for sending via messaging apps.

**Tax invoice toggle:** Collapsed by default. On toggle: reveals the tax invoice section inline (see §18).

**Timeline chart option:** When checked, the session power curve chart (§23) is included on a second page of the PDF, or appended below the receipt in the PNG.

### Download execution

On "Download PDF":
1. Button enters loading state (spinner)
2. App calls `GET /sessions/:id/receipt?format=pdf&taxInvoice=false`
3. Server returns a PDF binary
4. On success: the OS "Save to Files" sheet appears (iOS) or the file is saved to Downloads with a success snackbar (Android)
5. Sheet dismisses

If the user has already requested a receipt for this session: the server returns the same pre-generated PDF (cached). The download completes faster on subsequent requests.

### Download error

If the receipt generation fails:
- Sheet shows an error banner: "Receipt generation failed. Try again or contact support."
- "Try Again" Tertiary refetches
- If persistent: "Contact Support" links to support channel

---

## 17. Share Receipt Flow

"Share ↗" in the navigation bar opens the OS native share sheet. The content shared is a preformatted text block — fast to compose, works in any messaging app, does not require a PDF download.

### Shared text format (English)

```
⚡ EV Charging Receipt

📍 Elm Street Charging Hub
📅 14 Jun 2026 · 08:00 – 09:47 AM
🔌 CCS DC Fast · Connector 3

Energy delivered:  24.71 kWh
Session duration:  01:47:23
Total charged:     ¥2,032.60

Session ID: #4821K
```

### Shared text format (Persian / fa locale)

```
⚡ رسید شارژ خودرو برقی

📍 مرکز شارژ خیابان نارنجستان
📅 ۲۴ خرداد ۱۴۰۵ · ۰۸:۰۰ – ۰۹:۴۷
🔌 سی‌سی‌اس DC سریع · پریز ۳

انرژی دریافتی:   ۲۴٫۷۱ کیلووات‌ساعت
مدت جلسه:       ۰۱:۴۷:۲۳
مجموع کسر شده:  ۲٬۰۳۲٫۶۰ تومان

شناسه جلسه: #4821K
```

**Date format:** In fa locale, the date is in Shamsi (Solar Hijri) calendar, Persian-Indic digits for day/year, Persian month name.

**The "···" overflow menu also contains "Share as Image"** — this shares the PNG version of the receipt (same as the download sheet's PNG option, but skips the download sheet and goes directly to the OS share sheet with the file attached).

---

## 18. Tax Invoice Considerations

Tax invoices are relevant to:
- Business users seeking expense reimbursement
- Fleet operators
- Users in jurisdictions with recoverable VAT (Iran: 9% VAT standard rate)

### Tax invoice toggle in download sheet

When the "Include tax invoice" checkbox is toggled in the download sheet, a form expands inline:

```
  Tax Invoice Details
  ──────────────────────────────

  Company name      [__________________]  (required)
  Tax ID (شناسه ملی/کد اقتصادی)  [__________]  (required)
  Registered address  [__________________]
                      [__________________]

  □ Save these details for future invoices
```

Fields are pre-populated if the user has previously saved tax details.

**Field validation:**
- Company name: required, max 100 characters
- Tax ID: required, numeric, 10–11 digits (Iranian national economic code format: 11 digits, or national ID: 10 digits)
- Address: optional, but required for formal tax compliance in some jurisdictions

**"Save for future" checkbox:** Saves to the user's profile server-side. The tax details are associated with the account, not the device.

### Tax invoice document format

The tax invoice (appended to or separate from the regular receipt) includes:

- Seller: Operator's registered name, operator's tax ID, operator's registered address, operator's VAT registration number
- Buyer: User's company name, user's tax ID, user's registered address (from the form)
- Invoice number: system-generated, sequential within the operator's tax sequence
- Invoice date: session end date
- Item: "EV Charging Service — [energy] kWh — [station]"
- Pre-tax amount: `totalCost / 1.09` (for 9% VAT)
- VAT: `totalCost − preVat`
- Total with VAT: `totalCost`
- QR code: encodes the invoice number for tax authority verification (future)

**Legal note:** The tax invoice format displayed in the app is designed to meet Iranian VAT invoice requirements. Deployments in other jurisdictions must adapt the format to local tax law. The invoice format is server-side generated — the app passes the tax details and receives a compliant PDF.

---

## 19. Carbon Savings Presentation

Carbon savings is presented as a positive, ambient addition to the session summary — not a primary data point, and never manipulative or exaggerated.

### Carbon savings card (within collapsed "Carbon Impact" section)

```
  ┌─────────────────────────────────────────────────────┐
  │  🌱 CARBON IMPACT                                   │
  │                                                     │
  │  ~4.9 kg CO₂ avoided                               │
  │  type.numeric.large, color.secondary                │
  │                                                     │
  │  vs. equivalent petrol vehicle                      │
  │  type.body.small, color.text.secondary              │
  │  ─────────────────────────────────────────          │
  │  Equivalent to                                      │
  │  35 km emission-free driving                        │
  │  type.title.medium, color.secondary                 │
  │                                                     │
  │  Energy source: Grid (standard mix)                 │
  │  or: Certified renewable energy ✓                   │
  │  type.body.small, color.text.tertiary               │
  └─────────────────────────────────────────────────────┘
```

### Calculation basis

**CO₂ avoided calculation:**
`avoidedCO2_kg = (energyKwh × gasolineEmissionFactor) − (energyKwh × gridEmissionFactor)`

- `gasolineEmissionFactor`: 0.235 kg CO₂/kWh (equivalent petrol vehicle — based on average petrol car efficiency of 8.5L/100km × 2.31 kg CO₂/L, converted to kWh equivalent using 8.9 kWh/L petrol)
- `gridEmissionFactor`: deployment-configurable. Default: Iranian grid average (~0.0485 kg CO₂/kWh for standard grid, 0 for certified renewable)
- Result: `(24.71 × 0.235) − (24.71 × 0.0485) ≈ 4.6 kg CO₂`

**"Equivalent to [N] km" calculation:**
`distanceKm = energyKwh / 0.18` (assuming 18 kWh/100km average EV efficiency). Result: `24.71 / 0.18 ≈ 137 km`. The display shows the driven distance at EV efficiency — this is how far the user charged their car to travel, not a CO₂ comparison figure.

**The "~" tilde prefix:** CO₂ savings estimates are inherently approximate. The tilde is non-negotiable — it communicates that this is an estimate, preventing users from treating it as a precise scientific measurement.

**Renewable certification:** If the operator has certified their power source as renewable (green tariff), `gridEmissionFactor = 0`, and the card shows "Certified renewable energy ✓" and the "Equivalent to [N] km" line instead of the CO₂ comparison.

**When NOT to show carbon savings:** For fault-interrupted sessions where minimal energy was delivered (< 0.5 kWh), the carbon impact section is omitted. The environmental impact is too small to be meaningful and highlighting it after an unhappy session is tonally wrong.

---

## 20. Charging Statistics Presentation

Charging statistics give the user context about this session relative to their charging history. This section is low-priority but provides engagement and helps users track their charging habits.

### Statistics card (within collapsed "Your Stats" section)

```
  ┌─────────────────────────────────────────────────────┐
  │  YOUR STATS                                         │
  │                                                     │
  │  Sessions this month     7         (↑2 vs last)     │
  │  Energy this month       142.3 kWh                  │
  │  Spent this month        ¥8,538                     │
  │  Average session         20.3 kWh · 00:58           │
  │  ─────────────────────────────────────────          │
  │  All-time total                                     │
  │  34 sessions · 684 kWh · ¥41,040                    │
  └─────────────────────────────────────────────────────┘
```

**Month-over-month comparison:** The "(↑2 vs last)" label only appears when there is at least 2 full months of data (to avoid misleading comparisons for new users).

**Average session:** Computed server-side from all of the user's completed sessions. Displayed only after ≥5 sessions (to avoid unrepresentative averages for new users).

**This session vs. personal average (contextual note):**
A brief inline note below the stats: "This session: 24.71 kWh · 01:47. Your average: 20.3 kWh · 00:58. This was a longer-than-average session." `type.body.small`, `color.text.secondary`. Only shown when the session is ≥20% above or below the user's average — no note when it's a typical session (avoid noise).

---

## 21. Station Information Recap

The station recap is the lowest-priority section of the summary — the user already knows where they charged. It is collapsed by default and expanded only by those who need it (support references, bookmarking).

### Station info row (collapsed default, always visible)

```
  ─── Station ──────────────────────────────────── ▼
  Elm Street Charging Hub · CCS · Connector 3
  Session #4821K
```

A single compact row visible even when collapsed, giving enough context to identify the session without expanding.

### Station detail (expanded)

```
  ┌─────────────────────────────────────────────────────┐
  │  [Station photo 72dp circle or fallback bolt icon]  │
  │  Elm Street Charging Hub                            │
  │  12 Elm Street, District 4, Tehran                  │
  │  FastCharge Network                                 │
  │                                                     │
  │  Connector 3 · CCS DC Fast · 150 kW max             │
  │  Session ID: #4821K     [Copy]                      │
  │  Session started: 14 Jun 2026, 08:00:12 AM          │
  │  Session ended:   14 Jun 2026, 09:47:35 AM          │
  │                                                     │
  │  [Rate this station ★ ★ ★ ★ ★]                     │
  │  [Navigate ↗]  [View Station Details]               │
  └─────────────────────────────────────────────────────┘
```

**Session timestamps:** Full ISO-8601 local display (date + time + seconds). Seconds are shown on this screen for audit/dispute purposes — seconds matter when resolving billing edge cases.

**Rate this station (inline):** 5 star icons, tappable. On tap of a star rating:
- Stars fill to the selected rating immediately (animation: scale 1.0 → 1.2 → 1.0, 100ms)
- A brief inline text prompt slides down: "Add a note (optional)" with a 120dp text field
- "Submit" and "Skip" buttons
- On submit: rating is sent to `POST /stations/:id/ratings` and the field collapses
- On skip: rating only (no note) is submitted
- After submission: stars show the submitted rating in a muted state (not re-submittable)

**Navigate ↗:** Opens native maps to the station address. Useful for users who want to find the station again.

---

## 22. Vehicle Information Recap

In MVP, the app does not collect or store vehicle information — the user's vehicle type is unknown to the platform. This section is designed as a future expansion surface (see §33).

### MVP: no vehicle section

The "Vehicle" section is absent from the summary screen in MVP. No placeholder is shown.

### Post-MVP: vehicle section

When the user has a vehicle profile configured:

```
  ─── Vehicle ──────────────────────────────────── ▼
  2024 Tesla Model 3 LR · Charged to approx. 72%
```

Expanded:
```
  Vehicle           2024 Tesla Model 3 LR
  Est. SoC after    ~72% (based on 24.71 kWh added)
  Usable capacity   75 kWh (user-configured)
  Est. range added  ~180 km
```

"Est. SoC after" is calculated as: `previousSoC + (energyKwh / vehicleCapacityKwh × 100)`. Requires the user to have entered their previous SoC (from the session creation flow, future feature). This is explicitly marked as an estimate.

---

## 23. Session Timeline Visualization

The session timeline is a power-versus-time chart that tells the physical story of the charging session. It is particularly useful after abnormal sessions (fault, suspension, interruption) where understanding when things happened matters.

### Chart design

**Container:** Full-width card within the "Session Details" collapsible section.

- Height: 96dp for the chart area + 24dp for axis labels = 120dp card height
- Background: `color.surface`
- Border radius: `radius.lg`
- Padding: 16dp horizontal, 12dp top, 20dp bottom (for labels)

**Chart area (96dp):**

The chart is a filled area line chart — a smooth cubic spline curve connecting the power values from `ChargingRecord.meterValues[]`. The area below the line is filled with a gradient from `color.primary` at 30% opacity (at the line) to transparent (at the bottom). The line itself is 2dp, solid, gradient `color.primary` → `color.secondary` left to right.

**X axis (time):**
- Start: session start time (label at far left)
- End: session end time (label at far right)
- No intermediate tick marks unless session is >60 minutes (then add midpoint label)
- Labels: `type.label.small`, `color.text.tertiary`

**Y axis (power, kW):**
- No explicit Y axis line
- Two reference lines (dashed, 1dp, `color.outline` at 30%):
  - At peak power (labeled: "Peak: [N] kW", `type.label.small`, right-aligned, `color.text.tertiary`)
  - At average power (labeled: "Avg: [N] kW", `type.label.small`, right-aligned, `color.text.secondary`)

**Typical DC fast charge power curve shown:**
- Ramp phase: steep rise in first 2–5 minutes
- Plateau phase: sustained high power
- Taper phase: gradual decline as battery fills
- The curve shape itself communicates whether the charger performed as expected

### Fault/interruption annotation

If `stopReason` is a fault or power-loss type, a vertical red line is drawn at the moment of interruption, extending the full height of the chart area:
- Line: 1.5dp, `color.error`
- Label above the line: stop reason icon (⚠ 12dp, `color.error`) + abbreviated reason ("Fault", "Power loss")

### Suspension annotations

For each period where `SessionStatus` was `SuspendedByVehicle` or `SuspendedByCharger`, a shaded region is added to the chart:
- Background band: `color.warning` at 8% opacity
- The power line in this band is flat at 0 kW
- If there are multiple suspension periods, each gets its own band

### User-stopped annotation

A vertical line at the session end point:
- Line: 1.5dp, `color.secondary`
- Label: "You stopped" or "Vehicle signaled" depending on stop reason
- If the line is at the very end (normal completion), no explicit annotation is needed — the chart end is self-explanatory

### No chart data (charger does not report MeterValues frequently)

If `meterValues.length < 3` (some OCPP 1.6J chargers report only start and end meter readings):

The chart area is replaced with:

```
  [Chart icon 40dp, color.text.tertiary]
  Power curve unavailable
  This charger doesn't report live power data.
  type.body.medium, color.text.secondary, centered
```

The energy, duration, and peak power figures are still shown in the detail rows — only the visual chart is absent.

---

## 24. Session Stop Reason Presentation

Every session ended for a reason. The stop reason must be communicated in plain language, categorized by severity, and — for non-user-stopped sessions — accompanied by an explanation.

### Stop reason badge (in hero section, below title)

The stop reason badge appears directly below "Session Complete" in the hero section:

```
  ✓ Stopped by you                    (UserStopped — neutral)
  ✓ Vehicle fully charged             (VehicleFull — positive)
  ✓ Vehicle signaled complete         (VehicleRequested — positive)
  ⚠ Stopped by charger               (ChargerInitiated — warning)
  ⚠ Session timed out                (Timeout — warning)
  ✕ Power interruption               (PowerLoss — error)
  ✕ Charger fault                    (Faulted — error)
  ✕ Emergency stop                   (EmergencyStop — error)
     Session completed               (Unknown — neutral)
```

**Badge design:**
- Height: 28dp, `radius.full`
- Background: status color at 12% opacity
- Icon (✓ / ⚠ / ✕): 12dp, status color
- Label: `type.label.large`, status color

**Stop reason colors:**
| Reason category | Badge color | Hero background tint |
|----------------|-------------|---------------------|
| Positive (UserStopped, VehicleFull, VehicleRequested) | `color.secondary` | `color.secondaryContainer` |
| Warning (ChargerInitiated, Timeout) | `color.warning` | `color.warningContainer` |
| Error (PowerLoss, Faulted, EmergencyStop) | `color.error` | `color.errorContainer` |
| Neutral (Unknown) | `color.text.tertiary` | `color.surfaceVariant` |

### Stop reason explanations (expandable, within Session Details)

For non-user-initiated stop reasons, an explanation expands below the stop reason row in the details section. These are written in plain, non-technical language.

| Stop reason | Explanation |
|------------|-------------|
| `VehicleFull` | "Your vehicle's battery management system signaled that it was satisfied with the charge level. This is normal — the vehicle decides when it has enough." |
| `VehicleRequested` | "Your vehicle requested the session to end. This may be due to a charging schedule programmed in your vehicle's settings." |
| `ChargerInitiated` | "The charging station ended your session. This may be due to a scheduled maintenance window, load management, or an operator-defined session limit. Contact the operator if this was unexpected." |
| `Timeout` | "Your session was ended automatically because it reached the maximum session duration set by the operator. Energy delivery had already tapered off." |
| `PowerLoss` | "The charging station lost power unexpectedly. Your session has been finalized with the energy delivered up to that point." |
| `Faulted` | "The charging station reported a technical fault. Your session has been finalized. Energy delivered up to the fault is billed. Contact the operator if you have concerns." |
| `EmergencyStop` | "An emergency stop was activated. Your session was immediately terminated for safety. Energy delivered up to this point is billed." |
| `Unknown` | "The reason this session ended could not be determined from the charger's data. Energy and cost shown are based on the final meter reading." |

---

## 25. Error and Interrupted-Session Summaries

Sessions that end abnormally need a modified summary design that is honest, clear, and empathetic.

### Fault / Power-loss session summary

The hero section becomes an alert section:

```
  ┌─────────────────────────────────────────────────────┐
  │  [color.errorContainer background gradient]         │
  │                                                     │
  │  [⚠ icon 64dp, color.error]                         │
  │  Session Interrupted                                │
  │  ✕ Charger fault                                    │
  │                                                     │
  │  ┌──────────┬──────────┬──────────┐                 │
  │  │  8.21    │ 00:18:44 │  26.2 kW │                 │
  │  │  kWh     │ Duration │  Avg pwr │                 │
  │  └──────────┴──────────┴──────────┘                 │
  └─────────────────────────────────────────────────────┘
```

**The total cost card for fault sessions:**

```
  PARTIAL CHARGE BILLED                     type.label.small, color.error
  ¥992.60                                   type.numeric.display
  Energy delivered before fault             type.body.small, color.text.secondary
```

Background: `color.errorContainer` — the red tint communicates that this is not a normal completion.

**Fault session billing note:**

Below the billing breakdown, a bordered note in `color.errorContainer`:

```
  ⚠ You were charged only for energy delivered before the fault.
  No session fee applies to an interrupted session.  [What is this? →]
  Session fees are refunded if a session ends abnormally.
  type.body.small, color.text.secondary
```

"What is this? →" opens an in-app support article explaining fault billing policy.

**Operator fault refund flow (conditional):**

If the operator's configuration includes `faultRefundPolicy: full` (full refund on any fault):

```
  ✓ Full refund: ¥992.60 will be returned to your wallet
     within 1–3 business days.
  
  [Check Refund Status →]
```

If `faultRefundPolicy: partial` (energy billed, session fee refunded):

The billing breakdown shows session fee crossed out with strikethrough and "(refunded)" appended.

**Support contact for faulted sessions:**

Below the wallet card for fault sessions, always visible:

```
  ┌─────────────────────────────────────────────────────┐
  │  ⚠ Something went wrong?                            │
  │  If you believe you were incorrectly charged,       │
  │  contact us. Quote your Session ID: #4821K          │
  │                                                     │
  │  [Contact Support]  [Report Charger Issue]          │
  └─────────────────────────────────────────────────────┘
```

"Contact Support" opens the in-app support channel (chat or email, operator-configured).
"Report Charger Issue" submits a structured fault report: `POST /stations/:id/reports` with the session ID and `reportType: Fault`.

### Minimal-energy session summary

When `totalEnergyKwh < 0.5` (cable connected but almost no energy transferred — common when the session fails to authorize properly):

The summary shows a warning-category hero:

```
  ⚠ Very little energy was delivered
  ⚠ Power interruption

  0.03 kWh  |  00:01:12  |  ~1.5 kW avg

  Total charged: ¥0.00
  (Session fee waived for sessions under 0.1 kWh)
  or
  Total charged: ¥500.00 (session fee only)
```

**The de minimis session policy:** If energy is under a threshold (operator-configured, default 0.5 kWh), session fees may be waived or prorated. The screen must explicitly state which policy applied.

---

## 26. Offline Behavior

### What the summary screen can display offline

| Data | Offline availability | Source |
|------|---------------------|--------|
| Session header (energy, duration, cost) | Available if previously loaded | Hive cache, keyed `session_<id>_summary` |
| Billing breakdown | Available from cache | |
| Wallet balance | Last-known (possibly stale) | |
| Session timeline chart | Available from cache | |
| Station info | Available from cache | |
| Carbon stats | Available from cache | |
| Charging statistics | Not available | Requires server computation |
| Receipt download | Not available | |
| Tax invoice | Not available | |
| Station rating | Queued locally, sent when online | |

### Offline indicator

Standard offline banner: "Offline — showing saved session data." Appearing below the navigation bar, same design as HOME_SCREEN.md §10.

**Wallet balance when offline:** The wallet card shows "Balance now: [cached value] (last known)" with a small `color.warning` dot next to the balance — the balance may have changed since the summary was last fetched.

### Receipt download when offline

The "Download Receipt" button is shown but greyed (not fully disabled — the icon is greyed, the text changes to "Download when connected"). Tapping shows an inline tooltip: "Receipt download requires an internet connection."

### Receipt share when offline

The ↗ Share button still works — it shares the preformatted text block (which is constructed from cached data, not server-fetched).

---

## 27. Loading States

### Full-screen skeleton (loading on screen entry)

The `ChargingRecord` may not be immediately available when the screen opens — there is a brief finalization window (typically <3 seconds) after the OCPP `StopTransaction` is processed.

**Loading indicator approach:** Rather than a generic spinner, the loading state shows the charging session ring transitioning to a receipt — an animation that bridges the two screens:

- The session ring (now contracted to the 80dp medallion) rotates slowly, then completes with a checkmark
- Below it, the skeleton layout appears:

```
  [Ring medallion, 80dp, gentle rotation then completion]

  [Hero: 3 skeleton metric boxes, 80dp × 60dp each]

  [Total cost card: 120dp skeleton rectangle]

  [Breakdown card: 5 skeleton rows, each 48dp]

  [Wallet card: 3 skeleton rows]
```

**Shimmer:** Standard shimmer (LTR → RTL in fa locale), 1.2s period.

### Partial loading (header fast, breakdown slow)

The `ChargingRecord` endpoint returns data in phases:
1. Basic metrics (energy, duration, cost total) — fast, within 500ms
2. Meter values array (for timeline chart) — slower, within 2s
3. Charging statistics — slowest, computed on demand, up to 3s

The screen loads section by section:
- Hero, total cost card, and wallet card: render as soon as basic metrics arrive
- Billing breakdown: renders with basic metrics (the line items are derived from the same call)
- Session timeline chart: skeleton while meter values load, then renders
- Charging statistics: skeleton in "Your Stats" section while computing, then renders

If the timeline chart data takes >3 seconds: a timeout state within the chart area — "Chart loading slowly. Try refreshing." with a "Refresh" Tertiary icon button.

### Receipt finalization loading

In the moment after session completion and before the `ChargingRecord` is finalized:

A full-screen, non-dismissable loading state:

```
  [Ring medallion, gentle pulse, color.primary]

  Finalizing your session…
  type.headline.small, centered

  Computing your energy total and billing.
  This takes a few seconds.
  type.body.medium, color.text.secondary, centered
```

After 8 seconds without a finalized record: the loading state adds: "Taking longer than expected. The session will be finalized shortly — check your wallet for the final amount." A "Check Wallet" Secondary button appears. After 30 seconds: the loading gives up and shows an error state (§29).

---

## 28. Empty States

### Session ID valid but no session data

This should not occur in normal flow (the route is only reachable after a session exists), but defensively:

```
  [Illustration: receipt with question mark, 96dp]

  Session not found
  type.headline.small

  We couldn't load this session's details.
  It may still be processing.
  type.body.medium, color.text.secondary

  [  Try Again  ]  ← Primary Large
  [  Check Wallet  ]  ← Secondary
```

### User has no sessions (navigated here through some unexpected path)

```
  [Illustration: empty EV dashboard, 96dp]

  No sessions yet
  type.headline.small

  Your charging history will appear here
  after your first session.
  type.body.medium, color.text.secondary

  [  Find a Station  ]  ← Primary Large
```

---

## 29. Error States

### ChargingRecord finalization timeout (>30 seconds)

```
  [Warning icon 48dp, color.warning]

  Session still finalizing
  type.headline.small

  Your charging session is complete, but the
  final billing calculation is taking longer
  than expected. You will receive a notification
  when it's ready.
  type.body.medium, color.text.secondary

  Estimated energy: ~24.7 kWh
  (based on last meter reading)

  [  Check Wallet Later  ]  ← Primary Large
  [  Contact Support    ]  ← Tertiary
```

The estimated energy is shown from the last MeterValues reading available — clearly marked as an estimate. No cost is shown (the billing is not finalized). A push notification fires when the record is finalized.

### Billing discrepancy detected server-side

If the server detects that the computed billing amount differs from what was shown during the session (e.g., a tariff lookup failed and had to use a fallback), an amber notice appears below the total cost card:

```
  ⚠ Your billing was adjusted during finalization.
  The amount shown reflects the final confirmed charge.
  Session rate: ¥60/kWh (fallback — live rate unavailable at session start)
  [Why did this happen? →]
```

"Why did this happen?" links to an in-app FAQ article.

### Wallet deduction failed (post-session billing failure)

Rare but critical: the session completed but the wallet deduction failed (e.g., a race condition where the wallet was depleted by another transaction between session start and end).

```
  ⚠ Payment pending
  type.headline.small, color.warning

  ¥2,032.60 will be charged when resolved.
  type.body.medium, color.text.secondary

  Your wallet balance at session end was insufficient
  to cover the full session cost. The charge is pending
  and will be collected when you next add funds.

  [  Top Up Now  ]  ← Primary Large (resolves the pending charge)
  [  Contact Support  ]  ← Tertiary
```

A persistent amber badge appears in the Wallet tab until the pending charge is resolved.

### Receipt generation failure

The receipt generation API fails. Error shown within the download sheet (not a new screen):
- Primary button loading state resolves to error state: "Download failed" with a retry spinner option
- After 2 retries, show: "Receipt generation is unavailable. Email us at support@[operator] with session ID #4821K for a receipt." `type.body.small`, `color.text.secondary`

---

## 30. Accessibility Requirements

### Screen reader announcement on entry

Immediately on screen entry, the screen reader announces: "Charging session complete. [Energy] kilowatt-hours delivered. [Duration] hours and minutes. Total charged: [Amount]. Stopped by [reason]."

This announcement fires once and covers the four most critical data points. The user can then navigate to individual elements for detail.

### Heading hierarchy

- Screen title "Session Summary" — heading level 1 (not shown visually but present in semantics)
- "Session Complete" / "Session Interrupted" — heading level 2
- Section headers ("BILLING BREAKDOWN", "WALLET", "STATION") — heading level 3

### Numeric values

Each metric in the hero section has a full accessibility label that spells out the unit:

| Displayed | Accessibility label |
|-----------|---------------------|
| "24.71 kWh" | "24 point 71 kilowatt-hours" |
| "01:47:23" | "1 hour, 47 minutes, 23 seconds" |
| "13.8 kW" | "13 point 8 kilowatts average power" |
| "¥2,032.60" | "2032 tomans and 60 dinars" (in fa locale) |

### Chart accessibility

The session timeline chart is marked as a decorative image with a text alternative: "Power chart: session started at [time], peaked at [peak kW] after [N] minutes, tapered to end at [time]. Average power: [average kW]."

Users navigating with VoiceOver/TalkBack can skip the chart without losing information — all chart data is also present in text form within the Session Details section.

### Focus management

- On screen entry: focus moves to the status hero heading ("Session Complete")
- Collapsible sections: each section header is a button (expand/collapse). Screen reader announces "[Section name], collapsed. Double-tap to expand." or "expanded. Double-tap to collapse."
- "Rate this station" stars: announced as "Rate [station name]. [N] stars. Double-tap to select." When a star is tapped, the note field is announced as "Optional: add a note. Text field. Double-tap to type."
- Download sheet: focus moves to sheet title on open; returns to "Download Receipt" button on close

### Color and contrast

All text in the summary meets WCAG 2.1 AA (4.5:1 minimum). The `¥2,032.60` total in `type.numeric.display` on `color.secondaryContainer` background meets the 3:1 minimum for large text. Critical financial values (the total, wallet before/after) meet AAA (7:1).

### Touch targets

All interactive elements: 44×44dp minimum.
- Timeline chart expand button: 44dp height × full width
- Section expand/collapse rows: 48dp minimum height
- Star rating taps: each star occupies a 44dp × 44dp touch region (stars are 24dp visual with generous invisible hit areas)
- Overflow menu "···": 44×44dp icon button

---

## 31. RTL Behavior (Persian / Farsi)

### Hero section metrics

Metrics in the 3-column hero row:
- In LTR: Energy | Duration | Avg Power (left to right)
- In RTL: Avg Power | Duration | Energy (right to left — start of reading direction carries the first meaningful metric)

Each metric value within its cell: right-aligned in RTL. Units: follow the number (Persian convention).

### Numeric formatting

| Displayed (en) | Displayed (fa) |
|----------------|----------------|
| 24.71 kWh | ۲۴٫۷۱ کیلووات‌ساعت |
| ¥2,032.60 | ۲٬۰۳۲٫۶۰ تومان |
| 01:47:23 | ۰۱:۴۷:۲۳ (LTR container) |
| 13.8 kW | ۱۳٫۸ کیلووات |
| ~4.9 kg CO₂ | ~۴٫۹ کیلوگرم دی‌اکسیدکربن |
| 35 km | ۳۵ کیلومتر |

**Duration (HH:MM:SS):** Always in an explicit LTR container with Inter font. The surrounding sentence is RTL, the time value is LTR.

**Session ID and Transaction ID:** Always in explicit LTR containers, Latin characters only, monospace Inter font.

**Meter start/end values (for advanced users):** Always LTR, as these are meter odometer readings.

### Billing breakdown layout

In RTL:
- Component label: right-aligned (start)
- Sub-label (formula): right-aligned, below component
- Amount: left-aligned (end)

Cost formula sub-labels in Persian:
- "24.71 kWh × ¥60/kWh" → "۲۴٫۷۱ کیلووات‌ساعت × ۶۰ تومان/کیلووات‌ساعت"
- "5 min × ¥10/min" → "۵ دقیقه × ۱۰ تومان/دقیقه"

### Calendar and date display

Session timestamps in Persian locale:
- Gregorian "14 Jun 2026 · 08:00 AM" → Shamsi "۲۴ خرداد ۱۴۰۵ · ۰۸:۰۰"
- Timestamps in the receipt document: Shamsi date, Persian digits, Persian month name

### Session timeline chart

In RTL: the chart is mirrored — time flows from right (session start) to left (session end). The X axis labels swap positions. The gradient direction reverses: `color.secondary` → `color.primary` (right to left). The fault/suspension annotations mirror to their correct temporal positions.

### Shared text (Persian)

The ↗ Share action formats the text in Persian as shown in §17.

### Receipt PDF (Persian)

The PDF is generated server-side with RTL layout when the user's locale is `fa`. Right-to-left text, Persian digits, Shamsi dates, Vazirmatn font. The app passes `Accept-Language: fa` on the receipt generation request; the server applies the correct template.

---

## 32. Analytics Events

These events are fired from the Charging Summary screen. They are not implementation guidance — they are product requirements. The analytics system must capture these to enable product decisions.

### Session summary events

| Event name | Trigger | Properties |
|-----------|---------|------------|
| `session_summary_viewed` | Screen entry | `session_id`, `stop_reason`, `energy_kwh`, `cost_cents`, `duration_seconds`, `session_type` (walk-up/reservation), `is_fault` |
| `session_summary_time_on_screen` | Screen exit | `duration_seconds_on_screen`, `max_scroll_depth` (which section was reached) |
| `session_summary_exit_intent` | User taps "Back to Map" or "Done" | `time_on_screen_seconds` |

### Section engagement events

| Event name | Trigger | Properties |
|-----------|---------|------------|
| `section_expanded` | Any collapsible section expands | `section_name` (session_details/carbon/stats/station) |
| `billing_formula_expanded` | Tap on energy/time line item | `component_type` |
| `tariff_detail_expanded` | "Locked at booking" tapped | — |
| `fault_explanation_viewed` | Stop reason explanation read | `stop_reason` |

### CTA engagement events

| Event name | Trigger | Properties |
|-----------|---------|------------|
| `receipt_download_initiated` | Download sheet opened | — |
| `receipt_download_completed` | PDF/PNG saved successfully | `format` (pdf/png), `has_tax_invoice` |
| `receipt_download_failed` | Download error | `error_type` |
| `receipt_shared` | OS share sheet opened | `share_content_type` (text/image) |
| `tax_invoice_requested` | Tax invoice toggle enabled | `has_saved_details` |
| `carbon_badge_tapped` | Carbon section expanded | — |
| `station_rated` | Star rating submitted | `rating_stars` (1–5), `has_note` |
| `station_rating_skipped` | "Skip" tapped on note prompt | — |
| `wallet_viewed` | "View in Wallet" tapped | — |
| `support_contacted` | "Contact Support" tapped | `context` (billing/fault) |
| `fault_reported` | "Report Charger Issue" tapped | `stop_reason` |
| `low_balance_topup_tapped` | "Top Up Now" from low-balance banner | — |

### Business intelligence properties (on all events)

`user_id_hash` (anonymized), `station_id`, `operator_id`, `connector_type`, `locale`, `session_stop_reason`, `is_reservation_originated`.

---

## 33. Future Expansion Opportunities

### V2G / Vehicle to Grid session summary

When the session was a vehicle-to-grid export session (future feature — see ARCHITECTURE_FINAL.md §23):

**Hero section:**
- Title: "Export Complete" (not "Session Complete")
- Stop reason badge: "↑ Energy exported to grid"
- Metrics: Energy Exported / Duration / Avg Export Power

**Total cost card becomes a "Total Earned" card:**
```
  GRID CREDIT EARNED                    color.secondary
  + ¥744.00                             type.numeric.display, color.secondary (green, not price red)
  Added to your wallet                  type.body.small
```

**Billing breakdown becomes "Credit breakdown":**
- "Energy exported: 12.4 kWh × ¥60/kWh = ¥744.00"
- "Grid export fee: −¥0.00 (waived)" or "Grid export fee: −¥50.00"

**Carbon section:** "Energy contributed to grid: 12.4 kWh — helped power [N] homes for [N] hours." The user is a contributor, not a consumer.

### Smart Charging session summary

When the session ran on an off-peak smart charging schedule:

**Savings banner (above billing breakdown):**
```
  ⚡ Smart Charging saved you ¥[amount]
  You charged during off-peak hours.
  Off-peak: ¥45/kWh vs. peak: ¥74/kWh
```

**Billing breakdown:** Shows the time-of-use breakdown (same as dynamic pricing, §11), but with an explicit "Smart Charging" label on the off-peak rows.

### Subscription-based session summary

When the user is on a subscription plan (operator-specific, future):

**Hero total cost:** "¥0.00 — included in subscription" or "¥[overage] (over [plan limit] kWh)"

**New billing section:** "Subscription usage":
```
  Monthly plan:     250 kWh included
  Used this month:  142.3 kWh (before this session)
  This session:     + 24.71 kWh
  Total used:       167.01 kWh / 250 kWh
  [Progress bar: 66.8% of monthly limit]
  Remaining:        82.99 kWh until end of month
```

### Charging efficiency insights (AI-generated, future)

A personalized insight card below the session stats:

```
  💡 Insight
  Your CCS fast charger sessions average 76% efficiency —
  above the network average of 68%. Your vehicle appears
  to be well-matched to high-power DC charging.
```

Or for problematic patterns:
```
  💡 Tip
  This station's average session delivers 40% less
  power than its rated capacity. Consider a different
  station for faster charging.
```

### Carbon offset purchase (future)

Below the carbon savings card:

```
  🌱 Offset your remaining footprint
  This session: ~[net CO₂] kg (grid portion)
  Offset for ¥[amount]  [Offset Now]
```

"Offset Now" deducts from wallet and purchases a verified carbon credit (via operator partnership). A "Fully offset ✓" badge appears on the session summary and in the wallet history.

### Fleet receipt aggregation (future)

For fleet accounts: a "Group sessions" toggle on the summary. When active: this session's receipt can be attached to a fleet expense report. "Add to fleet report" creates a draft expense entry in the fleet management portal.

---

## 34. Transitions and Animations

### Entry transitions

| Entry path | Animation | Duration |
|-----------|-----------|---------|
| Auto-transition from live session | Ring contracts (220→80dp) + background fades dark→light + hero content fades in | 400ms, spring + ease-out |
| Push from notification / deep link | Slide up from bottom | 350ms, ease-out |
| Push from wallet history | Standard horizontal push | 300ms |
| Push from reservation history | Standard horizontal push | 300ms |

### Hero completion animation (auto-transition path only)

The contracted ring medallion (80dp) in the hero area:
- Starts at 80dp, spins once (360°, 400ms ease-in-out)
- Resolves to the ✓ checkmark symbol (300ms, scale 0.5→1.0, spring)
- A radial ripple expands from the medallion: `color.secondary` at 30% → transparent, radius 80dp → 200dp, 500ms ease-out
- The hero stat boxes cascade in: left box fades up (150ms), center box (200ms, 80ms delay), right box (150ms, 160ms delay)

For fault/error sessions: the medallion resolves to a ⚠ icon. No radial ripple. The hero background tints to `color.errorContainer`.

### Billing breakdown entry

Each line item in the billing breakdown animates in with a 100ms stagger (each row fades up 16dp → 0, 200ms ease-out):
1. Section header
2. Line items (staggered 100ms apart)
3. Divider slides in (left to right in LTR, right to left in RTL), 200ms
4. Total row: fades up, `type.numeric.large` counter-animates from 0 to the final value (300ms, ease-out) — the number appears to "fill in"

### Collapsible section expand/collapse

- Expand: height animates from 0 to full height, 250ms ease-out; content fades in 200ms with 50ms delay
- Collapse: height animates from full to 0, 200ms ease-in; content fades out 150ms
- Arrow icon: rotates 0° → 180° (expand) or 180° → 0° (collapse), 200ms

### Star rating animation

On star tap:
- Tapped star: scale 1.0 → 1.35 → 1.0, spring, 200ms
- Stars to the left/below (selected): fill in `color.warning`, sequential 50ms delay per star
- Note field: slides down 200ms ease-out

### Cost counter animation (entry)

The `¥2,032.60` total in the hero total card animates from ¥0.00 to the final value over 800ms, ease-out cubic. The number increments are not linear — they decelerate as they approach the final value (the last ¥100 takes as long as the first ¥1,000). This creates a satisfying "settling" effect.

This animation only runs on the first view of this screen for this session. On historical access (Path C), the number appears instantly.

### Reduced motion

Under `AccessibilityFeatures.reduceMotion`:
- Ring contract animation: instant position change + instant checkmark
- Ripple: no animation (omitted)
- Billing breakdown entry: no stagger, instant appearance
- Cost counter animation: instant final value display
- Section expand/collapse: instant height change, 100ms content fade
- Star animation: no scale animation, instant fill

---

*This document specifies the complete Charging Summary experience across all session types, states, and failure modes. It is the platform's last interaction in every charging journey. Every word it shows the user is a decision about trust. No ambiguity, no missing states, no surprises. Implementation proceeds only with full alignment on every section defined here.*