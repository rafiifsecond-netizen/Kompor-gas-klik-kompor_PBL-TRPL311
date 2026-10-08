import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class TechnicianServiceHistoryScreen extends StatelessWidget {
  const TechnicianServiceHistoryScreen({super.key});

  final List<Map<String, dynamic>> _history = const [
    {
      'orderNumber': '#SRV-2026-085',
      'service': 'Service Kompor Gas 2 Tungku',
      'customer': 'Anisa Wijaya',
      'date': '06 Okt 2026',
      'earning': 'Rp 85.000',
      'rating': '5.0',
    },
    {
      'orderNumber': '#SRV-2026-080',
      'service': 'Pembersihan Kerak Kompor',
      'customer': 'Rahmat Hidayat',
      'date': '04 Okt 2026',
      'earning': 'Rp 70.000',
      'rating': '4.9',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          'Riwayat Servis Selesai',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                    Text(item['orderNumber'] as String, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFFF7A00))),
                    Text(item['date'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item['service'] as String, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Pelanggan: ${item['customer']}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFA500), size: 18),
                        const SizedBox(width: 4),
                        Text(item['rating'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('Pendapatan: ${item['earning']}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.green.shade700)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
