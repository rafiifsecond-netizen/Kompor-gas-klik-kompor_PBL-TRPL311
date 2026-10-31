import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/order_model.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/order_history_card_widget.dart';
import '../../repositories/order_repository.dart';

class CustomerOrderHistoryScreen extends StatefulWidget {
  const CustomerOrderHistoryScreen({super.key});

  @override
  State<CustomerOrderHistoryScreen> createState() =>
      _CustomerOrderHistoryScreenState();
}

class _CustomerOrderHistoryScreenState
    extends State<CustomerOrderHistoryScreen> {
  bool _isLoading = true;
  List<OrderModel> _orders = [];
  String? _errorMessage;
  final _repository = OrderRepository();

  @override
  void initState() {
    super.initState();
    _fetchRealOrders();
  }

  Future<void> _fetchRealOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getOrders();
      setState(() {
        _orders = list.map(OrderModel.fromJson).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

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
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchRealOrders,
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.danger),
                        const SizedBox(height: 12),
                        Text(_errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _fetchRealOrders,
                            child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              size: 52, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('Belum ada pesanan riil di database',
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.customerCatalog),
                            child: const Text('Pesan Sekarang'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchRealOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (_, i) {
                          final o = _orders[i];
                          final String title = (o.items.isNotEmpty &&
                                  o.items.first.serviceName != null)
                              ? o.items.first.serviceName!
                              : 'Service Kompor Gas';
                          final statusLabel = switch (o.status) {
                            'completed' => 'Selesai',
                            'cancelled' => 'Dibatalkan',
                            'on_the_way' => 'Dalam Perjalanan',
                            'in_progress' => 'Sedang Proses',
                            _ => 'Menunggu',
                          };

                          return OrderHistoryCardWidget(
                            title: title,
                            orderNumber: o.orderNumber,
                            date: o.bookingDate,
                            price: 'Rp ${_fmt(o.totalAmount.toInt())}',
                            status: statusLabel,
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.customerOrderTracking,
                                arguments: o),
                            onReviewTap: o.isCompleted
                                ? () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.customerReview,
                                    arguments: {'orderId': o.id})
                                : null,
                            onReorderTap: () => Navigator.pushNamed(
                                context, AppRoutes.customerCatalog),
                          );
                        },
                      ),
                    ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  static String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
