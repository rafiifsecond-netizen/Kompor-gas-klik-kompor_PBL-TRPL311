# Fungsionalitas yang Sudah Berjalan

## 1. Tujuan

Dokumen ini mendokumentasikan dan memverifikasi fungsionalitas aplikasi mobile
KlikKompor berdasarkan kode pada direktori `mobile/lib/`. Penilaian berlaku
ketika `AppConfig.useDummyData = true`; konfigurasi tersebut bernilai `true`
secara konstan pada
[`app_config.dart`](../mobile/lib/core/config/app_config.dart#L1-L6).

## 2. Deskripsi Aplikasi dan Status Fungsionalitas

Dokumen ini menggambarkan fungsi aplikasi mobile KlikKompor berdasarkan kode
di `mobile/lib/`. Penilaian hanya berlaku ketika
`AppConfig.useDummyData = true`; nilainya saat ini memang `true` di
[`app_config.dart`](../mobile/lib/core/config/app_config.dart#L5).

Status yang digunakan:

- **Berjalan**: alur utama tersedia dan bekerja pada mode dummy.
- **Sebagian**: sebagian kebutuhan tersedia, tetapi ada batasan yang terlihat
  dari kode.
- **Belum ada**: kebutuhan tidak dapat digunakan sebagai alur fungsional pada
  mode dummy saat ini atau memang berada di luar aplikasi mobile.

Aplikasi mobile melayani Pelanggan dan Teknisi. Kebutuhan Admin F017–F020
berada pada Web Admin terpisah dan tidak memiliki route Admin di aplikasi
mobile.

## 2.1 Tabel ringkasan

| F-ID | Nama | Aktor | Screen utama | Status |
|---|---|---|---|---|
| F001 | Login | Pelanggan, Teknisi, Admin | `LoginScreen` | Sebagian |
| F002 | Registrasi Akun | Pelanggan, Teknisi | `RegisterScreen` | Sebagian |
| F003 | Lupa Password | Pelanggan, Teknisi, Admin | `ForgotPasswordScreen` | Sebagian |
| F004 | Ganti Password | Pelanggan, Teknisi, Admin | Form ubah password pada profil | Berjalan |
| F005 | Eksplorasi Layanan & Produk | Pelanggan | `CustomerHomeScreen`, `CustomerCatalogScreen`, `CustomerServiceDetailScreen` | Sebagian |
| F006 | Akses Dashboard & Informatif | Pelanggan | `CustomerHomeScreen` | Berjalan |
| F007 | Pemilihan & Penjadwalan Servis | Pelanggan | `CustomerServiceDetailScreen`, `CustomerBookingSummaryScreen`, `CustomerSelectScheduleScreen` | Berjalan |
| F008 | Pemilihan Teknisi | Pelanggan | `CustomerSelectTechnicianScreen` | Berjalan |
| F009 | Pembayaran | Pelanggan | `CustomerPaymentScreen` | Berjalan |
| F010 | Pelacakan & Riwayat Pesanan | Pelanggan | `CustomerOrderTrackingScreen`, `CustomerOrderHistoryScreen` | Berjalan |
| F011 | Komunikasi & Ulasan | Pelanggan | `CustomerChatScreen`, `CustomerReviewScreen` | Berjalan |
| F012 | Pengelolaan Profil | Pelanggan | `CustomerProfileScreen`, alamat, bantuan, notifikasi | Berjalan |
| F013 | Manajemen Tugas Servis | Teknisi | `TechnicianDashboardScreen`, `TechnicianIncomingOrdersScreen`, `TechnicianOrderDetailScreen` | Berjalan |
| F014 | Pembaruan Status Pengerjaan | Teknisi | `TechnicianUpdateStatusScreen`, `TechnicianOrderDetailScreen` | Berjalan |
| F015 | Komunikasi Lapangan | Teknisi | `TechnicianChatInboxScreen`, detail chat | Berjalan |
| F016 | Rincian Biaya Tambahan | Teknisi | `TechnicianAdditionalCostScreen`, detail pesanan | Berjalan |
| F017 | Kelola Katalog & Harga | Admin | Web dashboard terpisah | Di luar aplikasi mobile |
| F018 | Pengelolaan Data Pengguna | Admin | Web dashboard terpisah | Di luar aplikasi mobile |
| F019 | Monitoring Operasional Transaksi | Admin | Web dashboard terpisah | Di luar aplikasi mobile |
| F020 | Laporan & Rekapitulasi | Admin | Web dashboard terpisah | Di luar aplikasi mobile |

## 3. Rincian fungsionalitas

### F001 — Login

- **Status:** **Sebagian**.
- **Deskripsi:** Pelanggan dapat login dengan `dewi@example.com` dan teknisi
  dengan `agus.teknisi@klikkompor.com`, keduanya menggunakan password
  `password123`. Setelah berhasil, pelanggan diarahkan ke dashboard pelanggan
  dan teknisi ke dashboard teknisi. Field login memang memiliki hint “Email
  atau nomor telepon”, tetapi cabang dummy hanya membandingkan dua alamat
  email tersebut; username atau nomor telepon tidak dipakai untuk login dummy.
  Akun Admin sengaja ditolak di aplikasi mobile dan diberi pesan untuk memakai
  Web Admin.
- **Screen dan rute:** [`LoginScreen`](../mobile/lib/screens/auth/login_screen.dart#L10),
  rute `AppRoutes.login` (`/login`) di
  [`app_routes.dart`](../mobile/lib/core/routes/app_routes.dart#L5) dan
  [`route_generator.dart`](../mobile/lib/core/routes/route_generator.dart#L49).
  Navigasi hasil login menuju `AppRoutes.customerHome` atau
  `AppRoutes.technicianDashboard` di
  [`login_screen.dart`](../mobile/lib/screens/auth/login_screen.dart#L45-L56).
- **Interaksi dan validasi:** Form divalidasi sebelum submit; email wajib diisi
  dan password minimal 8 karakter. Tombol login menampilkan loading dan
  dinonaktifkan ketika proses berjalan. Login berhasil/gagal menampilkan
  SnackBar.
- **Sumber data:** `AuthProvider` → `AuthRepository` → `AuthService`.
  Cabang dummy di [`auth_service.dart`](../mobile/lib/services/auth_service.dart#L22-L45)
  mencocokkan dua email dummy dan password yang tersimpan di memori, lalu
  menghasilkan token dummy.
- **Bukti:** [`login_screen.dart`](../mobile/lib/screens/auth/login_screen.dart#L28-L63),
  [`auth_service.dart`](../mobile/lib/services/auth_service.dart#L22-L45).
- **Belum terpenuhi:** login dengan username/nomor telepon dan login Admin di
  mobile tidak tersedia. Bagian Admin memang berada di luar aplikasi mobile.

### F002 — Registrasi Akun

- **Status:** **Sebagian**.
- **Deskripsi:** Pengguna dapat memilih peran Pelanggan atau Teknisi lalu
  mengisi nama lengkap, email, nomor telepon, password, dan konfirmasi password.
  Registrasi dummy membuat `UserModel` di memori, menyimpan session, lalu
  mengarahkan pengguna ke dashboard sesuai peran.
- **Screen dan rute:** [`RegisterScreen`](../mobile/lib/screens/auth/register_screen.dart#L10),
  rute `AppRoutes.register` (`/register`) di
  [`app_routes.dart`](../mobile/lib/core/routes/app_routes.dart#L6) dan
  [`route_generator.dart`](../mobile/lib/core/routes/route_generator.dart#L52).
- **Interaksi dan validasi:** Pilihan role Pelanggan/Teknisi; validasi nama,
  email, telepon minimal 10 digit, password minimal 8 karakter, dan konfirmasi
  password harus sama. Tombol menampilkan loading dan SnackBar hasil.
- **Sumber data:** `AuthProvider`, `AuthRepository`, dan cabang dummy
  `AuthService.register`. Data user baru dibuat dengan id `999` di memori;
  validasi dummy memeriksa panjang password, kecocokan konfirmasi, email, dan
  nama di [`auth_service.dart`](../mobile/lib/services/auth_service.dart#L48-L76).
- **Bukti:** [`register_screen.dart`](../mobile/lib/screens/auth/register_screen.dart#L34-L60),
  [`register_screen.dart`](../mobile/lib/screens/auth/register_screen.dart#L100-L213),
  [`auth_service.dart`](../mobile/lib/services/auth_service.dart#L48-L76).
- **Belum terpenuhi:** tidak ada field username terpisah. “Data diri” yang
  benar-benar dikirim pada dummy adalah nama, email, telepon, password, dan
  role; alamat tidak diisi dari form ini.

### F003 — Lupa Password

- **Status:** **Sebagian**.
- **Deskripsi:** Pengguna dapat memasukkan email, memperoleh tampilan langkah
  “tautan terkirim”, lalu memasukkan password baru dan konfirmasi. Pada mode
  dummy, proses ini disimulasikan: `forgotPassword` mengembalikan token
  `123456` dan screen mengisikan token tersebut ke langkah berikutnya.
- **Screen dan rute:** [`ForgotPasswordScreen`](../mobile/lib/screens/auth/forgot_password_screen.dart#L9),
  rute `AppRoutes.forgotPassword` (`/forgot-password`) di
  [`app_routes.dart`](../mobile/lib/core/routes/app_routes.dart#L7) dan
  [`route_generator.dart`](../mobile/lib/core/routes/route_generator.dart#L55).
- **Interaksi dan validasi:** Langkah 1 memvalidasi email; langkah reset
  memvalidasi token, password minimal 8 karakter, dan kecocokan konfirmasi.
  Tombol reset menampilkan SnackBar dan kembali ke login saat berhasil.
- **Sumber data:** `AuthProvider.forgotPassword/resetPassword` dan
  `AuthService`. Cabang dummy menerima email yang mengandung `@`, mengembalikan
  `reset_token: 123456`, dan reset password hanya memeriksa password baru di
  [`auth_service.dart`](../mobile/lib/services/auth_service.dart#L164-L208).
- **Bukti:** [`forgot_password_screen.dart`](../mobile/lib/screens/auth/forgot_password_screen.dart#L29-L88),
  [`forgot_password_screen.dart`](../mobile/lib/screens/auth/forgot_password_screen.dart#L170-L335),
  [`auth_service.dart`](../mobile/lib/services/auth_service.dart#L164-L208).
- **Belum terpenuhi:** tidak ada email sungguhan yang dikirim. Email dan token
  hanya disimulasikan di memori; token/email juga tidak diverifikasi terhadap
  akun tertentu pada cabang dummy. Bagian Admin di mobile berada di luar
  cakupan aplikasi.

### F004 — Ganti Password

- **Status:** **Berjalan**.
- **Deskripsi:** Form ubah password tersedia dari profil pelanggan dan teknisi.
  Pengguna memasukkan password saat ini, password baru, dan konfirmasi password;
  setelah berhasil, screen menampilkan feedback.
- **Screen dan rute:** Form berada pada
  [`customer_profile_screen.dart`](../mobile/lib/screens/customer/customer_profile_screen.dart#L225-L360)
  dan form padanan pada
  [`technician_profile_screen.dart`](../mobile/lib/screens/technician/technician_profile_screen.dart#L280-L510).
  Rute profil adalah `AppRoutes.customerProfile`
  (`/customer/profile`) dan `AppRoutes.technicianProfile`
  (`/technician/profile`), didaftarkan di
  [`route_generator.dart`](../mobile/lib/core/routes/route_generator.dart#L118-L121).
- **Interaksi dan validasi:** Form menggunakan `Form`/`TextFormField`,
  password dapat ditampilkan/disembunyikan, password baru minimal 8 karakter,
  dan konfirmasi harus sama. Tombol submit memiliki loading/disable dan
  feedback.
- **Sumber data:** `AuthProvider.changePassword` → `AuthRepository` →
  `AuthService.changePassword`. Cabang dummy menyimpan password per email di
  memori, memverifikasi password lama, lalu menyimpan password baru jika
  valid di [`auth_service.dart`](../mobile/lib/services/auth_service.dart#L24-L45)
  dan [`auth_service.dart`](../mobile/lib/services/auth_service.dart#L166-L204).
- **Bukti:** [`auth_provider.dart`](../mobile/lib/providers/auth_provider.dart#L159-L188),
  [`auth_service.dart`](../mobile/lib/services/auth_service.dart#L166-L204).
- **Belum terpenuhi:** bagian Admin berada di luar aplikasi mobile dan
  bergantung pada Web Admin. Untuk pelanggan dan teknisi, ganti password dummy
  berjalan.

### F005 — Eksplorasi Layanan & Produk

- **Status:** **Sebagian**.
- **Deskripsi:** Pelanggan dapat melihat katalog layanan servis, mencari layanan
  berdasarkan nama atau kategori jika tersedia, melihat harga dan estimasi
  durasi, lalu membuka detail layanan. Data dummy berisi lima layanan servis
  kompor.
- **Screen dan rute:** `CustomerHomeScreen` menampilkan section layanan dan
  menuju `AppRoutes.customerCatalog`; katalog berada di
  [`customer_catalog_screen.dart`](../mobile/lib/screens/customer/customer_catalog_screen.dart#L10)
  dengan rute `/customer/catalog`. Detail berada di
  [`customer_service_detail_screen.dart`](../mobile/lib/screens/customer/customer_service_detail_screen.dart#L34)
  dengan rute `/customer/service-detail`.
- **Interaksi dan validasi:** Search field memfilter nama/kategori; tombol
  refresh memuat ulang; kartu layanan membuka detail. Detail menampilkan
  deskripsi, rating, jumlah ulasan, estimasi, dan harga, lalu menyediakan
  tombol pesan teknisi.
- **Sumber data:** `ServiceRepository.getServices/getService`; dummy
  `dummyServices` berisi layanan `Servis Kompor Gas`, `Servis Kompor Tanam`,
  `Cek Kebocoran Gas`, `Ganti Regulator`, dan `Ganti Selang Gas` di
  [`dummy_data.dart`](../mobile/lib/data/dummy/dummy_data.dart#L129-L135).
- **Bukti:** [`service_repository.dart`](../mobile/lib/repositories/service_repository.dart#L9-L31),
  [`customer_catalog_screen.dart`](../mobile/lib/screens/customer/customer_catalog_screen.dart#L43-L116),
  [`customer_service_detail_screen.dart`](../mobile/lib/screens/customer/customer_service_detail_screen.dart#L43-L74).
- **Belum terpenuhi:** tidak ada daftar produk pendukung terpisah dan tidak ada
  kategori produk pada data dummy. Kategori hanya dibaca secara opsional dari
  model layanan; lima data dummy layanan tidak mendefinisikan katalog produk.

### F006 — Akses Dashboard & Informatif

- **Status:** **Berjalan**.
- **Deskripsi:** Dashboard pelanggan menampilkan nama pengguna, search bar,
  carousel banner, section “Layanan Kami”, dan banner bawah dengan fallback
  visual. Banner promo dan informasi teknisi berpengalaman ditampilkan sebagai
  data statis di screen.
- **Screen dan rute:** [`customer_home_screen.dart`](../mobile/lib/screens/customer/customer_home_screen.dart#L80-L166),
  rute `AppRoutes.customerHome` (`/customer/home`) di
  [`route_generator.dart`](../mobile/lib/core/routes/route_generator.dart#L61-L63).
- **Interaksi dan validasi:** Carousel berjalan otomatis; search bar tersedia
  pada tampilan home; tombol “Layanan Lainnya” membuka katalog; bottom
  navigation menuju riwayat, chat, dan profil.
- **Sumber data:** Nama berasal dari `AuthProvider.user`; banner berasal dari
  konstanta lokal `_carouselItems` di
  [`customer_home_screen.dart`](../mobile/lib/screens/customer/customer_home_screen.dart#L19-L47).
  Pengingat mengambil pesanan selesai terakhir dari
  `OrderRepository.getOrders` dan menghitung saran sekitar enam bulan
  berikutnya di [`customer_home_screen.dart`](../mobile/lib/screens/customer/customer_home_screen.dart#L85-L101).
- **Bukti:** [`customer_home_screen.dart`](../mobile/lib/screens/customer/customer_home_screen.dart#L19-L47),
  [`customer_home_screen.dart`](../mobile/lib/screens/customer/customer_home_screen.dart#L105-L180),
  [`customer_home_screen.dart`](../mobile/lib/screens/customer/customer_home_screen.dart#L247-L303).
- **Catatan:** jika belum ada pesanan selesai, kartu menampilkan ajakan memesan
  servis pertama; tombol kartu membuka katalog.

### F007 — Pemilihan & Penjadwalan Servis

- **Status:** **Berjalan**.
- **Deskripsi:** Pelanggan memilih layanan dari detail, memilih alamat,
  menentukan tanggal dan jam kunjungan, memilih jenis kerusakan, menambahkan
  catatan opsional, lalu melanjutkan ke pembayaran.
- **Screen dan rute:** Detail menuju `AppRoutes.customerBookingSummary`
  (`/customer/booking-summary`) di
  [`customer_service_detail_screen.dart`](../mobile/lib/screens/customer/customer_service_detail_screen.dart#L209-L225).
  Booking summary berada di
  [`customer_booking_summary_screen.dart`](../mobile/lib/screens/customer/customer_booking_summary_screen.dart#L47-L80).
  Jalur alternatif jadwal berada pada `AppRoutes.customerSelectSchedule`
  (`/customer/select-schedule`) di
  [`customer_select_schedule_screen.dart`](../mobile/lib/screens/customer/customer_select_schedule_screen.dart#L35-L83).
- **Interaksi dan validasi:** Alamat dipilih dari `CustomerSelectAddressScreen`;
  tanggal memakai `showDatePicker` dengan rentang hari yang dibatasi; waktu
  dipilih melalui modal bottom sheet; jenis kerusakan wajib dipilih sebelum
  tombol pembayaran dapat dilanjutkan.
- **Sumber data:** Layanan dan jenis kerusakan berasal dari
  `ServiceRepository`; alamat berasal dari `AddressRepository`; data
  tanggal/waktu dan catatan berada pada state screen sampai dikirim ke
  pembayaran. `dummyDamageTypes` berada di
  [`dummy_data.dart`](../mobile/lib/data/dummy/dummy_data.dart#L136-L142).
- **Bukti:** [`customer_booking_summary_screen.dart`](../mobile/lib/screens/customer/customer_booking_summary_screen.dart#L84-L178),
  [`service_repository.dart`](../mobile/lib/repositories/service_repository.dart#L33-L46),
  [`customer_select_schedule_screen.dart`](../mobile/lib/screens/customer/customer_select_schedule_screen.dart#L91-L145).
- **Catatan:** tanggal, waktu, dan catatan booking berada pada state alur
  sampai order dibuat; pada mode dummy belum ada persistence backend.

### F008 — Pemilihan Teknisi

- **Status:** **Berjalan**.
- **Deskripsi:** Pelanggan dapat mencari teknisi berdasarkan nama atau
  spesialisasi dan mengaktifkan beberapa chip pengurutan sekaligus:
  Terdekat, Rating tertinggi, Harga termurah, atau Harga termahal. Pengurutan
  bertingkat mengikuti urutan chip dipilih. Hasil kosong menampilkan
  EmptyState dan tombol reset filter.
- **Screen dan rute:** [`customer_select_technician_screen.dart`](../mobile/lib/screens/customer/customer_select_technician_screen.dart#L8),
  rute `AppRoutes.customerSelectTechnician`
  (`/customer/select-technician`) di
  [`route_generator.dart`](../mobile/lib/core/routes/route_generator.dart#L76-L78).
- **Interaksi dan validasi:** Search field memfilter nama/spesialisasi;
  `FilterChip` dapat dipilih bersamaan; tombol Reset mengembalikan query kosong
  dan chip `Terdekat`; teknisi harus dipilih sebelum tombol lanjut aktif.
- **Sumber data:** `TechnicianRepository.getTechnicians` mengembalikan
  `dummyTechnicians` di
  [`technician_repository.dart`](../mobile/lib/repositories/technician_repository.dart#L8-L14).
  Data dummy memiliki `rating`, `price`, `distance_km`, dan
  `specialization` di [`dummy_data.dart`](../mobile/lib/data/dummy/dummy_data.dart#L1-L72).
- **Bukti:** UI chip, reset, EmptyState, dan tombol pilih berada di
  [`customer_select_technician_screen.dart`](../mobile/lib/screens/customer/customer_select_technician_screen.dart#L193-L277).
  Filter dan pengurutan bertingkat berada di
  [`customer_select_technician_screen.dart`](../mobile/lib/screens/customer/customer_select_technician_screen.dart#L302-L355).
- **Catatan:** chip tersebut menerapkan pengurutan bertingkat, bukan filter
  ambang batas yang menghapus teknisi dari hasil.

### F009 — Pembayaran

- **Status:** **Berjalan**.
- **Deskripsi:** Pelanggan dapat memilih Tunai/COD, Transfer Bank, atau QRIS,
  memeriksa ringkasan alamat/jadwal, lalu menekan tombol konfirmasi.
  Konfirmasi membuat order dummy baru dan mengarahkan pengguna ke tracking.
- **Screen dan rute:** [`customer_payment_screen.dart`](../mobile/lib/screens/customer/customer_payment_screen.dart#L10),
  rute `AppRoutes.customerPayment` (`/customer/payment`) di
  [`route_generator.dart`](../mobile/lib/core/routes/route_generator.dart#L79-L81).
- **Interaksi dan validasi:** Tiga pilihan metode berada pada satu selector;
  alamat wajib terisi; tombol konfirmasi dinonaktifkan saat processing,
  menampilkan spinner, dan memberi feedback sukses/gagal.
- **Sumber data:** `OrderRepository.createOrder` menambahkan order baru ke
  `dummyOrders` dalam mode dummy di
  [`order_repository.dart`](../mobile/lib/repositories/order_repository.dart#L38-L62).
  Metode yang dikirim adalah `cash`, `transfer`, atau `qris` dari
  [`customer_payment_screen.dart`](../mobile/lib/screens/customer/customer_payment_screen.dart#L20-L22)
  dan [`customer_payment_screen.dart`](../mobile/lib/screens/customer/customer_payment_screen.dart#L264-L275).
- **Bukti:** Pilihan metode dan validasi berada di
  [`customer_payment_screen.dart`](../mobile/lib/screens/customer/customer_payment_screen.dart#L79-L132),
  proses order berada di
  [`customer_payment_screen.dart`](../mobile/lib/screens/customer/customer_payment_screen.dart#L241-L344).
- **Catatan:** konfirmasi pada mode dummy tidak terhubung ke payment gateway
  atau transaksi bank sungguhan.

### F010 — Pelacakan & Riwayat Pesanan

- **Status:** **Berjalan**.
- **Deskripsi:** Pelanggan dapat melihat daftar order dummy pada riwayat,
  membuka tracking, melihat status bertahap, dan memperbarui tampilan dengan
  refresh. Status tracking dipetakan dari status order (`pending`, `accepted`,
  `on_the_way`, `in_progress`, `completed`), bukan hanya teks statis.
- **Screen dan rute:** Riwayat berada di
  [`customer_order_history_screen.dart`](../mobile/lib/screens/customer/customer_order_history_screen.dart#L8)
  dengan rute `AppRoutes.customerOrderHistory`
  (`/customer/order-history`). Tracking berada di
  [`customer_order_tracking_screen.dart`](../mobile/lib/screens/customer/customer_order_tracking_screen.dart#L18)
  dengan rute `AppRoutes.customerOrderTracking`
  (`/customer/order-tracking`).
- **Interaksi dan validasi:** Riwayat memiliki refresh, kartu order membuka
  tracking, order selesai dapat membuka ulasan, dan order dapat dipesan ulang.
  Tracking memiliki refresh/polling serta status step.
- **Sumber data:** `OrderRepository.getOrders/getOrder`; dummy order awal
  mencakup status pending, paid, in_progress, completed, cancelled, dan
  on_the_way di [`dummy_data.dart`](../mobile/lib/data/dummy/dummy_data.dart#L144-L151).
  `updateStatus` menyimpan status baru pada map `_dummyState` di
  [`order_repository.dart`](../mobile/lib/repositories/order_repository.dart#L64-L72).
- **Bukti:** Pemetaan status tracking berada di
  [`customer_order_tracking_screen.dart`](../mobile/lib/screens/customer/customer_order_tracking_screen.dart#L105-L119);
  pengambilan order berada di
  [`customer_order_history_screen.dart`](../mobile/lib/screens/customer/customer_order_history_screen.dart#L26-L45).
- **Catatan mode dummy:** Koordinat fallback peta tracking didefinisikan
  sebagai dua titik tetap di
  [`customer_order_tracking_screen.dart`](../mobile/lib/screens/customer/customer_order_tracking_screen.dart#L33-L34).
  Jadi status mengikuti data order, tetapi posisi peta dummy bukan lokasi
  real-time dari perangkat.

### F011 — Komunikasi & Ulasan

- **Status:** **Berjalan**.
- **Deskripsi:** Pelanggan dapat membuka daftar chat, memilih percakapan
  teknisi melalui route detail khusus, memuat pesan, dan mengirim pesan.
  Pelanggan juga dapat memilih rating 1–5, menambahkan komentar opsional, lalu
  menyimpan ulasan dummy ke memori.
- **Screen dan rute:** Daftar chat ada di
  [`customer_chat_screen.dart`](../mobile/lib/screens/customer/customer_chat_screen.dart#L9)
  dengan rute `AppRoutes.customerChat` (`/customer/chat`); detail chat memakai
  `AppRoutes.customerChatDetail` (`/customer/chat/detail`). Ulasan ada di
  [`customer_review_screen.dart`](../mobile/lib/screens/customer/customer_review_screen.dart#L8)
  dengan rute `AppRoutes.customerReview` (`/customer/review`).
- **Interaksi dan validasi:** Rating wajib dipilih sebelum tombol kirim aktif;
  tombol ulasan memiliki loading dan feedback; komentar boleh kosong. Chat
  detail memiliki input pesan dan tombol kirim yang mengabaikan pesan kosong.
- **Sumber data:** `ReviewRepository` menambah ulasan ke `_memory` pada
  [`review_repository.dart`](../mobile/lib/repositories/review_repository.dart#L8-L25).
  `ChatRepository.getOrderChat/sendMessage` memiliki cabang dummy dan
  menyimpan pesan di memori pada
  [`chat_repository.dart`](../mobile/lib/repositories/chat_repository.dart#L9-L32).
- **Bukti:** Submit ulasan berada di
  [`customer_review_screen.dart`](../mobile/lib/screens/customer/customer_review_screen.dart#L72-L113);
  pengiriman pesan customer berada di
  [`customer_chat_screen.dart`](../mobile/lib/screens/customer/customer_chat_screen.dart#L155-L165)
  dan [`customer_chat_screen.dart`](../mobile/lib/screens/customer/customer_chat_screen.dart#L237-L257).
- **Catatan:** komentar ulasan bersifat opsional; tidak ada batasan F011 yang
  tersisa pada alur dummy yang didukung kode.

### F012 — Pengelolaan Profil

- **Status:** **Berjalan**.
- **Deskripsi:** Pelanggan dapat melihat profil dan statistik, mengedit nama,
  nomor telepon, dan alamat, membuka alamat tersimpan, mengubah password,
  membuka riwayat/chat, serta membuka Pusat Bantuan. Screen notifikasi juga
  tersedia dan membaca data dummy.
- **Screen dan rute:** Profil pelanggan ada di
  [`customer_profile_screen.dart`](../mobile/lib/screens/customer/customer_profile_screen.dart#L16)
  dengan rute `/customer/profile`. Alamat berada di
  [`customer_select_address_screen.dart`](../mobile/lib/screens/customer/customer_select_address_screen.dart#L11)
  dengan rute `/customer/select-address`; bantuan di
  [`customer_help_center_screen.dart`](../mobile/lib/screens/customer/customer_help_center_screen.dart#L5)
  dengan rute `/customer/help-center`; notifikasi di
  [`customer_notification_screen.dart`](../mobile/lib/screens/customer/customer_notification_screen.dart#L8)
  dengan rute `/customer/notification`.
- **Interaksi dan validasi:** Edit profil menggunakan form dan validasi;
  alamat dapat dipilih, ditambah, diedit, dihapus, dan dijadikan alamat utama;
  FAQ bantuan dapat dibuka/tutup; notifikasi dapat ditandai satu per satu atau
  semua. Menu Notifikasi pada profil membuka route notifikasi. Logout
  menghapus session lokal dan kembali ke login.
- **Sumber data:** `ProfileRepository` menyediakan profil/statistik dummy dan
  perubahan profil mengubah map dummy di
  [`profile_repository.dart`](../mobile/lib/repositories/profile_repository.dart#L10-L75).
  Alamat berasal dari `AddressRepository` dan `dummyAddresses` di
  [`address_repository.dart`](../mobile/lib/repositories/address_repository.dart#L10-L64)
  serta [`dummy_data.dart`](../mobile/lib/data/dummy/dummy_data.dart#L312-L330).
  Notifikasi berasal dari `dummyNotifications` melalui
  [`notification_repository.dart`](../mobile/lib/repositories/notification_repository.dart#L8-L16).
- **Bukti:** Menu profil, termasuk tautan Notifikasi, berada di
  [`customer_profile_screen.dart`](../mobile/lib/screens/customer/customer_profile_screen.dart#L67-L119);
  load/save alamat berada di
  [`customer_select_address_screen.dart`](../mobile/lib/screens/customer/customer_select_address_screen.dart#L23-L79);
  operasi mutasi alamat berada di
  [`address_repository.dart`](../mobile/lib/repositories/address_repository.dart#L21-L64);
  FAQ berada di [`customer_help_center_screen.dart`](../mobile/lib/screens/customer/customer_help_center_screen.dart#L14-L35).
- **Catatan:** perubahan profil, alamat, notifikasi, dan password dummy hanya
  bertahan selama proses aplikasi berjalan; tidak diklaim sebagai persistence
  backend.

### F013 — Manajemen Tugas Servis

- **Status:** **Berjalan**.
- **Deskripsi:** Teknisi dapat membuka dashboard, melihat order masuk yang
  belum selesai/dibatalkan, menolak order dengan mengubah status menjadi
  `cancelled`, membuka pengelolaan order, dan melihat data pelanggan, kendala,
  alamat, serta peta/rute lokasi Batam dari order dummy.
- **Screen dan rute:** Dashboard menggunakan
  [`technician_dashboard_screen.dart`](../mobile/lib/screens/technician/technician_dashboard_screen.dart#L15)
  dan rute `/technician/dashboard`. Daftar masuk menggunakan
  [`technician_incoming_orders_screen.dart`](../mobile/lib/screens/technician/technician_incoming_orders_screen.dart#L8)
  dan rute `/technician/incoming-orders`. Detail menggunakan
  [`technician_order_detail_screen.dart`](../mobile/lib/screens/technician/technician_order_detail_screen.dart#L9)
  dan rute `/technician/order-detail`.
- **Interaksi dan validasi:** Daftar order dapat direfresh; tombol Tolak
  memanggil `updateStatus`; tombol Kelola Order membuka update status; detail
  mengambil order, biaya tambahan, dan katalog layanan.
- **Sumber data:** `OrderRepository.getOrders/getOrder/getAdditionalCosts`;
  order berasal dari `dummyOrders` lengkap di
  [`dummy_data.dart`](../mobile/lib/data/dummy/dummy_data.dart#L201-L297).
- **Bukti:** Filter order aktif berada di
  [`technician_incoming_orders_screen.dart`](../mobile/lib/screens/technician/technician_incoming_orders_screen.dart#L47-L69);
  tombol Tolak/Kelola berada di
  [`technician_incoming_orders_screen.dart`](../mobile/lib/screens/technician/technician_incoming_orders_screen.dart#L286-L326).
- **Catatan:** perubahan status dan order dummy tersimpan selama proses aplikasi
  berjalan; backend fase 2 belum menjadi sumber data pada mode dummy.

### F014 — Pembaruan Status Pengerjaan

- **Status:** **Berjalan**.
- **Deskripsi:** Teknisi dapat memilih status progres melalui screen update
  status atau slider pada detail order. Perubahan dipetakan ke status
  `accepted`, `on_the_way`, `in_progress`, atau `completed` dan disimpan pada
  state dummy repository.
- **Screen dan rute:** [`technician_update_status_screen.dart`](../mobile/lib/screens/technician/technician_update_status_screen.dart#L8)
  dengan rute `/technician/update-status`; detail order juga memperbarui
  status di [`technician_order_detail_screen.dart`](../mobile/lib/screens/technician/technician_order_detail_screen.dart#L510-L542).
- **Interaksi dan validasi:** Teknisi memilih salah satu status lalu menekan
  simpan, atau menggeser progres ke tahap berikutnya. Tombol/slider
  dinonaktifkan saat proses berjalan dan setelah selesai; SnackBar
  menampilkan hasil.
- **Sumber data:** `OrderRepository.updateStatus`; mode dummy menyimpan
  status pada static map `_dummyState` di
  [`order_repository.dart`](../mobile/lib/repositories/order_repository.dart#L64-L72).
- **Bukti:** Daftar label/status API berada di
  [`technician_update_status_screen.dart`](../mobile/lib/screens/technician/technician_update_status_screen.dart#L21-L35);
  submit update berada di
  [`technician_update_status_screen.dart`](../mobile/lib/screens/technician/technician_update_status_screen.dart#L181-L219).
- **Catatan:** Dua label UI terakhir sama-sama dipetakan ke `completed`, jadi
  “Pembayaran Diterima (Lunas)” dan “Pengerjaan Selesai” tidak menjadi dua
  status dummy yang berbeda.

### F015 — Komunikasi Lapangan

- **Status:** **Berjalan**.
- **Deskripsi:** Teknisi dapat melihat inbox dummy berisi minimal empat
  percakapan yang terhubung ke order, memfilter percakapan, membuka detail,
  memuat pesan, dan mengirim pesan. Pesan terakhir dan waktu diperbarui di
  memori setelah pengiriman.
- **Screen dan rute:** Inbox dan detail berada di
  [`technician_chat_screen.dart`](../mobile/lib/screens/technician/technician_chat_screen.dart#L12-L22)
  dan rute `/technician/chat`. Pemetaan inbox/detail berdasarkan argumen berada
  di [`route_generator.dart`](../mobile/lib/core/routes/route_generator.dart#L163-L184).
- **Interaksi dan validasi:** Inbox menyediakan pencarian dan filter “Semua”,
  “Aktif”, dan “Belum dibaca”. Detail memiliki input pesan, tombol kirim,
  loading, dan error feedback.
- **Sumber data:** `dummyTechnicianChats` menyediakan empat percakapan di
  [`dummy_data.dart`](../mobile/lib/data/dummy/dummy_data.dart#L422-L454).
  Inbox mengambilnya melalui `ChatRepository.getTechnicianChats`, sedangkan
  detail memakai `getOrderChat/sendMessage` di
  [`chat_repository.dart`](../mobile/lib/repositories/chat_repository.dart#L9-L56).
- **Bukti:** Pemanggilan inbox berada di
  [`technician_chat_screen.dart`](../mobile/lib/screens/technician/technician_chat_screen.dart#L42-L60);
  operasi kirim detail berada di
  [`technician_chat_screen.dart`](../mobile/lib/screens/technician/technician_chat_screen.dart#L552-L558).
- **Catatan:** route `/technician/chat` membuka inbox tanpa argumen. Dengan
  `orderId`, `customerName`, dan `orderDate`, route yang sama membuka detail
  percakapan; data pesan bertahan di memori selama proses aplikasi berjalan.

### F016 — Rincian Biaya Tambahan

- **Status:** **Berjalan**.
- **Deskripsi:** Teknisi dapat memasukkan nama sparepart dan harga positif.
  Item ditambahkan melalui `OrderRepository`, dibaca kembali dari
  `dummyAdditionalCosts`, dan ditampilkan lagi setelah reload detail.
- **Screen dan rute:** Form terpisah ada di
  [`technician_additional_cost_screen.dart`](../mobile/lib/screens/technician/technician_additional_cost_screen.dart#L5)
  dan rute `/technician/additional-cost`. Dialog detail order dipanggil dari
  [`technician_order_detail_screen.dart`](../mobile/lib/screens/technician/technician_order_detail_screen.dart#L642-L681).
- **Interaksi dan validasi:** Form memakai `Form`/`TextFormField`; nama wajib
  diisi dan harga harus berupa angka positif. Submit memanggil
  `addAdditionalCost`, lalu memuat ulang daftar biaya.
- **Sumber data:** `dummyAdditionalCosts` dibaca oleh
  `OrderRepository.getAdditionalCosts` dan ditambah oleh
  `OrderRepository.addAdditionalCost` di
  [`order_repository.dart`](../mobile/lib/repositories/order_repository.dart#L97-L148).
- **Bukti:** Submit form repository berada di
  [`technician_additional_cost_screen.dart`](../mobile/lib/screens/technician/technician_additional_cost_screen.dart#L45-L68);
  validasi berada di [baris 109-125](../mobile/lib/screens/technician/technician_additional_cost_screen.dart#L109-L125);
  perhitungan biaya pada detail berada di
  [`technician_order_detail_screen.dart`](../mobile/lib/screens/technician/technician_order_detail_screen.dart#L128-L144).

### F017 — Kelola Katalog & Harga

- **Status:** **Di luar aplikasi mobile**.
- **Deskripsi:** Tidak ada screen Admin mobile atau route mobile untuk
  mengelola katalog dan harga. Screen katalog yang ada adalah katalog layanan
  untuk pelanggan.
- **Screen/rute dan sumber data:** `CustomerCatalogScreen` hanya membaca
  `ServiceRepository.getServices`; route Admin tidak didefinisikan pada
  [`app_routes.dart`](../mobile/lib/core/routes/app_routes.dart#L1-L43).
- **Bukti:** Daftar route hanya memuat auth, customer, dan technician di
  [`app_routes.dart`](../mobile/lib/core/routes/app_routes.dart#L1-L43).
- **Belum terpenuhi:** seluruh pengelolaan katalog/harga Admin dilakukan atau
  direncanakan pada Web Admin, bukan aplikasi mobile.

### F018 — Pengelolaan Data Pengguna

- **Status:** **Di luar aplikasi mobile**.
- **Deskripsi:** Tidak ada screen atau route Admin mobile untuk mengelola
  pengguna. Aplikasi mobile hanya mengelola profil pengguna yang sedang login.
- **Bukti:** Tidak ada route Admin pada
  [`app_routes.dart`](../mobile/lib/core/routes/app_routes.dart#L1-L43);
  operasi profil mobile berada pada `ProfileRepository` di
  [`profile_repository.dart`](../mobile/lib/repositories/profile_repository.dart#L47-L75).
- **Belum terpenuhi:** pengelolaan seluruh data pengguna Admin berada di Web
  Admin, sesuai catatan kebutuhan.

### F019 — Monitoring Operasional Transaksi

- **Status:** **Di luar aplikasi mobile**.
- **Deskripsi:** Tidak ada dashboard monitoring Admin mobile. Pelanggan dan
  teknisi hanya melihat order sesuai screen masing-masing.
- **Bukti:** Route mobile yang tersedia tidak mendefinisikan dashboard Admin di
  [`app_routes.dart`](../mobile/lib/core/routes/app_routes.dart#L1-L43).
- **Belum terpenuhi:** monitoring operasional transaksi Admin tidak tersedia di
  aplikasi mobile.

### F020 — Laporan & Rekapitulasi

- **Status:** **Di luar aplikasi mobile**.
- **Deskripsi:** Tidak ada screen atau repository laporan Admin pada aplikasi
  mobile. `IncomeRepository` hanya menyediakan data order selesai untuk
  tampilan teknisi, bukan laporan Admin.
- **Bukti:** `IncomeRepository.getCompletedOrders` mengembalikan order selesai
  untuk mode dummy di
  [`income_repository.dart`](../mobile/lib/repositories/income_repository.dart#L7-L27);
  tidak ada route laporan Admin pada
  [`app_routes.dart`](../mobile/lib/core/routes/app_routes.dart#L1-L43).
- **Belum terpenuhi:** laporan dan rekapitulasi Admin berada di Web Admin.

## 4. Alur end-to-end yang tersedia

### Alur Pelanggan

Alur normal yang tersedia di mobile:

1. `SplashScreen` memeriksa session dan mengarahkan pengguna ke landing atau
   dashboard sesuai session di [`splash_screen.dart`](../mobile/lib/screens/auth/splash_screen.dart#L28-L47).
2. `LandingScreen` → `LoginScreen` (`/login`).
3. Login memakai akun dummy pelanggan → `CustomerHomeScreen`
   (`/customer/home`).
4. Home → `CustomerCatalogScreen` (`/customer/catalog`).
5. Pilih layanan → `CustomerServiceDetailScreen`
   (`/customer/service-detail`).
6. Tekan pesan → `CustomerBookingSummaryScreen`
   (`/customer/booking-summary`).
7. Pilih alamat melalui `CustomerSelectAddressScreen`
   (`/customer/select-address`), lalu tanggal, waktu, jenis kerusakan, dan
   catatan.
8. Lanjut → `CustomerPaymentScreen` (`/customer/payment`).
9. Pilih QRIS, Transfer Bank, atau Tunai/COD dan konfirmasi.
10. `OrderRepository.createOrder` menambah order ke dummy memory dan aplikasi
    membuka `CustomerOrderTrackingScreen` (`/customer/order-tracking`).
11. Riwayat tersedia di `CustomerOrderHistoryScreen`
    (`/customer/order-history`).
12. Dari menu chat pelanggan, pilih percakapan untuk membuka
    `AppRoutes.customerChatDetail` (`/customer/chat/detail`), baca pesan, dan
    kirim pesan melalui `ChatRepository`.
13. Jika order berstatus selesai, tombol review membuka `CustomerReviewScreen`
    (`/customer/review`), lalu ulasan disimpan ke memory `ReviewRepository`.

### Alur Teknisi

Alur teknisi yang tersedia atau sebagian tersedia:

1. `SplashScreen` atau `LoginScreen` mengarahkan akun teknisi ke
   `TechnicianDashboardScreen` (`/technician/dashboard`).
2. Dashboard mengambil order dari `OrderRepository` dan menampilkan peta,
   order aktif, serta tombol menuju `TechnicianIncomingOrdersScreen`
   (`/technician/incoming-orders`).
3. Daftar order aktif menampilkan order dummy yang belum completed/cancelled.
4. Teknisi dapat menolak order; status disimpan sebagai `cancelled`.
5. Teknisi dapat membuka `TechnicianUpdateStatusScreen`
   (`/technician/update-status`) untuk memilih status.
6. Status berubah melalui `OrderRepository.updateStatus` ke
   `accepted`, `on_the_way`, `in_progress`, atau `completed`.
7. `TechnicianOrderDetailScreen` (`/technician/order-detail`) menampilkan
   progres, layanan, biaya yang tersedia, dan kontrol status.
8. Detail memiliki form/dialog biaya tambahan. Submit memvalidasi nama dan
   harga positif, lalu `OrderRepository.addAdditionalCost` menyimpan item ke
   `dummyAdditionalCosts`; item dibaca kembali saat detail dimuat ulang.
9. Inbox chat teknisi (`/technician/chat`) memuat minimal empat percakapan
   dummy yang terhubung ke order. Detail chat dapat mengirim pesan dan
   memperbarui pesan terakhir di inbox selama proses aplikasi berjalan.

## 5. Akun dummy dan cara menjalankan

### Akun dummy

| Peran | Email | Password | Data |
|---|---|---|---|
| Pelanggan | `dewi@example.com` | `password123` | Dewi Lestari |
| Teknisi | `agus.teknisi@klikkompor.com` | `password123` | Andi Saputra |
| Admin | — | — | Login Admin mobile ditolak dan menampilkan pesan untuk memakai Web Admin |

Data akun berada di
[`dummy_data.dart`](../mobile/lib/data/dummy/dummy_data.dart#L74-L127), sedangkan
pencocokan login berada di
[`auth_service.dart`](../mobile/lib/services/auth_service.dart#L22-L39).

### Menjalankan aplikasi

Dari root repository:

```powershell
cd mobile
flutter pub get
flutter run
```

Mode dummy aktif secara konstan pada
[`app_config.dart`](../mobile/lib/core/config/app_config.dart#L1-L6):

```dart
static const bool useDummyData = true;
```

Verifikasi terakhir yang dicatat untuk aplikasi mobile menghasilkan 68 test
lulus, termasuk 54 kombinasi pada
[`responsive_test.dart`](../mobile/test/responsive_test.dart#L1-L220) dan test
repository/filter/password pada folder
[`test/`](../mobile/test/).

Daftar test yang tercatat:

| File | Jumlah |
|---|---:|
| `auth_repository_test.dart` | 2 |
| `filter_and_password_test.dart` | 2 |
| `order_repository_test.dart` | 1 |
| `repository_dummy_test.dart` | 4 |
| `validators_test.dart` | 4 |
| `widget_test.dart` | 1 |
| `responsive_test.dart` | 54 |
| **Total** | **68** |

## 6. Kebutuhan yang belum terpenuhi sepenuhnya

1. **F001:** login dummy hanya menerima email dummy tertentu; username/nomor
   telepon tidak benar-benar dipakai. Batasan ini bergantung pada backend fase
   2; bagian Admin juga berada di luar aplikasi mobile.
2. **F002:** tidak ada field username terpisah pada registrasi. Penambahan
   identitas username bergantung pada skema backend fase 2.
3. **F003:** email reset tidak benar-benar dikirim; token dan validasi reset
   disimulasikan di memori. Pengiriman email sungguhan bergantung pada layanan
   backend fase 2.
4. **F005:** katalog dummy hanya layanan servis, bukan produk pendukung dengan
   kategori produk. Katalog produk bergantung pada data dan API fase 2.
5. **F017–F020:** fungsi Admin berada di Web Admin dan tidak tersedia sebagai
   fitur aplikasi mobile; implementasinya bergantung pada dashboard dan backend
   fase 2.

Dokumen ini tidak menyatakan seluruh kebutuhan SKPPL sudah selesai; status
**Sebagian** dan **Di luar aplikasi mobile** di atas merupakan batasan yang
terlihat langsung dari implementasi saat ini.

## 7. Kesimpulan

Pada mode dummy, alur utama pelanggan tersedia dari login, eksplorasi layanan,
booking, pembayaran, tracking, chat, sampai ulasan. Alur teknisi tersedia untuk
melihat dan mengelola order, memperbarui status, menambah biaya, serta
berkomunikasi melalui inbox dan detail chat. F001, F002, F003, dan F005 masih
berstatus Sebagian karena batasan yang dijelaskan; F017–F020 berada di luar
aplikasi mobile. Dokumen ini tidak menyatakan seluruh kebutuhan SKPPL telah
selesai.
