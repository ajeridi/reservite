# 🍽️ ReserVite — Full-Stack Restaurant Reservation Platform

[![Flutter](https://img.shields.io/badge/Frontend-Flutter%203.38%20%7C%20Dart%203.10-02569B?logo=flutter)](https://flutter.dev/)
[![State Management](https://img.shields.io/badge/State-Riverpod%203%20(AsyncNotifier)-blueviolet)](https://riverpod.dev/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL%2016%2B-336791?logo=postgresql)](https://www.postgresql.org/)
[![API](https://img.shields.io/badge/API-PostgREST%20Automated%20Engine-blue)](https://postgrest.org/)
[![Security](https://img.shields.io/badge/Security-PL%2FpgSQL%20JWT%20%7C%20Bcrypt%20%7C%20RBAC-success)](#-database-security--in-database-jwt-auth)

> **Enterprise-grade restaurant reservation platform powered by a decoupled client-server architecture: an automated PostgREST API backed by PostgreSQL and 14 PL/pgSQL business integrity rules, paired with a multi-role cross-platform Flutter client leveraging Riverpod 3.**

---

## 🎯 System Overview & Key Features

**ReserVite** is a distributed booking management system built on a **Database-as-a-Service (BaaS) and Headless API architecture**. The core domain logic, temporal validations, and security policies are natively enforced inside PostgreSQL, exposing OpenAPI-compliant REST endpoints through PostgREST to a cross-platform Flutter client.

### Key Highlights
* **Dual-Persona Interface (Client & Manager):**
  * **Client Experience:** Restaurant discovery, available time-slot calculation, party size selection with real-time overbooking warnings, and reservation lifecycle tracking.
  * **Manager Workspace:** Restaurant overview, interactive table allocation based on party size, service schedule editing, and booking status resolution.
* **14 Enforced Business Integrity Rules (BR-01 to BR-14):** Critical business logic is enforced via PL/pgSQL triggers and constraints directly at the database level, preventing double bookings, overlapping services, and illegal status transitions.
* **Reactive State Management (Riverpod 3):** Clean separation of concerns powered by `AsyncNotifierProvider` ensuring predictable asynchronous data synchronization, caching, and state transitions across the Flutter client.
* **Smart Form Validation & Debouncing:** Custom `ValidatingTextEditingController` combined with debounce utilities to execute asynchronous backend validations (e.g., real-time username and email availability checks) without triggering request storms.
* **In-Database Cryptographic Authentication:** Stateless JWT token minting and signature validation (HMAC-SHA256) executed entirely in PL/pgSQL without third-party application servers.

---

## 🏗️ Software Architecture

The platform separates client presentation, state management, automated API dispatching, and relational database logic:

```text
ReserVite/
├── backend/
│   ├── scripts/
│   │   ├── 01_init.sql              # Schema isolation, JWT crypto engine & PostgREST reload triggers
│   │   ├── 02_security.sql          # RBAC roles, Bcrypt password hashing trigger & login procedures
│   │   ├── 03_tables_and_data.sql   # Relational schema (Restaurants, Tables, Services, Reservations)
│   │   ├── 04.00_checks.sql to 04.14# 14 PL/pgSQL triggers enforcing domain business rules
│   │   └── 05.00_ep_*.sql           # Stored procedures & RPC endpoints exposed to PostgREST
│   └── tests/                       # SQL unit tests with transactional rollbacks & HTTP test suites
├── frontend/
│   ├── lib/
│   │   ├── core/                    # HTTP client, persistent local storage (Hive), and debouncers
│   │   ├── models/                  # Immutable domain models with JSON serialization
│   │   ├── providers/               # Riverpod 3 AsyncNotifiers (Auth, Reservations, Tables, Services)
│   │   ├── views/
│   │   │   ├── pages/               # Application screens (Client & Manager flows)
│   │   │   └── widgets/             # Reusable UI components & custom pickers
│   │   └── main.dart                # Application entrypoint & Material Design 3 configuration
│   └── pubspec.yaml                 # Frontend dependencies and SDK configuration
└── scripts/                         # Shell and batch automation scripts for PostgreSQL & PostgREST
```

---

## 🔒 Database Security & In-Database JWT Auth

* **Zero-Knowledge Credential Storage:** Passwords submitted during registration trigger an automated `AFTER INSERT OR UPDATE` trigger executing `auth.crypt()` with Blowfish salt generation (`pgcrypto`).
* **Autonomous JWT Token Minting:** The `login(email, password)` database procedure directly constructs, signs (HMAC-SHA256), and returns an RFC-compliant JWT token containing user identity and role claims.
* **Strict PostgreSQL RBAC:** All access is mediated through native PostgreSQL roles:
  * `anon`: Read-only access to public discovery endpoints and authentication procedures.
  * `authenticator`: PostgREST connection identity prohibited from direct data manipulation.
  * `client`: Access restricted strictly to personal reservations and public directory data.
  * `manager`: Elevated permissions restricted exclusively to assigned restaurant instances.
* **Real-Time Schema Reload Trigger:** PostgreSQL DDL event triggers execute `NOTIFY pgrst, 'reload schema'` on schema alterations, keeping the API layer updated without server reboots.

---

## ⚖️ Business Rules Engine (Database-Enforced)

The core domain guarantees data consistency through 14 independent PL/pgSQL constraints and triggers:
* **BR-01 & BR-03:** Reservation assignment restricted to clients; allocated tables must belong to the target restaurant.
* **BR-02:** Party size for confirmed or completed bookings cannot exceed the cumulative capacity of assigned tables.
* **BR-04 & BR-05:** Booking timestamps must strictly fall within operating service hours and align with the restaurant's slot duration.
* **BR-06:** Prevention of double bookings: a single table cannot be assigned to multiple active reservations during the same service window.
* **BR-07 & BR-08:** Overlapping service shifts are prohibited; service boundaries must align with slot increments.
* **BR-09 & BR-11:** Strict state machine enforcement (`pending` ➔ `confirmed` ➔ `completed` / `cancelled`); completed and cancelled reservations are immutable.
* **BR-10:** Every restaurant must maintain at least one assigned manager.
* **BR-12:** Tables cannot be linked to pending or cancelled reservations.
* **BR-13:** A client cannot hold multiple active bookings on the same date within the same service window.
* **BR-14:** Reservations cannot be backdated prior to current or simulated system time.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter 3.38+ (Dart 3.10+), Material Design 3
* **State Management & Caching:** Flutter Riverpod 3 (`AsyncNotifier`), Hive CE (encrypted local storage)
* **Backend Database:** PostgreSQL 16+ (PL/pgSQL, pgcrypto)
* **API Dispatcher:** PostgREST (Headless RESTful mapping)
* **Testing Harness:** SQL test suites with transactional rollbacks (`BEGIN ... ROLLBACK`), REST Client (`.http`)