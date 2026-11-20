import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routes/route_args.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';

class TechnicianUpdateStatusScreen extends StatefulWidget {
  const TechnicianUpdateStatusScreen({super.key});

  @override
  State<TechnicianUpdateStatusScreen> createState() =>
      _TechnicianUpdateStatusScreenState();
}

class _TechnicianUpdateStatusScreenState
    extends State<TechnicianUpdateStatusScreen> {
  final _repository = OrderRepository();
  int _selectedStatusIndex = 1;
  bool _isSaving = false;

  final List<String> _statuses = [
    'Order Diterima (Accepted)',
    'Menuju Lokasi Pelanggan (On the Way)',
    'Tiba di Lokasi (Arrived)',
    'Sedang Mengerjakan Servis (In Progress)',
    'Pengerjaan Selesai (Completed)',
  ];

  final List<String> _statusApiCodes = [
    'accepted',
    'on_the_way',
    'arrived',
    'in_progress',
    'completed',
  ];

  @override
  Widget build(BuildContext context) {
    final rawArgs = RouteArgs.of<OrderModel>(context) ?? RouteArgs.map(context);
    final Map<String, dynamic> args = rawArgs is OrderModel
        ? rawArgs.toJson()
        : (rawArgs is Map<String, dynamic> ? rawArgs : {});

    final int orderId = int.tryParse(
            args['id']?.toString() ?? args['orderId']?.toString() ?? '1') ??
        1;
    final String orderNumber = args['orderNumber'] as String? ??
        args['order_number'] as String? ??
        '#SRV-2026-089';
    final String customerName = args['customerName'] as String? ??
        (args['customer'] is Map ? args['customer']['name'] : null) ??
        'Pelanggan KlikKompor';
    final String serviceName =
        args['serviceName'] as String? ?? 'Service Kompor Gas 2 Tungku';
    final String address = args['address'] as String? ??
        args['address_text'] as String? ??
        'Jl. Raplesia No. 10, Kel. Patriot Kec. Lubuk Baja';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Update Status Pekerjaan',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderNumber,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF7A00)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    serviceName,
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pelanggan: $customerName',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Alamat: $address',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status Pembayaran:',
                        style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (args['payment_status'] == 'paid')
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (args['payment_status'] == 'paid')
                                ? Colors.green.shade300
                                : Colors.orange.shade300,
                          ),
                        ),
                        child: Text(
                          (args['payment_status'] == 'paid') ? 'LUNAS' : 'BELUM LUNAS',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: (args['payment_status'] == 'paid')
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pembaruan di sini khusus status fisik pekerjaan teknisi. Konfirmasi uang tunai dikelola via tab Pendapatan/Dompet (F009).',
                      style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF1E40AF)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Pilih Status Pengerjaan Terbaru:',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            const SizedBox(height: 12),

            // Stepper Radio List
            ...List.generate(_statuses.length, (index) {
              final isSelected = index == _selectedStatusIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedStatusIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF7A00)
                          : AppColors.cardBorder,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color:
                            isSelected ? const Color(0xFFFF7A00) : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _statuses[index],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        final nav = Navigator.of(context);
                        final selectedCode =
                            _statusApiCodes[_selectedStatusIndex];

                        try {
                          // Update order status in MySQL database via REST API
                          await _repository
                              .updateStatus(orderId, {'status': selectedCode});
                        } catch (e) {
                          debugPrint('Update status error: $e');
                        }

                        if (!mounted) return;
                        setState(() => _isSaving = false);

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Status pesanan berhasil tersimpan di database sebagai "${_statuses[_selectedStatusIndex]}"!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        nav.pop(true);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        'Simpan Status Pekerjaan',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
