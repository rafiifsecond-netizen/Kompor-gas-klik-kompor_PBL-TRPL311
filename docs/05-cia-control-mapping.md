# CIA Control Mapping

Scope: development environment only. The source database is never used as the
restore target.

| ID | Control | Risiko | Evidence | Hasil | Status |
|---|---|---|---|---|---|
| C-01 | Column-limited views | Public/read-only roles expose email, phone, KTP, payment payload, or audit snapshots | `2026_10_28_170001_create_security_views.php`; four explicit views; public technician response hides contact fields | Views exclude sensitive columns and the read-only role is limited to views | Partially Comply until DBA applies grants |
| C-02 | Hash + salt | Credential disclosure enables account takeover | `User` hashed cast, `Hash::make`, Sanctum token storage, hashed reset tokens | Passwords and reset tokens are hashed; plaintext reset fallback removed | Comply in code |
| C-03 | Encryption | KTP and other sensitive values are readable at rest | `TechnicianProfile` encrypted cast; migration encrypts existing KTP values using `APP_KEY` | KTP is encrypted and hidden from serialization; key management remains environment responsibility | Partially Comply |
| I-01 | Transaction boundary | Partial order/payment/status updates create inconsistent totals or audit state | `DB::transaction()` in order creation/service replacement/status/reschedule/payment/additional-cost/role changes | Multi-step writes are enclosed in transactions | Comply in code |
| I-02 | Commit/rollback tests | Failures leave orphan rows or incorrect totals | Feature tests and direct rollback test; Laravel test suite evidence | Success and rollback scenarios are specified; full execution awaits stable DB/test baseline | Partially Comply |
| A-01 | Backup | Data loss or unusable backup | `database/security/backup-dev.ps1`; dated backup created with routines/triggers/events | Development backup created and ignored by Git; no password in command | Comply |
| A-02 | Restore | Backup cannot be recovered or restore overwrites source | `database/security/restore-test.ps1`; separate DB target and row/table checks | Restore procedure exists, but execution requires DBA credentials | Partially Comply |

## Key management risk

Laravel encrypted casting uses the environment-provided `APP_KEY`. It must be
stored in a secret manager or protected environment configuration, rotated with
a planned re-encryption procedure, and never committed, logged, or copied into
backup documentation. Losing the key makes encrypted KTP values unrecoverable.

## Transaction scenarios

The expected tests are:

1. A valid customer order creates its header, item rows, status log, optional
   chat, notification, and audit event.
2. An exception during a multi-step write rolls back all rows from that
   transaction.
3. Payment and additional-cost updates commit their related order totals only
   when their dependent row and audit/notification operations succeed.

Notifications are currently synchronous model writes. If they move to an
external queue, an outbox/idempotency design should be added so external side
effects cannot be mistaken for database atomicity.

