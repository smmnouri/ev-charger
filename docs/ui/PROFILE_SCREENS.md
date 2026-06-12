# Profile Screens

**Tab:** 5 of 5 (rightmost in LTR, leftmost in RTL)  
**Route:** `/profile`  
**Child routes:** `/profile/edit` · `/profile/kyc` · `/profile/kyc/status` · `/profile/security`  
**Last Updated:** 2026-06-11  
**References:** DESIGN_SYSTEM.md · ARCHITECTURE_FINAL.md §12 · SETTINGS_SCREENS.md

The Profile tab is the user's identity and account management surface. It centers on two concerns: who the user is (their personal information and KYC status), and how they have used the platform (their charging history in summary). It is not a settings dump — settings live in SETTINGS_SCREENS.md. Profile is specifically about the user's identity, verification status, and account security.

---

## Table of Contents

1. [Profile Overview Screen](#1-profile-overview-screen)
2. [KYC Status Display](#2-kyc-status-display)
3. [Personal Information Section](#3-personal-information-section)
4. [Usage Statistics Section](#4-usage-statistics-section)
5. [Edit Profile Screen](#5-edit-profile-screen)
6. [KYC Flow](#6-kyc-flow)
7. [KYC Status Screen](#7-kyc-status-screen)
8. [Account Security Screen](#8-account-security-screen)
9. [Sign Out Flow](#9-sign-out-flow)
10. [Loading States](#10-loading-states)
11. [Error States](#11-error-states)
12. [Accessibility Requirements](#12-accessibility-requirements)
13. [RTL Behavior](#13-rtl-behavior)

---

## 1. Profile Overview Screen

### Tab badge behavior

The Profile tab shows a static amber alert dot when:
- KYC is not approved (prompting the user to complete verification)
- Account security action is required (e.g., session expired on other device)

### Screen layout

```
┌──────────────────────────────────────────────────────────────┐
│  Profile                                   [Settings ⚙]      │  ← Nav bar
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │  ← Profile header card
│  │  [Avatar 72dp]  Ali Hosseini                        │    │
│  │                 +98 912 345 6789                    │    │
│  │                 ali@example.com (if set)            │    │
│  │                 [Edit Profile]                      │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │  ← KYC status card
│  │  Identity Verification        ✓ Verified  [→]       │    │
│  │  (or: ⚠ Verification required  [Verify Now →])     │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ─── Your activity ───────────────────────────────────      │
│  ┌──────────┬──────────┬──────────┐                         │  ← Stats row
│  │  34      │ 684 kWh  │  ¥41,040 │                         │
│  │ Sessions │  Energy  │   Spent  │                         │
│  └──────────┴──────────┴──────────┘                         │
│                                                              │
│  ─── Account ─────────────────────────────────────────      │
│                                                              │
│  [🔒] Account Security              ▸                       │
│  [⭐] Membership & Plan              ▸                       │  ← Future
│  [📋] Terms and Policies            ▸                       │
│  [❓] Help and Support               ▸                       │
│                                                              │
│  [Sign Out]  ← Tertiary, color.error, centered              │
│                                                              │
│  v1.0.0 (build 42)  · type.body.small, color.text.tertiary  │
└──────────────────────────────────────────────────────────────┘
```

### Profile header card

- Background: `color.surface`
- Border radius: `radius.xl`
- Padding: 20dp
- Elevation: 1

**Avatar (72dp circle):**
- If the user has uploaded a photo: `BoxFit.cover`, `radius.full`
- If no photo: initials avatar — background is a deterministic color derived from the user's name hash (one of 8 `color.tertiary`-family colors), white initials in `type.headline.small`
- "Edit" camera icon overlay: 24dp circle, `color.primary`, bottom-right corner of avatar; tapping opens image picker

**Name:** `type.headline.small`, `color.text.primary`
**Phone:** `type.body.medium`, `color.text.secondary`. Partially masked: "+98 912 *** 6789" — full number revealed on tap
**Email (if set):** `type.body.medium`, `color.text.secondary`

**"Edit Profile" button:** Tertiary, `color.primary`, right of the contact details. Navigates to `/profile/edit`.

---

## 2. KYC Status Display

The KYC status card is the highest-priority information after the user's identity on this screen.

### KYC status variants

**Approved:**
```
  ┌────────────────────────────────────────────────────────┐
  │  [Shield ✓ 32dp, color.secondary]                      │
  │  Identity Verified              Verified 14 Jun 2026   │
  │  You can reserve and charge.                           │
  └────────────────────────────────────────────────────────┘
```
Background: `color.secondaryContainer`. No CTA needed — status is confirmed.

**Not started:**
```
  ┌────────────────────────────────────────────────────────┐
  │  [Shield ⚠ 32dp, color.warning]                        │
  │  Verify Your Identity           [Verify Now →]         │
  │  Required to reserve and start charging.               │
  └────────────────────────────────────────────────────────┘
```
Background: `color.warningContainer`. "Verify Now →" Primary button.

**Pending review:**
```
  ┌────────────────────────────────────────────────────────┐
  │  [Shield ⏳ 32dp, color.primary]                       │
  │  Verification in Progress       Usually 2–5 min        │
  │  You'll be notified when complete.                     │
  └────────────────────────────────────────────────────────┘
```
Background: `color.primaryContainer`. No CTA.

**Rejected:**
```
  ┌────────────────────────────────────────────────────────┐
  │  [Shield ✕ 32dp, color.error]                          │
  │  Verification Failed            [Try Again →]          │
  │  Could not verify your identity.                       │
  └────────────────────────────────────────────────────────┘
```
Background: `color.errorContainer`. "Try Again →" Primary button.

---

## 3. Personal Information Section

Shown within the Edit Profile screen (not the overview). Read-only fields:
- **Phone number:** Set at registration. Cannot be changed in-app in MVP.
- **Account created:** Date of first login.

Editable fields:
- **Display name:** First + last name
- **Email address:** Optional; used for receipt delivery
- **Profile photo:** Camera / photo library picker

---

## 4. Usage Statistics Section

Three metric chips in a horizontal row, within a card:

| Metric | Value | Label |
|--------|-------|-------|
| Sessions | 34 | "Sessions" |
| Energy | 684 kWh | "Energy" |
| Spent | ¥41,040 | "Spent" |

**Card design:** `color.surfaceVariant`, `radius.lg`, no elevation.

Each metric:
- Value: `type.numeric.large` (32sp/700), `color.text.primary`
- Label: `type.label.small`, letter-spaced, `color.text.tertiary`, below value

Tapping the card navigates to the Wallet transaction history filtered to sessions only.

Values are computed server-side from the user's complete `ChargingRecord` history. Shown as loading skeletons while fetching. Shown as "—" if the fetch fails.

---

## 5. Edit Profile Screen

### Layout

Standard settings-style list screen with a save button in the nav bar.

```
┌──────────────────────────────────────────────────────────────┐
│  ← Cancel                               [Save]              │
│  Edit Profile                                                │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  [Avatar 96dp, center-aligned, with edit overlay]           │
│                                                              │
│  ─── Name ────────────────────────────────────────────      │
│  First name                 [Ali              ]             │
│  Last name                  [Hosseini         ]             │
│                                                              │
│  ─── Contact ────────────────────────────────────────       │
│  Email                      [ali@example.com  ]             │
│  Phone                      +98 912 *** 6789 (read-only)    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

**"Save" button:** Disabled until at least one field has changed. On tap: `PATCH /users/me` → 200 OK → dismiss with success toast "Profile updated." If error: error banner.

**Avatar edit:** Tapping the avatar opens an action sheet: "Take Photo" / "Choose from Library" / "Remove Photo". Photo cropped to a 1:1 square via a system-native crop UI.

**Phone number:** Displayed as read-only with a note: "Phone number cannot be changed. Contact support if needed." `type.body.small`, `color.text.tertiary`.

---

## 6. KYC Flow

The KYC flow is a distinct sub-flow within the Profile section. It is also accessible from any screen that requires KYC (station detail, session start, reservation creation) via a modal sheet.

### KYC steps

```
  Step 1: Document selection
  ↓
  Step 2: Document capture (front + back)
  ↓
  Step 3: Selfie capture
  ↓
  Step 4: Submission and pending state
```

**Step 1 — Document selection:**
Select from: "National ID card" (کارت ملی) / "Passport".
- Card with radio button, document illustration, list of requirements
- "Continue" Primary Large

**Step 2 — Document capture:**
For National ID card (most common in Iran): two sequential captures — front, then back.
- Camera preview fills the screen
- Animated document outline overlay (rounded rectangle guide) centers the document
- "Capture" large circular button (64dp, white)
- Auto-capture triggers when the document fills the guide frame sufficiently (contrast + edge detection)
- After capture: preview with retake/use options

**Step 3 — Selfie capture:**
- Circular face guide overlay
- "Look directly at the camera" instruction
- Liveness check: "Slowly turn your head left… now right." Progress indicators
- This is handled by the KYC provider's SDK (integrated as a native module)

**Step 4 — Submission:**
- Brief "Uploading documents…" state
- Transitions to KYC Status screen on submission

---

## 7. KYC Status Screen

Route: `/profile/kyc/status`

Shown after KYC submission and accessible from the profile to check status.

```
  [Status illustration: reviewing hourglass or verified shield]

  Status: [Pending Review / Verified / Action Required]

  Submitted: 14 Jun 2026, 2:15 PM

  [Explanation of current state]

  [CTA — varies by state]
```

**Push notification on status change:** When KYC transitions from Pending → Approved or Rejected, a push notification fires. The status screen updates via WebSocket or on next resume.

---

## 8. Account Security Screen

Route: `/profile/security`

### Options

**Active sessions:**
- A list of devices where the user is logged in (device name, last active, location approximation)
- "This device" labeled prominently
- "Sign out from this device" — each row has a "Sign out" trailing Tertiary button
- "Sign out all other devices" — Secondary, `color.error` text

**Biometric authentication:**
- Toggle: "Use Face ID / Fingerprint to open app"
- Requires the device to have biometric enrolled
- When enabled: app requires biometric on cold start and after 15-minute background

**App lock PIN (future):**
- Toggle: "Enable 6-digit PIN" — reserve for future implementation

**Account deletion:**
- "Delete Account" — Tertiary, `color.error`, at the bottom
- Tapping navigates to a confirmation flow: explains consequences (wallet balance, history deletion), requires entering the phone number as confirmation, then sends an account deletion request

---

## 9. Sign Out Flow

Tapping "Sign Out" from the profile overview opens a confirmation sheet:

```
  ──── (handle)

  Sign out?
  type.headline.small

  You'll need to sign in again to access your
  wallet and charging history.
  type.body.medium, color.text.secondary

  [  Sign Out  ]  ← Destructive Filled (color.error background)
  [  Cancel   ]  ← Tertiary
```

**On confirmation:**
- JWT revoked server-side (`POST /auth/signout`)
- Local storage cleared (`flutter_secure_storage` wiped)
- Navigation resets to the onboarding/login screen
- No loading state needed (the clear is immediate; network revocation is best-effort)

---

## 10. Loading States

**Profile overview:** Skeleton for name, phone, stats row. KYC card shows a neutral "Loading…" state. Stats metrics show skeleton rectangles.

**Edit profile:** Screen opens with current values pre-populated (from the cache that was loaded on the profile overview). No loading needed.

**KYC capture:** No loading during capture. Loading during upload (full-screen overlay: "Uploading documents…").

---

## 11. Error States

**Profile fetch failed:** "Couldn't load profile. [Retry →]" — inline error within the header card area. Rest of screen renders from cache.

**Edit save failed:** Error banner at top of screen: "Profile update failed. Check your connection and try again."

**KYC submission failed:** Full-screen error: "Upload failed. Please check your connection and try again." + retry.

---

## 12. Accessibility Requirements

**KYC camera:** Explicit instructions read aloud before capture. Capture button: "Capture document photo. Double-tap to take photo." Auto-capture is announced: "Document detected. Capturing automatically in 2 seconds. Double-tap to capture now."

**Active sessions list:** Each session row: "[Device name]. Last active [date]. [This device / Other device]. [Sign out button if applicable]."

**Sign out confirmation sheet:** Focus moves to sheet title. "Sign Out" button: "Sign out of your account. This action requires signing in again. Double-tap to confirm."

---

## 13. RTL Behavior

**Profile header:** Avatar on the right (start in RTL), name/phone left-aligned... actually, avatar should be on start (right in RTL), name to the left. All text right-aligned in RTL.

**Stats row:** Three metrics maintain left-to-right order within the row but the row is right-aligned as a unit in RTL. Individual metric values use Persian-Indic digits.

**Account list rows:** Icon on right (start), text right-aligned, chevron on left (end).

**KYC document capture:** Document guide overlay mirrors for right-to-left document layouts if applicable to the document type.

**Persian name fields:** RTL text input, Vazirmatn font, no explicit LTR override needed (names are RTL content).