# Settings Screens

**Route:** `/settings`  
**Entry:** ⚙ Settings icon in Profile tab nav bar  
**Last Updated:** 2026-06-11  
**References:** DESIGN_SYSTEM.md · ARCHITECTURE_FINAL.md §25 · PROFILE_SCREENS.md · NOTIFICATION_SCREENS.md §7

Settings contains preferences that change the behavior of the app globally: language, appearance, notifications, privacy, and legal. It is not a profile editing surface (that is PROFILE_SCREENS.md). Settings are grouped by domain and ordered from most-changed to least-changed based on typical user behavior.

---

## Table of Contents

1. [Settings Architecture](#1-settings-architecture)
2. [Settings Overview Screen](#2-settings-overview-screen)
3. [Language and Region Settings](#3-language-and-region-settings)
4. [Appearance Settings](#4-appearance-settings)
5. [Notification Settings](#5-notification-settings)
6. [Privacy Settings](#6-privacy-settings)
7. [About and Legal](#7-about-and-legal)
8. [Data Export and Deletion](#8-data-export-and-deletion)
9. [Settings Design Patterns](#9-settings-design-patterns)
10. [Loading and Error States](#10-loading-and-error-states)
11. [Accessibility Requirements](#11-accessibility-requirements)
12. [RTL Behavior](#12-rtl-behavior)

---

## 1. Settings Architecture

**Persistence model:**

| Setting | Storage | Sync |
|---------|---------|------|
| Language preference | `SharedPreferences` + server profile | Immediate server sync |
| Theme (light/dark/system) | `SharedPreferences` only | Local only |
| Notification preferences | Server (via `POST /users/me/notification-prefs`) | Server-authoritative |
| Analytics opt-out | `SharedPreferences` + server | Server records opt-out |
| Location permission | OS-level only | App reads OS permission |

**Language change cascade (per ARCHITECTURE_FINAL.md §25):**
Changing the language triggers:
1. `LocaleNotifier` update → `MaterialApp.locale` changes → entire UI re-renders in new locale
2. `StationMapNotifier.clearLocaleCache()`
3. `ReservationListNotifier.clearLocaleCache()`
4. `ProfileRepository.updateLocalePreference(locale)` (async, non-blocking)
5. `NotificationRepository.updateDeviceLocale(locale)` (async, non-blocking)

The UI re-render is immediate. Server syncs are fire-and-forget.

---

## 2. Settings Overview Screen

### Layout

Standard iOS/Android settings list style — grouped sections with list rows.

```
┌──────────────────────────────────────────────────────────────┐
│  ← Back                                                      │
│  Settings                                                    │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  PREFERENCES                                                 │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  🌐  Language                      English  ▸       │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  🎨  Appearance                    System   ▸       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  NOTIFICATIONS                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  🔔  Notification Settings                  ▸       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  PRIVACY                                                     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  📍  Location                      Always   ▸       │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  📊  Analytics                     On       ▸       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  DATA                                                        │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  📥  Export My Data                         ▸       │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  🗑  Delete Account                          ▸       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ABOUT                                                       │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  📋  Terms of Service                       ▸       │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  🔒  Privacy Policy                         ▸       │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  ❓  Help and Support                       ▸       │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  ⭐  Rate the App                           ▸       │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │     Version 1.0.0 (build 42)                        │    │
│  └─────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
```

### Row design (standard)

**Height:** 52dp  
**Leading:** Icon 20dp, `color.text.secondary`  
**Text:** `type.body.large`, `color.text.primary`  
**Trailing:** Current value in `type.body.medium`, `color.text.secondary` + ▸ chevron 16dp, `color.text.tertiary`  
**Divider:** 1dp `color.outline` at 20%, inset 16dp from start (not full-width)

**Section headers:** `type.label.small`, letter-spaced, `color.text.tertiary`, 16dp top padding, 8dp bottom padding.

---

## 3. Language and Region Settings

### Language selection screen

```
┌──────────────────────────────────────────────────────────────┐
│  ← Back                                                      │
│  Language                                                    │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  English                          ✓ (selected)      │    │
│  │  English (United Kingdom)                           │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  فارسی                                              │    │
│  │  Persian                                            │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  The app will restart its layout when you change language.  │
│  type.body.small, color.text.tertiary                        │
└──────────────────────────────────────────────────────────────┘
```

**Language row design (64dp height):**
- Primary text: native language name (`type.title.medium`, `color.text.primary`)
- Secondary text: English name (`type.body.small`, `color.text.secondary`)
- Trailing: ✓ checkmark (20dp, `color.primary`) for selected language; nothing for others

**On selection:**
1. The row shows a brief loading indicator (circular, 16dp, replacing the checkmark)
2. Locale changes instantly (300ms — the entire UI re-renders)
3. The settings screen itself re-renders in the new language
4. The navigation bar title changes: "تنظیمات" or "Settings"
5. No dialog asking "Are you sure?" — the change is immediate and reversible

**Note banner below list:** "Changing language affects all text and date formats. Some station names may not be available in all languages." `type.body.small`, `color.text.tertiary`.

---

## 4. Appearance Settings

### Appearance selection screen

```
  Theme

  ┌──────────────────────────────────────────────────────┐
  │  System default         Using dark mode now   ✓     │
  ├──────────────────────────────────────────────────────┤
  │  Light                                              │
  ├──────────────────────────────────────────────────────┤
  │  Dark                                               │
  └──────────────────────────────────────────────────────┘
```

**"System default"** sub-label: "Using [light/dark] mode now" — tells the user what "system default" currently means on their device.

**On selection:** Theme changes immediately across the app (Riverpod `ThemeNotifier` triggers MaterialApp rebuild). No restart required. The settings screen itself re-themes.

**The Charging Session screen exception:** The Charging Session screen always uses the dark theme regardless of system setting (per CHARGING_SESSION_SCREEN.md §4). This is noted in a footer: "Charging sessions always use dark mode for the best display." `type.body.small`, `color.text.tertiary`.

---

## 5. Notification Settings

Links to the Notification Preferences screen (NOTIFICATION_SCREENS.md §7).

The overview row shows current state: "All on" / "[N] types paused" / "All off".

If system-level notification permission is denied: the row shows "Permission required" in `color.warning` as the trailing value, and tapping opens the OS Settings app directly to the app's notification permissions page (via `openAppSettings()`).

---

## 6. Privacy Settings

### Location

**Row trailing value:** "Always" / "While using" / "Denied"

**On tap:** Navigates to a sub-screen:

```
  Location Services

  Current permission: While using the app

  The app uses location to:
  · Show your position on the charging map
  · Calculate distance to stations
  · Enable geofence check-in reminders (future)

  We do not:
  · Track your location in the background
  · Share your location with third parties

  [  Open Location Settings  ]  ← Secondary (opens OS settings)
```

If permission is "While using" or "Always": shows a note that this is sufficient. If "Denied": shows a warning and the OS settings button prominently.

### Analytics

**Toggle:** On / Off. `type.body.large` + toggle switch (44dp touch target).

**Explanation below toggle:** "Help us improve the app by sharing anonymous usage data. No personal information or location data is shared." `type.body.small`, `color.text.secondary`.

On opt-out: `POST /users/me/analytics-preference { enabled: false }` + local flag set. On confirmation: "Analytics disabled. You can re-enable at any time." toast.

---

## 7. About and Legal

**Terms of Service:** Opens in-app WebView (not external browser). Full ToS text, scrollable, with "Close" in nav bar.

**Privacy Policy:** Same as ToS.

**Help and Support:** Opens the operator's help center in an in-app WebView or a native chat interface (operator-configured).

**Rate the App:** Opens the App Store (iOS) or Play Store (Android) rating dialog in-app (via the `in_app_review` package). Falls back to opening the store listing if the in-app dialog is unavailable.

**Version row:** Non-tappable. Format: "Version [X.Y.Z] (build [N])". Long-press (5-second hold) reveals a developer mode toggle that enables additional debug logging (production build only shows version; this is a safety valve for support).

---

## 8. Data Export and Deletion

### Export My Data

On tap: a confirmation sheet:

```
  Export your data

  We'll prepare a file with all your:
  · Session history
  · Reservation history
  · Wallet transactions
  · Profile information

  This may take a few minutes. You'll receive
  an email with the download link.

  [  Request Export  ]  ← Primary
  [  Cancel         ]  ← Tertiary
```

On confirmation: `POST /users/me/data-export` → 202 Accepted → "Export request sent. You'll receive an email within 24 hours." toast.

### Delete Account

A multi-step confirmation flow to prevent accidental deletion:

**Step 1 (sheet):** "Delete your account?" — lists what will be deleted (profile, sessions, wallet). If wallet balance > ¥0: "⚠ Your wallet balance of ¥[amount] will be lost. Withdraw funds first." Primary button: "Continue to Delete"

**Step 2:** Requires entering the registered phone number as confirmation. Input field labeled "Enter your phone number to confirm." Primary: "Delete Account". This step prevents casual taps.

**Step 3 (loading):** `DELETE /users/me` → 202 Accepted → app wipes local storage → navigates to onboarding screen. A final email confirmation is sent.

---

## 9. Settings Design Patterns

**Toggle rows (48dp height):**
```
  [Icon]  Setting name                 [Toggle switch]
          Sub-explanation (optional)
```
- Toggle: standard OS toggle component (44dp touch target)
- On/Off state communicated by toggle position AND `color.secondary` (on) vs `color.outline` (off) track color

**Destructive rows (Delete Account, Sign Out):**
- Icon: `color.error`
- Text: `color.error`
- No trailing chevron — these are actions, not navigations

**External link rows (opens WebView or OS app):**
- Trailing: external link icon (↗, 16dp, `color.text.tertiary`) instead of ▸ chevron

**Current value display in overview row:** Always truncated to fit in the trailing space (max ~80dp). Full value visible on the sub-screen.

---

## 10. Loading and Error States

**Language list:** Loaded from a static local list — no loading needed.

**Notification preferences:** A brief 300ms loading skeleton while preferences fetch.

**Privacy settings:** OS permission status is synchronous — no loading.

**Data export:** Loading state only on the confirmation button tap (brief spinner).

---

## 11. Accessibility Requirements

**Section headers:** Announced as "Section: [name]."

**Toggle rows:** "[Setting name]. [On/Off]. Double-tap to toggle."

**Language selection rows:** "[Language in native script], [English name]. [Selected/Not selected]. Double-tap to apply."

**Destructive rows:** "[Action name]. Double-tap to proceed." The destructive nature is communicated by the text and by any confirmation sheets.

---

## 12. RTL Behavior

**All settings rows mirror:** Icon on right (start), text right-aligned, trailing value + chevron on left (end).

**Language selection:** Persian rows display "فارسی" as the primary text, "Persian" as secondary. The selected language name in the overview row also switches to the selected language's native name.

**On switching to Persian:** The settings screen itself re-renders entirely in RTL. All section headers, row labels, and trailing values switch to Persian. The settings structure and grouping are unchanged.

**Current value display in Persian:**
- Language: "فارسی" (not "Persian")
- Theme: "خودکار سیستم" / "روشن" / "تاریک"
- Location: "همیشه" / "هنگام استفاده" / "رد شده"
- Analytics: "فعال" / "غیرفعال"