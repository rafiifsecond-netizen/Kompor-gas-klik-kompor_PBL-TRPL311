import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/route_args.dart';
import '../../repositories/address_repository.dart';
import '../../repositories/order_repository.dart';
import '../../repositories/payment_repository.dart';
import '../../core/utils/app_feedback.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class CustomerPaymentScreen extends StatefulWidget {
  const CustomerPaymentScreen({super.key});

  @override
  State<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<CustomerPaymentScreen> {
  final _repository = OrderRepository();
  final _paymentRepo = PaymentRepository();
  final _promoController = TextEditingController();

  String _selectedMethod = 'cash'; // 'cash', 'bank', or 'qris'
  bool _isProcessing = false;
  bool _isValidatingPromo = false;
  String? _appliedPromoCode;
  double _discountAmount = 0.0;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  /// Extracts numeric amount from various string / int formats
  double _parseRupiah(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final digits = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(digits) ?? 0;
  }

  String _formatRupiah(num value) {
    return AppConstants.formatCurrency(value).replaceFirst('Rp ', '');
  }

  /// Resolve coordinates from arguments, default address, or device GPS
  Future<Map<String, double?>> _resolveCoordinates(
      Map<String, dynamic> args) async {
    var lat = double.tryParse(args['latitude']?.toString() ?? '');
    var lng = double.tryParse(args['longitude']?.toString() ?? '');
    if (lat != null && lng != null) {
      return {'latitude': lat, 'longitude': lng};
    }

    try {
      final rows = await AddressRepository().getAddresses();
      if (rows.isNotEmpty) {
        final preferred = rows.firstWhere(
          (row) =>
              row['is_default'] == true ||
              row['is_default'] == 1 ||
              row['is_default'] == '1',
          orElse: () => rows.first,
        );
        lat = double.tryParse(preferred['latitude']?.toString() ?? '');
        lng = double.tryParse(preferred['longitude']?.toString() ?? '');
        if (lat != null && lng != null) {
          return {'latitude': lat, 'longitude': lng};
        }
      }
    } catch (_) {}

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition();
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      }
    } catch (_) {}

    return {'latitude': null, 'longitude': null};
  }

  Future<void> _validateAndApplyPromo() async {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() {
      _isValidatingPromo = false;
      _appliedPromoCode = code;
      _discountAmount = 0;
    });
    if (mounted) {
      AppFeedback.success(
        context,
        'Promo akan divalidasi saat checkout berdasarkan data pesanan.',
      );
    }
  }

  Future<void> _handlePaymentConfirmation(
    Map<String, dynamic> args,
    String address,
    dynamic serviceId,
    double estimatedTotal,
  ) async {
    // 1. Validasi Alamat
    var validAddress = address.trim();
    var lat = double.tryParse(args['latitude']?.toString() ?? '');
    var lng = double.tryParse(args['longitude']?.toString() ?? '');

    if (validAddress.isEmpty) {
      try {
        final rows = await AddressRepository().getAddresses();
        if (rows.isNotEmpty) {
          final preferred = rows.firstWhere(
            (row) =>
                row['is_default'] == true ||
                row['is_default'] == 1 ||
                row['is_default'] == '1',
            orElse: () => rows.first,
          );
          validAddress = preferred['full_address']?.toString() ?? '';
          lat ??= double.tryParse(preferred['latitude']?.toString() ?? '');
          lng ??= double.tryParse(preferred['longitude']?.toString() ?? '');
        }
      } catch (_) {}
    }

    if (validAddress.isEmpty) {
      if (mounted) {
        AppFeedback.error(
          context,
          'Alamat layanan belum dipilih. Silakan kembali untuk memilih alamat.',
        );
      }
      return;
    }

    // 2. Fallback Service ID jika belum terisi
    var validServiceId = serviceId;
    if (validServiceId == null) {
      try {
        final res = await _repository.getServices();
        if (res is Map && res['data'] is List && (res['data'] as List).isNotEmpty) {
          validServiceId = (res['data'] as List).first['id'];
        }
      } catch (_) {}
      if (validServiceId == null) {
        if (mounted) {
          AppFeedback.error(
            context,
            'Layanan belum tersedia. Silakan pilih layanan yang valid.',
          );
        }
        return;
      }
    }

    if (!mounted) return;
    final nav = Navigator.of(context);
    setState(() => _isProcessing = true);
    Map<String, dynamic>? createdOrder;

    try {
      final coords = await _resolveCoordinates({
        ...args,
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
      });

      final scheduledAt = args['scheduled_at'] ??
          DateTime.now().add(const Duration(days: 1)).toIso8601String();

      final problemDesc = args['damageType']?.toString().isNotEmpty == true
          ? '${args['damageType']}${(args['notes'] as String?)?.trim().isNotEmpty == true ? ': ${args['notes']}' : ''}'
          : 'Permintaan servis kompor gas';

      final backendPaymentMethod = _selectedMethod;

      final res = await _repository.createOrder({
        'scheduled_at': scheduledAt,
        'address': validAddress,
        'latitude': coords['latitude'],
        'longitude': coords['longitude'],
        'problem_description': problemDesc,
        'payment_method': backendPaymentMethod,
        'technician_id': args['technician_id'],
        'services': [
          {
            'service_item_id': validServiceId,
            'quantity': 1,
          }
        ],
      });

      if (res is Map && res['data'] != null) {
        createdOrder = Map<String, dynamic>.from(res['data'] as Map);
      }
    } catch (e) {
      debugPrint('Order creation error: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        AppFeedback.error(
          context,
          'Gagal memproses pesanan: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isProcessing = false);

    final orderId = createdOrder?['id'] as int? ?? 0;
    final targetOrderData = createdOrder ?? {
      ...args,
      'address': validAddress,
      'payment_method': _selectedMethod,
    };

    if (_selectedMethod == 'qris') {
      try {
        final payRes = await _paymentRepo.checkout(
          orderId: orderId,
          paymentMethod: 'qris',
          promoCode: _appliedPromoCode,
        );
        if (mounted && payRes is Map && payRes['data'] != null) {
          final paymentData = payRes['data']['payment'] as Map<String, dynamic>;
          final qrisData = payRes['data']['qris'] as Map<String, dynamic>?;
          final qrString = qrisData?['qr_string']?.toString() ??
              paymentData['qris_qr_string']?.toString() ??
              '';
          if (qrString.isEmpty) {
            throw Exception('QRIS resmi belum tersedia dari gateway pembayaran.');
          }
          final payId = paymentData['id'] as int;
          final payAmount = (paymentData['amount'] as num).toDouble();

          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            backgroundColor: Colors.transparent,
            builder: (ctx) => _QrisModalSheet(
              paymentId: payId,
              qrString: qrString,
              amount: payAmount,
              onSuccess: () {
                Navigator.of(ctx).pop();
                nav.pushNamedAndRemoveUntil(
                  AppRoutes.customerOrderTracking,
                  (r) => r.settings.name == AppRoutes.customerHome,
                  arguments: targetOrderData,
                );
              },
              onDismiss: () {
                Navigator.of(ctx).pop();
                nav.pushNamedAndRemoveUntil(
                  AppRoutes.customerOrderTracking,
                  (r) => r.settings.name == AppRoutes.customerHome,
                  arguments: targetOrderData,
                );
              },
            ),
          );
          return;
        }
      } catch (e) {
        debugPrint('Checkout QRIS error: $e');
        if (mounted) {
          final message = e.toString().replaceAll('Exception: ', '');
          final userMessage = message.contains('401') ||
                  message.toLowerCase().contains('unauthorized')
              ? 'QRIS belum dapat dimuat karena Server Key Midtrans tidak aktif. Silakan hubungi admin.'
              : message.contains('QRIS resmi')
                  ? message
                  : 'Pembayaran QRIS gagal dibuat: $message';
          AppFeedback.error(
            context,
            userMessage,
          );
        }
        return;
      }
    } else {
      // Cash
      try {
        await _paymentRepo.checkout(
          orderId: orderId,
          paymentMethod: 'cash',
          promoCode: _appliedPromoCode,
        );
      } catch (e) {
        debugPrint('Checkout Cash error: $e');
        if (mounted) {
          AppFeedback.error(
            context,
            'Pembayaran tunai gagal dibuat. Silakan coba lagi.',
          );
        }
        return;
      }
    }

    if (!mounted) return;

    AppFeedback.success(
      context,
      _selectedMethod == 'cash'
          ? 'Pesanan berhasil dibuat! Bayar tunai ke teknisi saat servis selesai.'
          : 'Pesanan berhasil dibuat! Silakan selesaikan pembayaran.',
    );

    nav.pushNamedAndRemoveUntil(
      AppRoutes.customerOrderTracking,
      (r) => r.settings.name == AppRoutes.customerHome,
      arguments: targetOrderData,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = RouteArgs.map(context) ?? <String, dynamic>{};
    final String date = args['date'] as String? ?? 'Besok';
    final String time = args['time'] as String? ?? '09:00 - 12:00';
    final String address = (args['address'] as String? ?? '').trim();
    final String serviceName =
        args['service_name'] as String? ?? 'Servis Kompor Gas';
    final dynamic serviceId = args['service_id'];

    final total = double.tryParse(args['total_amount']?.toString() ?? '') ??
        double.tryParse(args['totalAmount']?.toString() ?? '') ??
        0;
    final basePrice = total > 0
        ? total
        : _parseRupiah(args['price'] ?? args['priceRange']);
    final effectiveBase = basePrice;
    final transportFee = _parseRupiah(args['transport_fee']);
    final estimatedTotal = (effectiveBase - _discountAmount).clamp(0.0, double.infinity) + transportFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Pembayaran',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEEEEEE), height: 1),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Section 1: Ringkasan Layanan ───────────────────────
                        _buildSectionHeader(
                          title: 'Ringkasan Layanan',
                          icon: Icons.receipt_long_rounded,
                        ),
                        const SizedBox(height: 10),
                        _buildOrderSummaryCard(
                          serviceName: serviceName,
                          date: date,
                          time: time,
                          address: address,
                        ),

                        const SizedBox(height: 22),

                        // ── Section 2: Pilihan Metode Pembayaran ───────────────
                        _buildSectionHeader(
                          title: 'Pilih Metode Pembayaran',
                          icon: Icons.payment_rounded,
                        ),
                        const SizedBox(height: 10),
                        _buildPaymentMethodsCard(),

                        const SizedBox(height: 14),

                        // ── Section 2b: Dynamic Details (QRIS / Bank / Cash) ───
                        if (_selectedMethod == 'qris')
                          _buildQrisInstructionCard(estimatedTotal)
                        else
                          _buildCashInstructionCard(),

                        const SizedBox(height: 22),

                        // ── Section 3: Kupon Promo ────────────────────────────
                        _buildSectionHeader(
                          title: 'Kupon Promo',
                          icon: Icons.confirmation_num_outlined,
                        ),
                        const SizedBox(height: 10),
                        _buildPromoCard(),

                        const SizedBox(height: 22),

                        // ── Section 4: Rincian Biaya Transparan ────────────────
                        _buildSectionHeader(
                          title: 'Rincian Biaya',
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                        const SizedBox(height: 10),
                        _buildCostBreakdownCard(effectiveBase, transportFee, estimatedTotal),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── Bottom Fixed Confirmation Bar ──────────────────────────────
                _buildBottomActionBar(args, address, serviceId, estimatedTotal),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummaryCard({
    required String serviceName,
    required String date,
    required String time,
    required String address,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.paleOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.handyman_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '$date ($time)',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F2F4)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address.isNotEmpty
                      ? address
                      : 'Alamat utama (otomatis digunakan dari data profil)',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: address.isNotEmpty
                        ? AppColors.textSecondary
                        : AppColors.primaryDark,
                    fontStyle: address.isNotEmpty
                        ? FontStyle.normal
                        : FontStyle.italic,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMethodRadioTile(
            id: 'cash',
            title: 'Tunai (Bayar di Tempat)',
            subtitle: 'Bayar uang pas langsung ke teknisi seusai kompor selesai diperbaiki',
            icon: Icons.payments_rounded,
            iconColor: const Color(0xFF16A34A),
            isFirst: true,
          ),
          const Divider(height: 1, color: Color(0xFFF1F2F4)),
          _buildMethodRadioTile(
            id: 'qris',
            title: 'QRIS Instan',
            subtitle: 'Scan kode QRIS dari GoPay, OVO, Dana, ShopeePay, atau m-Banking',
            badge: _buildQrisLogoWidget(width: 50, height: 22),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMethodRadioTile({
    required String id,
    required String title,
    required String subtitle,
    IconData? icon,
    Color? iconColor,
    Widget? badge,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = _selectedMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(14) : Radius.zero,
        bottom: isLast ? const Radius.circular(14) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(14) : Radius.zero,
            bottom: isLast ? const Radius.circular(14) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
              ),
              child: Center(
                child: badge ??
                    Icon(icon, size: 22, color: iconColor ?? Colors.black87),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFD1D5DB),
                  width: isSelected ? 5 : 2,
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrisInstructionCard(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pembayaran QRIS Midtrans',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildQrisLogoWidget(width: 68, height: 28),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Setelah mengonfirmasi pesanan, QR Code resmi Midtrans akan dimuat otomatis dengan batas waktu pembayaran 15 menit dan verifikasi lunas real-time.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildCashInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: Color(0xFF16A34A), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Anda tidak perlu membayar sekarang. Siapkan uang pas saat teknisi datang dan telah menyelesaikan pengecekan atau perbaikan kompor gas Anda.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF166534),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _appliedPromoCode != null ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_appliedPromoCode != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF16A34A)),
                      const SizedBox(width: 6),
                      Text(
                        'Promo ${_appliedPromoCode!} Aktif (-Rp ${_formatRupiah(_discountAmount)})',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _appliedPromoCode = null;
                        _discountAmount = 0.0;
                        _promoController.clear();
                      });
                    },
                    child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF166534)),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _promoController,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Kode promo (contoh: HEMAT20)',
                        hintStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 96,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _isValidatingPromo ? null : _validateAndApplyPromo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: _isValidatingPromo
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Terapkan', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCostBreakdownCard(
    double basePrice,
    double transportFee,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildCostRow('Biaya Servis Dasar', 'Rp ${_formatRupiah(basePrice)}'),
          if (_discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildCostRow('Diskon Kupon Promo', '-Rp ${_formatRupiah(_discountAmount)}', isGreen: true),
          ],
          const SizedBox(height: 8),
          _buildCostRow(
              'Ongkos Transport Teknisi', 'Rp ${_formatRupiah(transportFee)}'),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F2F4)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total Pembayaran',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Rp ${_formatRupiah(total)}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, String amount, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
                fontSize: 12.5, color: isGreen ? const Color(0xFF16A34A) : AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isGreen ? const Color(0xFF16A34A) : Colors.black87),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(
    Map<String, dynamic> args,
    String address,
    dynamic serviceId,
    double estimatedTotal,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Tagihan',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Rp ${_formatRupiah(estimatedTotal)}',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () => _handlePaymentConfirmation(
                          args,
                          address,
                          serviceId,
                          estimatedTotal,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _selectedMethod == 'cash'
                            ? 'Pesan Sekarang'
                            : 'Konfirmasi Bayar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Menampilkan logo QRIS asli yang diunggah pengguna
  Widget _buildQrisLogoWidget({
    double width = 52,
    double height = 22,
    bool isWhiteBackground = false,
  }) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: isWhiteBackground ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Image.asset(
        'assets/images/qris_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/qris_logo.webp',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Center(
                  child: Text(
                    'QRIS',
                    style: GoogleFonts.inter(
                      fontSize: height * 0.45,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QRIS PAYMENT MODAL SHEET (Live Countdown, QrImageView, Polling & Auto-Resolve)
// ─────────────────────────────────────────────────────────────────────────────
class _QrisModalSheet extends StatefulWidget {
  final int paymentId;
  final String qrString;
  final double amount;
  final VoidCallback onSuccess;
  final VoidCallback onDismiss;

  const _QrisModalSheet({
    required this.paymentId,
    required this.qrString,
    required this.amount,
    required this.onSuccess,
    required this.onDismiss,
  });

  @override
  State<_QrisModalSheet> createState() => _QrisModalSheetState();
}

class _QrisModalSheetState extends State<_QrisModalSheet> {
  final _paymentRepo = PaymentRepository();
  Timer? _countdownTimer;
  Timer? _pollingTimer;
  int _secondsLeft = 900; // 15 minutes
  bool _isPaid = false;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  void _startTimers() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
          _isExpired = true;
        });
      } else {
        setState(() => _secondsLeft--);
      }
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted || _isPaid || _isExpired) return;
      try {
        final statusRes = await _paymentRepo.getPaymentStatus(widget.paymentId);
        if (statusRes is Map && statusRes['data'] != null) {
          final status = statusRes['data']['payment_status']?.toString();
          if (status == 'paid') {
            timer.cancel();
            _countdownTimer?.cancel();
            if (mounted) {
              setState(() => _isPaid = true);
              Future.delayed(const Duration(milliseconds: 1000), widget.onSuccess);
            }
          } else if (status == 'expired' || statusRes['data']['is_expired'] == true) {
            timer.cancel();
            _countdownTimer?.cancel();
            if (mounted) setState(() => _isExpired = true);
          }
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatRupiah(num value) {
    return AppConstants.formatCurrency(value).replaceFirst('Rp ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pembayaran QRIS',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isExpired ? Colors.red.shade50 : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isExpired ? Colors.red.shade200 : AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: _isExpired ? Colors.red : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isExpired ? 'Kedaluwarsa' : _formatTimer(_secondsLeft),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _isExpired ? Colors.red : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total Bayar: Rp ${_formatRupiah(widget.amount)}',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          if (_isPaid) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 54),
                  const SizedBox(height: 12),
                  Text(
                    'Pembayaran Berhasil Diverifikasi!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_isExpired) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                  const SizedBox(height: 10),
                  Text(
                    'Waktu pembayaran telah habis',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: widget.qrString,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Buka aplikasi e-Wallet atau m-Banking Anda, pilih Scan QRIS dan arahkan ke kode QR di atas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: widget.onDismiss,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Text(
                _isPaid ? 'Lihat Status Pesanan' : 'Selesaikan Nanti (Cek Riwayat)',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
