# MySQL Security Baseline Assessment

Assessment date: 2026-10-28, development only. No production host was
contacted. Passwords, password hashes, and secrets are intentionally omitted.

## Evidence summary

- MySQL version: `8.0.41`.
- Runtime account: `klikkompor_app@localhost`.
- Runtime connection: local host, database `klikkompor_db`.
- `SHOW GRANTS` for runtime:
  - `GRANT USAGE ON *.* TO klikkompor_app@localhost`
  - `GRANT SELECT, INSERT, UPDATE, DELETE ON klikkompor.* TO klikkompor_app@localhost`
  - `GRANT ALL PRIVILEGES ON klikkompor_db.* TO klikkompor_app@localhost`
- `default_password_lifetime = 0`.
- Queries against `mysql.user` were rejected for the runtime account. Admin
  evidence is still required for account inventory and lock/expiry fields.
- Development backup completed with `mysqldump --single-transaction
  --no-tablespaces --routines --triggers --events`; the restore test is blocked
  until an administrative MySQL login is made available.

## B-01..B-08

| ID | Evidence | Criteria | Status | Finding | Bukti |
|---|---|---|---|---|---|
| B-01 | `SELECT VERSION()` | Supported MySQL release and version recorded | Comply | Version is known and recorded | MySQL 8.0.41 |
| B-02 | `SHOW GRANTS` runtime | Runtime account is separate from root/admin | Partially | Separate named account exists, but it has database-level `ALL PRIVILEGES` | `klikkompor_app@localhost` grants |
| B-03 | `SHOW GRANTS` runtime | Runtime has only required DML, no DDL/GRANT | Not Comply | `ALL PRIVILEGES` on `klikkompor_db` includes excessive privileges | `GRANT ALL PRIVILEGES ON klikkompor_db.*` |
| B-04 | Runtime host and account | Host restricted to localhost/specific IP | Comply | Runtime account is scoped to `localhost` | `klikkompor_app@localhost` |
| B-05 | `mysql.user` inventory | No anonymous/test/duplicate/unowned accounts | Not Verified | Runtime account cannot read `mysql.user`; admin query required | MySQL error 1142 |
| B-06 | `default_password_lifetime` and user metadata | Password expiration/lock policy is explicit | Partially | Global lifetime is `0`; per-account lock/expiry unknown | `default_password_lifetime=0` |
| B-07 | Backup command and file | Repeatable backup exists without password in command | Comply | Dated dev backup created and ignored by Git | `storage/app/backups/*.sql` |
| B-08 | Restore to isolated DB | Backup can be restored and verified | Not Verified | Restore requires an administrative account; not executed with runtime account | Root no-password probe denied |

## Analisis kondisi

The application runtime account is correctly named and host-restricted, but its
privilege set violates least privilege. The remediation must be executed by a
database administrator using the reviewed script in
`database/security/roles-privileges.sql`; it is not automatically executed by
Laravel.

The runtime account cannot inspect server accounts, which is desirable for
confidentiality but means B-05 and per-account B-06 require an administrator
snapshot. No account is dropped automatically because the user explicitly
prohibited destructive changes without approval.

The backup command avoids command-line passwords by using a temporary option
file. The option file is deleted after execution and backup files are ignored
by Git. A restore verification script is supplied in Week 5 and must target a
separate development database, never the source database.

