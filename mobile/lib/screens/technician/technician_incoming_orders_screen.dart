import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/order_model.dart';

class TechnicianIncomingOrdersScreen extends StatefulWidget {
  const TechnicianIncomingOrdersScreen({super.key});

  @override
  State<TechnicianIncomingOrdersScreen> createState() =>
      _TechnicianIncomingOrdersScreenState();
}

class _TechnicianIncomingOrdersScreenState
    extends State<TechnicianIncomingOrdersScreen> {
  late Future<List<OrderModel>> _ordersFuture;
  final Set<int> _updatingOrders = {};

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadIncomingOrders();
  }

  Future<List<OrderModel>> _loadIncomingOrders() async {
    final response = await ApiClient().get(
      ApiEndpoints.orders,
      queryParameters: const {'status': 'pending'},
    );
    if (response is! Map) return [];
    final payload = response['data'];
    final rows = payload is Map ? payload['data'] : payload;
    if (rows is! List) return [];
    return rows
        .whereType<Map>()
        .map((row) => OrderModel.fromJson(Map<String, dynamic>.from(row)))
        .where((order) => order.isPending)
        .toList();
  }

  Future<bool> _respondToOrder(OrderModel order, String status) async {
    setState(() => _updatingOrders.add(order.id));
    try {
      await ApiClient().patch(
        ApiEndpoints.updateOrderStatus(order.id),
        data: {'status': status},
      );
      if (!mounted) return false;
      setState(() {
        _updatingOrders.remove(order.id);
        _ordersFuture = _loadIncomingOrders();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'accepted'
              ? 'Pesanan diterima.'
              : 'Pesanan dibatalkan.'),
        ),
      );
      return true;
    } catch (error) {
      if (!mounted) return false;
      setState(() => _updatingOrders.remove(order.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui pesanan: $error')),
      );
      return false;
    }
  }

  void _reload() {
    setState(() => _ordersFuture = _loadIncomingOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pesanan Masuk',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _emptyState(
              icon: Icons.cloud_off_rounded,
              message: 'Pesanan gagal dimuat dari server.',
              actionLabel: 'Coba lagi',
              onAction: _reload,
            );
          }

          final orders = snapshot.data ?? const <OrderModel>[];
          if (orders.isEmpty) {
            return _emptyState(
              icon: Icons.inbox_outlined,
              message: 'Belum ada pesanan masuk.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final customer = order.customer?.name ?? 'Pelanggan';
              final serviceName = order.items
                  .map((item) => item.serviceName ?? item.service?.name)
                  .whereType<String>()
                  .where((name) => name.isNotEmpty)
                  .join(', ');
              final address = order.addressText ??
                  order.address?.addressLine ??
                  'Alamat belum tersedia';
              final busy = _updatingOrders.contains(order.id);

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE9E9E9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 39,
                              backgroundColor: const Color(0xFFEADDFF),
                              child: Text(
                                customer.isEmpty
                                    ? '?'
                                    : customer[0].toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF4F378A),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 92,
                              child: Text(
                                customer,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            children: [
                              _orderDetailRow(
                                'Jenis Layanan',
                                serviceName.isEmpty
                                    ? 'Servis Kompor'
                                    : serviceName,
                              ),
                              _orderDetailRow(
                                'Pesanan Masuk',
                                '${order.bookingDate} ${order.bookingTime}'
                                    .trim(),
                              ),
                              _orderDetailRow('Lokasi', address),
                              _orderDetailRow(
                                'Biaya Layanan',
                                _rupiah(order.totalAmount),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: busy
                                ? null
                                : () => _respondToOrder(order, 'rejected'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Batalkan'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: busy
                                ? null
                                : () async {
                                    final accepted = await _respondToOrder(
                                      order,
                                      'accepted',
                                    );
                                    if (!accepted || !context.mounted) return;
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.technicianOrderDetail,
                                      arguments: {
                                        'orderId': order.id,
                                        'orderNumber': order.orderNumber,
                                        'customerName': customer,
                                        'serviceName': serviceName.isEmpty
                                            ? 'Servis Kompor'
                                            : serviceName,
                                        'address': address,
                                        'latitude': order.latitude,
                                        'longitude': order.longitude,
                                        'paymentMethod': order.paymentMethod,
                                        'amount': order.totalAmount,
                                        'status': 'accepted',
                                      },
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: busy
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Terima'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _orderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _rupiah(double value) {
    final amount = value.round().toString();
    final formatted = amount.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $formatted';
  }
}
