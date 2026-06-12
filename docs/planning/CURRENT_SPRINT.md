# Sprint 02 - Authentication & App Entry

Status: In Progress

Release Target:
v0.2.0-auth

Branch:
feature/sprint-2-auth

## Current Sprint Goal

Implement the complete authentication and app entry flow for the mobile application.

## In Scope

* Splash Screen
* Welcome Screen
* Login Screen
* OTP Verification Screen
* Session Restore
* Auth Loading States
* Auth Error States
* RTL Verification
* Accessibility Verification

## Out of Scope

* Home Map
* Station Discovery
* Reservation
* Charging Session
* Wallet
* Notifications
* Settings
* Backend Integration

## Relevant Files

docs/ui/AUTH_SCREENS.md

mobile/lib/features/auth/

mobile/lib/core/navigation/

mobile/lib/core/localization/

mobile/lib/core/design_system/

## Acceptance Criteria

* User can enter phone number
* Mock OTP flow works
* OTP verification works
* Session restore works
* Auth state persists
* English and Persian supported
* RTL verified
* Route guards function correctly

## Constraints

* Mock services only
* No backend integration
* Follow existing Design System
* Follow existing Riverpod architecture
* Follow existing Go Router architecture
