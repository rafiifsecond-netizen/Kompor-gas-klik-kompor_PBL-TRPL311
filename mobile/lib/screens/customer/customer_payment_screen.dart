import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/route_args.dart';
import '../../repositories/address_repository.dart';
import '../../repositories/order_repository.dart';
import '../../core/utils/app_feedback.dart';
import '../../core/constants/app_colors.dart';

class CustomerPaymentScreen extends StatefulWidget {
  const CustomerPaymentScreen({super.key});

  @override
  State<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<CustomerPaymentScreen> {
  final _repository = OrderRepository();
  String _selectedMethod = 'cash'; // 'cash', 'bank', or 'qris'
  bool _isProcessing = false;

  // Selected Bank for Transfer
  String _selectedBank = 'BCA';
  final Map<String, Map<String, String>> _bankDetails = {
    'BCA': {
      'number': '8040 1234 5678 90',
      'holder': 'PT KLIK KOMPOR INDONESIA',
    },
    'Mandiri': {
      'number': '123 00 9876 5432 1',
      'holder': 'PT KLIK KOMPOR INDONESIA',
    },
    'BRI': {
      'number': '0341 01 002345 50 8',
      'holder': 'PT KLIK KOMPOR INDONESIA',
    },
    'BNI': {
      'number': '0987 6543 21',
      'holder': 'PT KLIK KOMPOR INDONESIA',
    },
  };

  /// Extracts numeric amount from various string / int formats
  double _parseRupiah(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final digits = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(digits) ?? 0;
  }

  String _formatRupiah(num value) {
    final str = value.toStringAsFixed(0);
    return str.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
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
      validServiceId ??= 2; // Default fallback to available service ID 2
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

      final backendPaymentMethod =
          _selectedMethod == 'bank' ? 'transfer' : _selectedMethod;

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

    AppFeedback.success(
      context,
      _selectedMethod == 'cash'
          ? 'Pesanan berhasil dibuat! Bayar tunai ke teknisi saat servis selesai.'
          : 'Pesanan berhasil dibuat! Silakan selesaikan pembayaran.',
    );

    nav.pushNamedAndRemoveUntil(
      AppRoutes.customerOrderTracking,
      (r) => r.settings.name == AppRoutes.customerHome,
      arguments: createdOrder ??
          {
            ...args,
            'address': validAddress,
            'payment_method': _selectedMethod,
          },
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
    final effectiveBase = basePrice > 0 ? basePrice : 95000.0;
    const transportFee = 15000.0;
    final estimatedTotal = effectiveBase + transportFee;

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
                        else if (_selectedMethod == 'bank')
                          _buildBankTransferInstructionCard()
                        else
                          _buildCashInstructionCard(),

                        const SizedBox(height: 22),

                        // ── Section 3: Rincian Biaya Transparan ────────────────
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
          ),
          const Divider(height: 1, color: Color(0xFFF1F2F4)),
          _buildMethodRadioTile(
            id: 'bank',
            title: 'Transfer Bank Virtual Account',
            subtitle: 'Transfer via BCA, Mandiri, BRI, atau BNI Virtual Account',
            icon: Icons.account_balance_rounded,
            iconColor: const Color(0xFF2563EB),
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
                        'Pembayaran QRIS',
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
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                // Header Banner di atas QR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQrisLogoWidget(
                        width: 52,
                        height: 20,
                        isWhiteBackground: true,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PEMBAYARAN STANDAR NASIONAL',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // QR Code Container dengan Logo QRIS di tengahnya
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_2_rounded,
                        size: 170,
                        color: Colors.black87,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: _buildQrisLogoWidget(width: 44, height: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'NMID: ID1020268877665',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'A.n. PT KLIK KOMPOR INDONESIA',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Buka aplikasi e-wallet (GoPay, OVO, Dana, ShopeePay) atau m-Banking Anda, lalu scan kode QR di atas untuk menyelesaikan pembayaran senilai Rp ${_formatRupiah(total)}.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferInstructionCard() {
    final currentBank = _bankDetails[_selectedBank] ?? _bankDetails['BCA']!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Bank Tujuan:',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _bankDetails.keys.map((bankName) {
                final isCurrent = _selectedBank == bankName;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(bankName),
                    selected: isCurrent,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedBank = bankName);
                    },
                    selectedColor: const Color(0xFFDBEAFE),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent
                          ? const Color(0xFF1D4ED8)
                          : Colors.black87,
                    ),
                    side: BorderSide(
                      color: isCurrent
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nomor Rekening Virtual Account:',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        currentBank['number']!,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: currentBank['number']!));
                        AppFeedback.success(
                            context, 'Nomor rekening disalin ke clipboard');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.copy_rounded,
                                size: 16, color: Color(0xFF2563EB)),
                            const SizedBox(width: 4),
                            Text(
                              'Salin',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  currentBank['holder']!,
                  style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
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

  Widget _buildCostRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
                fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
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
