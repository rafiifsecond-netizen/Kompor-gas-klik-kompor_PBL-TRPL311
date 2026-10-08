import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../services/storage_service.dart';

class CustomerPaymentScreen extends StatefulWidget {
  const CustomerPaymentScreen({super.key});

  @override
  State<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<CustomerPaymentScreen> {
  String _selectedMethod = 'cash'; // 'cash', 'bank', or 'qris'
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final String date = args['date'] as String? ?? 'Sab, 16 September 2026';
    final String time = args['time'] as String? ?? '09:00 - 12:00';
    final String address = args['address'] as String? ?? 'Jl. Geriya KPN No. 77';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 32, color: Colors.black),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Pembayaran',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Section: Metode Pembayaran ─────────────────────────
                    Text(
                      'Metode Pembayaran',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card Box Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
                      ),
                      child: Column(
                        children: [
                          // 1. Tunai (Bayar di tempat)
                          _buildOptionRow(
                            id: 'cash',
                            title: 'Tunai (Bayar di tempat)',
                            iconWidget: const Icon(Icons.payments_outlined, size: 28, color: Colors.black),
                            isTop: true,
                          ),
                          const Divider(color: Color(0xFFD9D9D9), height: 1, thickness: 1),

                          // 2. Transfer Bank
                          _buildOptionRow(
                            id: 'bank',
                            title: 'Transfer Bank',
                            iconWidget: const Icon(Icons.account_balance_outlined, size: 28, color: Colors.black),
                          ),
                          const Divider(color: Color(0xFFD9D9D9), height: 1, thickness: 1),

                          // 3. Qris
                          _buildOptionRow(
                            id: 'qris',
                            title: 'Qris',
                            iconWidget: _buildQrisBadge(),
                            isBottom: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Section: Ringkasan Pesanan ─────────────────────────
                    Text(
                      'Ringkasan Pesanan',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ellipse Avatar (69x69)
                        Container(
                          width: 69,
                          height: 69,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E293B),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Icon(
                              Icons.person_rounded,
                              size: 42,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Service Name & Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service Kompor Gas',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$date | $time',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF5D5555),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Alamar: ${address.contains(',') ? address.split(',').first : address}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF5D5555),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // ── Section: Total Estimasi ─────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Estimasi',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5D5555),
                          ),
                        ),
                        Text(
                          'Rp 90.000',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5D5555),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // ── Section: Button Konfirmasi Pembayaran ───────────────
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                setState(() => _isProcessing = true);
                                final nav = Navigator.of(context);

                                try {
                                  final token = StorageService.getToken();
                                  if (token != null && token.isNotEmpty) {
                                    // Submit real order to Laravel API database
                                    await ApiClient().post(
                                      ApiEndpoints.orders,
                                      data: {
                                        'scheduled_at': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
                                        'address': address,
                                        'problem_description': args['damageType'] ?? 'Service Kompor Gas',
                                        'payment_method': _selectedMethod == 'bank' ? 'transfer' : _selectedMethod,
                                        'services': [
                                          {'service_item_id': 1, 'quantity': 1}
                                        ],
                                      },
                                    );
                                  }
                                } catch (_) {
                                  // Fallback gracefully for demo/guest mode
                                }

                                if (!mounted) return;
                                setState(() => _isProcessing = false);
                                nav.pushNamedAndRemoveUntil(
                                  AppRoutes.customerOrderTracking,
                                  (r) => r.settings.name == AppRoutes.customerHome,
                                  arguments: args,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(29),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : Text(
                                'Konfirmasi Pembayaran',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required String id,
    required String title,
    required Widget iconWidget,
    bool isTop = false,
    bool isBottom = false,
  }) {
    final isSelected = _selectedMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      borderRadius: BorderRadius.vertical(
        top: isTop ? const Radius.circular(18) : Radius.zero,
        bottom: isBottom ? const Radius.circular(18) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: isTop ? const Radius.circular(18) : Radius.zero,
            bottom: isBottom ? const Radius.circular(18) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 32, height: 32, child: Center(child: iconWidget)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: isSelected ? const Color(0xFFFF7A00) : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrisBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'QRIS',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.black,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
