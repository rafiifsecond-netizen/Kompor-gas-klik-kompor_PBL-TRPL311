import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';
import '../../widgets/empty_state_widget.dart';

class TechnicianServiceHistoryScreen extends StatefulWidget {
  const TechnicianServiceHistoryScreen({super.key});

  @override
  State<TechnicianServiceHistoryScreen> createState() =>
      _TechnicianServiceHistoryScreenState();
}

class _TechnicianServiceHistoryScreenState
    extends State<TechnicianServiceHistoryScreen> {
  final _repository = OrderRepository();
  late Future<List<OrderModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<OrderModel>> _load() async {
    final rows = await _repository.getOrders();
    return rows
        .map(OrderModel.fromJson)
        .where((order) => order.status == 'completed')
        .toList();
  }

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
          style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: AppColors.danger),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _future = _load()),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final orders = snapshot.data ?? const <OrderModel>[];
          if (orders.isEmpty) {
            return const EmptyStateWidget(
              title: 'Belum ada riwayat servis',
              message: 'Servis yang sudah selesai akan muncul di sini.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final serviceName = order.items.isNotEmpty
                  ? (order.items.first.serviceName ??
                      order.items.first.service?.name ??
                      'Servis Kompor Gas')
                  : 'Servis Kompor Gas';
              final rating = order.review?.rating;
              final date = order.completedAt != null
                  ? DateFormat('dd MMM yyyy')
                      .format(DateTime.parse(order.completedAt!))
                  : order.bookingDate;

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
                        Text(order.orderNumber,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF7A00))),
                        Text(date,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(serviceName,
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Pelanggan: ${order.customer?.name ?? '-'}',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textSecondary)),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFFA500), size: 18),
                            const SizedBox(width: 4),
                            Text(rating?.toString() ?? '-',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(
                            'Pendapatan: Rp ${order.totalAmount.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.green.shade700)),
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
}
