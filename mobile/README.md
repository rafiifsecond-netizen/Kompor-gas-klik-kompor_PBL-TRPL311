# KlikKompor Mobile App (Flutter)

Aplikasi mobile KlikKompor untuk **Customer (Pelanggan)** dan **Teknisi (Technician)** berbasis Flutter & REST API Laravel.

## 📁 Struktur Direktori

```text
mobile/
├── analysis_options.yaml
├── pubspec.yaml
└── lib/
    ├── core/
    │   ├── constants/
    │   │   ├── api_endpoints.dart     # URL endpoint REST API
    │   │   ├── app_colors.dart        # Palet warna brand KlikKompor
    │   │   ├── app_constants.dart     # Konstanta, status, helper format rupiah & tanggal
    │   │   └── app_text_styles.dart   # Tipografi Plus Jakarta Sans
    │   ├── theme/
    │   │   └── app_theme.dart         # Material 3 Light Theme
    │   ├── routes/
    │   │   ├── app_routes.dart        # Definisi nama rute navigasi
    │   │   └── route_generator.dart   # Switch onGenerateRoute
    │   └── network/
    │       ├── api_client.dart        # Dio HTTP Client + Interceptor Bearer Token
    │       ├── api_exception.dart     # Error mapping & HTTP validation parser
    │       └── api_response.dart      # Generic standard response wrapper
    │
    ├── models/
    │   ├── user_model.dart            # Model User & Profil Teknisi
    │   ├── service_model.dart         # Model Layanan & Kategori Servis Kompor
    │   ├── address_model.dart         # Model Alamat Pelanggan
    │   ├── order_model.dart           # Model Pesanan Lengkap
    │   ├── order_item_model.dart      # Model Item Layanan dalam Pesanan
    │   ├── additional_cost_model.dart # Model Biaya Tambahan Sparepart
    │   ├── order_review_model.dart    # Model Ulasan & Rating
    │   ├── chat_model.dart            # Model Chat & Pesan Konsultasi Order
    │   └── notification_model.dart    # Model Notifikasi
    │
    ├── services/
    │   ├── storage_service.dart       # SharedPreferences (Token & Cache Session)
    │   └── auth_service.dart          # REST API Login, Register, Me, Logout
    │
    ├── repositories/
    │   └── auth_repository.dart       # Single Source of Truth Session Auth
    │
    ├── providers/
    │   └── auth_provider.dart         # State Management Auth (Provider)
    │
    ├── screens/
    │   ├── auth/
    │   │   ├── splash_screen.dart     # Auto-login & Routing sesuai Role
    │   │   ├── login_screen.dart      # Login Form + Demo Credentials + Setting Host API
    │   │   └── register_screen.dart   # Pendaftaran Customer & Teknisi
    │   ├── customer/
    │   │   └── customer_home_screen.dart
    │   └── technician/
    │       └── technician_dashboard_screen.dart
    │
    ├── widgets/
    │   ├── custom_button.dart         # Tombol Primer/Outlined + Loading State
    │   ├── custom_text_field.dart     # Input Form + Toggle Password + Validasi
    │   ├── loading_indicator.dart     # Animasi Loading
    │   ├── empty_state_widget.dart    # Komponen State Kosong
    │   └── error_state_widget.dart    # Komponen Error State + Tombol Coba Lagi
    │
    └── main.dart                      # Entrypoint Aplikasi Mobile
```

## 🚀 Cara Menjalankan

1. Masuk ke folder `mobile`:
   ```bash
   cd mobile
   ```

2. Jalankan `pub get`:
   ```bash
   flutter pub get
   ```

3. Pastikan backend Laravel sedang aktif di terminal lain:
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

4. Jalankan aplikasi Flutter:
   ```bash
   flutter run
   ```

## 🔑 Kredensial Uji Coba Demo

Tersedia tombol preset sekali klik di Login Screen:
- **Pelanggan**: `dewi@example.com` / `password123`
- **Teknisi**: `agus.teknisi@klikkompor.com` / `password123`
