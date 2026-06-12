# Screen Inventory Final

**Document type:** Complete route catalog and navigation map  
**Last Updated:** 2026-06-11  
**Scope:** All screens, all states, all routes  
**References:** All screen specification documents · ARCHITECTURE_FINAL.md §1 (navigation) · DESIGN_SYSTEM_REVIEW.md §11

This is the authoritative record of every screen and route in the application. Use it to verify navigation completeness, identify guard requirements, and plan state management scope. Any screen not listed here has not been designed.

---

## Table of Contents

1. [Screen Count Summary](#1-screen-count-summary)
2. [Route Catalog](#2-route-catalog)
3. [Screen State Variants](#3-screen-state-variants)
4. [Navigation Connection Map](#4-navigation-connection-map)
5. [Guard Requirements](#5-guard-requirements)
6. [Data Source Requirements](#6-data-source-requirements)
7. [Deep Link Catalog](#7-deep-link-catalog)
8. [Modal and Sheet Inventory](#8-modal-and-sheet-inventory)
9. [Navigation Flows (User Journeys)](#9-navigation-flows-user-journeys)
10. [Offline-capable Screens](#10-offline-capable-screens)

---

## 1. Screen Count Summary

| Category | Screen count | State variants |
|----------|-------------|---------------|
| Main tab screens | 5 | 20 |
| Station domain | 2 | 12 |
| Reservation domain | 3 | 18 |
| Charging domain | 2 | 22 |
| Wallet domain | 3 | 12 |
| Profile domain | 4 | 14 |
| Notification domain | 2 | 6 |
| Settings domain | 4 | 10 |
| Auth domain | 2 | 6 |
| **Total screens** | **27** | **120** |
| Modals / bottom sheets | 22 | — |
| Deep link handlers | 3 | — |

---

## 2. Route Catalog

All routes registered in Go Router.

### Auth domain

| Route | Screen | Spec |
|-------|--------|------|
| `/` | App entry / splash | ARCHITECTURE_FINAL.md §1 |
| `/onboarding` | Onboarding / phone entry | ARCHITECTURE_FINAL.md §12 |
| `/onboarding/verify` | OTP verification | ARCHITECTURE_FINAL.md §12 |

### Map / Home domain

| Route | Screen | Spec |
|-------|--------|------|
| `/map` | Map home (Tab 1) | HOME_SCREEN.md |

### Station domain

| Route | Screen | Spec |
|-------|--------|------|
| `/stations/:id` | Station details | STATION_DETAILS_SCREEN.md |
| `/stations/:id/gallery` | Full-screen gallery lightbox | STATION_DETAILS_SCREEN.md §6 |

### Reservation domain

| Route | Screen | Spec |
|-------|--------|------|
| `/reservations` | Reservation list (Tab 2) | RESERVATION_FLOW.md §2 |
| `/reservations/create/:stationId` | Reservation creation form | RESERVATION_FLOW.md §5 |
| `/reservations/:id` | Reservation detail | RESERVATION_FLOW.md §3 |

### Charging domain

| Route | Screen | Spec |
|-------|--------|------|
| `/charging/:sessionId` | Active charging session | CHARGING_SESSION_SCREEN.md |
| `/charging/:sessionId/summary` | Charging summary / receipt | CHARGING_SUMMARY_SCREEN.md |

### Wallet domain

| Route | Screen | Spec |
|-------|--------|------|
| `/wallet` | Wallet overview (Tab 4) | WALLET_SCREENS.md |
| `/wallet/topup` | Top-up amount selection | PAYMENT_FLOW.md §4 |
| `/wallet/transactions/:id` | Transaction detail | WALLET_SCREENS.md §5 |

### Profile domain

| Route | Screen | Spec |
|-------|--------|------|
| `/profile` | Profile overview (Tab 5) | PROFILE_SCREENS.md §1 |
| `/profile/edit` | Edit profile | PROFILE_SCREENS.md §5 |
| `/profile/kyc` | KYC flow (entry) | PROFILE_SCREENS.md §6 |
| `/profile/kyc/status` | KYC status | PROFILE_SCREENS.md §7 |
| `/profile/security` | Account security | PROFILE_SCREENS.md §8 |

### Notification domain

| Route | Screen | Spec |
|-------|--------|------|
| `/notifications` | Notification center | NOTIFICATION_SCREENS.md §3 |

### Settings domain

| Route | Screen | Spec |
|-------|--------|------|
| `/settings` | Settings overview | SETTINGS_SCREENS.md §2 |
| `/settings/language` | Language selection | SETTINGS_SCREENS.md §3 |
| `/settings/appearance` | Theme selection | SETTINGS_SCREENS.md §4 |
| `/settings/notifications` | Notification preferences | NOTIFICATION_SCREENS.md §7 |
| `/settings/location` | Location permissions | SETTINGS_SCREENS.md §6 |

---

## 3. Screen State Variants

Every screen has multiple states. All must be implemented.

### `/map` (HOME_SCREEN.md)

| State | Trigger |
|-------|---------|
| Loading | Initial load, location acquiring |
| Map — no session active | Default state, user browsing |
| Map — station bottom sheet peek | Station selected from map or list |
| Map — station bottom sheet expanded | User pulls sheet up |
| Map — active session banner | Session in progress (sticky stop bar) |
| Map — offline | No internet |
| Map — location denied | OS location permission denied |
| Map — empty area | No stations in viewport |

### `/stations/:id` (STATION_DETAILS_SCREEN.md)

| State | Trigger |
|-------|---------|
| Loading | Screen open before data fetched |
| Loaded — no session active | Default state |
| Loaded — reservation exists | User has existing reservation at this station |
| Loaded — session active | User is currently charging here |
| Not found (404) | Station ID invalid |
| Gallery lightbox | User taps gallery image |

### `/reservations` (RESERVATION_FLOW.md)

| State | Trigger |
|-------|---------|
| Loading | Tab selected |
| Empty | No reservations ever |
| Upcoming reservations | Active/pending reservations exist |
| Past reservations | History only |
| Mixed | Both upcoming and past |
| Offline | Cached list shown |

### `/reservations/:id` (RESERVATION_FLOW.md)

| State | Trigger |
|-------|---------|
| Pending | Reservation created, not yet confirmed |
| Confirmed — countdown active | Confirmed, before check-in window |
| Check-in window open | Within 30 min before start |
| Check-in window — 15min warning | `color.warning` countdown |
| Check-in window — 5min warning | `color.error` countdown |
| Checked in | User tapped "Start Charging" |
| Completed | Session ended after reservation |
| Cancelled by user | User cancelled |
| Cancelled by operator | Operator cancelled |
| Expired / No-show | Check-in window passed |

### `/charging/:sessionId` (CHARGING_SESSION_SCREEN.md)

| State | Trigger |
|-------|---------|
| Preparing | OCPP state: Preparing |
| Authorizing | OCPP state: Authorizing — 202 response received |
| Charging | OCPP state: Charging — active energy delivery |
| Suspended by vehicle | OCPP state: SuspendedByVehicle |
| Suspended by charger | OCPP state: SuspendedByCharger |
| Interrupted | OCPP state: Interrupted — network/power issue |
| Finishing | OCPP state: Finishing |
| Faulted | OCPP state: Faulted |
| Stop requested | User tapped Stop, 202 pending |
| Offline — session may be active | App lost network mid-session |
| Network loss | Reconnecting overlay |

### `/charging/:sessionId/summary` (CHARGING_SUMMARY_SCREEN.md)

| State | Trigger |
|-------|---------|
| Entry animation | Dark→light transition from session screen |
| Normal completed | Session finished normally |
| User-stopped | User initiated stop |
| Charger fault (partial charge) | OCPP fault mid-session |
| Network interruption | Session ended due to connectivity |
| Free session | `totalCost = 0` |
| Paid session | Standard billing |
| Reservation-originated | Started from a reservation |
| Walk-up | No prior reservation |
| Tax invoice requested | User requests formal invoice |
| Loading (historical access) | Viewing old session summary |

### `/wallet` (WALLET_SCREENS.md)

| State | Trigger |
|-------|---------|
| Loading | Tab selected |
| Balance > threshold | Normal state |
| Low balance | `balance < threshold` |
| Zero balance | `balance = 0` |
| Pending charge | Unresolved pending transaction |
| Empty (no transactions) | First-time user |
| Offline | Cached balance and transactions |

### `/wallet/topup` (PAYMENT_FLOW.md)

| State | Trigger |
|-------|---------|
| Amount selection | Screen entry |
| Custom amount entry | User taps "Custom" |
| Gateway redirect | User taps "Pay" — browser opens |
| Payment return — success | Deep link return |
| Payment return — failed | Deep link return with failure |
| Payment return — cancelled | Deep link return with cancel |
| Payment — crashed app recovery | App relaunched after crash mid-payment |

### `/profile` (PROFILE_SCREENS.md)

| State | Trigger |
|-------|---------|
| Loading | Tab selected |
| KYC: not started | New user |
| KYC: pending | Submitted, awaiting review |
| KYC: approved | Full access |
| KYC: rejected | Re-verification needed |

### `/profile/kyc` (PROFILE_SCREENS.md §6)

| State | Trigger |
|-------|---------|
| Document selection | KYC flow entry |
| Document capture — front | National ID step 1 |
| Document capture — back | National ID step 2 |
| Selfie + liveness | Step 3 |
| Uploading | Step 4 |
| Submission success | After upload |
| Upload failed | Network or server error |

---

## 4. Navigation Connection Map

A textual representation of all navigation connections. Each entry is `Source → [action] → Destination`.

### From `/map`

```
/map → [tap station pin or list item] → /stations/:id
/map → [tap bell icon] → /notifications
/map → [tap active session banner] → /charging/:sessionId
/map → [tap profile icon] → /profile (or tab switch)
```

### From `/stations/:id`

```
/stations/:id → [tap Reserve] → /reservations/create/:stationId
/stations/:id → [tap Start Charging → 202 success] → /charging/:sessionId
/stations/:id → [tap gallery image] → /stations/:id/gallery (lightbox)
/stations/:id → [tap KYC required] → /profile/kyc (modal)
/stations/:id → [back] → /map or previous
```

### From `/reservations`

```
/reservations → [tap reservation card] → /reservations/:id
/reservations → [tap "Find a station" empty state] → /map
/reservations → [tab bar] → any other tab
```

### From `/reservations/create/:stationId`

```
/reservations/create/:stationId → [form submit success] → /reservations/:id (new)
/reservations/create/:stationId → [cancel] → /stations/:id
```

### From `/reservations/:id`

```
/reservations/:id → [tap Start Charging → 202 success] → /charging/:sessionId
/reservations/:id → [tap Cancel] → /reservations (list)
/reservations/:id → [tap station name] → /stations/:id
```

### From `/charging/:sessionId`

```
/charging/:sessionId → [session completed → auto-navigate] → /charging/:sessionId/summary
/charging/:sessionId → [user stop → completed] → /charging/:sessionId/summary
/charging/:sessionId → [fault → session ends] → /charging/:sessionId/summary
```

### From `/charging/:sessionId/summary`

```
/charging/:sessionId/summary → [tap Done] → /map (tab 1)
/charging/:sessionId/summary → [tap Add Funds] → /wallet/topup
/charging/:sessionId/summary → [tap station name] → /stations/:id
/charging/:sessionId/summary → [tap transaction reference] → /wallet/transactions/:id
```

### From `/wallet`

```
/wallet → [tap + Add Funds] → /wallet/topup
/wallet → [tap transaction] → /wallet/transactions/:id
/wallet → [tap "View Session Summary" in transaction detail] → /charging/:sessionId/summary
```

### From `/wallet/topup`

```
/wallet/topup → [Pay button → OS browser] → external (Shaparak)
/wallet/topup → [deep link return evcharger://payment/result] → /wallet (with toast)
/wallet/topup → [cancel] → /wallet
```

### From `/profile`

```
/profile → [tap Edit Profile] → /profile/edit
/profile → [tap Verify Now / Try Again] → /profile/kyc
/profile → [tap KYC status] → /profile/kyc/status
/profile → [tap Account Security] → /profile/security
/profile → [tap Settings ⚙] → /settings
/profile → [tap Terms / Privacy] → in-app WebView (modal)
```

### From `/notifications`

```
/notifications → [tap reservation notification] → /reservations/:id
/notifications → [tap session notification] → /charging/:sessionId or /charging/:sessionId/summary
/notifications → [tap wallet notification] → /wallet or /wallet/topup
/notifications → [tap KYC notification] → /profile/kyc/status
/notifications → [tap station available] → /stations/:id
/notifications → [back] → previous screen
```

### From `/settings`

```
/settings → [Language] → /settings/language
/settings → [Appearance] → /settings/appearance
/settings → [Notifications] → /settings/notifications
/settings → [Location] → /settings/location
/settings → [ToS / Privacy] → in-app WebView (modal)
/settings → [Help] → WebView or native chat (operator-configured)
/settings → [Rate App] → App Store / Play Store
```

---

## 5. Guard Requirements

Every route is guarded by one or more conditions.

| Route | Auth required | KYC required | Session ownership | Other |
|-------|--------------|-------------|------------------|-------|
| `/` | No | No | No | Redirect to /map or /onboarding |
| `/onboarding` | No (unauthenticated only) | No | No | |
| `/onboarding/verify` | No | No | No | |
| `/map` | Yes | No | No | |
| `/stations/:id` | No | No | No | Public route |
| `/stations/:id/gallery` | No | No | No | Public route |
| `/reservations` | Yes | No | No | |
| `/reservations/create/:stationId` | Yes | Yes | No | KYC required |
| `/reservations/:id` | Yes | No | Yes | User owns reservation |
| `/charging/:sessionId` | Yes | No | Yes | User owns session |
| `/charging/:sessionId/summary` | Yes | No | Yes | User owns session |
| `/wallet` | Yes | No | No | |
| `/wallet/topup` | Yes | No | No | |
| `/wallet/transactions/:id` | Yes | No | Yes | User owns transaction |
| `/profile` | Yes | No | No | |
| `/profile/edit` | Yes | No | No | |
| `/profile/kyc` | Yes | No | No | Redirect to /profile/kyc/status if KYC pending |
| `/profile/kyc/status` | Yes | No | No | |
| `/profile/security` | Yes | No | No | Biometric re-auth if enabled |
| `/notifications` | Yes | No | No | |
| `/settings` | Yes | No | No | |
| `/settings/language` | Yes | No | No | |
| `/settings/appearance` | Yes | No | No | |
| `/settings/notifications` | Yes | No | No | |
| `/settings/location` | Yes | No | No | |

**KYC guard behavior:** If KYC is required and not approved, the route redirect to a modal sheet explaining KYC is required with a "Verify Identity" CTA. The user is not navigated away from their current screen — the KYC entry sheet appears over it.

**Auth guard behavior:** Unauthenticated users attempting any auth-required route are redirected to `/onboarding` with the intended route saved in redirect parameter.

---

## 6. Data Source Requirements

What each screen needs and from where.

| Screen | Data sources | Real-time? |
|--------|-------------|-----------|
| `/map` | Station list (`GET /stations?lat=&lng=&radius=`), user session status | Yes (WebSocket for station updates, session heartbeat) |
| `/stations/:id` | Station detail (`GET /stations/:id`), live connector status | Yes (WebSocket for connector status) |
| `/reservations` | User reservations (`GET /users/me/reservations`) | No (pull-to-refresh) |
| `/reservations/:id` | Reservation detail (`GET /reservations/:id`) | Yes (countdown computed locally from server-provided timestamps) |
| `/reservations/create/:stationId` | Station info (from cache), available time slots (`GET /stations/:id/availability`) | No |
| `/charging/:sessionId` | Session state (`GET /charging/sessions/:id`) | Yes (WebSocket heartbeat every 5s) |
| `/charging/:sessionId/summary` | Session record (`GET /charging/records/:id`) | No (historical, immutable) |
| `/wallet` | Balance (`GET /users/me/wallet/balance`), transactions (`GET /users/me/wallet/transactions`) | No (pull-to-refresh) |
| `/wallet/topup` | Wallet balance (cached), top-up presets (`GET /config/topup-presets`) | No |
| `/wallet/transactions/:id` | Transaction detail (`GET /users/me/wallet/transactions/:id`) | No |
| `/profile` | User profile (`GET /users/me`), usage stats (`GET /users/me/stats`) | No |
| `/profile/edit` | User profile (from cache) | No |
| `/profile/kyc` | KYC provider SDK (native) | — |
| `/profile/kyc/status` | KYC status (`GET /users/me/kyc`) | Yes (WebSocket for status change) |
| `/profile/security` | Active sessions (`GET /users/me/sessions`) | No |
| `/notifications` | Notification list (`GET /notifications`), unread count | No (pull-to-refresh) |
| `/settings` | Settings (local `SharedPreferences`) | No |

### Caching policy

| Data type | Cache duration | Storage |
|-----------|---------------|---------|
| Station list | 5 minutes | Riverpod in-memory |
| Station detail | 10 minutes | Riverpod in-memory |
| User profile | 30 minutes | Riverpod + Hive |
| Session state | Real-time only (no cache) | Riverpod in-memory |
| Session record (historical) | Indefinite | Hive |
| Wallet balance | 2 minutes | Riverpod in-memory |
| Transactions (page 1) | 5 minutes | Riverpod in-memory |
| Notifications | 10 minutes | Riverpod in-memory |
| Settings | Session lifetime | SharedPreferences |

---

## 7. Deep Link Catalog

Three deep link entry points:

### `evcharger://payment/result`

**Parameters:** `?intentId=&status=success|failed|cancelled`

**Handler behavior:**
1. Check `SharedPreferences` for stored `paymentIntentId`
2. If `intentId` matches stored intent: clear stored intent
3. `POST /payments/intents/:intentId/verify` to confirm server-side
4. Navigate to `/wallet` with appropriate toast
5. If mismatch: ignore deep link (security — prevents forged deep links)

### `evcharger://reservations/:id`

**Source:** Push notification tap (background/killed state)  
**Handler behavior:** Auth check → navigate to `/reservations/:id`

### `evcharger://charging/:sessionId`

**Source:** Push notification tap for session events  
**Handler behavior:** Auth check → if session active: navigate to `/charging/:sessionId`; if completed: navigate to `/charging/:sessionId/summary`

### `evcharger://charging/:sessionId/summary`

**Source:** Push notification for session completion  
**Handler behavior:** Auth check → navigate to `/charging/:sessionId/summary`

---

## 8. Modal and Sheet Inventory

All bottom sheets, dialogs, and modals — separate from routed screens.

| Name | Type | Entry point | Spec |
|------|------|------------|------|
| Station bottom sheet (peek) | Persistent bottom sheet | Map — tap station pin | HOME_SCREEN.md §6 |
| Station bottom sheet (expanded) | Persistent bottom sheet | Map — pull sheet up | HOME_SCREEN.md §6 |
| KYC required sheet | Modal sheet | Any KYC-gated action | STATION_DETAILS_SCREEN.md §12, PROFILE_SCREENS.md §6 |
| Reservation creation — connector select | Full-screen or large sheet | STATION_DETAILS_SCREEN.md — Reserve CTA | RESERVATION_FLOW.md §5 |
| Reservation cancel confirmation | Modal sheet | RESERVATION_FLOW.md §8 | RESERVATION_FLOW.md §8 |
| Reservation check-in sheet | Modal sheet | RESERVATION_FLOW.md §14 | RESERVATION_FLOW.md §14 |
| Stop charging confirmation | Bottom sheet (2-step) | CHARGING_SESSION_SCREEN.md — Stop tap | CHARGING_SESSION_SCREEN.md §12 |
| Fault acknowledgment sheet | Modal sheet | CHARGING_SESSION_SCREEN.md fault state | CHARGING_SESSION_SCREEN.md §16 |
| Network loss overlay | Full-screen overlay | Mid-session network drop | CHARGING_SESSION_SCREEN.md §18 |
| Tax invoice request sheet | Modal sheet | CHARGING_SUMMARY_SCREEN.md | CHARGING_SUMMARY_SCREEN.md §21 |
| Add funds confirmation | Bottom sheet | STATION_DETAILS_SCREEN.md, wallet | PAYMENT_FLOW.md §4 |
| Payment security warning | Bottom sheet | `/wallet/topup` | PAYMENT_FLOW.md §7 |
| Export data confirmation | Bottom sheet | SETTINGS_SCREENS.md §8 | SETTINGS_SCREENS.md §8 |
| Delete account — step 1 | Bottom sheet | SETTINGS_SCREENS.md §8 | SETTINGS_SCREENS.md §8 |
| Delete account — step 2 (confirm phone) | Full-screen or large sheet | SETTINGS_SCREENS.md §8 | SETTINGS_SCREENS.md §8 |
| Sign out confirmation | Bottom sheet | PROFILE_SCREENS.md §9 | PROFILE_SCREENS.md §9 |
| Notification permission pre-prompt | Bottom sheet | Post-reservation creation | NOTIFICATION_SCREENS.md §8 |
| Location permission explanation | Sub-screen (pushed) | SETTINGS_SCREENS.md §6 | SETTINGS_SCREENS.md §6 |
| Station gallery lightbox | Full-screen overlay (or route) | STATION_DETAILS_SCREEN.md §6 | STATION_DETAILS_SCREEN.md §6 |
| ToS / Privacy Policy | In-app WebView modal | Profile / Settings | SETTINGS_SCREENS.md §7 |
| Help and Support | In-app WebView or native | Profile / Settings | SETTINGS_SCREENS.md §7 |
| "Notify me" confirmation | Inline toast / sheet | STATION_DETAILS_SCREEN.md §9 | STATION_DETAILS_SCREEN.md §9 |

---

## 9. Navigation Flows (User Journeys)

The most important user journeys represented as screen sequences.

### Journey 1: Walk-up charge (no reservation)

```
/map
  → /stations/:id          [tap station pin]
  → /charging/:sessionId   [tap Start Charging → 202 → OCPP Preparing]
  → /charging/:sessionId   [OCPP: Charging state]
  → /charging/:sessionId/summary  [session ends → auto-navigate]
  → /map                   [tap Done]
```

### Journey 2: Reserve and charge

```
/map
  → /stations/:id                    [tap station pin]
  → /reservations/create/:stationId  [tap Reserve]
  → /reservations/:id                [reservation confirmed]
  → /map or /reservations            [user waits; push notifications sent]
  → /reservations/:id                [check-in window opens — push tap]
  → /charging/:sessionId             [tap Start Charging → 202 → OCPP]
  → /charging/:sessionId/summary     [session ends]
  → /map                             [tap Done]
```

### Journey 3: Top-up wallet

```
/wallet
  → /wallet/topup          [tap + Add Funds]
  → [OS browser — Shaparak gateway]
  → evcharger://payment/result?status=success
  → /wallet                [deep link → verified → balance updated toast]
```

### Journey 4: New user — first charge

```
/onboarding               [phone entry]
  → /onboarding/verify    [OTP]
  → /map                  [authenticated]
  → /stations/:id         [user finds station]
  → [KYC required sheet]  [user tries to reserve]
  → /profile/kyc          [Verify Identity CTA]
  → /profile/kyc/status   [submitted — pending]
  → /profile/kyc/status   [push notification: approved]
  → /stations/:id         [user returns to station]
  → /reservations/create/:stationId
  → ... (Journey 2)
```

### Journey 5: Fault during charging

```
/charging/:sessionId      [OCPP: Charging]
  → /charging/:sessionId  [OCPP: Faulted]
  → [Fault acknowledgment sheet]
  → /charging/:sessionId/summary  [fault variant — partial billing]
  → /wallet               [if refund pending]
```

---

## 10. Offline-capable Screens

Screens that degrade gracefully without network connectivity.

| Screen | Offline behavior | Cache source |
|--------|----------------|-------------|
| `/map` | Last-fetched station list shown; WebSocket unavailable — no live updates | Riverpod in-memory |
| `/stations/:id` | Cached station data shown; connector status frozen | Riverpod in-memory |
| `/reservations` | Cached reservation list shown; banner displayed | Riverpod + Hive |
| `/reservations/:id` | Cached reservation detail; countdown computed from stored timestamps | Hive |
| `/charging/:sessionId` | Critical: dashed arc offline indicator; session continues on charger | Local session state |
| `/charging/:sessionId/summary` | Full offline access (historical, immutable) | Hive |
| `/wallet` | Cached balance shown with "as of [time]" label | Riverpod + Hive |
| `/wallet/transactions/:id` | Cached transaction detail (read-only) | Hive |
| `/profile` | Cached profile shown | Riverpod + Hive |
| `/notifications` | Cached notification list | Riverpod in-memory |
| `/settings` | Fully offline (all local) | SharedPreferences |

**Screens that require connectivity (no meaningful offline state):**
- `/onboarding`, `/onboarding/verify` (auth requires network)
- `/wallet/topup` (payment requires network)
- `/profile/kyc` (document upload requires network)
- `/reservations/create/:stationId` (booking requires network)