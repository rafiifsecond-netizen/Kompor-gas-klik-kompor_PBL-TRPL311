import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/notification_card_widget.dart';

class CustomerNotificationScreen extends StatelessWidget {
  const CustomerNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Tandai semua', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          NotificationCardWidget(
            title: 'Pesanan Diterima',
            message: 'Pesanan #KK-2026-001 telah dikonfirmasi. Teknisi akan segera berangkat.',
            tag: 'Order',
            time: 'Hari ini, 09:00',
            icon: Icons.check_circle_rounded,
          ),
          NotificationCardWidget(
            title: 'Teknisi Dalam Perjalanan',
            message: 'Ahmad Subagyo sedang menuju lokasi Anda. Estimasi tiba 30 menit.',
            tag: 'Status',
            time: 'Hari ini, 09:15',
            icon: Icons.directions_car_rounded,
          ),
          NotificationCardWidget(
            title: 'Servis Selesai',
            message: 'Pesanan #KK-2026-001 telah selesai. Jangan lupa beri ulasan!',
            tag: 'Selesai',
            time: 'Kemarin, 11:30',
            icon: Icons.done_all_rounded,
          ),
        ],
      ),
    );
  }
}
