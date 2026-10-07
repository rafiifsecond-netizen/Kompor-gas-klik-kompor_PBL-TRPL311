import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class CustomerOrderTrackingScreen extends StatelessWidget {
  const CustomerOrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final technician = args['technician'] as Map<String, dynamic>? ?? {'name': 'Ahmad Subagyo'};
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Lacak Pesanan'), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildStatusBanner(),
          const SizedBox(height: 20),
          _buildTimeline(),
          const SizedBox(height: 20),
          _buildTechnicianCard(technician, context),
        ]),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryAccent]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Pesanan Diterima!', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 6),
        Text('Teknisi sedang menuju lokasi Anda.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
        const SizedBox(height: 14),
        Row(children: [
          const Icon(Icons.access_time_rounded, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text('Estimasi tiba: 30-45 menit', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
        ]),
      ]),
    );
  }

  Widget _buildTimeline() {
    final steps = [
      {'label': 'Pesanan Dibuat', 'done': true},
      {'label': 'Pembayaran Diterima', 'done': true},
      {'label': 'Teknisi Berangkat', 'done': true},
      {'label': 'Teknisi Tiba', 'done': false},
      {'label': 'Servis Selesai', 'done': false},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Pesanan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((e) {
            final step = e.value;
            final isDone = step['done'] as bool;
            final isLast = e.key == steps.length - 1;
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppColors.primary : AppColors.chipInactive,
                  ),
                  child: Icon(isDone ? Icons.check_rounded : Icons.circle_outlined, size: 14, color: isDone ? Colors.white : AppColors.textMuted),
                ),
                if (!isLast) Container(width: 2, height: 28, color: isDone ? AppColors.primary : AppColors.chipInactive),
              ]),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(step['label'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: isDone ? FontWeight.w700 : FontWeight.w400, color: isDone ? AppColors.textPrimary : AppColors.textMuted)),
              ),
            ]);
          }),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(Map<String, dynamic> technician, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Row(children: [
        Container(
          width: 54, height: 54,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFEFE2)),
          child: const Icon(Icons.person_rounded, size: 30, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(technician['name'] as String? ?? 'Teknisi', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
          Text('Teknisi KlikKompor', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
        ])),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.customerChat),
        ),
      ]),
    );
  }
}
