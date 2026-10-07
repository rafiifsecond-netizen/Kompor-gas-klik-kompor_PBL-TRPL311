import 'package:intl/intl.dart';

class AppConstants {
  static const String appName = 'KlikKompor';
  static const String appTagline = 'Solusi Servis Kompor Gas Cepat & Terpercaya';

  // Storage Keys
  static const String keyToken = 'klikkompor_token';
  static const String keyUser = 'klikkompor_user';
  static const String keyBaseUrl = 'klikkompor_custom_base_url';

  // User Roles
  static const String roleCustomer = 'customer';
  static const String roleTechnician = 'technician';
  static const String roleAdmin = 'admin';

  // Order Status Constants
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusOnTheWay = 'on_the_way';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Indonesian Status Labels
  static const Map<String, String> statusLabels = {
    statusPending: 'Menunggu Konfirmasi',
    statusAccepted: 'Pesanan Diterima',
    statusOnTheWay: 'Teknisi Menuju Lokasi',
    statusInProgress: 'Pengerjaan Berlangsung',
    statusCompleted: 'Selesai',
    statusCancelled: 'Dibatalkan',
  };

  // Payment Status Labels
  static const Map<String, String> paymentStatusLabels = {
    'unpaid': 'Belum Dibayar',
    'paid': 'Lunas',
    'refunded': 'Dikembalikan',
  };

  // Rupiah Currency Formatter
  static String formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final num value = amount is num ? amount : (num.tryParse(amount.toString()) ?? 0);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  // Indonesian Date/Time Formatter
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dateTime);
  }

  static String formatTimeOnly(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('HH:mm', 'id_ID').format(dateTime);
  }
}
