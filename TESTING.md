# APIForge Testing Strategy & Test Suite Guide

APIForge maintains a rigorous automated testing strategy to guarantee stability, data integrity, and security across all mobile platforms.

---

## 🎯 Testing Philosophy: Zero External Network Dependencies

A core invariant of the APIForge test suite is:
> **No automated test should ever depend on public internet servers, external mock APIs, or network reachability.**

All HTTP requests, timeouts, cancellations, and failures are tested using mock executors or controlled local in-memory streams. All SQLite persistence tests run against fast, isolated, in-memory databases (`NativeDatabase.memory()`).

---

## 📊 Test Pyramid & Coverage Breakdown

```
          / \
         /   \       End-to-End Flow Tests (1 test)
        / E2E \      - Full lifecycle: Build -> Send -> Inspect -> Save -> History -> Replay
       /-------\
      / Widget  \    Widget Tests (5 tests)
     /   Tests   \   - ResponseInspectorWidget, Syntax highlighting, Status badges, Navigation
    /-------------\
   /  Repository   \  Persistence & Repository Tests (16 tests)
  /     Tests       \ - SQLite Drift CRUD, Cascades, Transactions, Secure Storage, FIFO History
 /-------------------\
/     Unit Tests      \ Pure Unit Tests (40 tests)
/-----------------------\ - UrlValidator, SecretRedactor, CurlGenerator, Engine, Auth, Postman
```

**Total Automated Tests:** **62 Tests (100% Passing)**

---

## 🏃 Running the Tests

### 1. Run Complete Test Suite
```bash
flutter test
```

### 2. Run with Code Coverage
```bash
flutter test --coverage
```
Coverage information will be generated in `coverage/lcov.info`.

### 3. Run Specific Test Groups
- **Pure Unit Tests:**
  ```bash
  flutter test test/unit/networking/
  flutter test test/unit/environments/
  flutter test test/unit/authentication/
  ```
- **Database & Storage Tests:**
  ```bash
  flutter test test/unit/storage/
  flutter test test/unit/history/
  ```
- **Import/Export & Postman Tests:**
  ```bash
  flutter test test/unit/import_export/
  ```
- **End-to-End Flow Test:**
  ```bash
  flutter test test/widget/e2e_request_flow_test.dart
  ```

---

## 🔍 Continuous Integration (CI) Verification

Every commit and pull request triggers `.github/workflows/ci.yml`, running:
1. `dart format --output=none --set-exit-if-changed .` (100% strict code style enforcement)
2. `flutter analyze` (Zero analyzer warnings or errors)
3. `flutter test --coverage` (All 62 tests passing)
