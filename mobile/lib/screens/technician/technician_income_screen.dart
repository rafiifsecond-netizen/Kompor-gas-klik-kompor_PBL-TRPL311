import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../repositories/income_repository.dart';

class TechnicianIncomeScreen extends StatefulWidget {
  const TechnicianIncomeScreen({super.key});

  @override
  State<TechnicianIncomeScreen> createState() => _TechnicianIncomeScreenState();
}

class _TechnicianIncomeScreenState extends State<TechnicianIncomeScreen> {
  final _repository = IncomeRepository();
  late Future<List<OrderModel>> _ordersFuture;
  bool _showWeekly = false;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadCompletedOrders();
  }

  Future<List<OrderModel>> _loadCompletedOrders() async {
    final orders = <OrderModel>[];
    var pageNumber = 1;
    var lastPage = 1;

    do {
      final response = await _repository.getCompletedOrders(page: pageNumber);
      if (response is! Map || response['success'] != true) {
        throw Exception('Data pendapatan tidak dapat dimuat.');
      }

      final page = response['data'];
      if (page is Map) {
        final rows = page['data'];
        if (rows is List) {
          orders.addAll(
            rows.whereType<Map>().map((row) => OrderModel.fromJson(
                  Map<String, dynamic>.from(row),
                )),
          );
        }
        lastPage = int.tryParse(page['last_page']?.toString() ?? '') ?? 1;
      } else if (page is List) {
        orders.addAll(
          page.whereType<Map>().map((row) => OrderModel.fromJson(
                Map<String, dynamic>.from(row),
              )),
        );
        lastPage = 1;
      }
      pageNumber++;
    } while (pageNumber <= lastPage);

    return orders.where((order) => order.isPaid).toList();
  }

  DateTime? _orderDate(OrderModel order) {
    return DateTime.tryParse(order.completedAt ?? '') ??
        DateTime.tryParse(order.bookingDate);
  }

  double _netEarnings(OrderModel order) {
    final approvedCosts = order.additionalCosts
        .where((cost) => cost.isApproved)
        .fold<double>(0, (total, cost) => total + cost.amount);
    final serviceAmount = order.items.isEmpty
        ? (order.subtotal - approvedCosts).clamp(0, double.infinity).toDouble()
        : order.items.fold<double>(0, (total, item) => total + item.subtotal);
    return serviceAmount * 0.9 + approvedCosts;
  }

  double _sum(List<OrderModel> orders, bool Function(DateTime) includes) {
    return orders.fold<double>(0, (total, order) {
      final date = _orderDate(order);
      return date != null && includes(date)
          ? total + _netEarnings(order)
          : total;
    });
  }

  String _rupiah(double amount) {
    final digits = amount.round().toString();
    final grouped = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp$grouped';
  }

  String _dateLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showUnavailable(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature belum tersedia.')),
    );
  }

  void _showTransactions(List<OrderModel> orders) {
    final sortedOrders = [...orders]..sort((a, b) =>
        (_orderDate(b) ?? DateTime(0)).compareTo(_orderDate(a) ?? DateTime(0)));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  'Riwayat transaksi',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: sortedOrders.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada transaksi pendapatan.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: sortedOrders.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 20, endIndent: 20),
                        itemBuilder: (context, index) {
                          final order = sortedOrders[index];
                          final date = _orderDate(order);
                          return ListTile(
                            title: Text(
                              order.orderNumber.isEmpty
                                  ? 'Pesanan selesai'
                                  : order.orderNumber,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              date == null ? '-' : _dateLabel(date),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            trailing: Text(
                              _rupiah(_netEarnings(order)),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF07912F),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: FutureBuilder<List<OrderModel>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            final orders = snapshot.data ?? const <OrderModel>[];
            final todayTotal = _sum(
              orders,
              (date) =>
                  !date.isBefore(startOfDay) &&
                  date.isBefore(startOfDay.add(const Duration(days: 1))),
            );
            final weekTotal = _sum(
              orders,
              (date) =>
                  !date.isBefore(startOfWeek) &&
                  date.isBefore(startOfWeek.add(const Duration(days: 7))),
            );
            final balance = _sum(orders, (_) => true);

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
              children: [
                Text(
                  'Pendapatan',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ringkasan Pendapatan',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.black),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _PeriodTab(
                            label: 'Harian',
                            selected: !_showWeekly,
                            onTap: () => setState(() => _showWeekly = false),
                          ),
                          _PeriodTab(
                            label: 'Mingguan',
                            selected: _showWeekly,
                            onTap: () => setState(() => _showWeekly = true),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 17, 12, 20),
                        child: Column(
                          children: [
                            Text(
                              _showWeekly ? 'Minggu ini' : 'Hari ini',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (snapshot.hasError)
                              TextButton.icon(
                                onPressed: () => setState(
                                  () => _ordersFuture = _loadCompletedOrders(),
                                ),
                                icon:
                                    const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Coba muat ulang'),
                              )
                            else if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            else
                              Text(
                                _rupiah(_showWeekly ? weekTotal : todayTotal),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF07912F),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 17, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Saldo dompet',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.hasError ||
                                snapshot.connectionState ==
                                    ConnectionState.waiting
                            ? '—'
                            : _rupiah(balance),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 34),
                      Row(
                        children: [
                          Expanded(
                            child: _WalletAction(
                              icon: Icons.south_rounded,
                              label: 'Tarik ke bank',
                              onTap: () => _showUnavailable('Tarik ke bank'),
                            ),
                          ),
                          Expanded(
                            child: _WalletAction(
                              icon: Icons.receipt_long_rounded,
                              label: 'Riwayat transaksi',
                              onTap: () => _showTransactions(orders),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            const SizedBox(height: 13),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: selected ? Colors.black : const Color(0xFFB7B7B7),
              ),
            ),
            const SizedBox(height: 9),
            Container(
              height: 1,
              color: selected ? AppColors.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.inter(
                fontSize: 9,
                height: 1.15,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
