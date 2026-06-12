# EV Charger

Enterprise-grade EV Charging Platform built with Flutter and .NET.

## Overview

EV Charger is a scalable electric vehicle charging platform designed for mobile-first charging experiences.

The platform supports:

* Station discovery
* Connector availability
* Reservations
* Charging session management
* Wallet and payments
* User authentication and KYC
* Multi-language support (English & Persian)
* OCPP integration

The architecture is designed for future support of:

* OCPP 2.0.1
* OCPP 2.1
* Smart Charging
* Plug & Charge
* Fleet Management
* Corporate Accounts
* V2G / V2H / V2X

---

## Project Structure

```text
EVCharger/

├── docs/
│   ├── architecture/
│   ├── planning/
│   └── ui/
│
├── mobile/
│   └── Flutter application
│
└── .claude/
```

---

## Technology Stack

### Mobile

* Flutter
* Riverpod
* Go Router
* Dio
* Hive
* Secure Storage

### Backend (Planned)

* .NET 9
* PostgreSQL
* Redis
* RabbitMQ

### Protocols

* OCPP 1.6J (MVP)
* OCPP 2.0.1 (Future)
* OCPP 2.1 (Future)

---

## Architecture Principles

### Clean Architecture

The mobile application follows a feature-first Clean Architecture approach.

### State Management

Riverpod is used for dependency injection and state management.

### Navigation

Go Router provides declarative navigation and route guards.

### Internationalization

Supported MVP languages:

* English (LTR)
* Persian / Farsi (RTL)

RTL support is a non-negotiable architectural requirement.

---

## Current Status

### Completed

* Core platform architecture
* Mobile architecture
* Design system
* Routing architecture
* Riverpod foundation
* Localization foundation
* Authentication architecture
* Charging architecture
* Reservation architecture
* Wallet architecture
* Station discovery architecture

### Current Phase

Sprint 2 – Authentication & App Entry Flow

---

## Documentation

### Architecture

See:

```text
docs/architecture/
```

### UI Specifications

See:

```text
docs/ui/
```

### Planning

See:

```text
docs/planning/
```

---

## Releases

### v0.1.0-foundation

Completed:

* Flutter foundation
* Design system
* Routing
* Riverpod setup
* Localization
* Network layer
* Storage layer

---

## Roadmap

### Sprint 2

Authentication & App Entry Flow

### Sprint 3

Home + Map Experience

### Sprint 4

Station Details

### Sprint 5

Reservation Flow

### Sprint 6

Charging Session

### Sprint 7

Charging Summary

### Sprint 8

Wallet & Payments

---

## License

Private project.
All rights reserved.
