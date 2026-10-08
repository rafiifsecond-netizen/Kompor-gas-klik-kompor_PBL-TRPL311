import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class TechnicianUpdateStatusScreen extends StatefulWidget {
  const TechnicianUpdateStatusScreen({super.key});

  @override
  State<TechnicianUpdateStatusScreen> createState() => _TechnicianUpdateStatusScreenState();
}

class _TechnicianUpdateStatusScreenState extends State<TechnicianUpdateStatusScreen> {
  int _currentStep = 1; // 1: Dalam Perjalanan, 2: Mulai Pengerjaan, 3: Selesai

  final List<String> _statuses = [
    'Order Diterima',
    'Dalam Perjalanan ke Lokasi',
    'Sedang Mengerjakan Servis',
    'Pengerjaan Selesai',
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final String orderNumber = args['orderNumber'] as String? ?? '#SRV-2026-089';
    final String customerName = args['customerName'] as String? ?? 'Budi Santoso';
    final String serviceName = args['serviceName'] as String? ?? 'Service Kompor Gas 2 Tungku';
    final String address = args['address'] as String? ?? 'Jl. Raplesia No. 10, Kel. Patriot Kec. Lubuk Baja';

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
            // Card Order Info
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        orderNumber,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFFF7A00)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statuses[_currentStep],
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(serviceName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Pelanggan: $customerName', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text('Alamat: $address', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text('Progres Status', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Timeline Steps
            ...List.generate(_statuses.length, (index) {
              final isCompleted = index <= _currentStep;
              final isCurrent = index == _currentStep;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? const Color(0xFFFF7A00) : Colors.grey.shade300,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_rounded : Icons.circle_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      if (index < _statuses.length - 1)
                        Container(
                          width: 2,
                          height: 36,
                          color: index < _currentStep ? const Color(0xFFFF7A00) : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _statuses[index],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isCompleted ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 36),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < _statuses.length - 1) {
                    setState(() => _currentStep++);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pekerjaan telah selesai!')),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _currentStep < _statuses.length - 1
                      ? 'Lanjut Ke Status Berikutnya'
                      : 'Selesaikan Pekerjaan',
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
