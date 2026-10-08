import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/order_history_card_widget.dart';

class CustomerOrderHistoryScreen extends StatelessWidget {
  const CustomerOrderHistoryScreen({super.key});

  static const _orders = [
    {'title': 'Service Kompor Gas 2 Tungku', 'orderNumber': '#KK-2026-001', 'date': '1 Okt 2026', 'price': 'Rp 105.000', 'status': 'Selesai'},
    {'title': 'Ganti Selang Gas', 'orderNumber': '#KK-2026-002', 'date': '15 Sep 2026', 'price': 'Rp 55.000', 'status': 'Selesai'},
    {'title': 'Service Kompor Gas 1 Tungku', 'orderNumber': '#KK-2026-003', 'date': '5 Sep 2026', 'price': 'Rp 80.000', 'status': 'Dibatalkan'},
  ];

  void _onNavTap(BuildContext context, int index) {
    final route = switch (index) {
      0 => AppRoutes.customerHome,
      1 => AppRoutes.customerOrderHistory,
      2 => AppRoutes.customerChat,
      3 => AppRoutes.customerProfile,
      _ => null,
    };
    if (route != null && index != 1) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Riwayat Pesanan'), backgroundColor: Colors.white),
      body: _orders.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.receipt_long_outlined, size: 52, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('Belum ada pesanan', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.customerCatalog),
              child: const Text('Pesan Sekarang'),
            ),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _orders.length,
            itemBuilder: (_, i) {
              final o = _orders[i];
              return OrderHistoryCardWidget(
                title: o['title']!,
                orderNumber: o['orderNumber']!,
                date: o['date']!,
                price: o['price']!,
                status: o['status']!,
                onReviewTap: o['status'] == 'Selesai' ? () => Navigator.pushNamed(context, AppRoutes.customerReview) : null,
                onReorderTap: () => Navigator.pushNamed(context, AppRoutes.customerCatalog),
              );
            },
          ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }
}
