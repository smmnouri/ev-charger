# Wallet Screens

**Tab:** 4 of 5 (second from right)  
**Primary route:** `/wallet`  
**Child routes:** `/wallet/topup` · `/wallet/transactions/:id`  
**Last Updated:** 2026-06-11  
**References:** DESIGN_SYSTEM.md · ARCHITECTURE_FINAL.md §13 · CHARGING_SUMMARY_SCREEN.md §13-14

The wallet is the financial backbone of the platform. It is a prepaid balance system: users load funds before charging, and each session deducts from that balance. The wallet's append-only, immutable ledger model means every transaction is permanent and auditable. The UI must reflect that permanence: no ambiguous pending states, no round numbers, no hidden fees.

---

## Table of Contents

1. [Wallet Architecture for UI](#1-wallet-architecture-for-ui)
2. [Wallet Overview Screen (Tab 4)](#2-wallet-overview-screen-tab-4)
3. [Balance Display Design](#3-balance-display-design)
4. [Transaction History List](#4-transaction-history-list)
5. [Transaction Detail Screen](#5-transaction-detail-screen)
6. [Transaction Types Catalog](#6-transaction-types-catalog)
7. [Low Balance States](#7-low-balance-states)
8. [Loading States](#8-loading-states)
9. [Empty State](#9-empty-state)
10. [Error States](#10-error-states)
11. [Offline Behavior](#11-offline-behavior)
12. [Accessibility Requirements](#12-accessibility-requirements)
13. [RTL Behavior](#13-rtl-behavior)
14. [Analytics Events](#14-analytics-events)

---

## 1. Wallet Architecture for UI

The wallet ledger is append-only. Transactions are never edited or deleted — only new entries are added (including correction and refund entries). The UI must surface this model honestly.

**Balance computation:** `currentBalance = SUM(credit transactions) − SUM(debit transactions)`. The balance shown to the user is always computed from the full ledger, not a cached balance field that could drift.

**Unit:** All internal values are in the smallest currency unit (Rials for Iranian deployment). Display converts to Tomans: `displayTomans = rails / 10`. The `CurrencyFormatter` handles this conversion. The user always sees Tomans; the system always stores Rials.

**Transaction types (sealed enum):**

| Type | Direction | Icon | Color |
|------|-----------|------|-------|
| `TopUp` | Credit (+) | ↓ arrow in circle | `color.secondary` |
| `SessionDebit` | Debit (−) | ⚡ bolt | `color.primary` |
| `ReservationFee` | Debit (−) | 📅 calendar | `color.tertiary` |
| `CancellationFee` | Debit (−) | ✕ x-mark | `color.warning` |
| `NoShowFee` | Debit (−) | ⏰ clock | `color.warning` |
| `Refund` | Credit (+) | ↩ return arrow | `color.secondary` |
| `OperatorCredit` | Credit (+) | ★ star | `color.tertiary` |
| `PendingCharge` | Debit (−, pending) | ⏳ hourglass | `color.text.tertiary` |

---

## 2. Wallet Overview Screen (Tab 4)

### Tab badge behavior

The Wallet tab shows an alert dot (`color.warning`, static) when:
- Wallet balance is below the low-balance threshold
- A pending charge is unresolved
- A refund has been processed since last visit

### Screen layout

```
┌──────────────────────────────────────────────────────────────┐
│  Wallet                                    [Transaction ↓]    │  ← Nav bar
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │  ← Balance card
│  │  BALANCE                                            │    │
│  │  ¥47,967                                            │    │
│  │  .40 tomans                                         │    │
│  │                                                     │    │
│  │  [+ Add Funds]          [Transaction History]       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  RECENT TRANSACTIONS                                         │  ← Section header
│  ┌─────────────────────────────────────────────────────┐    │
│  │  ⚡  Elm Street Charging Hub      − ¥2,032    ▸    │    │  ← Debit card
│  │     14 Jun · CCS · 24.71 kWh                       │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  ↓   Top-up via card              + ¥20,000   ▸   │    │  ← Credit card
│  │     13 Jun · Bank card *1234                        │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  ↩  Refund — North District Hub   + ¥500      ▸   │    │  ← Refund
│  │     12 Jun · Operator fault refund                 │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  View All Transactions  →                           │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 3. Balance Display Design

The balance card is the primary element of the wallet screen. It receives the most visual weight.

### Balance card

- Background: gradient from `color.primary` (#0F5EFF) at the top-left to `color.tertiary` (#6B4EFF) at the bottom-right — a premium, bold card
- Border radius: `radius.xl` (20dp)
- Padding: 24dp
- Height: 180dp

**"BALANCE" label:** `type.label.small`, letter-spaced, white at 70%

**Amount display:**

The balance is displayed in two tiers:

```
  ¥47,967           ← type.numeric.display (48sp/700), white
        .40 tomans  ← sub-toman portion, type.title.medium, white at 60%
                      + " tomans" label, type.body.small, white at 60%
```

The integer and fractional parts are typographically separated: the main figure large and bold, the fractional part smaller and lower, inline. This pattern avoids the visual noise of showing two decimal places at full size for a balance that may be ¥50,000.

**Negative balance (should not occur, but defensive):**

```
  − ¥1,500.00       ← color.error on white (inverted card: white background, error red text)
```

If balance is negative (system error / pending charge not collected), the card background inverts: white background with red text. A warning banner appears below: "Your account has a pending balance. Add funds to resolve."

### Action buttons in balance card

Two buttons at the bottom of the card:

**"+ Add Funds" (Primary, white background, `color.primary` text, 44dp, radius.full):**
Opens the top-up flow (PAYMENT_FLOW.md). This is the most important action in the Wallet tab.

**"Transaction History" (Tertiary, white at 80% text, 44dp):**
Scrolls to the transaction list section, or navigates to the full transaction history screen on small devices.

### Balance privacy toggle (overflow menu "···")

In the navigation bar overflow: "Hide balance" — replaces the numeric balance with "••••" (masking). Tap anywhere on the card to reveal. State persists for the session only (does not persist across app restarts).

---

## 4. Transaction History List

The transaction list is a chronologically ordered ledger. Most recent first.

### Section grouping

Transactions are grouped by month:
```
  JUNE 2026
  [transaction cards]

  MAY 2026
  [transaction cards]
```

Month headers: `type.label.small`, letter-spaced, `color.text.tertiary`, 12dp vertical padding.

### Transaction card (72dp height)

```
  [Icon 40dp]   Transaction title         + ¥20,000  ▸
                Date · Sub-detail          (or − ¥2,032)
```

**Icon circle (40dp, `radius.full`):**
- Background: transaction type color at 12% opacity
- Icon: transaction type icon (20dp), transaction type color

**Primary text:** Transaction title, `type.title.medium`, `color.text.primary`, 1 line
**Secondary text:** Date in locale format + separator dot + sub-detail, `type.body.small`, `color.text.secondary`

**Amount (end-aligned):**
- Credit: "+ ¥[amount]", `type.numeric.medium`, `color.secondary`
- Debit: "− ¥[amount]", `type.numeric.medium`, `color.error`
- Pending: "[amount]", `type.numeric.medium`, `color.text.tertiary`

**Trailing ▸:** 16dp chevron, `color.text.tertiary`, indicating the row is tappable to view detail.

**Divider:** 1dp `color.outline` at 20%, start-inset by 56dp (aligns with text start, not icon start).

### Running balance

A subtle running balance can be toggled via the navigation bar: "Show running balance" toggle. When active, each transaction card shows an additional line below the amount: "Balance: ¥[balance after this transaction]" `type.label.small`, `color.text.tertiary`, right-aligned.

### Pagination

The transaction list loads 20 items per page. A "Load more" button appears at the bottom of each loaded group when more are available. Cursor-based pagination per ARCHITECTURE_FINAL.md §8.

---

## 5. Transaction Detail Screen

Route: `/wallet/transactions/:id`

### Layout

Header: transaction icon (64dp circle, large version of the list icon), transaction title centered.

**Amount display:** Large, centered. Same split typography as the balance card:
- Credit: "+ ¥20,000.00", `type.numeric.display`, `color.secondary`
- Debit: "− ¥2,032.60", `type.numeric.display`, `color.error`

**Detail rows (key–value pairs):**

| Field | Detail |
|-------|--------|
| Date & Time | Full timestamp (date + time + seconds) |
| Type | Human-readable transaction type |
| Status | Confirmed / Pending |
| Reference | Transaction ID (long-press to copy) |
| Balance after | Wallet balance after this transaction |

For `SessionDebit` type: additional rows linking to the session:
- Energy delivered, duration, connector, station
- "View Session Summary →" Tertiary link

For `Refund` type: additional row: "Refund for: [original transaction reference]"

For `TopUp` type: payment method details (card last 4 digits, bank name), payment gateway reference.

---

## 6. Transaction Types Catalog

### SessionDebit

Title format: "[Station name]"
Sub-detail: "[Energy] kWh · [Connector type]"
Amount: negative, `color.error`

### TopUp

Title: "Top-up via [payment method]"
Sub-detail: "[Bank name] card *[last 4]" or "Bank transfer"
Amount: positive, `color.secondary`

### ReservationFee

Title: "Reservation fee — [Station name]"
Sub-detail: "Reserved [date]"
Amount: negative (or ¥0 if free reservation), `color.tertiary`

### CancellationFee

Title: "Cancellation fee — [Station name]"
Sub-detail: "Reservation cancelled [date]"
Amount: negative, `color.warning`

### NoShowFee

Title: "No-show fee — [Station name]"
Sub-detail: "Reservation expired [date]"
Amount: negative, `color.warning`

### Refund

Title: "Refund — [reason]"
Sub-detail: "For session/reservation on [date]"
Amount: positive, `color.secondary`

### PendingCharge

Title: "Pending charge — [Station name]"
Sub-detail: "Will be collected when resolved"
Amount displayed in `color.text.tertiary` with a ⏳ icon prefix, no + or − prefix
Additional row in detail: explanation of why the charge is pending

---

## 7. Low Balance States

The threshold for "low balance" is operator-configured (default: ¥5,000). When `balance < threshold`:

### Wallet tab badge

Static amber dot (no count number) appears on Tab 4.

### Balance card warning

A 36dp amber banner appears within the balance card, below the action buttons:
```
  ⚠ Low balance — add funds before your next charge
```
`type.body.small`, amber text, inline within the card. The card background gradient does not change.

### Screen-level prompt

An inline card below the balance card (above transaction history):
```
  ┌──────────────────────────────────────────────────┐
  │  ⚠ Your balance may not cover your next charge.  │
  │  Most sessions require at least ¥2,000.          │
  │  [Add Funds Now →]                               │
  └──────────────────────────────────────────────────┘
```
`color.warningContainer` background, `radius.md`. Dismissable (swipe off or ✕). Dismissed state persists until the balance drops below threshold again after a top-up.

### Zero balance

If `balance = 0`:
The balance card changes:
- Background: `color.surfaceVariant` (grey — loss of the premium gradient signals inability to act)
- Balance display: "¥0" in `color.text.secondary`
- "+ Add Funds" button becomes Primary filled with `color.warning` background — urgency without alarm

---

## 8. Loading States

**Balance card:** Skeleton fills the card area — two rectangles: 120dp × 24dp (label), 180dp × 52dp (amount). Standard shimmer.

**Transaction list:** 3 card skeletons (72dp each), each with: 40dp circle + two rectangles. Shimmer in reading direction.

The balance loads first (fast, from the API balance endpoint). The transaction list may lag by 500ms–1s. The screen renders the loaded balance immediately; the list section shows skeletons until ready.

---

## 9. Empty State

When the wallet has never had any transactions:

```
  [Balance card — shows ¥0 with no transactions]

  [Illustration: empty wallet / EV with question mark]
  No transactions yet
  type.headline.small, centered

  Add funds to your wallet to start charging.
  type.body.medium, color.text.secondary, centered

  [  Add Funds  ]  ← Primary Large
```

---

## 10. Error States

### Balance fetch failed

```
  [Error icon in balance card area]
  Balance unavailable · Try Again
  type.body.medium, color.error
```
"Try Again" link refetches. The transaction list may still load (separate endpoint).

### Transaction list fetch failed

The balance card renders normally. The transaction history section shows:
```
  Couldn't load transactions.  [Retry →]
```
Retry link refetches the transaction list only.

---

## 11. Offline Behavior

**Balance:** Last known balance shown with a `color.warning` dot and "Balance as of [last sync time]" sub-label.

**Transaction list:** Cached transactions shown. A banner: "Offline — showing saved transactions." New transactions from other devices not reflected.

**"Add Funds" button while offline:** Tapping shows a sheet: "Add funds requires an internet connection." No navigation.

---

## 12. Accessibility Requirements

**Balance card:** Accessibility label: "Wallet balance: [amount] tomans." When privacy mode active: "Wallet balance hidden. Double-tap to reveal."

**Each transaction card:** "[Transaction type]. [Station name or description]. [Amount] tomans [credited/debited]. [Date]. Double-tap to view details."

**Low balance banner:** Announced as a live region update when balance drops below threshold during the session.

**Running balance toggle:** Accessibility label: "Toggle running balance display."

---

## 13. RTL Behavior

**Balance card:** Amount right-aligned in RTL (natural for RTL reading). "+ Add Funds" and "Transaction History" buttons mirror positions.

**Transaction cards:** Icon on right (start), amount on left (end), text right-aligned.

**Amount formatting:**
- Credit: "+ ۲۰٬۰۰۰٫۰۰ تومان"
- Debit: "− ۲٬۰۳۲٫۶۰ تومان"

**Month header:** Persian month names (فروردین, اردیبهشت, خرداد…). Year in Persian-Indic digits.

**Running balance:** Left-aligned (end side) in RTL.

---

## 14. Analytics Events

| Event | Trigger | Properties |
|-------|---------|------------|
| `wallet_viewed` | Tab opens | `balance_cents`, `transaction_count` |
| `add_funds_tapped` | "+ Add Funds" tap | `current_balance_cents` |
| `transaction_detail_viewed` | Transaction card tap | `transaction_type`, `amount_cents` |
| `balance_hidden` | Privacy toggle | — |
| `low_balance_prompt_dismissed` | Dismiss banner | `balance_cents` |
| `running_balance_toggled` | Toggle | `enabled` |