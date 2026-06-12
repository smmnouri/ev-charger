# Payment Flow

**Routes:** `/wallet/topup` · `/wallet/topup/method` · `/wallet/topup/confirm` · `/wallet/topup/result`  
**Entry points:** "+ Add Funds" in Wallet tab · Low-balance prompt · Session start confirmation (insufficient balance) · Reservation check-in (insufficient balance)  
**Last Updated:** 2026-06-11  
**References:** DESIGN_SYSTEM.md · ARCHITECTURE_FINAL.md §13 · WALLET_SCREENS.md

The top-up flow is the only place in the app where money moves from the user's bank account into the platform wallet. Every design decision here must communicate security, transparency, and reversibility. A user who trusts the payment flow will top up generously; one who is anxious about it will use the minimum possible amount and contact support when anything goes wrong.

---

## Table of Contents

1. [Payment Architecture](#1-payment-architecture)
2. [Amount Selection Screen](#2-amount-selection-screen)
3. [Payment Method Screen](#3-payment-method-screen)
4. [Payment Gateway Handoff](#4-payment-gateway-handoff)
5. [Payment Confirmation Screen](#5-payment-confirmation-screen)
6. [Payment Success Screen](#6-payment-success-screen)
7. [Payment Failure Handling](#7-payment-failure-handling)
8. [Transaction Verification and Idempotency](#8-transaction-verification-and-idempotency)
9. [Saved Payment Methods](#9-saved-payment-methods)
10. [Loading States](#10-loading-states)
11. [Offline Behavior](#11-offline-behavior)
12. [Accessibility Requirements](#12-accessibility-requirements)
13. [RTL Behavior](#13-rtl-behavior)
14. [Security Considerations in UI](#14-security-considerations-in-ui)

---

## 1. Payment Architecture

**Payment gateway:** The app integrates with the Iranian Shaparak payment network via a configured payment gateway (Zarinpal, IDpay, or similar). The gateway interaction is handled via a WebView or in-app browser — the card data is entered entirely within the gateway's secure environment. The app never handles raw card numbers.

**Top-up flow:**

```
  App creates payment intent
  ↓
  `POST /payments/intents` → returns {intentId, gatewayUrl}
  ↓
  App opens gateway URL in in-app browser (WebView)
  ↓
  User completes payment (card entry + OTP)
  ↓
  Gateway redirects to deep link: `evcharger://payment/result?intentId=&status=`
  ↓
  App closes WebView, fetches final status: `GET /payments/intents/:id`
  ↓
  On success: wallet balance updated via server → Push event → UI refreshes
```

**Idempotency:** Each payment intent has a unique ID. If the app is killed mid-payment and reopened, the same intent ID is reused — no double-charge.

**Currency:** All amounts entered in Tomans (user-facing). The API receives amounts in Rials (`amountRials = tomans × 10`).

---

## 2. Amount Selection Screen

### Layout

```
┌──────────────────────────────────────────────────────────────┐
│  ← Back                                                      │
│  Add Funds                                                   │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Current balance: ¥47,967                           │    │  ← Balance context
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  How much would you like to add?                            │
│  type.headline.small                                         │
│                                                              │
│  ┌──────────┬──────────┬──────────┐                         │  ← Quick amounts
│  │ ¥10,000  │ ¥20,000  │ ¥50,000  │                         │
│  └──────────┴──────────┴──────────┘                         │
│  ┌──────────┬──────────┬──────────┐                         │
│  │ ¥100,000 │ ¥200,000 │ Custom   │                         │
│  └──────────┴──────────┴──────────┘                         │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │  ← Custom input (conditional)
│  │  ¥ [____________] tomans                            │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  Minimum: ¥5,000 · Maximum: ¥500,000 per transaction        │
│  type.body.small, color.text.tertiary                        │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Balance after: ¥67,967                             │    │  ← Live preview
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Continue →                                         │    │  ← Primary CTA
│  └─────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
```

### Quick amount chips

6 chips in a 3×2 grid. Chip design: 96dp × 48dp, `radius.md`, `color.surfaceVariant` background. Selected: `color.primary` background, white text.

**Contextual chip highlighting:** If the user arrived from a "low balance" prompt during a session start flow, the chip that would bring the balance above the minimum session threshold is highlighted with a `color.warning` border: "Minimum needed" sub-label.

### Custom amount input

Appears when "Custom" chip is tapped. A large numeric input field (48dp height):
- Leading: currency symbol "¥" (`type.title.large`, `color.text.secondary`)
- Input: `type.numeric.large`, `color.text.primary`
- Trailing: "tomans" label
- Keyboard: numeric pad (no decimal — Tomans are always whole numbers in practice)
- The amount chips deselect when custom amount is active

### "Balance after" preview card

Updates live as the user selects a quick amount or types. Shows the projected new balance:
- Background: `color.surfaceVariant`, `radius.md`
- "Balance after: ¥[projected]" — amount in `type.numeric.medium`, `color.secondary`

If the projected balance exceeds the platform maximum (operator-configured, e.g., ¥2,000,000), an amber note appears: "Maximum wallet balance is ¥2,000,000."

### Validation

- Below minimum: "Minimum top-up is ¥5,000" — Continue button disabled
- Above maximum per transaction: "Maximum per transaction is ¥500,000" — Continue button disabled
- Empty: Continue button disabled

---

## 3. Payment Method Screen

### Layout

After selecting an amount, the user selects their payment method.

```
┌──────────────────────────────────────────────────────────────┐
│  ← Back                                                      │
│  Payment Method                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Adding ¥20,000 to your wallet                              │  ← Confirm context
│                                                              │
│  PAY WITH                                                    │  ← Section header
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  💳  Bank Card (Shaparak)            ▸             │    │  ← Method card
│  │      Shetab network — all banks supported           │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  🏦  Internet Banking                ▸             │    │
│  │      Direct bank transfer                          │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  SAVED CARDS                                                 │  ← Section (if any)
│  ┌─────────────────────────────────────────────────────┐    │
│  │  💳  Melli Bank *1234               ▸             │    │
│  │      Shetab debit card                              │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  🔒 Secured by Shaparak national payment network            │
│  type.body.small, color.text.tertiary, centered              │
└──────────────────────────────────────────────────────────────┘
```

**Method cards (64dp height):**
- Icon: 36dp circle, payment method icon
- Primary text: method name, `type.title.medium`
- Secondary text: description, `type.body.small`, `color.text.secondary`
- Trailing ▸: `color.text.tertiary`

### Shaparak security badge

At the bottom of the screen, always visible:
```
  🔒 Secured by Shaparak
  Your payment is processed directly by the national banking network.
  We never store your card information.
```
`type.body.small`, `color.text.tertiary`, centered. This is not optional — it must appear.

---

## 4. Payment Gateway Handoff

### Pre-gateway screen (brief, 500ms)

Before the WebView opens, a 500ms full-screen interstitial:

```
  [Bank logo or Shaparak logo, 64dp]
  Opening secure payment…
  type.body.medium, color.text.secondary
  [Loading spinner, 24dp]
```

This brief screen prevents the jarring perception of "app disappeared and something weird opened."

### WebView / in-app browser

The payment gateway opens in a `SafariViewController` (iOS) or `CustomTabsActivity` (Android). Not a Flutter WebView — the OS-native browser component provides the security indicators (HTTPS lock icon, URL bar) that users trust.

**URL bar:** Visible and pinned. The user must be able to see the HTTPS URL of the payment gateway. Hiding the URL bar is a security anti-pattern for payment flows.

**Back gesture:** On Android back gesture / iOS swipe from edge: the user is not immediately kicked out. A confirmation sheet appears: "Leave payment? Your payment has not been processed." + "Stay" (Primary) + "Leave" (Tertiary, `color.error`).

### Gateway completion: deep link handling

On payment completion (success or failure), the gateway redirects to the app via deep link:
`evcharger://payment/result?intentId=abc123&status=success`

The app:
1. Closes the WebView immediately
2. Navigates to the Payment Confirmation screen with a loading state
3. Fetches `GET /payments/intents/:id` to verify the status server-side
4. Never trusts the `status` parameter in the deep link alone — server verification is mandatory

**If the deep link never fires** (user navigated away within the browser, killed the app): On the next app open, the `AppStartGuard` checks for any open payment intents and resolves them.

---

## 5. Payment Confirmation Screen

The confirmation screen is shown while the app verifies the payment with the server. It is a loading/verification state, not a success state.

```
┌──────────────────────────────────────────────────────────────┐
│  Verifying payment…                                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│        [Animated verification: pulsing circle]               │
│                                                              │
│             Confirming your payment…                         │
│        type.body.medium, color.text.secondary                │
│                                                              │
│        This usually takes a few seconds.                     │
│        type.body.small, color.text.tertiary                  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

Not dismissable during verification. If verification takes >10 seconds: "Taking longer than expected. Do not close the app." warning.

If verification takes >30 seconds: "Payment verification is delayed. We'll notify you when confirmed. Check your wallet in a few minutes." + "Back to Wallet" Primary button.

---

## 6. Payment Success Screen

```
┌──────────────────────────────────────────────────────────────┐
│  ✕ (close)                                                    │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│   [✓ checkmark, 64dp, color.secondary, spring in 300ms]      │
│                                                              │
│   ¥20,000 added                                              │
│   type.numeric.display, color.text.primary, centered         │
│                                                              │
│   ┌─────────────────────────────────────────────────┐       │
│   │  New balance    ¥67,967.40                      │       │
│   │  Added          + ¥20,000.00                    │       │
│   │  Method         Melli Bank *1234                │       │
│   │  Reference      PAY-20260614-X9K2L              │       │
│   └─────────────────────────────────────────────────┘       │
│                                                              │
│   ┌─────────────────────────────────────────────────┐       │
│   │  Done                                           │       │  ← Primary: returns to entry point
│   └─────────────────────────────────────────────────┘       │
│   ┌─────────────────────────────────────────────────┐       │
│   │  View in Wallet                                 │       │  ← Secondary: goes to wallet
│   └─────────────────────────────────────────────────┘       │
└──────────────────────────────────────────────────────────────┘
```

**"Done" navigation context:**
- If arrived from Wallet tab: dismisses back to wallet (balance updates automatically via push event)
- If arrived from session start flow (insufficient balance): dismisses back to the session start confirmation sheet, which is now re-enabled
- If arrived from reservation check-in (insufficient balance): dismisses back to check-in sheet

**Auto-dismiss:** If the user does not interact for 15 seconds, auto-dismisses to the appropriate destination with a countdown in the "Done" button label.

---

## 7. Payment Failure Handling

### Gateway-side failure (card declined, OTP failed)

The gateway handles this internally and keeps the user within the gateway flow. The app only receives the final `failure` deep link after all retry attempts.

On failure deep link:

```
┌──────────────────────────────────────────────────────────────┐
│  ← Back                                                      │
│  Payment Not Processed                                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│   [✕ icon, 48dp, color.error]                               │
│                                                              │
│   Payment failed                                             │
│   type.headline.small, centered                              │
│                                                              │
│   [Error reason — see table below]                           │
│   type.body.medium, color.text.secondary, centered           │
│                                                              │
│   Reference: [gateway error code]                            │
│   type.body.small, color.text.tertiary, centered             │
│   (for support reference only)                               │
│                                                              │
│   ┌─────────────────────────────────────────────────┐       │
│   │  Try Again                                      │       │  ← Primary: re-opens gateway
│   └─────────────────────────────────────────────────┘       │
│   ┌─────────────────────────────────────────────────┐       │
│   │  Choose Different Method                        │       │  ← Secondary
│   └─────────────────────────────────────────────────┘       │
└──────────────────────────────────────────────────────────────┘
```

**Error messages by gateway code:**

| Reason | User message |
|--------|-------------|
| Insufficient funds | "Your card has insufficient funds. Try a different card or amount." |
| Card blocked | "Your card is blocked for online purchases. Contact your bank." |
| OTP expired | "The OTP expired. Please try again." |
| OTP incorrect | "Incorrect OTP entered too many times. Try again or contact your bank." |
| Card not supported | "This card type is not supported. Use a Shetab network card." |
| Transaction limit | "Your daily online transaction limit has been reached. Try tomorrow or a different card." |
| Generic | "Payment could not be processed. Please try again or use a different method." |

**Wallet unchanged:** Always confirmed visually: "Your wallet balance was not affected." `type.body.small`, `color.text.tertiary`, below the error message.

---

## 8. Transaction Verification and Idempotency

**Scenario: User makes a payment but the app crashes before the deep link is handled.**

On cold start, `AppStartGuard` checks `LocalStorage` for any payment intents in state `pending_verification`. If found:
- A brief "Checking payment status…" overlay appears at the home screen
- `GET /payments/intents/:id` is called
- If `confirmed`: navigate to Payment Success screen with the confirmed intent
- If `failed`: navigate to Payment Failed screen
- If `pending`: show a banner: "Payment verification in progress. We'll notify you when complete."

The payment intent is stored in `SharedPreferences` from the moment it is created until it is either confirmed or failed. This ensures no payment is lost even if the app is killed.

---

## 9. Saved Payment Methods

**Not supported in MVP.** Card tokenization for recurring use requires PCI-DSS compliance infrastructure and bank partnerships beyond MVP scope.

**Design reserve:** The payment method screen includes a "SAVED CARDS" section in its layout (§3) — visually present but populated from an empty array in MVP. When the user adds a card through the normal gateway flow, a post-payment prompt asks: "Save this card for faster future payments?" — the toggle adds the tokenized card to the server-side payment method list.

The saved card design is specified so that when the backend supports it, the frontend is ready.

---

## 10. Loading States

**Amount selection:** No loading — amounts are predefined; the current balance is fetched on screen mount (shown with skeleton while loading).

**Payment method:** No loading — methods are hardcoded; saved cards fetch takes <500ms (skeleton in that section only).

**Confirmation screen:** The entire screen is a loading state (§5).

**Success/failure screens:** No skeleton — data comes from the payment intent response in a single payload.

---

## 11. Offline Behavior

The entire top-up flow requires internet connectivity. If the user is offline when they tap "+ Add Funds":

```
  [cloud-offline icon 48dp]
  You're offline
  type.headline.small

  Adding funds requires an internet connection.
  type.body.medium, color.text.secondary

  [  OK  ]  ← Primary
```

Shown as a bottom sheet, not a new screen. Dismissed with "OK." No navigation change.

---

## 12. Accessibility Requirements

**Amount chips:** Each chip's accessibility label: "[Amount] tomans. [Selected/Not selected]. Double-tap to select."

**Custom amount field:** "Enter top-up amount in tomans. Minimum 5,000. Maximum 500,000 per transaction."

**"Balance after" preview:** Announced as a live region update when the projected balance changes. "Balance after top-up: [amount] tomans."

**Payment method list:** Each method: "[Method name]. [Description]. Double-tap to select and continue."

**Security badge:** Announced once on screen entry as static text. Not repeated on every focus cycle.

---

## 13. RTL Behavior

**Amount chips:** Displayed in a 3×2 grid — layout mirrors naturally. Amounts are Persian-Indic: "۱۰٬۰۰۰ تومان" etc.

**Custom amount field:** Leading "¥" symbol on the right (start) in RTL. Input grows to the left. "tomans" label on the left (end) in RTL.

**"Balance after" preview:** "موجودی بعد از شارژ: ۶۷٬۹۶۷٫۴۰ تومان"

**Payment method cards:** Icon on right, text right-aligned, chevron on left.

**Success screen:** "¥20,000 اضافه شد" — amount first, then verb (Persian natural order).

**Security badge:** "🔒 پرداخت امن از طریق شبکه شاپرک"

---

## 14. Security Considerations in UI

These are UI-level security decisions — not backend security architecture.

1. **URL bar always visible in WebView.** Users must see the HTTPS URL.
2. **App never handles card numbers.** The "We never store your card information" message must always be visible on the payment method screen.
3. **Back confirmation during payment.** Prevents accidental gateway abandonment that could leave intents in ambiguous states.
4. **Payment reference always shown on success.** The reference number enables support verification — it must be copyable.
5. **No payment amounts in push notification previews.** Notifications should not expose wallet amounts on the lock screen. Notification template: "Payment confirmed" (no amount). The amount is inside the app only.
6. **Balance privacy toggle in wallet.** Users should be able to hide their balance from observers in public spaces.