# EV Charging Platform — Architecture Final

**Status:** Finalized — Implementation Ready  
**Scope:** Flutter Mobile Application (MVP)  
**Last Updated:** 2026-06-11  
**Supersedes:** PROJECT_CONTEXT.md

This document is the single source of truth for the entire platform architecture. Every implementation decision must be consistent with this baseline. Do not modify this document without a deliberate architecture review. No section may be changed unilaterally during implementation.

---

## Table of Contents

1. [Product Scope](#1-product-scope)
2. [MVP Scope](#2-mvp-scope)
3. [Domain Modules](#3-domain-modules)
4. [Entity Catalog](#4-entity-catalog)
5. [Aggregate Catalog](#5-aggregate-catalog)
6. [Repository Catalog](#6-repository-catalog)
7. [Use Case Catalog](#7-use-case-catalog)
8. [API Standards](#8-api-standards)
9. [WebSocket Standards](#9-websocket-standards)
10. [OCPP Architecture](#10-ocpp-architecture)
11. [Security Architecture](#11-security-architecture)
12. [Authentication and KYC](#12-authentication-and-kyc)
13. [Wallet and Financial Rules](#13-wallet-and-financial-rules)
14. [Pricing and Tariff Rules](#14-pricing-and-tariff-rules)
15. [Reservation Architecture](#15-reservation-architecture)
16. [Charging Architecture](#16-charging-architecture)
17. [Station Discovery Architecture](#17-station-discovery-architecture)
18. [Navigation Architecture](#18-navigation-architecture)
19. [Riverpod State Management Architecture](#19-riverpod-state-management-architecture)
20. [Folder Structure Architecture](#20-folder-structure-architecture)
21. [Offline Strategy](#21-offline-strategy)
22. [Scalability Strategy](#22-scalability-strategy)
23. [Future Roadmap](#23-future-roadmap)
24. [Non-Negotiable Architectural Constraints](#24-non-negotiable-architectural-constraints)
25. [Internationalization and Localization Architecture](#25-internationalization-and-localization-architecture)

---

## 1. Product Scope

An enterprise-grade EV Charging Management Platform. The platform enables EV drivers to discover charging stations, make reservations, manage active charging sessions, and handle payments through a digital wallet — all from a mobile application.

The platform is built for long-term extensibility. The architecture accommodates the following capabilities from day one, even though none are implemented in the MVP:

- Smart Charging (ISO 15118, demand-side management, charging schedules)
- Plug & Charge (ISO 15118-2, automated authorization without app interaction)
- Fleet Management (group vehicles, shared billing, usage reports)
- Corporate Accounts (multi-user organizations, admin portal, cost centers)
- V2G / V2H / V2B / V2X (bidirectional energy flows, vehicle-to-grid)
- Subscription plans (membership tiers, discounted rates)
- Multi-currency support (currently blocked pending CurrencyMismatchFailure resolution)

Every structural decision in this document is evaluated against: does this prevent adding the above capabilities later without rewriting existing code?

---

## 2. MVP Scope

The MVP delivers a complete end-to-end EV charging experience with five core user flows:

| Flow | Description |
|------|-------------|
| Authentication + KYC | Phone OTP login, JWT session management, identity verification |
| Station Discovery | Map-based station browsing, real-time availability, station detail |
| Reservation | Connector slot booking, cancellation, calendar management |
| Charging Session | Remote session start/stop, live metrics, receipt |
| Wallet | Balance view, top-up, transaction history |

### MVP boundaries (explicitly out of scope)

- Fleet or corporate features
- Subscription plans or loyalty tiers
- Smart Charging or load management
- ISO 15118 / Plug & Charge
- V2G / V2H / V2B / V2X
- Multi-currency wallet (single currency per deployment)
- Web application or admin portal
- Operator-facing tools

### Backend stack

| Concern | Technology |
|---------|-----------|
| API | .NET 9 |
| Database | PostgreSQL |
| Cache | Redis |
| Message broker | RabbitMQ |
| EV Protocol (current) | OCPP 1.6J |
| EV Protocol (future) | OCPP 2.0.1, OCPP 2.1 |

### Mobile stack

| Concern | Technology |
|---------|-----------|
| Framework | Flutter |
| State management | Riverpod |
| Navigation | Go Router |
| HTTP client | Dio |
| Real-time | WebSocket (dart:io) |
| Secure storage | flutter_secure_storage |
| Local cache | Hive |
| Push notifications | FCM (Android), APNS (iOS) |
| Cryptography | Platform-native (BoringSSL / CommonCrypto) |
| Maps | Native map SDK (TBD at implementation) |

---

## 3. Domain Modules

Eight bounded contexts. Each is a separate `features/<name>/` directory with its own domain, application, infrastructure, and presentation layers.

| Module | Type | Description |
|--------|------|-------------|
| `auth` | Feature | Phone+OTP login, JWT lifecycle, session management |
| `profile` | Feature | User profile, vehicles, KYC submission |
| `station` | Feature | Station map, search, detail, real-time availability |
| `reservation` | Feature | Slot booking, cancellation, lifecycle |
| `charging` | Feature | Active session monitoring, OCPP via PAL |
| `wallet` | Feature | Balance, top-up, transaction ledger |
| `tariff` | Headless feature | Pricing schedules, cost estimation, tariff snapshots |
| `notification` | Headless feature | Device registration, delivery pipeline, preferences |

**Headless modules** have domain, application, and infrastructure layers but no presentation layer. They serve other features through their providers and domain types.

### Cross-module import rules

- A feature may import another feature's `domain/` for shared types only
- A feature never imports another feature's `application/`, `infrastructure/`, or `presentation/`
- Cross-feature state access is through Riverpod providers — never direct class imports
- Each feature exposes a `<feature>_module.dart` barrel as its only public API
- `core/` may never import from `features/`

---

## 4. Entity Catalog

Entities are objects with identity. They are defined in `<feature>/domain/entities/`.

### Auth domain

| Entity | Key fields |
|--------|-----------|
| `UserSession` | sessionId, userId, deviceId, createdAt, lastActiveAt, isCurrentDevice |
| `AuthToken` | accessToken (raw string), refreshToken (raw string), expiresAt |
| `ActiveDevice` | deviceId, deviceName, platform, lastActiveAt |

### Profile domain

| Entity | Key fields |
|--------|-----------|
| `UserProfile` | userId, phone (PhoneNumber), displayName, avatarUrl, createdAt |
| `Vehicle` | vehicleId, userId, make, model, year, connectorType (ConnectorType) |
| `KycSubmission` | submissionId, userId, kycStatus (KycStatus), submittedAt, reviewedAt, rejectionReason? |

### Station domain

| Entity | Key fields |
|--------|-----------|
| `Station` | stationId, name, address, location (GeoPoint), connectors, operatorId, amenities |
| `Connector` | connectorId, stationId, type (ConnectorType), powerKw, status (ChargerStatus) |
| `StationCluster` | clusterId, centroid (GeoPoint), stationCount, viewport bounds |

### Reservation domain

| Entity | Key fields |
|--------|-----------|
| `Reservation` | reservationId, userId, connectorId, stationId, timeSlot (TimeSlot), status (ReservationStatus), tariffSnapshot (TariffSnapshot), vehicleId, createdAt |
| `AvailabilitySlot` | connectorId, startTime, endTime, isAvailable, reservationId? |

### Charging domain

| Entity | Key fields |
|--------|-----------|
| `ChargingSession` | sessionId, reservationId?, connectorId, userId, status (SessionStatus), metrics (SessionMetrics), startedAt, commandId? |
| `ChargingRecord` | sessionId, connectorId, userId, stopReason (SessionStopReason), finalMetrics (SessionMetrics), isBillable, tariffSnapshot (TariffSnapshot), stoppedAt, transactionId? |
| `SessionMetrics` | energyKwh (EnergyKwh), durationSeconds, estimatedCost (Cents), peakPowerKw?, stateOfCharge?, activePowerKw?, measurands (Map — OCPP 2.x only) |

`ChargingSession` is the active, mutable entity. `ChargingRecord` is the immutable completed record. They are separate entities, not the same entity in different states.

### Wallet domain

| Entity | Key fields |
|--------|-----------|
| `WalletAccount` | walletId, userId, balance (Cents), currency (CurrencyCode), updatedAt |
| `Transaction` | transactionId, walletId, type (TransactionType), amount (Cents), description, reference, idempotencyKey, createdAt |
| `PaymentIntent` | paymentIntentId, walletId, amount (Cents), status, idempotencyKey, createdAt, confirmedAt? |

### Tariff domain

| Entity | Key fields |
|--------|-----------|
| `TariffSchedule` | tariffId, connectorId, components, validFrom, validUntil, currency (CurrencyCode), operatorId |
| `TariffComponent` | componentId, type (flat/time/energy/session), rate (TariffRate), conditions (timeOfDay?, dayOfWeek?, minPowerKw?) |

### Notification domain

| Entity | Key fields |
|--------|-----------|
| `DeviceRegistration` | deviceId, userId, fcmToken, platform (ios/android), registeredAt, lastRefreshedAt |
| `NotificationRecord` | notificationId, userId, type, title, body, data, channel, deliveredAt, readAt? |
| `NotificationPreference` | userId, category (session/reservation/wallet/security), enabled, quietHoursStart?, quietHoursEnd? |

### Shared value objects (core/domain/value_objects/)

These cross feature boundaries. They live in `core/` and are never owned by a single feature.

| Value object | Used by |
|-------------|---------|
| `UserId` | All modules |
| `StationId` | station, reservation, charging |
| `ConnectorId` | station, reservation, charging, tariff |
| `SessionId` | charging, wallet |
| `ReservationId` | reservation, charging |
| `Cents` | wallet, charging, reservation, tariff |
| `CurrencyCode` | wallet, tariff |
| `PhoneNumber` | auth, profile |
| `GeoPoint` | station |
| `ConnectorType` | station, profile (vehicles) |
| `ChargerStatus` | station, charging |
| `KycStatus` | profile, auth (in JWT claims) |
| `EnergyKwh` | charging, tariff |
| `TimeSlot` | reservation |

---

## 5. Aggregate Catalog

An aggregate is a consistency boundary. Only the aggregate root may be referenced from outside the aggregate. Internal entities are accessed only through the root.

| Aggregate root | Internal members | Invariant enforced |
|---------------|-----------------|-------------------|
| `UserSession` | `AuthToken`, `ActiveDevice` | A session has exactly one token and one device binding |
| `UserProfile` | `Vehicle[]`, `KycSubmission` | KYC submission belongs to one profile; vehicle list is user-scoped |
| `Station` | `Connector[]` | Connectors cannot exist without a parent station |
| `Reservation` | `AvailabilitySlot` (reference only) | Reservation holds a TariffSnapshot at creation time — not a live tariff reference |
| `ChargingSession` | `SessionMetrics` | Metrics exist only within a session; session is the single writer |
| `ChargingRecord` | `SessionMetrics` (final copy) | Immutable after creation; no fields ever updated |
| `WalletAccount` | `Transaction[]` | Transactions are append-only; balance is derived from ledger, not stored independently |
| `TariffSchedule` | `TariffComponent[]` | Components belong to one schedule; schedules are versioned by validFrom/validUntil |
| `DeviceRegistration` | `NotificationPreference[]` | Preferences are tied to the device registration, not the user directly |

---

## 6. Repository Catalog

All repositories are abstract interfaces in `<feature>/domain/repositories/`. Concrete implementations are in `<feature>/infrastructure/repositories/`. The application layer depends on the interface, never the implementation.

| Repository | Key operations |
|-----------|---------------|
| `AuthRepository` | `sendOtp(phone)`, `verifyOtp(phone, code)`, `refresh()`, `logout()`, `listActiveSessions()`, `revokeSession(sessionId)` |
| `ProfileRepository` | `getProfile()`, `updateProfile(fields)`, `addVehicle(vehicle)`, `updateVehicle(id, fields)`, `removeVehicle(id)` |
| `KycRepository` | `submitKyc(documents)`, `getKycStatus()` |
| `StationRepository` | `getStationsInViewport(bounds, zoom)`, `getStationDetail(stationId)`, `searchStations(query, near)`, `getConnectorAvailability(connectorId)` |
| `ReservationRepository` | `createReservation(request)`, `cancelReservation(id, reason)`, `getReservation(id)`, `listReservations(cursor, status)`, `getAvailableSlots(connectorId, date)` |
| `ChargingRepository` | `startSession(connectorId, reservationId?)`, `stopSession(sessionId)`, `getSession(sessionId)`, `getRecord(sessionId)` |
| `WalletRepository` | `getAccount()`, `topUp(amount, idempotencyKey)`, `listTransactions(cursor)`, `getTransaction(id)` |
| `TariffRepository` | `getTariff(connectorId)`, `estimateCost(connectorId, durationMinutes, energyKwh)` |
| `NotificationRepository` | `registerDevice(token, platform)`, `unregisterDevice(deviceId)`, `updatePreferences(prefs)`, `listNotifications(cursor)` |
| `JwksRepository` | `fetchJwks()`, `getCachedJwks()` — used only by `JwksProvider` in `core/security/` |

---

## 7. Use Case Catalog

A use case is created only when an operation spans more than one repository or has orchestration logic that does not belong in a notifier. Simple single-repository operations live directly in notifiers.

| Use Case | Repositories touched | Reason for use case |
|----------|---------------------|---------------------|
| `StartSessionUseCase` | `ChargingRepository`, `WalletRepository`, `TariffRepository`, `ReservationRepository` | Validates connector, checks balance against tariff estimate, sends OCPP start command, correlates 202 response with WebSocket confirmation, handles timeout |
| `StopSessionUseCase` | `ChargingRepository`, `WalletRepository` | Sends OCPP stop command, awaits WebSocket confirmation, triggers wallet reconciliation, creates ChargingRecord |
| `CreateReservationUseCase` | `ReservationRepository`, `WalletRepository`, `TariffRepository`, `StationRepository` | Validates slot availability, checks balance against tariff estimate, captures TariffSnapshot at creation time, handles race conditions on concurrent bookings |
| `CancelReservationUseCase` | `ReservationRepository`, `WalletRepository` | Validates cancellation window, triggers refund to wallet if within policy, updates reservation status |
| `WalletTopUpUseCase` | `WalletRepository` | Initiates payment intent, polls/waits for confirmation, credits wallet — full idempotency key lifecycle |
| `SubmitKycUseCase` | `KycRepository`, `ProfileRepository` | Document validation (client-side), upload to secure endpoint, submit for review, update profile |
| `RevokeSessionUseCase` | `AuthRepository` | Revokes specific session; if current device, logs out locally |
| `ForceTokenRefreshUseCase` | `AuthRepository` | Used when KYC WebSocket event or server 401 demands immediate refresh outside the normal interceptor path |

---

## 8. API Standards

### Error responses — RFC 7807 Problem Details

All API errors return Problem Details format. No other error format is used.

```
HTTP/1.1 402 Payment Required
Content-Type: application/problem+json

{
  "type": "https://api.evcharger.com/errors/insufficient-funds",
  "title": "Insufficient funds",
  "status": 402,
  "detail": "Wallet balance of ¥450 is insufficient for estimated cost of ¥800",
  "instance": "/wallet/transactions/attempt-abc123",
  "traceId": "abc123"
}
```

`ApiError` (an `AppError` variant) carries the full Problem Details object. Widgets render `title` and `detail`. `instance` and `traceId` are shown only behind a "Report this issue" action.

### Pagination — cursor-based

All list endpoints use cursor-based pagination. Offset pagination is never used.

```
GET /reservations?cursor=<opaque>&limit=20
→ { "items": [...], "nextCursor": "<opaque>", "hasMore": true }
```

`PaginatedState<T>` in the application layer carries `items`, `nextCursor`, `hasMore`, and `lastFetchedAt`.

### HTTP status conventions

| Scenario | Status |
|----------|--------|
| OCPP-dependent command accepted | 202 Accepted |
| Resource created | 201 Created |
| Successful mutation | 200 OK |
| Successful delete / no body | 204 No Content |
| Client validation error | 422 Unprocessable Entity |
| Authentication required | 401 Unauthorized |
| KYC or permission denied | 403 Forbidden |
| Resource not found | 404 Not Found |
| Conflict (e.g. slot taken) | 409 Conflict |
| Rate limited | 429 Too Many Requests |
| Server maintenance | 503 Service Unavailable |

### 202 Accepted pattern for OCPP commands

OCPP-dependent commands (`POST /sessions/start`, `POST /sessions/{id}/stop`) return 202 Accepted immediately. The actual outcome arrives via WebSocket.

The response body carries a `commandId`:
```
HTTP/1.1 202 Accepted
{ "commandId": "cmd-abc123", "message": "Command sent to charger" }
```

The notifier correlates the WebSocket confirmation event using `commandId`. If no confirming event arrives within the timeout (30 seconds), the notifier emits `OcppTimeoutError`.

### API endpoints by feature

**Authentication**
```
POST   /auth/send-otp                 Send OTP to phone number (rate limited)
POST   /auth/verify                   Verify OTP, return JWT + refresh token
POST   /auth/refresh                  Refresh access token using refresh token
POST   /auth/logout                   Revoke current session
GET    /auth/sessions                 List active sessions for user
DELETE /auth/sessions/{sessionId}     Revoke specific session
```

**Profile & KYC**
```
GET    /profile                       Get current user profile
PATCH  /profile                       Update profile fields
POST   /profile/vehicles              Add vehicle
PUT    /profile/vehicles/{id}         Update vehicle
DELETE /profile/vehicles/{id}         Remove vehicle
POST   /kyc/submissions               Submit KYC documents
GET    /kyc/status                    Get current KYC status
```

**Stations**
```
GET    /stations                      Stations in viewport (?bounds=&zoom=)
GET    /stations/{id}                 Station detail
GET    /stations/search               Text search (?q=&near=)
GET    /connectors/{id}/availability  Availability slots for a connector
GET    /connectors/{id}/tariff        Active tariff for connector
POST   /connectors/{id}/tariff/estimate  Cost estimate (?minutes=&kwh=)
```

**Reservations**
```
POST   /reservations                  Create reservation
GET    /reservations                  List user's reservations (paginated)
GET    /reservations/{id}             Reservation detail
DELETE /reservations/{id}             Cancel reservation
```

**Charging Sessions**
```
POST   /sessions/start                Start charging session → 202
POST   /sessions/{id}/stop            Stop charging session → 202
GET    /sessions/{id}                 Active session state
GET    /sessions/{id}/record          Completed session record (receipt)
```

**Wallet**
```
GET    /wallet                        Wallet balance and currency
POST   /wallet/topup                  Initiate top-up (idempotency key required)
GET    /wallet/transactions           Transaction history (paginated)
GET    /wallet/transactions/{id}      Transaction detail
```

**Devices & Notifications**
```
POST   /devices                       Register device for push notifications
DELETE /devices/{deviceId}            Unregister device
PUT    /notifications/preferences     Update notification preferences
GET    /notifications                 Notification history (paginated)
```

**Security**
```
POST   /security/events               Log client-side security events (SignatureInvalid, DeviceIdMismatch)
```

**JWKS (public)**
```
GET    /.well-known/jwks.json         Public key set for JWT verification
```

---

## 9. WebSocket Standards

### Connection model

One persistent WebSocket connection per authenticated session. All real-time topics are multiplexed over this single connection via a topic-prefix routing protocol. There is no per-feature WebSocket connection.

```
WebSocketManager (singleton, app lifetime)
  ├── WebSocketClient         raw connection lifecycle
  ├── TopicRouter             dispatches messages by topic prefix
  ├── EventReplayBuffer       tracks lastSequenceId per topic
  └── ReconnectScheduler      exponential backoff: 1s → 2s → 4s → 8s → 30s (cap)
```

The WebSocket connects to the business API layer, not directly to the OCPP Gateway. The OCPP Gateway publishes events to RabbitMQ; the business API consumes and forwards to mobile clients.

### Event envelope

Every WebSocket message uses this envelope:

```json
{
  "topic": "session.abc123.events",
  "sequenceId": 47,
  "timestamp": "2026-06-11T14:30:00Z",
  "type": "SessionStatusChanged",
  "payload": { ... }
}
```

`sequenceId` is monotonically increasing per topic. The `EventReplayBuffer` tracks the last seen value per topic. On reconnect, the subscribe frame includes `lastSequenceId` to request replay of missed messages. The server replays events within a 5-minute window.

### Topic naming

```
charger.{stationId}.status              Station-level connector availability
session.{sessionId}.events              Session lifecycle events
session.{sessionId}.meters              Meter values (energy, duration, cost)
reservation.{userId}.updates            Reservation lifecycle for this user
notifications.{userId}                  General in-app events (same payload as push)
kyc.{userId}.status                     KYC decision events
```

Topics are subscribed and unsubscribed via control frames. `WebSocketManager` maintains a reference count per topic. When the last subscriber unsubscribes, an unsubscribe frame is sent to the server.

### Viewport-scoped subscriptions

`StationAvailabilityStreamProvider(stationId)` is an `autoDispose` stream provider. The map widget watches providers for each visible station ID. Riverpod's `autoDispose` automatically sends subscribe/unsubscribe frames as station IDs enter and leave the viewport — no manual subscription management in the map widget.

### Reconnection and event replay

On reconnect: for each active topic subscription, the manager sends a subscribe frame with `lastSequenceId`. The server replays missed events within the replay window. `EventReplayBuffer` prevents state gaps during brief disconnects. This applies to all topics including mid-session meter values.

---

## 10. OCPP Architecture

### Protocol Abstraction Layer (PAL)

Domain logic never references OCPP types, message formats, or status codes. The PAL is the complete isolation boundary between the OCPP protocol world and the domain model.

All OCPP-specific code is confined to: `charging/infrastructure/adapters/`

### Revised PAL interface

```
OcppProtocolAdapter (abstract interface)
  translateInbound(rawMessage: OcppRawMessage, context: AdapterContext) → List<OcppDomainEvent>
  translateOutbound(command: SessionCommand, context: AdapterContext) → OcppRawMessage
```

**Why `List<OcppDomainEvent>`:** OCPP 2.x `TransactionEvent(Updated)` can produce both a `MeterValueReceivedEvent` AND a `SessionStatusChangedEvent` in one message. The original `translateInbound() → SessionEvent` signature cannot represent this cardinality correctly. The list handles one-to-many translation.

**Why `AdapterContext`:** Some OCPP messages have context-dependent interpretation. `StopTransaction` reason codes map differently depending on whether the session was EV-initiated or remotely stopped. The context carries the state needed for correct interpretation without coupling the adapter to global state.

```
AdapterContext {
  sessionId:    String
  connectorId:  String
  version:      OcppVersion   (v16, v20, v21)
  sessionState: Map<String, dynamic>   // adapter-internal stateful data
}
```

### Adapter implementations

| Adapter | Protocol | Status |
|---------|----------|--------|
| `Ocpp16Adapter` | OCPP 1.6J | Active |
| `Ocpp20Adapter` | OCPP 2.0.1 | Future |
| `Ocpp21Adapter` | OCPP 2.1 | Future |

### OcppDomainEvent sealed union

```
OcppDomainEvent (sealed):
  SessionDomainEvent(event: SessionEvent)
  StationDomainEvent(event: StationEvent)
  UnknownDomainEvent(rawType: String, rawPayload: Map)
```

`UnknownDomainEvent` is never silently discarded. It is logged to the security event endpoint for monitoring unknown OCPP message types in production.

### SessionEvent sealed class

The domain layer works exclusively with `SessionEvent`:

```
SessionEvent (sealed):
  SessionStartedEvent         sessionId, connectorId, timestamp
  SessionStatusChangedEvent   sessionId, newStatus (SessionStatus)
  MeterValueReceivedEvent     sessionId, energyKwh, durationSeconds, estimatedCost (Cents), activePowerKw?
  SessionStoppedEvent         sessionId, finalMetrics, stopReason (SessionStopReason), isBillable, transactionId?
  SessionErrorEvent           sessionId, failure (AppError)
```

### StationEvent sealed class (station domain)

```
StationEvent (sealed):
  StationConnectedEvent         stationId, firmware, capabilities
  StationHeartbeatEvent         stationId, timestamp
  ConnectorStatusChangedEvent   stationId, connectorId, newStatus (ChargerStatus), errorCode?
  StationFaultedEvent           stationId, errorCode, info
```

### SessionStatus state machine

```
Initiated → Connecting → Preparing → Charging → StopRequested → Finishing → Completed
                                        ↓               ↓
                                  SuspendedByVehicle  SuspendedByCharger
                                        ↓               ↓
                                   (resume) → Charging
                                        ↓
                                    Interrupted
                                        ↓
                                     Faulted
```

| Status | Description |
|--------|-------------|
| `Initiated` | App sent start command; awaiting OCPP acknowledgement |
| `Connecting` | OCPP RemoteStartTransaction acknowledged |
| `Preparing` | Charger preparing; vehicle not yet connected |
| `Charging` | Energy flowing |
| `SuspendedByVehicle` | Vehicle paused charging (BMS decision) |
| `SuspendedByCharger` | Charger paused charging (rate limit, load management) |
| `StopRequested` | App sent stop command; awaiting OCPP acknowledgement |
| `Finishing` | Stop acknowledged; finalizing session |
| `Completed` | Session ended normally; ChargingRecord created |
| `Interrupted` | Session ended abnormally; isBillable determined by stopReason |
| `Faulted` | Hardware fault; not billable |

### SessionStopReason sealed class

Maps all OCPP 1.6J and 2.x stop reason codes to domain types.

| Domain reason | OCPP 1.6J source | OCPP 2.x source |
|--------------|-----------------|-----------------|
| `EmergencyStop` | `EmergencyStop` | `EmergencyStop` |
| `LocalStop` | `Local` | `Local` |
| `Remote` | `Remote` | `Remote` |
| `DeAuthorized` | `DeAuthorized` | `DeAuthorized` |
| `PowerLoss` | `PowerLoss` | `PowerLoss` |
| `Reboot` | `Reboot` | `Reboot` |
| `EVDisconnected` | — | `EVDisconnected` |
| `SOCLimitReached` | — | `SOCLimitReached` (Smart Charging) |
| `Other` | `Other` | `Other` |

`isBillable` derivation: `Remote`, `LocalStop`, `SOCLimitReached` → true. `EmergencyStop`, `PowerLoss`, `Reboot`, `Faulted`, `EVDisconnected` → false (platform policy, configurable server-side). `DeAuthorized` → always false (authorization failure). `Other` → false by default.

### OCPP Gateway (backend)

- Separate service cluster from the business API
- Chargers maintain WebSocket connections to the gateway, not to the business API
- Sticky routing: a charger always connects to the same gateway node for session continuity
- Gateway publishes OCPP events to RabbitMQ
- Business API consumes from RabbitMQ and forwards relevant events to mobile clients via WebSocket
- Gateway scales independently of the business API

---

## 11. Security Architecture

### Core security module

```
core/security/
├── jwt_verifier.dart          9-step validation pipeline; sole producer of VerifiedJwtClaims
├── jwks_provider.dart         JWKS fetch + cache management
├── jwks_cache.dart            Cache model: keys Map<kid,PublicKey>, fetchedAt, TTL, graceEndsAt
├── verified_jwt_claims.dart   Immutable output; private constructor — only JwtVerifier can construct
├── jwt_validation_failure.dart  Sealed failure class (12 variants)
├── algorithm_allowlist.dart   Hardcoded: ES256, RS256, ES384, RS384 only
└── device_id_service.dart     Generate and read stable device ID from SecureStorage
```

`core/security/` has zero dependency on any feature module and zero dependency on `core/auth/`. The dependency arrow is: `core/auth/` depends on `core/security/`.

### JWT validation pipeline (9 steps)

Every JWT — received from login, token refresh, or SecureStorage on cold start — is run through the complete pipeline. Partial verification is never used.

```
[1] Structural validation
    — Exactly 3 '.' separated segments
    — Each segment is valid base64url
    — Total length within bounds (100–4096 bytes)
    → Failure: MalformedToken

[2] Header parsing
    — Decode and deserialize header segment
    — Extract: alg (string, required), kid (string, required)
    → Failure: MalformedToken

[3] Algorithm allowlist
    — Allowed: ES256, RS256, ES384, RS384 only
    — Rejected: none, HS256, HS384, HS512, and any unlisted value
    — "alg: none" is always rejected (explicit attack class)
    → Failure: AlgorithmNotAllowed

[4] Public key resolution
    — Look up key by kid in JwksCache
    — If kid not found: trigger one JWKS refresh, retry lookup once
    — If still not found: fail
    → Failure: UnknownKeyId

[5] Signature verification
    — Verify cryptographic signature over header.payload using resolved public key
    — Uses platform-native crypto APIs (BoringSSL/CommonCrypto)
    → Failure: SignatureInvalid

[6] Payload parsing
    — Decode and deserialize payload segment
    → Failure: MalformedToken

[7] Standard claims validation
    — exp:  > now − 30s (clock skew tolerance; hardcoded, not configurable)
    — iat:  < now + 30s  AND  > now − 24h
    — nbf:  if present, ≤ now + 30s
    — iss:  exact match against AppConfig.jwtIssuer
    — aud:  must contain AppConfig.appClientId
    — sub:  non-empty UUID string
    → Failure: TokenExpired | TokenNotYetValid | IssuerMismatch | AudienceMismatch | MissingRequiredClaim

[8] Device binding
    — JWT must contain deviceId claim
    — deviceId must exactly match device's own ID from SecureStorage
    — deviceId is generated on first install, never changes (survives app updates, not reinstalls)
    → Failure: DeviceIdMismatch

[9] Custom claims extraction and validation
    — kycStatus: must be one of {none, pending, approved, rejected}
    — phone: must match E.164 format (^\+[1-9]\d{7,14}$)
    — sessionId: UUID v4 format
    → Failure: InvalidClaimValue | MissingRequiredClaim

→ Return: VerifiedJwtClaims (immutable)
```

### VerifiedJwtClaims — structural trust enforcement

`VerifiedJwtClaims` has a private constructor. The only way to obtain an instance is through `JwtVerifier.verify()`. Dart enforces this at compile time — no factory method, no workaround.

Route guards, KYC decisions, and all application code accept `VerifiedJwtClaims?` as input. They are structurally incapable of reading a raw JWT string. If `VerifiedJwtClaims` is null, the user is unauthenticated.

This is the primary defense against JWT claim tampering. There is no convention or code review rule that enforces this — the type system does.

### JwtValidationFailure response matrix

| Failure | AuthNotifier response | UX effect |
|---------|----------------------|-----------|
| `MalformedToken` | Hard logout, clear all storage | "Session expired, please log in" |
| `AlgorithmNotAllowed` | Hard logout, log security event | "Session invalid, please log in" |
| `UnknownKeyId` (after refresh retry) | Hard logout | "Session expired, please log in" |
| `SignatureInvalid` | Hard logout, log security event to server | "Session invalid, please log in" |
| `TokenExpired` | Attempt silent refresh | Transparent to user |
| `TokenNotYetValid` | Retry after 30s | Transparent (edge case) |
| `IssuerMismatch` | Hard logout, log security event | "Session invalid" |
| `AudienceMismatch` | Hard logout, log security event | "Session invalid" |
| `DeviceIdMismatch` | Hard logout, log security event, show security alert notification | Security alert banner shown |
| `MissingRequiredClaim` | Hard logout | "Session invalid" |
| `InvalidClaimValue` | Hard logout | "Session invalid" |
| `JwksFetchFailed` | Apply offline grace period policy (see Section 21) | Depends on cache state |

`SignatureInvalid` and `DeviceIdMismatch` are logged to `POST /security/events` with device ID, timestamp, and failure type — never the JWT itself.

### JWKS key management

**Distribution endpoint:** `GET /.well-known/jwks.json` — unauthenticated, CDN-cached, certificate-pinned.

**Preferred algorithm:** ES256 (ECDSA P-256). Smaller signatures (64 bytes vs 256 bytes for RS256), faster verification on ARM, hardware acceleration on modern devices. RS256 permitted for development/staging environments.

**Client cache model:**
```
JwksCache {
  keys:           Map<kid, PublicKey>    keyed by kid
  fetchedAt:      DateTime
  ttl:            Duration               24 hours (hardcoded)
  graceEndsAt:    DateTime               fetchedAt + ttl + 6h = fetchedAt + 30h
  endpointUrl:    String
}
```

Stored in SecureStorage, encrypted at rest, `ThisDeviceOnly` attribute (no iCloud backup).

**Cache refresh triggers (priority order):**
1. `kid` in JWT header not found in cache → immediate refresh
2. Cache age > 12h on app foreground → background refresh
3. App cold start + cache age > 12h → refresh before first verification
4. Manual trigger after `DeviceIdMismatch` security event

**Key rotation lifecycle:**
- Day −7: Server generates new key pair, adds new-kid to JWKS alongside old-kid
- Day 0: Server begins signing new tokens with new-kid; old tokens (old-kid) remain valid
- Day +2: Old tokens have expired (max lifetime 24h); server removes old-kid from JWKS
- Both kids coexist in JWKS during the overlap window — no client disruption

**Emergency revocation:** Server removes compromised kid from JWKS immediately, invalidates all refresh tokens in database. All clients receive `UnknownKeyId` on next verification → force re-authentication.

### Re-verification triggers

- App cold start (read raw JWT from SecureStorage → run full pipeline)
- `AppLifecycleState.resumed`
- Every token refresh response (new JWT always re-verified before use)
- Kid not found in JWKS cache (triggers JWKS fetch, then re-verification)

### SecureStorage platform attributes

| Item | iOS Keychain | Android |
|------|-------------|---------|
| Access token (raw JWT) | `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` | Hardware-backed, user-authenticated |
| Refresh token | `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` | Hardware-backed, user-authenticated |
| JWKS cache | `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` | Software-backed |
| Device ID | `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` | Software-backed |

`ThisDeviceOnly` prevents iCloud Keychain backup and cross-device restoration, enforcing device binding at the storage level.

### Explicitly deferred security controls (post-MVP)

The following were identified during the architecture audit but are deferred:

- Certificate pinning (identified as gap; required before production)
- Screen recording prevention (iOS, Android FLAG_SECURE)
- App inactivity lock (session timeout after N minutes idle)
- Biometric-gated token access
- Root/jailbreak detection
- Google Play Integrity API / Apple App Attest

---

## 12. Authentication and KYC

### Authentication model

- Phone number + OTP only (no password, no social login in MVP)
- Refresh token rotation with replay detection — a rotated refresh token cannot be reused
- Maximum 5 active sessions per user; the 6th login requires revoking an existing session
- Each JWT is device-bound via `deviceId` claim
- JWT signed with ES256, verified client-side via JWKS

### JWT custom claims

| Claim | Type | Description |
|-------|------|-------------|
| `kycStatus` | String | `none` \| `pending` \| `approved` \| `rejected` |
| `phone` | String | E.164 phone number |
| `deviceId` | String | Stable device identifier (generated on install) |
| `sessionId` | String | UUID of this auth session |

### Authentication flow

```
App cold start → /splash
  ├── First launch              → /onboarding → /auth/phone
  ├── No token in SecureStorage → /auth/phone
  ├── Token present             → JwtVerifier.verify(rawJwt)
  │     ├── SignatureInvalid    → hard logout → /auth/phone
  │     ├── TokenExpired        → attempt POST /auth/refresh
  │     │     ├── Success       → verify new token → proceed
  │     │     └── Failure       → /auth/phone
  │     └── Success (VerifiedJwtClaims):
  │           ├── kycStatus: none     → /kyc/intro
  │           ├── kycStatus: pending  → /kyc/pending
  │           ├── kycStatus: rejected → /kyc/rejected
  │           └── kycStatus: approved → /shell/map
```

### OTP flow

```
/auth/phone → POST /auth/send-otp (rate limited: 5 requests/hour per phone)
    ↓
/auth/otp (60s countdown, resend after 30s)
  ├── Wrong OTP (≤ 4 attempts): inline error with remaining count
  ├── 5+ wrong attempts: lockout countdown shown
  ├── OTP expired: back to /auth/phone
  ├── Max sessions reached → /auth/sessions (user must revoke one session)
  └── Success: JWT + refresh token returned
             → JwtVerifier.verify(newJwt)
             → DeviceRegistration for push notifications
             → kycStatus → correct zone
```

### KYC state machine

```
none → (user initiates KYC) → pending → approved
                                      → rejected → (user resubmits) → pending
```

- `none`: User has not started KYC. App prompts on first access to KYC-required route.
- `pending`: Documents submitted; under review. User sees a waiting screen. KYC WebSocket topic pushes updates.
- `approved`: Full access to all features.
- `rejected`: User sees rejection reason and can resubmit (up to 3 attempts; after 3, requires support).

### KYC status freshness

`kycStatus` in JWT reflects the status at token issuance. Status changes server-side are propagated via:

1. WebSocket topic `kyc.{userId}.status` → `KycNotifier` receives event → `AuthNotifier.forceRefresh()` → new JWT with updated status
2. Push notification (`kyc_approved`, `kyc_rejected`) → same refresh path

This is the only legitimate path for `kycStatus` to change on the client. There is no way to manually alter it — the signature verification closes this.

### KYC requirement matrix

| Feature | Auth required | KYC approved required |
|---------|:---:|:---:|
| Browse map | Yes | No |
| View station detail | Yes | No |
| Create reservation | Yes | Yes |
| Start charging | Yes | Yes |
| Wallet balance view | Yes | No |
| Wallet top-up | Yes | Yes |
| Wallet transaction history | Yes | Yes |
| Profile view / edit | Yes | No |
| View notification history | Yes | No |

### AuthState (revised)

```
AuthState (sealed):
  Unauthenticated(reason: UnauthReason?)
  Authenticated(claims: VerifiedJwtClaims)
  Unverifiable(cachedClaims: VerifiedJwtClaims, reason: String)
```

`Unverifiable` is emitted when JWKS is fully expired and offline. The user can still see cached data (map, reservations) but cannot perform any mutation or financial operation. See Section 21 for the full offline JWKS policy.

---

## 13. Wallet and Financial Rules

### Absolute rules — no exceptions

1. **All monetary values are integer `Cents`** — no floats, no `double`, no `Decimal`, no `String`. If a value represents money, it is `Cents`.
2. **The transaction ledger is append-only** — no `Transaction` record is ever updated or deleted. Balance is always derived by summing the ledger, never stored as a mutable field independent of the ledger.
3. **All financial operations carry an idempotency key** — safe to retry without double-charging. The server rejects duplicate idempotency keys with 409.
4. **Wallet, Payment, and Settlement are separate bounded contexts** — they share `Cents` and `CurrencyCode` value objects but no entities or repositories.

### Cents value object

Located in `core/domain/value_objects/money/`. Used by wallet, charging, reservation, and tariff features.

```
Cents {
  value: int        (must be ≥ 0; negative Cents not permitted — use TransactionType to represent direction)
  currency: CurrencyCode
}
```

Arithmetic on `Cents` is only permitted through explicit methods that preserve the currency invariant. Direct integer arithmetic on `cents.value` is prohibited in application and domain code.

### CurrencyMismatchFailure

Operations involving `Cents` values from different currencies fail with `CurrencyMismatchFailure`. This is enforced at the domain layer. The current MVP is single-currency per deployment. Multi-currency support requires a dedicated architecture extension (not designed in this document).

### Transaction types

```
TransactionType (enum):
  TopUp           Wallet funded (payment received)
  SessionCharge   Deducted for completed charging session
  ReservationHold Reserved amount held (pending session)
  HoldRelease     Hold released on cancellation or session end
  Refund          Manual or policy-driven refund
  Adjustment      Operator correction (admin only)
```

### Wallet balance derivation

`WalletAccount.balance` is a cached computed value, not an independent field. The authoritative balance is the sum of all `Transaction` entries. The cached value is refreshed by the server after every transaction. The client never computes balance from the ledger locally — it reads from the API.

### Top-up flow (idempotency)

```
Client generates idempotency key (UUID)
    ↓
POST /wallet/topup { amount, idempotencyKey, paymentMethod }
    ↓
Server: create PaymentIntent (idempotency key stored)
    ↓
Payment gateway processes payment
    ↓
Server: append TopUp Transaction → update balance
    ↓
200 OK { transaction, newBalance }

On retry with same idempotencyKey:
    Server returns the original response (no duplicate charge)
```

---

## 14. Pricing and Tariff Rules

### Module design

`tariff` is a headless feature module (domain + application + infrastructure; no presentation). It provides pricing data to `reservation` and `charging` features through its providers.

### TariffRate value object

```
TariffRate {
  value:    int     raw integer
  scale:    int     number of decimal places
  currency: CurrencyCode
}
actual rate = value / 10^scale
```

Examples: `{value: 150, scale: 2}` → 1.50 per unit. `{value: 50, scale: 0}` → 50 per unit (JPY, no decimals).

All intermediate calculations use integer arithmetic scaled by `10^scale`. No floating-point arithmetic is used anywhere in tariff calculations.

### TariffSnapshot value object

An immutable copy of the applicable tariff at the time of reservation creation. Stored on the `Reservation` entity and `ChargingRecord`. Ensures receipt accuracy even if the tariff changes after the session.

```
TariffSnapshot {
  tariffId:     String
  components:   List<TariffComponent>   (deep copy)
  currency:     CurrencyCode
  capturedAt:   DateTime
}
```

### TariffCalculator

Pure domain service. Stateless. Zero dependencies on repositories or infrastructure.

```
TariffCalculator.calculate(
  schedule: TariffSchedule,
  metrics: SessionMetrics
) → Cents
```

Takes the applicable tariff schedule and actual session metrics; returns a final cost as `Cents`. Used for post-session billing reconciliation.

```
TariffCalculator.estimate(
  schedule: TariffSchedule,
  durationMinutes: int,
  energyKwh: EnergyKwh
) → Cents
```

Used for pre-session cost estimates shown in reservation confirmation and session start screens.

### Tariff component types

| Component type | Billing basis |
|---------------|--------------|
| `flat` | Fixed fee per session (regardless of duration or energy) |
| `time` | Per-minute or per-hour rate |
| `energy` | Per-kWh rate |
| `session` | Synonym for `flat` in some operator configurations |

Multiple components combine additively: `totalCost = sum(TariffCalculator.calculate(component, metrics))`.

### Currency protection

Before any tariff operation, the tariff's `currency` is compared against the wallet's `currency`. If they differ, `CurrencyMismatchFailure` is returned immediately. No estimation, no session start, no reservation is permitted across currencies.

---

## 15. Reservation Architecture

### Reservation entity state machine

```
Pending → Confirmed → Active (session started) → Completed
                    ↓
              Cancelled (before start time)
                    ↓
              Expired (start time passed without activation)
                    ↓
              NoShow (OCPP session never received after reservation window)
```

### Reservation creation flow

```
/map/station/:id → "Reserve" connector
    ↓ KYC guard applied
/reservations/new?stationId=&connectorId=
  Step 1: Select available time slot (from GET /connectors/{id}/availability)
  Step 2: Select vehicle (from ProfileNotifier vehicles list)
  Step 3: Review pricing
    — GET /connectors/{connectorId}/tariff
    — POST /connectors/{connectorId}/tariff/estimate
    — Check wallet balance (from WalletNotifier) vs estimate
    ├── Insufficient balance → navigate to /wallet/topup → return with balance updated
    └── Sufficient balance → continue
  Step 4: Confirm
    ↓
  POST /reservations → 201
    ↓
  Navigate to /reservations/:id
  (Creation steps replaced in back stack — not pushed)
```

`TariffSnapshot` is captured at Step 3 and included in the `POST /reservations` body. The server validates and stores the snapshot. This ensures the user agreed to the tariff displayed at booking time.

### Reservation cancellation

- Cancellation is permitted until the reservation `startTime − 15 minutes` (policy enforced server-side)
- Cancellation within policy → `HoldRelease` transaction if a hold was placed
- Cancellation outside policy → configurable fee (platform configuration; domain models the fee, policy is server-side)
- `DELETE /reservations/{id}` → server returns 200 with updated reservation or 409 if outside cancellation window

### Race condition handling

Slot availability is checked at Step 1 and validated again at `POST /reservations`. If the slot was taken between steps, the server returns 409 Conflict. `CreateReservationUseCase` surfaces this as a `ValidationError` with a message to select a new slot — it does not retry automatically.

---

## 16. Charging Architecture

### Session start flow (202 pattern)

```
StartSessionUseCase:
  1. Validate connector is available (StationRepository)
  2. Validate wallet balance ≥ estimated cost (WalletRepository + TariffRepository)
  3. POST /sessions/start → 202 Accepted { commandId }
  4. ActiveSessionNotifier.state = SessionStatus.Initiated(commandId)
  5. Start 30s timeout timer
  6. WebSocket session.{sessionId}.events received:
     ├── SessionStartedEvent → status = Connecting → Preparing → Charging
     └── SessionErrorEvent   → status = Faulted
  7. On timeout (no confirming event) → OcppTimeoutError
```

### Session stop flow

```
StopSessionUseCase:
  1. POST /sessions/{id}/stop → 202 Accepted { commandId }
  2. ActiveSessionNotifier.state = SessionStatus.StopRequested
  3. Start 30s timeout timer
  4. WebSocket session.{sessionId}.events received:
     ├── SessionStoppedEvent → status = Finishing → Completed
     │   → WalletNotifier.refresh() (balance updated)
     │   → ChargingRecord created server-side
     └── SessionErrorEvent   → revert to Charging (stop failed), surface error
  5. On timeout → OcppTimeoutError (user can retry stop)
```

### Stop button behaviour during async wait

The stop confirmation screen is a **full-screen route** (`/charging/:id/stop`), not a dialog. This prevents back-button dismissal while the OCPP stop command is in flight. The back button is disabled during the `StopRequested → Finishing` states.

### Mid-session WebSocket disconnect

```
WS disconnect detected during active session
    ↓
ActiveSessionNotifier → SessionConnectivityState.degraded
    ↓
UI: warning banner; meter values frozen with last-known timestamp
Stop button: disabled (cannot confirm OCPP command without WS)
    ↓
ReconnectScheduler fires (exponential backoff: 1s → 2s → 4s → 8s → 30s)
    ↓
On reconnect: subscribe with lastSequenceId → server replays missed events
    ↓
ActiveSessionNotifier processes replay → state catches up
    ↓
SessionConnectivityState.restored → banner dismissed, stop re-enabled
```

The charger continues charging during the disconnect. No data is lost. No duplicate billing occurs (append-only idempotent ledger). The replay mechanism restores all missed meter values.

### Session state persistence

`ActiveSessionNotifier` is `autoDispose: false` (app-lifetime). The active session state persists across all tab switches, app backgrounding, and navigation. The persistent mini-card above the bottom nav bar reflects this state on all tabs.

The session state is not persisted to Hive. If the app is force-killed during an active session, the session continues on the charger. On next app launch, `bootstrap.dart` checks for an active session via `GET /sessions/active` and restores `ActiveSessionNotifier` state.

---

## 17. Station Discovery Architecture

### Viewport-based subscription model

The map widget requests stations for the current map viewport: `GET /stations?bounds=<bbox>&zoom=<level>`. The server returns either individual station markers (high zoom) or cluster aggregates (low zoom).

When a station marker becomes visible on the map, the widget subscribes to `charger.{stationId}.status` via `StationAvailabilityStreamProvider(stationId)`. When the station leaves the viewport, `autoDispose` cancels the subscription automatically.

### Server-side clustering

Below zoom level 12 (configurable), the server returns `StationCluster` objects instead of individual stations. Clusters carry: centroid, station count, and dominant status (any-available / all-unavailable / mixed). The client renders clusters as count badges on the map.

At zoom ≥ 12, individual stations are returned with connector-level status.

### ChargerStatus value object

```
ChargerStatus (enum):
  Available
  Preparing
  Charging
  SuspendedEV
  SuspendedEVSE
  Finishing
  Reserved
  Unavailable
  Faulted
```

These values are derived from OCPP `StatusNotification` messages processed by `Ocpp16Adapter`. The domain `ChargerStatus` mirrors OCPP 1.6J connector status. For OCPP 2.x compatibility, the adapter maps the extended status enum to these domain values.

### Station search

`GET /stations/search?q=<text>&near=<lat,lon>&radius=<meters>` — server-side full-text and geo search. The client sends the query and current location; the server returns ranked results. No client-side filtering.

### Connector detail

`/map/station/:stationId/connector/:connectorId` shows:
- Connector type (icon + label)
- Max power (kW)
- Current status (live via WebSocket)
- Active tariff (GET /connectors/{id}/tariff)
- Cost estimate calculator (interactive, uses TariffCalculator client-side with server-fetched TariffSchedule)
- "Reserve" CTA (KYC-guarded) → reservation flow
- "Start Charging" CTA (KYC-guarded, if no reservation required) → session start flow

---

## 18. Navigation Architecture

### Route zones

The entire route tree is divided into three isolated zones. Guards move users between zones — no manual `context.go()` at zone boundaries.

```
/ (root — splash evaluation only)
│
├── /splash
├── /onboarding
│
├── /auth                                  Pre-auth zone
│   ├── /auth/phone
│   ├── /auth/otp
│   └── /auth/sessions
│
├── /kyc                                   KYC zone (authenticated, not yet approved)
│   ├── /kyc/intro
│   ├── /kyc/identity
│   ├── /kyc/pending
│   └── /kyc/rejected
│
└── /shell                                 Authenticated shell (StatefulShellRoute)
    ├── /map                               Tab 1 — Station Discovery
    │   ├── /map/search
    │   └── /map/station/:stationId
    │       ├── /map/station/:stationId/connector/:connectorId
    │       └── /map/station/:stationId/reviews
    ├── /reservations                      Tab 2
    │   ├── /reservations/new
    │   │   └── /reservations/new/confirm
    │   └── /reservations/:id
    │       └── /reservations/:id/cancel
    ├── /charging                          Tab 3 — always present
    │   ├── /charging/idle
    │   ├── /charging/:sessionId
    │   │   ├── /charging/:sessionId/stop
    │   │   └── /charging/:sessionId/receipt
    ├── /wallet                            Tab 4
    │   ├── /wallet/topup
    │   │   └── /wallet/topup/confirm
    │   ├── /wallet/history
    │   └── /wallet/history/:txId
    └── /profile                           Tab 5
        ├── /profile/edit
        ├── /profile/vehicles
        │   ├── /profile/vehicles/add
        │   └── /profile/vehicles/:vehicleId
        ├── /profile/sessions
        ├── /profile/kyc
        └── /profile/settings
            ├── /profile/settings/notifications
            └── /profile/settings/security
│
└── /error
    ├── /error/not-found
    ├── /error/forbidden
    ├── /error/maintenance
    └── /error/generic
```

### Bottom navigation tabs

| Tab | Badge condition |
|-----|-----------------|
| Map | None |
| Reservations | Upcoming count (within 24h) |
| Charging | Pulse animation when session active |
| Wallet | None |
| Profile | Warning dot if kycStatus is pending or rejected |

**RTL tab order:** In LTR (English) tabs render left-to-right as listed above. In RTL (Persian), Flutter's `StatefulShellRoute` mirrors the visual order right-to-left automatically — tab indices are unchanged, only screen position reverses. Tab 0 (Map) appears at the far right in RTL; Tab 4 (Profile) at the far left.

The Charging tab is always rendered. When no session is active it shows `/charging/idle`. This ensures deep-linking to a session always resolves correctly.

A **persistent session mini-card** anchored above the bottom nav bar appears on all tabs whenever a session is active. It is a shell-level widget, not a route. Driven by `ActiveSessionNotifier` state.

### Guard chain

Guards are evaluated inside GoRouter's `redirect` callback in priority order. `GoRouter.refreshListenable` is wired to `AuthNotifier` as a `ChangeNotifier` adapter — any auth state change (login, logout, KYC update) re-evaluates all guards automatically.

```
[1] OnboardingGuard       → /onboarding           if first launch (SharedPreferences flag)
[2] AuthGuard             → /auth/phone            if verifiedClaims is null
[3] ClaimsIntegrityGuard  → attempt refresh        if verifiedClaims.expiresAt ≤ now
                          → /auth/phone on failure
[4] KycGuard              → /kyc/[state]           if route requires KYC and kycStatus ≠ approved
[5] ActiveSessionGuard    → /charging/:sessionId   if session active and destination is /charging/idle
```

`ClaimsIntegrityGuard` (position 3) replaces the original `TokenRefreshGuard`. Guards run synchronously in GoRouter's `redirect` callback — they do not trigger network calls inline. When expiry is detected, the guard redirects to a refresh-holding screen that performs the async token refresh and then resumes navigation.

### Deep links

Scheme: `evcharger://` and Universal Links: `app.evcharger.com`

| Deep link | Internal route | Guards |
|-----------|---------------|--------|
| `.../station/:id` | `/map/station/:id` | Auth |
| `.../charging/:sessionId` | `/charging/:sessionId` | Auth |
| `.../reservation/:id` | `/reservations/:id` | Auth |
| `.../wallet/topup` | `/wallet/topup` | Auth + KYC |
| `.../auth/otp?phone=:p` | `/auth/otp` (pre-filled) | None |
| `.../kyc/resume` | `/kyc/[current state]` | Auth |
| `.../receipt/:sessionId` | `/charging/:sessionId/receipt` | Auth |

Cold-start deep link: store target as pending redirect → run splash evaluation → navigate to target after all guards pass.

### Push notification navigation

Notification payloads carry a `target` object with `route` and `params` fields. The `NotificationRouter` (in `core/routing/`) resolves this to an internal route and navigates.

| Notification type | Navigation target | Foreground behavior |
|------------------|-------------------|---------------------|
| `session_started` | `/charging/:id` | Navigate to Charging tab |
| `session_completed` | `/charging/:id/receipt` | In-app banner |
| `session_failed` | `/charging/:id` (error state) | Navigate + error shown |
| `reservation_reminder_30m` | `/reservations/:id` | In-app banner |
| `reservation_reminder_now` | `/reservations/:id` | In-app banner |
| `reservation_cancelled` | `/reservations` | In-app banner + toast |
| `wallet_low_balance` | `/wallet/topup` | In-app banner |
| `wallet_topup_complete` | `/wallet` | In-app banner |
| `kyc_approved` | `/shell/map` | Navigate + celebration |
| `kyc_rejected` | `/kyc/rejected` | Navigate |
| `payment_failed` | `/wallet/topup` | Navigate |
| `security_alert` | `/profile/settings/security` | Alert dialog (blocks other actions) |

**Three-state notification handling:**
- **Terminated:** FCM data-only message → app opens cold → `NotificationRouter` navigates on first frame
- **Backgrounded:** FCM → system tray → user taps → app foregrounded → `NotificationRouter` navigates
- **Foregrounded:** In-app banner queue in `NotificationNotifier` → FIFO, max 3 banners, auto-dismiss after 5s

### Error routes

OCPP command errors are not route-level. They arrive via WebSocket and are handled as state transitions within `/charging/:id`. Network errors during screen load are handled as error states within the current screen (not route-level), with a retry action.

`/error/*` routes are for unrecoverable situations only: unknown routes (GoRouter `errorBuilder`), suspended accounts (403), server maintenance (503).

---

## 19. Riverpod State Management Architecture

### Provider layer graph

Dependencies flow downward only. No layer references a layer above it.

```
Layer 5 — UI Notifiers     feature state; consumed by widgets
    ↑
Layer 4 — Repositories     stateless data access; returns domain models
    ↑
Layer 3 — Services         cross-cutting: TokenService, WebSocketManager, LocalCacheService
    ↑
Layer 2 — Infrastructure   DioClient, WebSocketClient, SecureStorage, ConnectivityMonitor
    ↑
Layer 1 — Environment      AppConfig: base URL, WS URL, timeouts, feature flags
```

### Provider type selection

| Type | Use when |
|------|----------|
| `AsyncNotifier<T>` | State from an API call; has loading/data/error lifecycle |
| `AsyncNotifier<T>.family` | Same, keyed by entity ID (detail screens) |
| `Notifier<T>` | Synchronous or derived state |
| `StreamNotifier<T>` | Stream-driven state that also needs imperative actions (`ActiveSessionNotifier`) |
| `StreamProvider<T>` | Read-only observation of a stream; no actions |

### autoDispose policy

| Provider | autoDispose | Rationale |
|----------|:---:|---------|
| `AuthNotifier` | No | App lifetime — guards depend on it always existing |
| `WebSocketManager` | No | App lifetime — single connection |
| `WalletNotifier` | No | Balance needed globally (mini-card, reservation form, session start guard) |
| `ActiveSessionNotifier` | No | Session persists across all navigation |
| `StationMapNotifier` | No | Map state must survive tab switches |
| `ConnectivityNotifier` | No | App lifetime — all notifiers react to it |
| `ProfileNotifier` | No | Vehicles list needed by reservation form |
| `NotificationNotifier` | No | App lifetime — banner queue and preferences |
| `LocaleNotifier` | No | App lifetime — drives MaterialApp.locale and text direction; locale change triggers cache invalidation |
| `StationDetailNotifier(id)` | Yes | Release memory when leaving detail screen |
| `StationAvailabilityNotifier(id)` | Yes | Cancels WS subscription when no listeners |
| `ReservationDetailNotifier(id)` | Yes | Release when leaving detail screen |
| `ReservationNewNotifier` | Yes | Scoped to creation flow only |
| `TransactionHistoryNotifier` | Yes | Release when leaving wallet history |
| `KycNotifier` | Yes | Only active during KYC zone |
| `TariffNotifier(connectorId)` | Yes | Release when leaving connector detail |

### State ownership — single writer rule

No cross-notifier mutation. Notifier A never calls methods on Notifier B. Cross-module influence is read-only (`ref.watch`) or reactive (`ref.listen`).

| State | Owner | Cross-module reads |
|-------|-------|-------------------|
| VerifiedJwtClaims, userId, kycStatus | `AuthNotifier` | GoRouter guard, all notifiers |
| Map viewport, station clusters | `StationMapNotifier` | Map widget |
| Station detail | `StationDetailNotifier(id)` | Detail screen, ReservationNewNotifier |
| Per-station live availability | `StationAvailabilityNotifier(id)` | Map widget, station detail |
| Reservation list | `ReservationListNotifier` | Reservations tab |
| Reservation entity | `ReservationDetailNotifier(id)` | Detail screen, ActiveSessionNotifier |
| New reservation form | `ReservationNewNotifier` | Creation screens only |
| Active session | `ActiveSessionNotifier` | Charging tab, mini-card, GoRouter guard |
| Wallet balance | `WalletNotifier` | Wallet tab, ReservationNewNotifier (read), session start guard |
| Transaction history | `TransactionHistoryNotifier` | Wallet history screen |
| Profile + vehicles | `ProfileNotifier` | Profile tab, ReservationNewNotifier (vehicles) |
| Connectivity | `ConnectivityNotifier` | All notifiers via `ref.listen` |
| In-app banners | `NotificationNotifier` | Shell widget |
| Active locale + text direction | `LocaleNotifier` | MaterialApp, all formatters, Dio locale interceptor |
| Active tariff | `TariffNotifier(connectorId)` | Connector detail, ReservationNewNotifier |

### Reactive cascades (ref.listen)

```
ActiveSessionNotifier session completed
    → WalletNotifier.refresh()

ConnectivityNotifier → online
    → StationMapNotifier.refreshVisible()
    → WalletNotifier.refresh()
    → ReservationListNotifier.refresh()
    → ProfileNotifier.flushWriteQueue()
    → AuthNotifier.reVerifyToken() (re-run JwtVerifier pipeline)

AuthNotifier → unauthenticated
    → GoRouter redirects to /auth/phone
    → NotificationRepository.unregisterDevice()
    → WebSocketManager.disconnect()
    → ref.invalidate: WalletNotifier, ProfileNotifier, ActiveSessionNotifier, ReservationListNotifier

KycNotifier → kycStatusChanged
    → AuthNotifier.forceRefresh()

LocaleNotifier → locale changed
    → StationMapNotifier.clearLocaleCache()     (station names re-fetched with new Accept-Language)
    → ReservationListNotifier.clearLocaleCache() (reservation station names re-fetched)
    → ProfileRepository.updateLocalePreference(locale)   (async, best-effort server sync)
    → NotificationRepository.updateDeviceLocale(locale)  (push notification templates re-keyed)
```

### State shape conventions

- `AsyncNotifier` holds a typed domain object — never a raw API response or DTO
- List-backed notifiers hold `PaginatedState<T>` (items, nextCursor, hasMore, lastFetchedAt) — not bare `List<T>`
- Error type is the sealed `AppError` — pattern-matched in widgets; never raw `Exception`

`AppError` variants:
- `NetworkError` — no connectivity
- `ApiError` — HTTP error + RFC 7807 Problem Details
- `OcppTimeoutError` — 202 received but no WebSocket confirmation within 30s
- `AuthError` — token expired, revoked, or unverifiable
- `ValidationError` — client-side constraint violated
- `CurrencyMismatchError` — cross-currency operation attempted

### Optimistic updates

For mutations likely to succeed (cancel reservation, update profile):
1. Capture pre-mutation state in a local variable
2. Apply expected state change immediately
3. Call repository method
4. On failure: revert to captured state, surface `AppError`
5. On success: state already reflects truth; optionally `ref.invalidate` to force fresh fetch

### Repository provider contract

All repository providers are overridable. Concrete implementation is the default; tests provide fakes. Abstract interface is defined in `domain/repositories/`. Concrete class and its provider declaration are in `infrastructure/repositories/`.

---

## 20. Folder Structure Architecture

### Top-level layout

```
lib/
├── main.dart
├── main_dev.dart
├── main_staging.dart
│
├── l10n/
│   ├── app_en.arb               English strings (source locale — all keys defined here)
│   └── app_fa.arb               Persian/Farsi translations
│
├── app/
│   ├── app.dart                   ProviderScope + MaterialApp + GoRouter wiring
│   ├── app_config.dart            Environment values (baseUrl, wsUrl, jwtIssuer, appClientId, jwksEndpoint)
│   └── bootstrap.dart             Startup: storage init, JWKS check, token re-verification, active session check
│
├── core/
│   ├── domain/
│   │   └── value_objects/
│   │       ├── ids/               UserId, StationId, ConnectorId, SessionId, ReservationId
│   │       ├── money/             Cents, CurrencyCode
│   │       └── primitives/        PhoneNumber, GeoPoint, TimeSlot, EnergyKwh, ConnectorType, ChargerStatus
│   ├── locale/
│   │   ├── locale_notifier.dart       Active locale state + persistence (autoDispose: false)
│   │   ├── supported_locales.dart     Enum: en (LTR), fa (RTL); BCP 47 tags
│   │   └── locale_storage.dart        Read/write locale preference from SharedPreferences
│   ├── network/
│   │   ├── api_client.dart        Configured Dio instance + provider
│   │   ├── api_endpoints.dart     All URL path constants
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       ├── retry_interceptor.dart
│   │       ├── problem_details_interceptor.dart
│   │       └── locale_interceptor.dart            Injects Accept-Language header on every request
│   ├── security/
│   │   ├── jwt_verifier.dart
│   │   ├── jwks_provider.dart
│   │   ├── jwks_cache.dart
│   │   ├── verified_jwt_claims.dart
│   │   ├── jwt_validation_failure.dart
│   │   ├── algorithm_allowlist.dart
│   │   └── device_id_service.dart
│   ├── websocket/
│   │   ├── websocket_manager.dart
│   │   ├── topic_router.dart
│   │   ├── reconnect_scheduler.dart
│   │   └── event_replay_buffer.dart
│   ├── storage/
│   │   ├── secure_storage.dart
│   │   └── local_cache_service.dart
│   ├── routing/
│   │   ├── app_router.dart
│   │   ├── route_names.dart
│   │   ├── notification_router.dart
│   │   └── guards/
│   │       ├── auth_guard.dart
│   │       ├── claims_integrity_guard.dart
│   │       ├── kyc_guard.dart
│   │       ├── active_session_guard.dart
│   │       └── onboarding_guard.dart
│   ├── error/
│   │   ├── app_error.dart
│   │   └── problem_details.dart
│   ├── connectivity/
│   │   └── connectivity_notifier.dart
│   └── ui/
│       ├── theme/                       AppTheme: two TextTheme instances (Latin / Persian)
│       ├── widgets/
│       ├── extensions/
│       └── formatters/
│           ├── currency_formatter.dart  Cents → locale-specific display string
│           ├── number_formatter.dart    Locale-aware digits, separators, units
│           └── date_formatter.dart      Gregorian / Shamsi calendar, timezone, relative time
│
└── features/
    ├── auth/
    ├── profile/
    ├── station/
    ├── reservation/
    ├── charging/
    ├── wallet/
    ├── tariff/              (headless — no presentation/)
    └── notification/        (headless — no presentation/)
```

### Per-feature directory contract

```
features/<feature>/
├── <feature>_module.dart         Public API barrel

├── domain/
│   ├── entities/
│   ├── value_objects/
│   ├── repositories/             Abstract interfaces only
│   ├── events/                   Domain events (charging: SessionEvent; station: StationEvent)
│   └── failures/                 Feature-specific failure types (sealed)

├── application/
│   ├── notifiers/                AsyncNotifier / Notifier / StreamNotifier
│   ├── state/                    Typed state objects
│   └── use_cases/                Multi-repo orchestration only

├── infrastructure/
│   ├── datasources/
│   │   ├── remote/               Dio-based calls; returns DTOs
│   │   └── local/                LocalCacheService reads/writes
│   ├── repositories/             Concrete implementations + provider declarations
│   ├── models/                   JSON-serializable DTOs
│   ├── mappers/                  DTO → domain entity
│   └── adapters/                 OCPP adapters (charging feature only)

└── presentation/                 (absent for headless modules)
    ├── screens/
    ├── widgets/
    └── routes/
```

### Import discipline

```
ALLOWED:
  presentation/  → application/ (watch providers)
  presentation/  → core/ui/
  application/   → domain/
  application/   → core/domain/
  infrastructure/ → domain/ (implements interfaces)
  infrastructure/ → core/network | core/websocket | core/storage | core/security
  any layer       → core/ (always allowed)
  feature A       → feature B's domain/ (shared types only)

PROHIBITED:
  domain/        → anything (zero dependencies)
  application/   → infrastructure/ (uses interfaces, not impls)
  application/   → presentation/
  feature A      → feature B's application/, infrastructure/, or presentation/
  core/          → features/ (core never knows about features)
```

### Use case rule

A `use_case/` file is created only when:
- The operation spans more than one repository, OR
- The orchestration logic does not fit cleanly in a notifier

Simple single-repository CRUD lives directly in notifiers.

---

## 21. Offline Strategy

### Per-feature offline classification

| Feature | Read while offline | Write while offline | Strategy |
|---------|:-----------------:|:------------------:|----------|
| Auth (JWT guard) | Yes (cached VerifiedJwtClaims) | No (OTP requires network) | JWT + JWKS grace period |
| Auth (token refresh) | N/A | Blocked | Redirect to /auth/phone after grace |
| Station map | Yes (last-known viewport from Hive) | N/A | Stale-while-revalidate; "cached at [time]" indicator |
| Station availability | Yes (last-known status) | N/A | Timestamp shown; no live status |
| Reservations | Yes (Hive-cached list) | Queued (create/cancel) | Write queue flushed on reconnect |
| Charging session | Yes (last-known metrics) | Queued (stop command) | Session safety overrides auth gate |
| Wallet | Yes (cached balance) | Blocked (top-up) | "Reconnect to add funds" |
| Tariffs | Yes (last-fetched TariffSchedule) | N/A | Use cached for estimates; mark as cached |
| Notifications | Yes (cached history) | N/A | OS-level FCM/APNS queuing handles delivery |
| KYC | Yes (cached status) | Blocked | Status may be stale; show "last updated" |

### Offline write queue

The `LocalCacheService` maintains a write queue for deferrable mutations. Each entry carries: operation type, payload, idempotency key, created at, retry count.

On connectivity restored (`ConnectivityNotifier` → online): queue is flushed in order. Entries that fail with 4xx errors are discarded (not retried). Entries that fail with 5xx are retried up to 3 times with exponential backoff.

The write queue is stored in Hive. It survives app restarts.

### JWT + JWKS offline state machine

Four distinct states. Transitions are one-directional while offline; reconnection restores from any state.

```
[State A] Offline / Verified
  Condition: verifiedClaims.expiresAt > now AND jwksCache.fetchedAt + ttl > now
  Access: Full (read + write)
  Effect: No degradation — local verification succeeds with fresh JWKS cache

[State B] Offline / GracePeriod
  Condition: verifiedClaims.expiresAt > now AND jwksCache within grace window (TTL → TTL+6h)
  Access: Read + non-financial operations only
  Effect: VerifiedJwtClaims carry verificationConfidence: degraded
          Financial routes (/wallet/topup, /charging/start, /reservations/new) blocked

[State C] Offline / Unverifiable
  Condition: verifiedClaims.expiresAt > now AND jwksCache.graceEndsAt ≤ now
  Access: Read-only (cached data only)
  Effect: AuthState.Unverifiable — persistent banner: "Reconnect to continue"
          User is NOT logged out; session data preserved
          Exception: if active charging session exists, session screen stays accessible

[State D] Offline / Expired
  Condition: verifiedClaims.expiresAt ≤ now (adjusted for 30s tolerance)
  Access: None — locked out
  Effect: Attempt POST /auth/refresh (requires network)
          If network unavailable: AuthState.Unauthenticated
          Exception: if active charging session, preserve session display; retry refresh on reconnect
```

Grace period duration: 6 hours (hardcoded, not configurable — this is a security parameter).

### Active session + offline + token expired (special case)

If all three conditions are simultaneously true: active charging session + offline + token expired, session safety overrides the auth gate. The app shows the session screen in a degraded state (last known metrics, connectivity warning). The stop action is queued but not executed until connectivity is restored and the token is refreshed. As soon as connectivity returns: refresh token → re-verify → attempt queued stop if user requested it.

### Cache storage backend

| Data | Backend | Eviction |
|------|---------|----------|
| JWT (raw) | SecureStorage | Cleared on logout |
| JWKS cache | SecureStorage | TTL-based (24h + 6h grace) |
| Station viewport | Hive | LRU by viewport; max 3 viewports cached |
| Reservation list | Hive | Replaced on each full refresh |
| Reservation detail | Hive | LRU; max 20 entries |
| Session metrics | Memory only (ActiveSessionNotifier) | Cleared on session end |
| Wallet balance | Hive | Replaced on each refresh |
| Tariff schedules | Hive | TTL-based (1 hour); replaced on fetch |
| Notification history | Hive | Last 50 entries; FIFO eviction |
| Write queue | Hive | Cleared on successful flush |

Hive stores binary format. No migration mechanism — breaking schema changes require a version bump with a clean-delete strategy (clear old box, re-fetch from server).

---

## 22. Scalability Strategy

### Backend scalability

| Component | Scaling approach |
|-----------|-----------------|
| Business API (.NET 9) | Stateless; horizontal scaling behind load balancer |
| OCPP Gateway | Separate cluster; sticky WebSocket routing per charger; independent horizontal scaling |
| PostgreSQL | Read replicas for reporting queries; primary for all writes |
| Redis | Session cache, rate limiting, JWKS distribution cache |
| RabbitMQ | Decouples OCPP Gateway from Business API; queue depth as backpressure signal |

### Mobile scalability

| Concern | Design decision |
|---------|----------------|
| Station map data volume | Server-side clustering at low zoom; client receives aggregates, not individual stations |
| WebSocket fanout | Viewport-based subscriptions; client subscribes only to visible stations; autoDispose cancels on scroll |
| Push notification volume | FCM/APNS data-only messages; client fetches full payload on receipt (avoids push payload size limits) |
| Pagination | Cursor-based; client requests next page on scroll (no preloading of large lists) |
| Image loading | Native map SDK handles tile caching; app image assets served from CDN with cache headers |

### OCPP scalability

- Sticky WebSocket routing ensures a charger's messages always arrive at the same gateway node
- RabbitMQ exchanges provide fan-out: one OCPP event can trigger multiple consumers (billing, availability update, analytics) without coupling
- OCPP Gateway nodes are stateless for business logic; session affinity is for protocol continuity only, not data

---

## 23. Future Roadmap

### OCPP 2.0.1 and OCPP 2.1

Adding OCPP 2.x support requires only adding a new adapter:

```
charging/infrastructure/adapters/
├── ocpp_protocol_adapter.dart     (interface — unchanged)
├── ocpp16_adapter.dart            (active — unchanged)
├── ocpp20_adapter.dart            (new)
└── ocpp21_adapter.dart            (new)
```

Domain and application layers are untouched. The revised PAL interface (`translateInbound → List<OcppDomainEvent>`) already handles OCPP 2.x cardinality. `SessionStopReason` already contains OCPP 2.x stop codes (`EVDisconnected`, `SOCLimitReached`). `SessionMetrics` already carries optional OCPP 2.x measurands (`stateOfCharge`, `activePowerKw`, `measurands` map).

**TransactionEvent (OCPP 2.x):** The OCPP 2.x `TransactionEvent` message type replaces `StartTransaction` / `StopTransaction` / `MeterValues` from OCPP 1.6J. The `Ocpp20Adapter.translateInbound()` maps all three `TransactionEvent` event types (`Started`, `Updated`, `Ended`) to the appropriate `SessionDomainEvent` entries. No domain layer changes required.

### Smart Charging

`StartSessionUseCase` gains an `initiationMode` parameter (`manual`, `scheduled`, `smart`). The smart charging schedule (target SOC, departure time, max rate) is passed as optional context. The OCPP Gateway handles `SetChargingProfile` — the mobile app provides preferences; the backend applies them.

`SessionMetrics` already carries `stateOfCharge?` and `activePowerKw?` for Smart Charging display.

### ISO 15118 / Plug & Charge

The `StartSessionUseCase` gains `initiationMode: plug_and_charge`. In this mode, the session is started by the charger detecting the vehicle's contract certificate — not by the app. The app receives the `SessionStartedEvent` via WebSocket. No OCPP command is issued from the app. No UI changes to the happy path; the app shows the session immediately on event receipt.

### V2G / V2H / V2B / V2X

The `charging` feature's session state machine is extended with bidirectional energy flow states (`Discharging`, `BidirectionalReady`). The `SessionMetrics.energyKwh` value can be negative for discharge sessions. The wallet treats discharge credits as `TopUp` transactions. The `TariffCalculator` gains a `discharge` rate component.

Reserved route namespace: `/v2x/...`

### Fleet Management

Reserved feature namespace: `features/fleet/`. A `FleetGuard` is added after `KycGuard` in the guard chain. Fleet features operate on shared `UserId` lists with a new `FleetAccount` aggregate.

### Corporate Accounts

Reserved feature namespace: `features/corporate/`. JWT gains an optional `orgId` claim. A `CorporateGuard` is added to the guard chain. Cost allocation and invoicing are new bounded contexts.

### Subscription Plans

Reserved feature namespace: `features/subscription/`. Affects `TariffCalculator` — member discounts are applied as a rate modifier. Subscription status is a JWT claim (`subscriptionTier`).

### Reserved namespaces

```
Route namespaces (reserved, no routes currently exist):
  /fleet/...
  /corporate/...
  /smart-charging/...
  /v2x/...
  /subscription/...

Feature namespaces (reserved, no feature directories currently exist):
  features/fleet/
  features/corporate/
  features/smart_charging/
  features/v2x/
  features/subscription/
```

---

## 24. Non-Negotiable Architectural Constraints

These constraints are absolute. They may not be relaxed, worked around, or deferred during implementation. Any change requires an explicit architecture review and modification of this document.

---

**C-1: Protocol Abstraction Layer**

Domain logic never references OCPP types, message formats, status codes, or version-specific identifiers. OCPP is confined entirely to `charging/infrastructure/adapters/`. The domain layer works only with domain types: `SessionEvent`, `SessionStatus`, `SessionStopReason`, `ChargerStatus`.

---

**C-2: Revised PAL interface signature**

The `OcppProtocolAdapter` interface signature is:
```
translateInbound(rawMessage, context: AdapterContext) → List<OcppDomainEvent>
translateOutbound(command, context: AdapterContext) → OcppRawMessage
```

The original single-return signature (`translateInbound → SessionEvent`) is permanently retired. It cannot handle OCPP 2.x one-to-many message translation.

---

**C-3: Integer-only monetary arithmetic**

All monetary values are represented as `Cents` (integer value + `CurrencyCode`). No `double`, no `Decimal`, no string-formatted money is used anywhere in domain or application code. `TariffRate` uses integer value + scale for sub-cent rates. No floating-point arithmetic on money at any layer.

---

**C-4: Append-only wallet ledger**

No `Transaction` record is ever updated or deleted. No balance field is stored independently of the ledger. All financial operations carry an idempotency key. The wallet bounded context is separate from the payment and settlement bounded contexts.

---

**C-5: VerifiedJwtClaims only in guards and application code**

Route guards and all application code accept only `VerifiedJwtClaims`. Raw JWT strings are never passed to the application layer or read by guards. `VerifiedJwtClaims` has a private constructor — it can only be produced by `JwtVerifier` after the full 9-step validation pipeline. This constraint is enforced by the type system, not by convention.

---

**C-6: Algorithm allowlist**

JWT algorithm verification accepts only: `ES256`, `RS256`, `ES384`, `RS384`. The algorithm `none` and HMAC algorithms (`HS256`, `HS384`, `HS512`) are permanently rejected. The allowlist is hardcoded in `AlgorithmAllowlist` — it is not configurable at runtime or through `AppConfig`.

---

**C-7: Device binding**

Every JWT is bound to the device that authenticated. The server embeds `deviceId` in the JWT. The client verifies `deviceId` matches the device's own stable identifier on every JWT validation. A JWT from another device is rejected with `DeviceIdMismatch` → hard logout + security event.

---

**C-8: TariffSnapshot at reservation creation**

Every `Reservation` and every `ChargingRecord` carries an immutable `TariffSnapshot` capturing the tariff at the time of booking or session start. Session cost reconciliation uses the snapshot, not the current live tariff. This ensures receipts are accurate regardless of tariff changes after the fact.

---

**C-9: CurrencyMismatchFailure**

Any operation involving `Cents` values with different `CurrencyCode` values must fail with `CurrencyMismatchFailure`. No silent currency conversion. The wallet and all pricing operations are single-currency per deployment. Multi-currency support requires a dedicated architecture extension.

---

**C-10: Single writer per state**

No `Notifier` calls methods on another `Notifier`. Cross-notifier influence is read-only (`ref.watch`) or reactive (`ref.listen`). There is exactly one notifier that owns and writes each piece of state. This is the single-writer rule and it is absolute.

---

**C-11: 202 Accepted pattern for OCPP commands**

OCPP-dependent commands (`start session`, `stop session`) always return HTTP 202. The notifier holds the `commandId` and correlates it with the confirming WebSocket event. If no event arrives within 30 seconds, `OcppTimeoutError` is emitted. No notifier waits on a OCPP result synchronously by polling the API.

---

**C-12: Clean Architecture dependency rule**

Dependencies point inward only:
```
presentation → application → domain ← infrastructure (injected)
```

`domain/` has zero framework dependencies (no Flutter, no Riverpod, no Dio, no platform imports). `application/` depends on domain interfaces; concrete implementations are injected via Riverpod providers and never imported directly.

---

**C-13: ChargingSession and ChargingRecord are separate entities**

`ChargingSession` is the mutable active entity. `ChargingRecord` is the immutable completed record. They are never the same class in different states. A record is created when a session reaches a terminal state. The record is never updated after creation.

---

**C-14: JWKS certificate pinning**

The JWKS endpoint (`/.well-known/jwks.json`) is protected by the same certificate pinning as all other API calls. It uses the same pinned `DioClient`, not a separate HTTP client. A JWKS fetch through an unpinned client is a security vulnerability (allows serving forged public keys).

---

**C-15: No hardcoded user-visible strings**

All user-visible text in UI code must come from `AppLocalizations` (generated from ARB files). String literals are prohibited in widget trees, button labels, error messages, empty states, loading labels, and accessibility semantics. Technical strings (route names, API field names, log messages, enum identifiers) are exempt. Domain and application layer failures are mapped to localized strings only at the presentation layer — `AppLocalizations` is never imported in `domain/` or `application/`.

---

**C-16: Directional layout — no hardcoded LTR assumptions**

All widget layout must use directional variants. `EdgeInsetsDirectional` (start/end) replaces `EdgeInsets.only(left/right)`. `AlignmentDirectional` replaces `Alignment.centerLeft/Right`. `TextAlign.start`/`TextAlign.end` replace `TextAlign.left`/`TextAlign.right`. No widget may hardcode left-to-right flow. Custom page transition animations must query `Directionality.of(context)` to determine slide direction.

---

*This document reflects all architectural decisions finalized across the complete pre-implementation architecture phase. It supersedes PROJECT_CONTEXT.md as the implementation reference. Implementation must not begin until this document is reviewed and accepted.*

---

## 25. Internationalization and Localization Architecture

### Design philosophy

Internationalization (i18n) is a first-class architectural concern, not an afterthought. The two failure modes of bolted-on i18n — hardcoded strings discovered late, and LTR layout assumptions requiring a full widget rewrite — are structurally prevented by constraints C-15 and C-16. Persian/Farsi (RTL) is a co-equal supported locale alongside English (LTR). No feature is considered complete until it is verified in both locales.

### Supported locales

| Locale tag | Language | Script | Direction | Calendar system | Number digits |
|------------|----------|--------|:---------:|-----------------|:-------------:|
| `en` | English | Latin | LTR | Gregorian | 0–9 (Latin) |
| `fa` | Persian / Farsi | Perso-Arabic | RTL | Solar Hijri (Shamsi) | ۰–۹ (Persian-Indic) |

**Persian digit policy:** The `intl` package formats numbers with Persian-Indic digits (۰۱۲۳۴۵۶۷۸۹) when locale is `fa`. Exception: OTP codes, session IDs, station IDs, transaction IDs, and phone numbers always use Latin digits (0–9) with explicit LTR directionality, regardless of locale. These are technical identifiers, not quantities.

### Locale management — LocaleNotifier

`LocaleNotifier` lives in `core/locale/`. It is app-lifetime (`autoDispose: false`). `MaterialApp.locale` is driven by `LocaleNotifier.state`.

**Locale resolution priority (highest wins):**
1. User's stored preference (`SharedPreferences` — loaded synchronously on bootstrap, no network needed)
2. User's profile preference (server-side, synced on `ProfileNotifier` load; overwrites local only if explicitly changed on another device)
3. Device system locale (if in the supported locale list)
4. Fallback: `en`

**Locale change flow:**
```
User selects locale in /profile/settings
    ↓
LocaleNotifier.setLocale(locale)
    ↓
[1] Write to SharedPreferences           (synchronous — UI updates immediately)
    ↓
[2] MaterialApp.locale updates           (entire widget tree rebuilds; Directionality flips)
    ↓
[3] Reactive cascade fires (ref.listen):
    — StationMapNotifier.clearLocaleCache()
    — ReservationListNotifier.clearLocaleCache()
    — ProfileRepository.updateLocalePreference(locale)     (async, best-effort)
    — NotificationRepository.updateDeviceLocale(locale)    (async, best-effort)
```

### Flutter localization setup

**Package:** `flutter_localizations` (Flutter SDK) + `intl`

**`MaterialApp` configuration:**
- `localizationsDelegates`: `AppLocalizations.delegate`, `GlobalMaterialLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate`
- `supportedLocales`: `[Locale('en'), Locale('fa')]`
- `locale`: driven by `LocaleNotifier.state`
- `localeResolutionCallback`: falls back to `en` if device locale is not supported

**Generated class:** `AppLocalizations` (generated by `flutter gen-l10n` from ARB files). Accessed via `AppLocalizations.of(context)` in widget code. Never accessed in domain or application layers.

### ARB string management

**File locations:**
```
lib/l10n/
├── app_en.arb     Source locale — defines all keys; must be complete
└── app_fa.arb     Persian translations — must contain every key from app_en.arb
```

**Key naming convention:** `<feature>_<screen>_<element>` using camelCase.

Examples:
```
auth_otp_resendButton
auth_otp_attemptsRemaining
charging_session_stopConfirmTitle
charging_session_stopConfirmBody
wallet_topup_insufficientBalanceError
reservation_new_pricingStep_estimatedCost
```

**ICU message format** for parameterized strings and plurals:
```
"reservationList_upcomingCount": "{count, plural, =0{No upcoming} =1{1 upcoming} other{{count} upcoming}}"
"sessionMetrics_energyValue": "{kwh} kWh"
"walletBalance_display": "Balance: {amount}"
```

**Translation completeness rule:** `app_fa.arb` must contain every key defined in `app_en.arb`. The `flutter gen-l10n` tool enforces this at build time — a missing key is a build error.

**String categories in ARB:**
- Navigation labels (tab names, screen titles, back button labels)
- Action labels (CTAs, button text)
- Status messages (session states, reservation states, KYC states, connectivity states)
- Error messages (client validation errors, AppError display strings)
- Empty states ("No reservations yet", "No transactions")
- Confirmation dialogs (titles and body copy)
- In-app notification banner text
- Accessibility labels (`Semantics.label` values for screen readers)

**What is NOT in ARB:**
- Route names, API field names, enum identifiers, log messages (technical; not user-visible)
- Server-returned RFC 7807 `title` and `detail` strings (pre-localized server-side)
- Push notification title and body (pre-localized server-side)

### Typography architecture

Two font families cover the two scripts. A single font cannot serve both Latin and Perso-Arabic with acceptable quality.

| Script | Primary font | Rationale |
|--------|-------------|-----------|
| Latin (English) | Inter | Legibility, wide Unicode coverage, open license |
| Persian | Vazirmatn | Most widely used open-source Persian font; excellent screen legibility; Latin fallback built-in |

**Font fallback chain:** The locale-specific font is `fontFamily`. The other script's font is in `fontFamilyFallback`. This handles mixed-script text (e.g., a Persian sentence containing a Latin brand name or model number) without visual inconsistency.

**Locale-specific `TextTheme`:** `AppTheme` defines two `TextTheme` instances. The Persian `TextTheme` differs in:
- `fontFamily`: Vazirmatn
- `height` (line height): ~1.6 (Persian script requires more vertical space than Latin ~1.4)
- Letter spacing adjustments per Vazirmatn metrics

A `ThemeExtension<AppTypography>` carries the active typography set. `LocaleNotifier` triggers a `ThemeData` rebuild on locale change.

### RTL layout rules (enforcement of C-16)

**Spacing:**

| Prohibited | Required instead |
|-----------|-----------------|
| `EdgeInsets.only(left: x)` | `EdgeInsetsDirectional.only(start: x)` |
| `EdgeInsets.only(right: x)` | `EdgeInsetsDirectional.only(end: x)` |
| `EdgeInsets.fromLTRB(...)` | `EdgeInsetsDirectional.fromSTEB(...)` |
| Top/bottom-only: `EdgeInsets.symmetric(vertical: x)` | Exempt — no LTR assumption |

**Alignment:**

| Prohibited | Required instead |
|-----------|-----------------|
| `Alignment.centerLeft` | `AlignmentDirectional.centerStart` |
| `Alignment.centerRight` | `AlignmentDirectional.centerEnd` |
| `TextAlign.left` | `TextAlign.start` |
| `TextAlign.right` | `TextAlign.end` |

**Directional icons:** Flutter automatically mirrors `Icons.arrow_back`, `Icons.arrow_forward`, `Icons.chevron_left`, `Icons.chevron_right`, `Icons.navigate_before`, `Icons.navigate_next` when `Directionality` is RTL. Custom SVG icons that convey direction must have an explicit RTL variant or use a conditional `Transform.scale(scaleX: -1)`.

**Page transitions:** GoRouter's default `MaterialPage` transition respects `Directionality` automatically. Custom `CustomTransitionPage` implementations must query `Directionality.of(context)` and reverse the horizontal slide direction accordingly. Never hardcode slide direction.

**Form fields:** Use `InputDecoration.prefixIcon` and `suffixIcon` (directional) rather than manually positioned widgets inside `Stack`. In RTL, prefix icons appear on the right automatically.

**Always-LTR elements** (wrapped in `Directionality(textDirection: TextDirection.ltr)`):
- OTP input fields
- Phone number display
- Station ID, session ID, transaction ID labels
- Technical code display (version numbers, connector IDs)

### Number formatting

All number formatting goes through `core/ui/formatters/number_formatter.dart`. No widget formats numbers directly.

| Value type | English (`en`) | Persian (`fa`) |
|------------|---------------|---------------|
| Energy | `12.5 kWh` | `۱۲٫۵ کیلووات‌ساعت` |
| Duration (minutes) | `45 min` | `۴۵ دقیقه` |
| Duration (h:mm) | `1:30` | `۱:۳۰` |
| Power | `50 kW` | `۵۰ کیلووات` |
| SOC percentage | `80%` | `۸۰٪` |
| Station count | `12 stations` | `۱۲ ایستگاه` |

**Implementation:** `intl.NumberFormat` with the active locale. Persian-Indic digits and correct separators (٫ decimal, ٬ grouping) are applied automatically by `intl`.

### Currency formatting

All currency formatting goes through `core/ui/formatters/currency_formatter.dart`. `Cents` is always the input; a locale-specific display string is the output.

| Locale | Format pattern | Example: 15,000 IRR |
|--------|---------------|---------------------|
| `en` | Symbol before amount | ﷼15,000 |
| `fa` | Amount then name | ۱۵٬۰۰۰ ریال |

**Implementation:** `intl.NumberFormat.currency(locale: locale, symbol: ..., decimalDigits: ...)`. Currency symbol placement is locale-determined by `intl` — no manual positioning.

**Toman/Rial display mode:** Iranian prices are colloquially in Tomans (1 Toman = 10 Rials). The wallet stores Rials (the smallest unit, equivalent to Cents). A `CurrencyDisplayMode` enum (`rials`, `tomans`) in `AppConfig` drives a ÷10 conversion at display time. This is a deployment configuration, not a locale setting — a deployment can be `fa` locale with either `rials` or `tomans` display.

### Date and time formatting

All date/time formatting goes through `core/ui/formatters/date_formatter.dart`. The domain layer always works with `DateTime` (Gregorian, UTC). Calendar conversion is a presentation-only concern.

**Calendar systems:**

| Locale | Calendar | Example |
|--------|----------|---------|
| `en` | Gregorian | Jun 11, 2026 |
| `fa` | Solar Hijri (Shamsi) | ۲۱ خرداد ۱۴۰۵ |

**Shamsi calendar support:** Flutter's `intl` package does not natively support Shamsi. A dedicated Dart package (e.g., `shamsi_date`) provides Gregorian ↔ Shamsi conversion. Conversion happens only at display time in `DateFormatter`.

**Format types exposed by DateFormatter:**

| Format type | English | Persian |
|-------------|---------|---------|
| `dateOnly` | Jun 11, 2026 | ۲۱ خرداد ۱۴۰۵ |
| `timeOnly` | 2:30 PM | ۱۴:۳۰ |
| `dateTime` | Jun 11, 2026, 2:30 PM | ۲۱ خرداد ۱۴۰۵ ساعت ۱۴:۳۰ |
| `relative` | 5 minutes ago | ۵ دقیقه پیش |
| `duration` | 45 min | ۴۵ دقیقه |
| `slotRange` | 2:00–3:00 PM | ۱۴:۰۰–۱۵:۰۰ |

**Timezone:** Server sends UTC ISO 8601. `DateFormatter` converts to device local timezone before formatting. Reservation slot times are particularly critical — they display in local timezone with the correct calendar.

### Validation messages

**Client-side validation:** Form field validators receive `AppLocalizations` as a parameter and return localized strings from ARB files. No validator hardcodes a string literal.

**Server-side validation (RFC 7807):** All API requests include `Accept-Language: <locale>` injected by `locale_interceptor.dart`. The server returns RFC 7807 `title` and `detail` in the requested language. The client renders these directly without translation — they are already localized.

**AppError localization at the presentation layer:**
- `ApiError`: renders server-returned `title` and `detail` (already localized by server)
- `NetworkError`, `OcppTimeoutError`, `AuthError`, `ValidationError`: mapped to ARB strings in the presentation layer via `AppError.localizedMessage(AppLocalizations)` extension
- Domain layer failures (`CurrencyMismatchFailure`, `JwtValidationFailure`, etc.) are mapped to `AppError` variants at the infrastructure boundary, then to ARB strings in the presentation layer

### Notification templates

**Architecture decision: server-side localization for push notifications.**

Push notification title and body are rendered by the server before delivery to FCM/APNS. The client's `locale` is sent during device registration and updated on every locale change.

**Device registration includes locale:**
```
POST /devices  { fcmToken, platform, locale: "fa" }
PUT  /devices/{deviceId}  { locale: "fa" }   (on locale change)
```

**Server-side template system:** The backend maintains localized notification template sets per `(eventType, locale)`. Template variables use ICU format. The server resolves all variables at send time and delivers the final, pre-rendered string.

**In-app notification banners:** `NotificationRecord.body` arrives pre-localized. The client renders it directly. Banner layout direction (`Directionality`) is determined by the client's active locale — not by the content of the string.

### Station and content localization

**Accept-Language header:** Injected on every API request by `locale_interceptor.dart`. The server returns locale-specific versions of: station `name`, station `address`, operator `name`, connector type labels, and RFC 7807 error strings.

**Domain entity design:** `Station.name` and `Station.address` are single `String` fields, not `Map<locale, String>`. The API returns the locale-appropriate version. The domain entity does not carry multiple locales simultaneously.

**Cache key strategy:** Hive cache keys for locale-sensitive entities include the locale code: `station_<id>_en`, `station_<id>_fa`. This allows both locales to be cached independently — switching back to a previous locale does not require a re-fetch.

**Cache invalidation on locale change:** `LocaleNotifier` reactive cascade (see Section 19) clears viewport and reservation caches so the next API call fetches names in the new locale.

### Deep links

Deep link URL paths and parameters are locale-neutral. Route paths use English identifiers (`/map`, `/charging`, `/reservations`). No localized URL paths are defined.

**Deep link URL encoding:** Any non-ASCII parameter (e.g., a localized search query passed as a query parameter) is percent-encoded per RFC 3986. `NotificationRouter` and `GoRouter` URL-decode parameters before use.

**Universal Links / App Links:** The `app.evcharger.com` domain serves both locales. No locale-specific subdomain. Language is determined by the device/user preference at runtime, not by the URL.

### Future language expansion

Adding a new supported locale requires changes in exactly these places — and no others, if C-15 and C-16 are respected throughout implementation:

1. Create `lib/l10n/app_<code>.arb` with all keys from `app_en.arb` translated
2. Add `Locale('<code>')` to `MaterialApp.supportedLocales`
3. Add an entry to `SupportedLocale` enum in `core/locale/supported_locales.dart`
4. Update `locale_storage.dart` validation to accept the new code
5. If the locale uses a non-Gregorian calendar: add a formatter branch in `DateFormatter`
6. If the locale uses non-Latin digits: `intl.NumberFormat` handles this automatically from the locale tag
7. If the locale uses a non-Latin script font: add a font entry in `AppTheme` and `AppTypography`
8. Add locale to the server-side notification template system
9. Add the locale option to the `/profile/settings` locale picker UI

**RTL languages (same layout path as Persian, no additional widget work):** Arabic (`ar`), Hebrew (`he`), Urdu (`ur`). A different font (e.g., Noto Sans Arabic) and potentially a different calendar (Islamic Hijri for Arabic) are the only additions.

**LTR languages (new ARB file only, no layout work):** Turkish (`tr`), German (`de`), French (`fr`), Spanish (`es`), Japanese (`ja`), Korean (`ko`).

**Planned but not committed:** Arabic (`ar`), Turkish (`tr`).