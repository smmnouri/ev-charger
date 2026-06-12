# Sprint 02 — Authentication & App Entry

**Status:** Complete  
**Release Tag:** v0.2.0-auth  
**Branch:** `feature/sprint-2-auth`  
**Dates:** 2026-06-12  
**Author:** Rayan Nouri

---

## Delivered Features

### AUTH-01 — Splash Screen & Welcome Screen

**Splash Screen** (`features/auth/presentation/screens/splash_screen.dart`)
- Always-dark branded entry point (`AppColors.backgroundDark`) shown during auth state resolution
- Gradient bolt logo (primary → tertiary), localized app name via `l10n.appName`
- `CircularProgressIndicator` with `Semantics(label: l10n.loading)` for screen reader support
- Displayed whenever `AuthState.unknown` — no timer, no auto-dismiss; GoRouter redirect handles transition once `resolveFromStorage()` completes in `main()`

**Welcome Screen** (`features/auth/presentation/screens/onboarding_screen.dart`)
- Theme-adaptive scaffold (follows system light/dark)
- Gradient bolt logo, localized headline (`welcomeTitle`), value proposition body (`welcomeBody`), primary CTA (`welcomeGetStarted`)
- RTL-ready: centered text layout works for both en/fa; `Semantics(label: l10n.appName)` on logo
- Primary button navigates to `/onboarding/login` via `context.push(AppRoutes.login)`

**New ARB keys (en + fa):** `welcomeTitle`, `welcomeBody`, `welcomeGetStarted`

---

### AUTH-02 — Login Screen, OTP Verification & Session Restore

**Login Screen** (`features/auth/presentation/screens/login_screen.dart`)
- Phone number entry with country code picker (Iran `+98` / Germany `+49`)
- Digit-only input forced LTR via `Directionality(textDirection: TextDirection.ltr)` — phone numbers are never RTL regardless of locale
- Per-country digit length enforcement: Iran = 10 digits, Germany = 10–12 digits
- `FilteringTextInputFormatter.digitsOnly` + `LengthLimitingTextInputFormatter` applied
- Inline validation displayed as `InputDecoration.errorText`; cleared on any keystroke
- Mock network delay: 1 500 ms; all-zeros phone triggers `errorGeneric` failure path
- Country picker presented as `ModalBottomSheet` with `showDragHandle: true`; each entry shows flag (excluded from semantics), localized country name, dial code, and a checkmark for the active selection
- `textInputAction: TextInputAction.done` on phone field; keyboard action submits form
- Country code button `Semantics.label` uses localized country name + dial code (e.g., `"Iran +98"`) — no raw emoji in accessibility tree

**OTP Verification Screen** (`features/auth/presentation/screens/otp_screen.dart`)
- Six individual digit boxes in a forced-LTR `Row`; each `TextField` has `maxLength: 1`, `FilteringTextInputFormatter.digitsOnly`
- Auto-advance: focus moves to the next box after each digit entry
- Backspace-to-previous: `FocusNode.onKeyEvent` intercepts `LogicalKeyboardKey.backspace` on an empty box and moves focus back
- `textInputAction: TextInputAction.next` on boxes 0–4; `TextInputAction.done` on box 5
- Auto-submit fires when all six boxes are filled; manual submit button also available (disabled when boxes are incomplete or loading)
- 60-second resend countdown via `Timer.periodic`; "Resend code" button appears after timeout
- Mock verification delay: 1 200 ms; `000000` triggers invalid-code error path
- Error text wrapped in `Semantics(liveRegion: true)` — TalkBack/VoiceOver announces failures without requiring focus movement
- On success: writes mock JWT tokens to `SecureStorage`, calls `AuthNotifier.setAuthenticated()`; GoRouter `globalRedirect` handles navigation to `/map`

**Session Restore** (`main.dart` — Sprint 1 infrastructure)
- `SecureStorage.hasAccessToken()` checked at app launch before `runApp()`
- `AuthNotifier.resolveFromStorage(hasToken: ...)` sets `AuthState.authenticated` or `unauthenticated`
- Users with a stored token bypass all auth screens and land directly on `/map`

**New ARB keys (en + fa):** `loginTitle`, `loginSubtitle`, `loginPhoneHint`, `loginSelectCountry`, `loginCountryIran`, `loginCountryGermany`, `loginInvalidPhone`, `otpTitle`, `otpSubtitle`, `otpResendIn`, `otpResendCode`, `otpInvalidCode`, `otpSemanticLabel`

---

### AUTH-04 — Authentication Polish

Accessibility, keyboard UX, and localization fixes across all four auth screens. No new features.

| Screen | Fix |
|--------|-----|
| Splash | Hardcoded `'EV Charger'` replaced with `l10n.appName` (×2: Text + Semantics label) |
| Splash | `CircularProgressIndicator` wrapped in `Semantics(label: l10n.loading)` |
| Login | `textInputAction: TextInputAction.done` added to phone field |
| Login | Dead variable `borderWidth = hasError ? 1.0 : 1.0` removed |
| Login | Country code button semantic label updated to use localized country name |
| Login | `showDragHandle: true` added to country picker bottom sheet |
| OTP | Timer callback extracted to named method `_onResendTick`; `initState` starts timer directly without calling `setState` |
| OTP | `textInputAction` set per-box: `next` for boxes 0–4, `done` for box 5 |
| OTP | Error text wrapped in `Semantics(liveRegion: true)` |

---

## Architectural Decisions

### 1. GoRouter `globalRedirect` as single auth gate

All auth state transitions are handled in `RouteGuards.globalRedirect()` in `core/router/route_guards.dart`. No screen navigates imperatively on auth state changes — screens call `AuthNotifier` methods and the router reacts:

```
AuthState.unknown        → redirect to /
AuthState.unauthenticated → redirect to /onboarding (saving intended destination)
AuthState.authenticated  → redirect away from auth/splash routes to /map
```

Consequence: OTP screen calls `setAuthenticated()` and does nothing else. The router redirect drives the user to `/map`. This keeps all routing logic in one place.

### 2. `AuthState` enum drives all routing

`AuthNotifier.build()` initialises to `AuthState.unknown`. The splash screen is always the first frame the user sees while `main()` awaits `SecureStorage.hasAccessToken()`. This eliminates any "flash of wrong screen" on app launch.

### 3. Phone numbers and OTP always LTR

Phone numbers, dial codes, and OTP digit boxes are wrapped in `Directionality(textDirection: TextDirection.ltr)` explicitly. This is a locale-invariant rule: numeric inputs must not mirror in RTL mode. The wrapping is applied at the widget level so the rule is enforced regardless of the ambient locale.

### 4. Mock error paths are test-deterministic

| Input | Behaviour |
|-------|-----------|
| Phone: all zeros (e.g., `0000000000` for Iran) | Simulates network error — `errorGeneric` shown |
| OTP: `000000` | Simulates invalid code — `otpInvalidCode` shown, boxes cleared |
| Any other valid input | Simulates success |

This allows manual QA of all three states without a backend.

### 5. Session restore happens before `runApp()`

`main()` awaits `SecureStorage.hasAccessToken()` in a pre-run `ProviderContainer`, calls `resolveFromStorage()`, then passes the container to `UncontrolledProviderScope`. The app never renders a frame with `AuthState.unknown` for a returning user — they see the splash for one frame at most before the redirect fires.

### 6. Token storage is mock-only

Mock tokens follow the pattern `mock_access_<phone>` / `mock_refresh_<phone>`. The `SecureStorage` wrapper stores these in `flutter_secure_storage` (Android encrypted prefs, iOS Keychain), so session restore works across cold starts even in mock mode. Sprint 3 backend integration will replace the token values; the storage layer does not change.

---

## Commits

| Hash | Scope | Description |
|------|-------|-------------|
| `6b51dd8` | AUTH-01 | feat: implement splash screen and welcome screen |
| `3f9ba49` | AUTH-01 | feat: implement splash and welcome screens (planning doc update) |
| `d21cf91` | AUTH-02 | feat: implement login and OTP verification screens |
| `138f2df` | AUTH-04 | fix: authentication polish — accessibility, keyboard UX, localization |

> Note: AUTH-03 was not assigned in this sprint. Numbering skips from AUTH-02 to AUTH-04.

**Files changed (sprint scope):**
```
mobile/lib/features/auth/presentation/screens/splash_screen.dart      (new)
mobile/lib/features/auth/presentation/screens/onboarding_screen.dart  (replaced stub)
mobile/lib/features/auth/presentation/screens/login_screen.dart       (new)
mobile/lib/features/auth/presentation/screens/otp_screen.dart         (replaced stub)
mobile/lib/core/l10n/arb/app_en.arb                                   (16 new keys)
mobile/lib/core/l10n/arb/app_fa.arb                                   (16 new keys)
mobile/lib/core/l10n/app_localizations*.dart                          (regenerated)
mobile/lib/core/router/app_router.dart                                (login route wired)
mobile/lib/core/router/app_routes.dart                                (login constant)
mobile/lib/core/router/route_guards.dart                              (login in auth guard)
```

---

## Localization Coverage

**16 new ARB keys** added in both `app_en.arb` and `app_fa.arb`:

| Key | English | Persian |
|-----|---------|---------|
| `welcomeTitle` | Welcome to EV Charger | به شارژ خودرو برقی خوش آمدید |
| `welcomeBody` | Find charging stations… | ایستگاه‌های شارژ را پیدا کنید… |
| `welcomeGetStarted` | Get Started | شروع کنید |
| `loginTitle` | Enter your number | شماره را وارد کنید |
| `loginSubtitle` | We'll send a verification code… | کد تأیید به این شماره ارسال می‌شود. |
| `loginPhoneHint` | 000 000 0000 | 000 000 0000 |
| `loginSelectCountry` | Select country | انتخاب کشور |
| `loginCountryIran` | Iran | ایران |
| `loginCountryGermany` | Germany | آلمان |
| `loginInvalidPhone` | Enter a valid phone number | یک شماره تلفن معتبر وارد کنید |
| `otpTitle` | Verify your number | تأیید شماره |
| `otpSubtitle` | Enter the 6-digit code sent to {phone}. | کد ۶ رقمی ارسال شده به {phone} را وارد کنید. |
| `otpResendIn` | Resend in {seconds}s | ارسال مجدد در {seconds} ثانیه |
| `otpResendCode` | Resend code | ارسال مجدد کد |
| `otpInvalidCode` | Incorrect code. Try again. | کد نادرست است. دوباره امتحان کنید. |
| `otpSemanticLabel` | 6-digit verification code | کد تأیید ۶ رقمی |

---

## Known Limitations

These are sprint-scoped constraints, not defects. All are expected for v0.2.0-auth.

1. **No backend integration.** All network operations are simulated with `Future.delayed`. Sprint 3 will wire the real auth API.

2. **Mock JWT tokens.** Stored tokens are `mock_access_<phone>` strings. Real token validation, refresh, and expiry are not implemented.

3. **Two countries only.** Iran (`+98`, 10 digits) and Germany (`+49`, 10–12 digits) are hardcoded in `_kCountries`. A real country picker with search will be required before international launch.

4. **No Iranian phone format enforcement.** Validation checks digit count (10) but does not enforce the `09xx` prefix required by Iranian mobile numbers.

5. **OTP paste not supported.** Each box has `maxLength: 1`. Pasting a 6-digit string fills only the first box. A single-field hidden input approach would support paste but adds complexity deferred to polish.

6. **Resend rate limiting is client-side only.** The 60-second countdown is purely UI. Without a backend there is no server-side throttling.

7. **OTP delivered by mock only.** No SMS, WhatsApp, or voice fallback. The "code" is any 6 digits (except `000000`).

8. **No account creation or sign-up flow.** The login screen implies an existing account. Registration is out of scope for Sprint 2.

9. **AUTH-03 not assigned.** Task numbering skips from AUTH-02 to AUTH-04. No work is missing; AUTH-03 was simply not created in the sprint backlog.

10. **Deep link handling absent.** If the app is cold-launched via a deep link while unauthenticated, the user is redirected to `/onboarding` with a `?redirect=` query param, but the post-auth redirect is not consumed after login. This will be addressed in Sprint 3 alongside backend integration.

---

## Acceptance Criteria — Verification

| Criterion | Status |
|-----------|--------|
| User can enter phone number | ✅ |
| Mock OTP flow works | ✅ |
| OTP verification works | ✅ |
| Session restore works | ✅ |
| Auth state persists across cold starts | ✅ |
| English supported | ✅ |
| Persian (fa) supported | ✅ |
| RTL verified | ✅ |
| Route guards function correctly | ✅ |
| `flutter analyze` — 0 issues | ✅ |
