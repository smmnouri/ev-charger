Project: EV Charging Management Platform

Current Phase:
Mobile User Application (Flutter MVP)

Architecture Status:
The platform architecture has already been designed.

Core Modules Completed:

1. Authentication / Profile / KYC
2. Station Discovery
3. Reservation
4. Charging
5. Wallet

Platform Architecture Completed:

1. Global API Specification
2. Global Integration Architecture
3. OCPP Integration Architecture

Technology Stack:

Frontend:

* Flutter
* Riverpod
* Go Router
* Dio
* WebSocket

Backend:

* .NET 9
* PostgreSQL
* Redis
* RabbitMQ

EV Charging Architecture:

Current Protocol:

* OCPP 1.6J

Future Protocol Support:

* OCPP 2.0.1
* OCPP 2.1

Important Architectural Decisions:

1. Protocol Abstraction Layer (PAL)

* Domain logic must never reference OCPP directly.
* OCPP is isolated behind protocol adapters.

2. Separate OCPP Adapters

* OCPP 1.6J Adapter
* OCPP 2.0.1 Adapter
* OCPP 2.1 Adapter

3. OCPP Gateway

* Separate service cluster.
* Sticky WebSocket routing.
* Independent horizontal scaling.

4. Wallet Architecture

* Wallet, Payment, and Settlement are separate bounded contexts.
* Money represented as integer cents only.
* Append-only immutable ledger.
* All financial operations are idempotent.

5. Authentication

* Phone + OTP only.
* Refresh token rotation with replay detection.
* JWT includes KYC status.
* Max 5 active sessions per user.

6. Station Discovery

* Viewport-based subscriptions.
* Server-side clustering at low zoom.
* Native map markers.
* OCPP-driven charger availability.

7. API Standards

* RFC 7807 Problem Details.
* Cursor-based pagination.
* Event envelope with replay support.
* Public/Internal API separation.
* 202 Accepted for OCPP-dependent commands.

Project Goal:
Build a scalable enterprise-grade EV Charging Platform starting with a Flutter mobile application while keeping the architecture ready for:

* Smart Charging
* ISO 15118
* Plug & Charge
* Fleet Management
* Corporate Accounts
* V2G
* V2H
* V2B
* V2X

Important Rule:
Do not generate implementation code until architecture, navigation, state management, and project structure are finalized.
