# KlikKompor Final Audit Matrix

Audit date: 2026-11-21

This matrix distinguishes code presence and automated coverage from external
integration and device evidence. A row is not `PRODUCTION READY` unless all
required external dependencies and deployment controls have been verified.

| ID / feature | Flutter page | Web Admin page | API / web entry point | Controller / service | Model / database | Automated evidence | Status |
|---|---|---|---|---|---|---|---|
| F001 Login | `auth/login_screen.dart` | `admin/login` | `POST /api/v1/auth/login` | `AuthController@login` | `User` / `users`, tokens | `KlikKomporApiTest::test_user_can_login_and_receive_token` | IMPLEMENTED; AUTOMATED TESTED |
| F002 Registration | `auth/register_screen.dart` | Admin user management | `POST /api/v1/auth/register` | `AuthController@register` | `User`, `TechnicianProfile` / `users`, `technician_profiles` | `DashboardManagementAndTechnicianRegistrationTest::test_prospective_technician_can_register_and_starts_as_pending` | IMPLEMENTED; AUTOMATED TESTED |
| F003 Forgot password | `auth/forgot_password_screen.dart` | `admin/forgot-password` | `POST /api/v1/auth/forgot-password` | `AuthController@forgotPassword` / Laravel Mail | `password_reset_tokens`, `ActivityLog` | Route/controller present; no end-to-end SMTP assertion | IMPLEMENTED; NOT VERIFIED |
| F004 Change/reset password | `customer_profile_screen.dart`, `forgot_password_screen.dart` | Admin profile password/reset | `PUT /api/v1/auth/password`, `POST /api/v1/auth/reset-password` | `AuthController@changePassword`, `resetPassword` | `users`, `password_reset_tokens` | Backend validation present; Flutter field mapping fixed | IMPLEMENTED; NOT VERIFIED |
| F005 Catalog exploration | `customer_catalog_screen.dart`, `customer_service_detail_screen.dart` | `admin/services` | `GET /api/v1/categories`, `GET /api/v1/services` | `ServiceCatalogController` | `ServiceCategory`, `ServiceItem` / `service_categories`, `service_items` | `KlikKomporApiTest::test_can_retrieve_public_service_categories_and_items` | IMPLEMENTED; AUTOMATED TESTED |
| F006 Dashboard | `customer_home_screen.dart`, technician dashboard | `admin/dashboard` | `GET /api/v1/dashboard/banners`, admin dashboard routes | `BannerController`, `AdminController` | `Banner`, `Order`, `User` / related tables | `DashboardManagementAndTechnicianRegistrationTest` banner tests | IMPLEMENTED; AUTOMATED TESTED |
| F007 Booking/scheduling | booking summary, select address/schedule/payment | `admin/orders` | `POST /api/v1/orders`, order reschedule/cancel routes | `OrderController`, `TravelFeeService` | `Order`, `OrderItem`, `Address` / `orders`, `order_items`, `addresses` | `KlikKomporApiTest::test_customer_can_create_service_order` | IMPLEMENTED; AUTOMATED TESTED |
| F008 Technician selection | `customer_select_technician_screen.dart` | technician management | `GET /api/v1/technicians` | `TechnicianController@index/show` | `User`, `TechnicianProfile`, `TechnicianService` | `KlikKomporApiTest::test_can_search_verified_technicians` | IMPLEMENTED; AUTOMATED TESTED |
| F009 Payment | `customer_payment_screen.dart` | `admin/payments` | checkout/status/webhook/upload-proof/cash confirmation | `PaymentController`, `PaymentService`, `MidtransService` | `Payment`, `WebhookEvent`, `CommissionRecord` / `payments`, `webhook_events`, `commission_records` | `FinalPaymentSpecificationTest`, `ComprehensivePaymentAuditTest` | IMPLEMENTED; AUTOMATED TESTED; NOT VERIFIED externally |
| F010 Tracking/history | order tracking/history screens | `admin/orders`, reports | `GET /api/v1/orders`, order detail/status | `OrderController`, `TechnicianController` | `Order`, `OrderStatusLog`, technician profile | workflow/status tests | IMPLEMENTED; AUTOMATED TESTED; DEVICE NOT VERIFIED |
| F011 Chat/review | customer/technician chat and review screens | admin reviews | chat and review routes | `ChatController`, `ReviewController` | `Chat`, `ChatMessage`, `Review` / `chats`, `chat_messages`, `reviews` | `KlikKomporExtendedFeaturesTest` chat tests | IMPLEMENTED; AUTOMATED TESTED |
| F012 Customer profile | `customer_profile_screen.dart` | `admin/profile`, users | `/auth/me`, `/auth/profile`, `/auth/logout` | `AuthController` | `User`, `Address` / `users`, `addresses` | API/auth coverage | IMPLEMENTED; AUTOMATED TESTED |
| F013 Technician tasks | incoming/dashboard/order detail screens | technician approval/orders | order list/detail and technician routes | `OrderController`, `TechnicianController` | `Order`, `OrderStatusLog` | workflow and RBAC tests | IMPLEMENTED; AUTOMATED TESTED |
| F014 Work status | `technician_update_status_screen.dart` | order monitoring | `PATCH /api/v1/orders/{id}/status` | `OrderController@updateStatus` | `Order`, `OrderStatusLog` | sequential status and invalid-jump tests | IMPLEMENTED; AUTOMATED TESTED |
| F015 Technician communication | technician chat/location screens | operational order view | chat and technician location endpoints | `ChatController`, `TechnicianController` | `Chat`, `ChatMessage`, `TechnicianProfile` | chat/location paths covered partially | IMPLEMENTED; AUTOMATED TESTED; DEVICE NOT VERIFIED |
| F016 Additional cost | `technician_additional_cost_screen.dart` | order/payment review | additional-cost CRUD/approve/reject | `AdditionalCostController` | `AdditionalCost`, `Order`, `ActivityLog` / `additional_costs`, `orders`, `activity_logs` | `KlikKomporExtendedFeaturesTest::test_additional_costs_proposal_approval_and_rejection` | IMPLEMENTED; AUTOMATED TESTED |
| F017 Catalog/price management | catalog consumes API | `admin/services` | admin service CRUD/toggle routes | `ServiceCatalogController` | `ServiceCategory`, `ServiceItem` | comprehensive catalog and historical-price tests | IMPLEMENTED; AUTOMATED TESTED |
| F018 User management | registration/profile flows | `admin/customers`, `admin/technicians` | admin users/approval/role routes | `AdminController`, `AdminTechnicianApprovalController` | `User`, `TechnicianProfile` | technician registration/approval/RBAC tests | IMPLEMENTED; AUTOMATED TESTED |
| F019 Operational/transaction monitoring | order/payment/wallet screens | dashboard, payments, orders | admin dashboard/payment/report routes | `AdminController`, `AdminPaymentController` | orders, payments, wallets, logs | payment and dashboard tests | IMPLEMENTED; AUTOMATED TESTED |
| F020 Reports/recap | income screen consumes wallet data | `admin/reports`, CSV export | web report/export routes | `AdminReportController` | orders, payments, commission/wallet records | `ComprehensiveWorkflowAuditTest` report/export tests | IMPLEMENTED; AUTOMATED TESTED |

## Verified fixes in this audit

- Payment checkout now rejects a second successful payment for the same order.
- Polling expiry/failure releases reserved promo usage.
- Midtrans refund requests are sent through Core API before local refund state
  is committed; test mode remains isolated from non-testing environments.
- Promo validation requires order ownership.
- Payment status is restricted to the customer, assigned technician, or admin.
- Admin tariff and commission settings are persisted instead of returning a
  success message only.
- Flutter no longer uses demo QR/VA/account values or navigates to success after
  a failed payment.

## External verification procedure

### Midtrans Sandbox

1. Provide `MIDTRANS_SERVER_KEY`, `MIDTRANS_CLIENT_KEY`, `MIDTRANS_MERCHANT_ID`,
   and `MIDTRANS_IS_PRODUCTION=false` in the deployment environment.
2. Configure the Midtrans notification URL to
   `/api/v1/payments/webhook` and use HTTPS/reachable infrastructure.
3. Create a QRIS and Virtual Account payment from a real customer order.
4. Pay it through the Midtrans Sandbox simulator.
5. Capture the gateway response, webhook payload, signature validation result,
   payment row, order status, commission record, and wallet ledger entry.
6. Repeat the webhook and confirm no duplicate wallet credit.
7. Test `expire`, `deny`, `cancel`, partial/full refund, and late webhook cases.

No Sandbox result is claimed by this document because credentials and a
reachable callback endpoint were not available during the audit.

### GPS and routing

1. Use a physical Android/iOS device with location enabled.
2. Grant foreground location permission and verify denied/service-disabled UI.
3. Start an assigned job and confirm periodic `PATCH
   /api/v1/technician/location` updates.
4. Confirm customer tracking reads the current technician coordinates.
5. Configure `ROUTING_OSRM_URL`, capture a route response, and verify the order
   snapshot contains distance, duration, source, and configured fee.
6. Disable network/routing and verify the recorded Haversine fallback is shown
   as an estimate, not as a road route.

### SMTP and document uploads

`MAIL_MAILER=log` is currently configured, so forgot-password delivery is not
SMTP-tested. Provide SMTP credentials, send a reset request, inspect the
received code, and complete reset. Technician documents require a private
storage policy review; public URLs must not expose identity documents.

## Migration safety

- The migrations are additive and do not call `migrate:fresh` or delete
  business rows.
- `2026_11_21_020000_add_travel_pricing_snapshots` is pending.
- The current MySQL application user lacks `ALTER` permission, so it cannot be
  applied by the app user.
- A DBA should take a backup, grant only the required `ALTER`, `CREATE` (if
  needed), `INDEX`, and `REFERENCES` privileges, run `php artisan migrate
  --force`, verify `php artisan migrate:status`, then revoke temporary
  privileges. Do not edit the `migrations` table manually.

## Overall classification

`IMPLEMENTED`: F001-F020 have corresponding application surfaces and backend
paths.  
`AUTOMATED TESTED`: Laravel suite currently passes 91 tests / 577 assertions.  
`INTEGRATION TESTED`: Not verified for Midtrans, SMTP, OSRM production endpoint,
or real storage delivery.  
`DEVICE TESTED`: Not verified; Flutter SDK/device was unavailable.  
`PRODUCTION READY`: Not established until external, device, migration-permission,
and deployment checks pass.  
`NOT VERIFIED`: external callbacks, physical GPS, SMTP delivery, Flutter
analyze/test, and production MySQL migration execution.
