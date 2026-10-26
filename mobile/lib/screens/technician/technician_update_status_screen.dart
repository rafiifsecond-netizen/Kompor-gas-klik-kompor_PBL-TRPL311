import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';

class TechnicianUpdateStatusScreen extends StatefulWidget {
  const TechnicianUpdateStatusScreen({super.key});

  @override
  State<TechnicianUpdateStatusScreen> createState() => _TechnicianUpdateStatusScreenState();
}

class _TechnicianUpdateStatusScreenState extends State<TechnicianUpdateStatusScreen> {
  int _selectedStatusIndex = 1;

  final List<String> _statuses = [
    'Order Diterima',
    'Dalam Perjalanan ke Lokasi',
    'Sedang Mengerjakan Servis',
    'Pengerjaan Selesai',
  ];

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> args = rawArgs is OrderModel
        ? rawArgs.toJson()
        : (rawArgs is Map<String, dynamic> ? rawArgs : {});

    final String orderNumber = args['orderNumber'] as String? ?? args['order_number'] as String? ?? '#SRV-2026-089';
    final String customerName = args['customerName'] as String? ?? (args['customer'] is Map ? args['customer']['name'] : null) ?? 'Budi Santoso';
    final String serviceName = args['serviceName'] as String? ?? 'Service Kompor Gas 2 Tungku';
    final String address = args['address'] as String? ?? args['address_text'] as String? ?? 'Jl. Raplesia No. 10, Kel. Patriot Kec. Lubuk Baja';

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
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFFF7A00)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    serviceName,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pelanggan: $customerName',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Alamat: $address',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Pilih Status Terbaru:',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
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
                      color: isSelected ? const Color(0xFFFF7A00) : AppColors.cardBorder,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                        color: isSelected ? const Color(0xFFFF7A00) : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _statuses[index],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status berhasil diperbarui menjadi "${_statuses[_selectedStatusIndex]}"!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Simpan Status Pekerjaan',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
