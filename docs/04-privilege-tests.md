# Privilege Tests

These tests are read-only or use disposable test objects in the development
database. Run them as the relevant MySQL account after a DBA applies
`database/security/roles-privileges.sql`. Never run destructive tests against
production.

## Runtime account

| Test | Expected | Result before remediation |
|---|---|---|
| `SELECT COUNT(*) FROM users` | Allowed | Allowed |
| `INSERT/UPDATE/DELETE` on an application-owned feature row | Allowed only where application feature supports it | Currently allowed |
| `CREATE TABLE kk_privilege_probe (...)` | Forbidden | **Must be tested after script**; current `ALL PRIVILEGES` likely allows it |
| `ALTER TABLE users ADD ...` | Forbidden | **Must be tested after script** |
| `DROP TABLE kk_privilege_probe` | Forbidden | **Must be tested after script** |
| `GRANT SELECT ON ...` | Forbidden | **Must be tested after script** |
| `SELECT User, Host FROM mysql.user` | Forbidden | Already denied: MySQL error 1142 |
| `SHOW GRANTS` for another account | Forbidden | **Must be verified with DBA evidence** |

Expected post-remediation evidence:

```sql
SHOW GRANTS FOR 'klikkompor_app'@'localhost';
-- Must show kk_runtime only and no ALL PRIVILEGES, CREATE, ALTER, DROP,
-- CREATE USER, GRANT OPTION, or database administration privileges.
```

## Migration account

| Test | Expected |
|---|---|
| `CREATE/ALTER/DROP` migration-owned schema | Allowed |
| `GRANT ...` or `CREATE USER` | Forbidden because `GRANT OPTION` is absent |
| `SELECT/INSERT/UPDATE/DELETE` application tables | Allowed for migration verification |
| Runtime API request using migrator credentials | Not allowed; never put this account in deployed `.env` |

## Role and revoke verification

1. Capture `SHOW GRANTS FOR 'klikkompor_app'@'localhost'` before applying the
   script.
2. Apply the script as DBA.
3. Run `SET DEFAULT ROLE` verification by opening a new connection.
4. Confirm `SHOW GRANTS` contains `kk_runtime` and no direct `ALL PRIVILEGES`.
5. Execute the forbidden probes above and record the exact MySQL error.
6. Confirm the application can still authenticate, read catalog/order data,
   write an order, and write an audit event.

The script does not drop existing accounts, and unknown accounts remain a DBA
finding until reviewed. This avoids destructive cleanup without ownership
evidence.

