# Notification Screens

**In-app notification center route:** `/notifications`  
**Entry:** Bell icon in navigation bars · System notification tap (deep-links to relevant screen)  
**Last Updated:** 2026-06-11  
**References:** DESIGN_SYSTEM.md · ARCHITECTURE_FINAL.md §3 (notification module) · RESERVATION_FLOW.md §15-16

The notification system has two surfaces: **push notifications** (OS-level, shown on lock screen and notification center) and the **in-app notification center** (a screen within the app listing all notifications). This document specifies both surfaces and defines every notification type the platform sends.

---

## Table of Contents

1. [Notification Architecture](#1-notification-architecture)
2. [Push Notification Catalog](#2-push-notification-catalog)
3. [In-App Notification Center Screen](#3-in-app-notification-center-screen)
4. [Notification Card Design](#4-notification-card-design)
5. [Notification Detail Behavior](#5-notification-detail-behavior)
6. [Notification Categories and Channels](#6-notification-categories-and-channels)
7. [Notification Preferences Screen](#7-notification-preferences-screen)
8. [Notification Permission Prompt](#8-notification-permission-prompt)
9. [Badge Count Management](#9-badge-count-management)
10. [Loading and Empty States](#10-loading-and-empty-states)
11. [Offline Behavior](#11-offline-behavior)
12. [Accessibility Requirements](#12-accessibility-requirements)
13. [RTL Behavior](#13-rtl-behavior)

---

## 1. Notification Architecture

**Server-side generation:** All notifications are generated server-side. The app client never generates notification content. This ensures:
- Persian and English templates produce correctly formatted content
- Notification timing is controlled by server logic, not client scheduling
- Notification content is consistent with server state

**Delivery path:** Server → FCM (Firebase Cloud Messaging) / APNs → OS notification tray → App.

**In-app notification center:** A separate API endpoint (`GET /notifications`) returns the list of notifications for the authenticated user. This is not the same as the OS notification history — it is the platform's own notification log, persisted server-side.

**Locale for content:** The notification locale is the user's stored profile locale preference (`user.localePreference`). The `NotificationRepository.updateDeviceLocale(locale)` call (per ARCHITECTURE_FINAL.md §25 reactive cascade) ensures the server always knows the current locale.

**3-state push handling (per ARCHITECTURE_FINAL.md §18):**
1. App in foreground: notification delivered as an in-app banner (custom UI, not the OS notification)
2. App in background: OS notification displayed; tap navigates via `NotificationRouter`
3. App killed: OS notification displayed; tap cold-starts app, `AppStartGuard` routes via `NotificationRouter`

---

## 2. Push Notification Catalog

Complete catalog of all notifications the platform sends.

### Category: Reservation

| ID | Title | Body | Action on tap |
|----|-------|------|---------------|
| `res.created` | "Reservation confirmed" | "[Connector] at [Station] · [Date, Time]" | Open reservation detail |
| `res.reminder.24h` | "Charging tomorrow" | "[Station] at [time]. Wallet: ¥[bal]" | Open reservation detail |
| `res.reminder.1h` | "1 hour until your charge" | "Head to [Station] soon" | Open reservation detail |
| `res.reminder.35min` | "Head to the station" | "[Station] in 35 min" | Open maps navigation |
| `res.reminder.10min` | "Almost time" | "[Station] reservation in 10 min" | Open reservation detail |
| `res.window.open` | "Check in now" | "30 min to check in at [Station]" | Open reservation detail |
| `res.window.15min` | "15 minutes left" | "Check in before [time]" | Open reservation detail |
| `res.window.5min` | "5 minutes!" | "Cancel if you can't make it" | Open reservation detail |
| `res.expired` | "Reservation expired" | "Connector released. [Fee if any]" | Open reservation list |
| `res.cancelled.operator` | "Reservation cancelled by operator" | "[Station] cancelled your booking" | Open reservation list |

### Category: Charging Session

| ID | Title | Body | Action on tap |
|----|-------|------|---------------|
| `session.started` | "Charging started" | "[Station] · [Connector]" | Open active session |
| `session.completed` | "Charging complete" | "¥[cost] · [kWh] kWh · [duration]" | Open session summary |
| `session.faulted` | "Charger fault" | "Session interrupted at [Station]" | Open session summary |
| `session.suspended` | "Charging paused" | "Vehicle paused charging at [Station]" | Open active session |
| `session.low_power` | "Charging slowly" | "Low power detected at [Station]" | Open active session |

### Category: Wallet

| ID | Title | Body | Action on tap |
|----|-------|------|---------------|
| `wallet.topup` | "Funds added" | "¥[amount] added to your wallet" | Open wallet |
| `wallet.low_balance` | "Low balance" | "¥[balance] remaining. Add funds." | Open wallet top-up |
| `wallet.pending_charge` | "Payment pending" | "¥[amount] pending from [session]" | Open wallet |
| `wallet.refund` | "Refund processed" | "¥[amount] refunded from [operator]" | Open wallet |

### Category: Account & KYC

| ID | Title | Body | Action on tap |
|----|-------|------|---------------|
| `kyc.approved` | "Identity verified ✓" | "You can now reserve and start charging" | Open profile |
| `kyc.rejected` | "Verification failed" | "Please try again with a clearer photo" | Open KYC flow |
| `kyc.expiring` | "Verification expiring" | "Re-verify your identity by [date]" | Open KYC flow |

### Category: Station

| ID | Title | Body | Action on tap |
|----|-------|------|---------------|
| `station.available` | "[Station] connector available" | "A [connector type] connector is now free" | Open station details |

"station.available" is sent when the user has tapped "Notify Me" on an occupied connector (STATION_DETAILS_SCREEN.md §9).

---

## 3. In-App Notification Center Screen

The notification center is accessible from a bell icon in the navigation bars of key screens (Map, Reservations, Wallet). It is not a separate tab.

### Bell icon badge

The bell icon shows a red count badge when there are unread notifications. Count reflects unread count (capped at 99). Badge cleared when the notification center is opened.

### Screen layout

```
┌──────────────────────────────────────────────────────────────┐
│  ← Back                         Notifications   [Mark all ✓]│
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  [TODAY] ─────────────────────────────────────────          │  ← Date group
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  ● [icon]  Charging complete                10:42  │    │  ← Unread
│  │            ¥2,032 · 24.71 kWh · 01:47              │    │
│  │            Elm Street Charging Hub                  │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │    [icon]  Reservation confirmed          09:15    │    │  ← Read (no dot)
│  │            CCS at Elm Street · 3:30 PM             │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  [YESTERDAY] ────────────────────────────────────────       │
│  ...                                                         │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

**Date groups:** "TODAY", "YESTERDAY", then "MON 9 JUN" etc. `type.label.small`, letter-spaced, `color.text.tertiary`.

**Unread dot:** 8dp circle, `color.primary`, at the start of unread notifications.

---

## 4. Notification Card Design

**Card height:** 80dp minimum (expands for longer body text).

**Card design:**
- Background: `color.primaryContainer` at 6% opacity for unread; `color.surface` for read
- No border for read; 1dp `color.primary` at 20% opacity for unread (left side only — a 3dp left accent bar)
- Padding: 16dp horizontal, 12dp vertical

**Content:**
- Leading: 40dp circle, category icon (20dp), category color background at 12%
- Title: `type.title.medium`, `color.text.primary`, 1 line
- Body: `type.body.small`, `color.text.secondary`, max 2 lines, ellipsis
- Trailing: time label, `type.label.small`, `color.text.tertiary`; below: unread dot if applicable

**Swipe to dismiss:** Swipe left reveals a "Dismiss" action (red background, trash icon). Full swipe removes the notification from the list (server marks as dismissed).

---

## 5. Notification Detail Behavior

Tapping a notification:
1. Marks it as read on the server (`PATCH /notifications/:id/read`)
2. Navigates directly to the relevant screen via `NotificationRouter`
3. The notification center is dismissed (not retained in the back stack)

**Navigation targets:**
- Reservation notifications → `/reservations/:id`
- Session notifications → `/charging/:id/summary` or `/charging/:id`
- Wallet notifications → `/wallet` or `/wallet/topup`
- KYC notifications → `/profile/kyc/status`
- Station available notification → `/stations/:id`

---

## 6. Notification Categories and Channels

Two channels (configurable in device notification settings):

**"Reservations & Charging" channel:** Default sound, badge. Used for: reservation reminders, session start/complete.

**"Urgent" channel:** Louder sound, persistent banner. Used for: check-in window open (5-min warning), fault alerts, payment pending.

**"Updates" channel:** Silent, no badge. Used for: promotional, system announcements, KYC status.

---

## 7. Notification Preferences Screen

Route: within Settings screen (SETTINGS_SCREENS.md §6). Linked from the notification permission prompt.

### Layout

```
  CHARGING SESSIONS
  ○ Session started                [toggle]
  ○ Session completed              [toggle, on by default]
  ○ Charger fault                  [toggle, on by default, cannot disable]
  ○ Low power warning              [toggle]

  RESERVATIONS
  ○ Reservation confirmed          [toggle, on by default]
  ○ 1 hour reminder                [toggle, on by default]
  ○ 10 minute reminder             [toggle, on by default]
  ○ Check-in window open           [toggle, on by default, cannot disable]
  ○ 5 minute warning               [toggle, on by default, cannot disable]
  ○ Reservation expired            [toggle, on by default]

  WALLET
  ○ Funds added                    [toggle]
  ○ Low balance warning            [toggle, on by default]
  ○ Refunds                        [toggle, on by default]

  ACCOUNT
  ○ KYC status changes             [toggle, on by default, cannot disable]
```

**"Cannot disable" toggles:** Some notifications are safety-critical (fault alerts, check-in window). These toggles are shown but locked to ON. A lock icon (14dp) appears next to the label. Tapping shows a tooltip: "This notification cannot be disabled as it is required for the service."

---

## 8. Notification Permission Prompt

The app requests notification permission at two points:
1. After the user creates their first reservation (contextual, within Reservation Success screen §6 of RESERVATION_FLOW.md)
2. On first session start (contextual)

The prompt is never shown cold (on app first launch). It is always contextually motivated.

### In-app pre-prompt (before OS dialog)

```
  ──── (sheet)

  Get important reminders
  type.headline.small

  We'll notify you when your reservation
  is about to start and when your charging
  session completes.

  [  Enable Notifications  ]  ← Primary Large
  [  Not Now              ]  ← Tertiary
```

"Enable Notifications" triggers the OS permission dialog. "Not Now" dismisses. The pre-prompt is shown at most twice across the app's lifetime — never again after two dismissals.

---

## 9. Badge Count Management

The app badge count (on the app icon) reflects the total unread notification count. This is updated via:
- Push notification arrival (OS increments badge)
- App resume: `GET /notifications/unread_count` → sets badge to server count

On opening the notification center: all notifications are marked as read, badge cleared.

On individual notification dismissal (swipe): server count decremented, badge updated.

---

## 10. Loading and Empty States

**Loading:** 3 card skeletons (80dp each), shimmer.

**Empty (no notifications ever):**
```
  [Bell illustration, 80dp, color.text.tertiary at 20%]
  No notifications yet
  type.headline.small, centered
  You'll see charging and reservation
  updates here.
  type.body.medium, color.text.secondary, centered
```

**Empty (all dismissed):**
```
  You're all caught up
  type.title.medium, color.text.secondary, centered
  No unread notifications.
```

---

## 11. Offline Behavior

The notification center loads from cache (last-fetched notification list). A standard offline banner. New notifications cannot be fetched but the cached list is fully readable. "Mark all read" is queued and synced on reconnect.

---

## 12. Accessibility Requirements

**Bell icon badge:** Accessibility label: "Notifications, [N] unread." When 0: "Notifications, no unread."

**Each notification card:** "[Title]. [Body text]. [Time]. [Unread/Read]. Double-tap to open."

**"Mark all read" button:** "Mark all notifications as read. Double-tap to confirm."

**Swipe-to-dismiss:** Accessible via a "More options" button on each card: "Dismiss notification. Double-tap to remove."

---

## 13. RTL Behavior

**Date group headers:** Persian dates (Shamsi), right-aligned.

**Notification cards:** Unread accent bar on the right side (start in RTL). Icon on right (start), text right-aligned, time on left (end).

**Push notification content:** All body text is in Persian when locale is `fa` (server-generated).

**Time display:** Absolute times (10:42) remain in LTR container. Relative times ("2 hours ago" → "۲ ساعت پیش") use Persian.