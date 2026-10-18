# APIForge Architecture & Engineering Specification

This document details the software architecture, design principles, subsystem boundaries, and technical decisions implemented across the **APIForge** mobile application.

---

## 🏛️ 1. Architectural Style & Clean Architecture

APIForge follows a **Feature-First Clean Architecture** with strict layer separation:

```
lib/
├── app/                      # Application entry, GoRouter configuration, App-level shells
│   ├── app.dart
│   ├── app_router.dart
│   └── scaffold_with_nav_bar.dart
├── core/                     # Shared cross-cutting concerns & foundational primitives
│   ├── errors/               # Domain failure hierarchy (NetworkFailure, TimeoutFailure, etc.)
│   ├── networking/           # HttpRequestExecutor, SecretRedactor, UrlValidator, CurlGenerator
│   ├── storage/              # Drift Database (Tables, Migrations), SecureStorageService
│   ├── theme/                # Material 3 Design System, AppColors, AppTheme
│   └── widgets/              # Reusable UI components (MethodBadge, StatusCodeBadge, EmptyState)
└── features/                 # Vertical domain feature slices
    ├── authentication/       # Bearer, Basic, API Key models and Header Generators
    ├── collections/          # SQLite collections, folders, saved request CRUD, cascading deletion
    ├── environments/         # Environments, variables, secret storage, substitution engine
    ├── history/              # Request history audit logs, FIFO retention pruning, replay
    ├── import_export/        # APIForge JSON v1 exporter/importer, Postman v2.1 collection parser
    ├── request_builder/      # Verb selection, dynamic key-value headers/params, body formatting
    ├── response_inspector/   # JSON syntax highlighter, latency/size badges, raw & headers view
    └── settings/             # Themes, retention limit dropdown, privacy toggles
```

### Layer Constraints & Data Flow
1. **Presentation Layer**: Flutter widgets and Riverpod `StateNotifierProvider` / `StreamProvider`. Widgets only observe state and dispatch user intents; they never execute direct I/O or SQL statements.
2. **Domain Layer**: Pure Dart entities (e.g. `CollectionEntity`, `HistoryEntryEntity`, `AuthConfig`), domain value objects, domain services (`VariableSubstitutionEngine`, `AuthHeaderGenerator`), and repository interfaces (`ICollectionsRepository`, `IHistoryRepository`). Contains zero Flutter framework dependencies.
3. **Data / Infrastructure Layer**: Concrete repository implementations (`CollectionsRepositoryImpl`, `HistoryRepositoryImpl`), Drift generated DAOs, Dio HTTP executor (`HttpRequestExecutor`), and `FlutterSecureStorage` adapters.

---

## ⚡ 2. State Management with Riverpod

APIForge relies on **Riverpod 2.x** for state management and dependency injection.

### Key Providers Pattern
- **Singletons**: `appDatabaseProvider`, `secureStorageServiceProvider`, and `httpRequestExecutorProvider` instantiate core infrastructure dependencies and automatically release resources via `ref.onDispose()`.
- **StateNotifier Providers**: `requestBuilderProvider` encapsulates complex UI state (`RequestState`) comprising URL validation, selected verb, parameters, headers, body, authentication, active cancellation tokens, execution status, and inspected responses.
- **Reactive Streams**: `collectionsListProvider`, `historyListProvider`, and `collectionRequestsProvider(id)` watch Drift SQLite tables via reactive query streams (`query.watch()`). Any insert, update, or cascade delete instantly updates all UI observers without manual event bus notifications.

---

## 💾 3. Persistence Strategy: Drift & SQLite

### Schema & Tables
APIForge uses **Drift (formerly Moor)** on top of SQLite:
- `Workspaces`: Top-level organizational grouping.
- `Collections`: Groups requests and folders.
- `Folders`: Supports nested folder hierarchies.
- `SavedRequests`: Detailed request definitions (method, url, queryParamsJson, headersJson, bodyType, bodyContent, formDataJson, authType, authConfigJson).
- `Environments`: Environment grouping (`Local`, `Development`, `Production`).
- `EnvironmentVariables`: Variable key-value pairs with `isSecret` and `secretRefId` pointers.
- `RequestHistoryEntries`: Request execution audit log with status, timing, size, and headers.

### Foreign Key Cascade Integrity
SQLite foreign keys are explicitly enforced on connection open:
```dart
beforeOpen: (details) async {
  await customStatement('PRAGMA foreign_keys = ON');
}
```
In addition, repository implementations enforce transactional deletions (`db.transaction`) so deleting a collection cascades cleanly to all contained requests and folders without orphaned rows.

---

## 🌐 4. Networking & Execution Layer

### Non-Throwing Status Code Inspection
Standard HTTP clients (like default Dio) throw exceptions on HTTP status codes outside `200..299`. For an API testing client, HTTP 4xx and 5xx responses (e.g., 400 Bad Request, 401 Unauthorized, 404 Not Found, 500 Internal Server Error) are **valid inspection payloads**, not fatal application crashes.

APIForge configures Dio with:
```dart
validateStatus: (statusCode) => true,
```
This guarantees that all HTTP responses reach the `ResponseInspectorWidget`, where status badges, headers, and error bodies are inspected with syntax highlighting. Pure transport failures (DNS resolution failure, offline, TLS certificate errors, socket timeouts) are caught and mapped into typed domain failures:
- `TimeoutFailure`: Configurable connect/receive/send timeout elapsed.
- `NetworkFailure`: No network connectivity or host unreachable.
- `TlsFailure`: Handshake or SSL certificate verification failure.
- `CancelledFailure`: Request aborted by user via `CancelToken`.

---

## 🔐 5. Security Architecture

1. **Hardware Keystore Boundary**: Plaintext secret values are never saved to the SQLite database. The relational database stores an empty string and an opaque UUID pointer (`secretRefId`). The actual secret is written to `FlutterSecureStorage` (AES-256 GCM backed by Android Keystore / iOS Keychain).
2. **Secret Redaction**:
   - `SecretRedactor` scans headers and query parameters for sensitive keys (`authorization`, `token`, `secret`, `api-key`, `password`, `cookie`).
   - cURL export masks sensitive values when the user toggles secret protection.
   - Request history auto-redacts Authorization and secret tokens before persistence.
3. **Cross-Host Redirect Sanitization**:
   - If an authenticated request is redirected to a different origin host, `AuthHeaderGenerator.stripCrossHostAuth()` strips the Authorization header to prevent token leakage to untrusted third parties.
4. **Postman Import Sandbox**:
   - Postman Collection v2.1 files can contain executable JavaScript in `"event"` arrays (`prerequest` and `test` scripts). `PostmanCollectionParser` explicitly ignores and discards these scripts, ensuring zero arbitrary code execution risk.
