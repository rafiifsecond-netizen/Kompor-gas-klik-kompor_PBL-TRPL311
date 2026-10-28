# Access Design, AAA, dan Audit

## User-role matrix

| Aktor | Identitas | Otorisasi utama | Data yang boleh diakses |
|---|---|---|---|
| Guest | Login/register/reset atau katalog publik | Tidak ada role | Katalog aktif dan endpoint auth |
| Customer | Sanctum token atau web session | `role:customer` dan ownership order | Profil, alamat, order sendiri, chat order sendiri, notifikasi dan review sendiri |
| Technician | Sanctum token atau web session | `role:technician` dan assignment order | Profil teknisi, order yang ditangani/pending assignment, chat terkait, status dan biaya tambahan |
| Admin | Web session atau Sanctum token | `role:admin` | Operasional seluruh data sesuai kebutuhan administrasi dan audit |
| System | Proses aplikasi | Internal service/model | Notifikasi, audit, dan pekerjaan yang dipicu transaksi |

## Access control matrix

`R` = SELECT, `C` = INSERT, `U` = UPDATE, `D` = DELETE. Matriks ini
menjadi target otorisasi aplikasi dan privilege database; akun runtime tidak
boleh memperoleh DDL atau `GRANT OPTION`.

| Tabel | Guest | Customer | Technician | Admin |
|---|---:|---:|---:|---:|
| `users` | - | R/U own | R/U own | R/C/U/D administrasi |
| `technician_profiles` | - | R public subset | R/U own | R/C/U/D |
| `service_categories` | R active | R active | R active | R/C/U/D |
| `service_items` | R active | R active | R active | R/C/U/D |
| `technician_services` | - | R public subset | R/U own | R/C/U/D |
| `addresses` | - | R/C/U/D own | - | R only when operationally required |
| `orders` | - | R/C own | R/U assigned or pending; no arbitrary D | R/C/U/D |
| `order_items` | - | R own through order | R/U assigned order | R/C/U/D |
| `order_status_logs` | - | R own order | R/C assigned order | R/C/U/D |
| `payments` | - | R/C own order | - | R/C/U/D |
| `additional_costs` | - | R/U own order | R/C/U assigned order | R/C/U/D |
| `chats` / `chat_messages` | - | R/C own order | R/C own order | R for support |
| `notifications` | - | R/U own | R/U own | R/U operational |
| `reviews` | - | R/C own completed order | R received | R/U/D moderation |
| `activity_logs` | - | - | - | R; application C only |

Database grants are intentionally coarser than row ownership. Row ownership
must remain enforced by Laravel controllers/policies and later automated
authorization tests.

## Sensitive data matrix

| Classification | Examples | Default handling |
|---|---|---|
| Public | Active service name, category, base price, verified technician summary | Public read endpoint; exclude internal columns |
| Internal | Order status metadata, service assignment, operational notifications | Authenticated role/ownership only |
| Confidential | Email, phone, chat, payment references, audit metadata | Minimum role and ownership; never place in public views |
| Sensitive | Password hash, access token, reset token, KTP, address, coordinates, payment payload | Hash/encrypt/redact; no raw audit snapshots; restricted reads |

## Authentication and authorization implementation

- Passwords use Laravel `hashed` cast and `Hash::make`; no custom SHA-2
  password storage is allowed.
- API authentication uses Sanctum bearer tokens.
- API role middleware is registered as `role` in
  [bootstrap/app.php](../bootstrap/app.php).
- Web admin routes are grouped under `auth` and `role:admin`; route closures
  no longer decide access by redirecting unauthenticated users.
- Object ownership remains checked at controller boundaries for orders,
  addresses, chats, costs, and reviews.
- `TechnicianProfile::ktp_number` uses Laravel encrypted casting. The
  encryption key is the environment-provided `APP_KEY`; it must never be
  committed or printed.

## Mandatory audit events

The application must record:

1. Successful and failed login.
2. Logout.
3. Registration, password change, password reset request, and password reset.
4. Role/privilege changes and technician verification.
5. Access to customer PII by technician/admin.
6. Order creation, status transition, reschedule, and service changes.
7. Payment processing and additional-cost lifecycle.
8. Changes to sensitive profile data.

`ActivityLog::logEvent()` sanitizes known sensitive keys and text before
persisting `old_values`, `new_values`, and descriptions. Raw password, token,
email, phone, address, coordinates, message, payment payload, and KTP values
must not be written to audit records.

## Remaining design decision

The database privilege layer still needs separate runtime and migration
accounts. Current evidence shows `klikkompor_app@localhost` has excessive
`ALL PRIVILEGES` on `klikkompor_db`; the remediation script is intentionally
separate and will be reviewed in Week 4 before manual execution.

