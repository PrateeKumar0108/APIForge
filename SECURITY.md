# APIForge Security Policy & Threat Model

APIForge is designed as an offline-first mobile API client. Because developer tools handle sensitive API keys, session cookies, and authentication bearer tokens, security and privacy are foundational constraints.

---

## 🛡️ OWASP Mobile Top 10 Mitigation Matrix

| OWASP Mobile Risk | Threat in API Clients | APIForge Mitigation |
|---|---|---|
| **M1: Insecure Credential Storage** | API keys and Bearer tokens stored in plaintext in SQLite or SharedPreferences. | Secrets are stored exclusively in hardware-backed storage (`FlutterSecureStorage` using Android Keystore / iOS Keychain). SQLite stores an empty string and an opaque `secretRefId`. |
| **M2: Insecure Communication** | Cleartext HTTP or improper certificate validation. | All requests default to HTTPS. Network execution layer validates TLS handshakes and surfaces `TlsFailure` on certificate mismatch. |
| **M3: Insecure Authentication / Authorization** | Tokens forwarded across untrusted redirects. | `AuthHeaderGenerator.stripCrossHostAuth` detects host mismatches between initial request and redirect target and strips the `Authorization` header. |
| **M4: Insufficient Input Validation** | Malicious URLs or payloads crashing the application. | `UrlValidator` performs protocol and hostname validation before request dispatch. Regex checks prevent malformed URI parsing. |
| **M6: Inadequate Privacy Controls** | Accidental credential leakage in history logs or exported collection files. | Sensitive headers (`Authorization`, `X-API-Key`, `Cookie`) are masked (`[REDACTED]`) before persistence. Request body logging is strictly opt-in. |
| **M8: Code Execution via Untrusted Data** | Executing malicious JavaScript scripts embedded in Postman collections. | `PostmanCollectionParser` discards all executable scripts (`prerequest`, `test`, `event`) at parse time. No `eval` or dynamic code evaluation exists in the codebase. |

---

## 🔒 Secret Handling Guarantees

### 1. Separation of Relational State and Sensitive Secrets
```
[User Input] --> [Is Secret = true?]
                      |
        +-------------+-------------+
        |                           |
  (Relational Data)           (Secret Value)
        |                           |
  [Drift / SQLite]           [Android Keystore / iOS Keychain]
  - id                       - secretRefId (UUID)
  - key                      - AES-256 encrypted plaintext
  - value = ""
  - secretRefId = UUID
```

### 2. Export Sanitization
Whenever a collection or environment is exported via `CollectionExportService`:
- Variable values marked `isSecret: true` are exported as `"[SECRET_REDACTED]"`.
- All `Authorization` headers (Bearer tokens, Basic auth passwords) are redacted with `"[REDACTED]"`.
- `authConfig` credentials (tokens, passwords, API keys) are sanitized prior to JSON serialization.

---

## 📢 Reporting Security Vulnerabilities

If you discover a security vulnerability in APIForge, please report it privately:
- Do NOT open a public GitHub issue.
- Email `security@apiforge.dev` with a description of the vulnerability, steps to reproduce, and impact assessment.
- We will acknowledge receipt within 48 hours and work with you on a coordinated disclosure.
