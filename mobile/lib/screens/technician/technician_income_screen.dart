import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_feedback.dart';
import '../../models/order_model.dart';
import '../../repositories/income_repository.dart';
import '../../repositories/payment_repository.dart';

class TechnicianIncomeScreen extends StatefulWidget {
  const TechnicianIncomeScreen({super.key});

  @override
  State<TechnicianIncomeScreen> createState() => _TechnicianIncomeScreenState();
}

class _TechnicianIncomeScreenState extends State<TechnicianIncomeScreen> {
  final _repository = IncomeRepository();
  final _paymentRepo = PaymentRepository();

  late Future<List<OrderModel>> _ordersFuture;
  Map<String, dynamic>? _walletData;
  bool _isLoadingWallet = true;
  bool _showWeekly = false;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadCompletedOrders();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() => _isLoadingWallet = true);
    try {
      final res = await _paymentRepo.getTechnicianWallet();
      if (res is Map && res['data'] != null) {
        setState(() {
          _walletData = Map<String, dynamic>.from(res['data'] as Map);
          _isLoadingWallet = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingWallet = false);
    }
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
    // Platform fee 5% based on final payment specification
    return serviceAmount * 0.95 + approvedCosts;
  }

  double _sum(List<OrderModel> orders, bool Function(DateTime) includes) {
    return orders.fold<double>(0, (total, order) {
      final date = _orderDate(order);
      return date != null && includes(date)
          ? total + _netEarnings(order)
          : total;
    });
  }

  String _rupiah(num amount) {
    final isNegative = amount < 0;
    final digits = amount.abs().round().toString();
    final grouped = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return isNegative ? '-Rp$grouped' : 'Rp$grouped';
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

  void _showPayoutDialog() {
    final balance = (_walletData?['balance'] as num?)?.toInt() ?? 0;
    if (balance < 50000) {
      AppFeedback.error(
        context,
        'Saldo aktif minimum untuk penarikan adalah Rp 50.000 (Saldo Anda: ${_rupiah(balance)})',
      );
      return;
    }

    final amountController = TextEditingController(text: balance.toString());
    final bankController = TextEditingController(text: _walletData?['bank_name']?.toString() ?? 'BCA');
    final accountNumController = TextEditingController(text: _walletData?['bank_account_number']?.toString() ?? '');
    final accountHolderController = TextEditingController(text: _walletData?['bank_account_holder']?.toString() ?? '');
    bool isSubmitting = false;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Tarik Saldo ke Rekening Bank',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo Tersedia: ${_rupiah(balance)}',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nominal Penarikan (Rp)',
                    hintText: 'Minimal 50.000',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bankController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Bank (contoh: BCA, Mandiri)',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: accountNumController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Rekening',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: accountHolderController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pemilik Rekening',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final amt = int.tryParse(amountController.text.trim()) ?? 0;
                      if (amt < 50000) {
                        AppFeedback.error(ctx, 'Minimal penarikan adalah Rp 50.000');
                        return;
                      }
                      if (amt > balance) {
                        AppFeedback.error(ctx, 'Nominal melebihi saldo aktif Anda');
                        return;
                      }
                      if (bankController.text.trim().isEmpty ||
                          accountNumController.text.trim().isEmpty ||
                          accountHolderController.text.trim().isEmpty) {
                        AppFeedback.error(ctx, 'Semua data rekening bank wajib diisi');
                        return;
                      }

                      final navigator = Navigator.of(dialogCtx);
                      setDialogState(() => isSubmitting = true);
                      try {
                        await _paymentRepo.requestPayout(
                          amount: amt,
                          bankName: bankController.text.trim(),
                          accountNumber: accountNumController.text.trim(),
                          accountHolder: accountHolderController.text.trim(),
                        );
                        if (!mounted) return;
                        navigator.pop();
                        AppFeedback.success(
                          context,
                          'Pengajuan penarikan Rp ${_rupiah(amt)} berhasil dikirim! Menunggu transfer admin.',
                        );
                        _loadWallet();
                      } catch (e) {
                        if (!mounted) return;
                        AppFeedback.error(context, 'Gagal mengajukan penarikan: $e');
                        setDialogState(() => isSubmitting = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Ajukan Penarikan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactions() {
    final transactions = (_walletData?['transactions'] as List?) ?? const [];

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mutasi Dompet Teknisi',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${transactions.length} mutasi',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada mutasi transaksi dompet.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 20, endIndent: 20),
                        itemBuilder: (context, index) {
                          final tx = Map<String, dynamic>.from(transactions[index] as Map);
                          final isCredit = tx['type'] == 'credit';
                          final amt = (tx['amount'] as num?) ?? 0;
                          final dateStr = tx['created_at']?.toString() ?? '';
                          final parsedDate = DateTime.tryParse(dateStr);

                          return ListTile(
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                color: isCredit ? const Color(0xFF16A34A) : Colors.red,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              tx['description']?.toString() ?? tx['transaction_number']?.toString() ?? 'Transaksi',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              parsedDate != null ? _dateLabel(parsedDate) : dateStr,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            trailing: Text(
                              '${isCredit ? '+' : '-'}${_rupiah(amt)}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isCredit ? const Color(0xFF07912F) : Colors.red.shade700,
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

    final walletBalance = (_walletData?['balance'] as num?)?.toDouble() ?? 0.0;
    final pendingBalance = (_walletData?['pending_balance'] as num?)?.toDouble() ?? 0.0;
    final isSuspended = _walletData?['is_suspended_from_orders'] == true || walletBalance < -200000;

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

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dompet & Pendapatan',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      onPressed: () {
                        _loadWallet();
                        setState(() => _ordersFuture = _loadCompletedOrders());
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Peringatan Batas Utang Tunai
                if (isSuspended) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Akun Anda disuspend karena saldo utang cash melebihi batas Rp 200.000. Segera setorkan komisi ke platform.',
                            style: GoogleFonts.inter(fontSize: 11.5, color: Colors.red.shade900, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Kartu Saldo Dompet Teknisi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Saldo Aktif Dompet',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Komisi 5%',
                              style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isLoadingWallet ? 'Memuat...' : _rupiah(walletBalance),
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dana Ditahan (Escrow)',
                                style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white70),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isLoadingWallet ? '—' : _rupiah(pendingBalance),
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _showPayoutDialog,
                                icon: const Icon(Icons.arrow_upward_rounded, size: 14),
                                label: const Text('Tarik Saldo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFC2410C),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: _showTransactions,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white60),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('Mutasi', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  'Ringkasan Pesanan Selesai',
                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                    borderRadius: BorderRadius.circular(10),
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
                      const SizedBox(height: 20),
                      Text(
                        _showWeekly
                            ? 'Pendapatan minggu ini'
                            : 'Pendapatan hari ini',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.hasError ||
                                snapshot.connectionState ==
                                    ConnectionState.waiting
                            ? '—'
                            : _rupiah(_showWeekly ? weekTotal : todayTotal),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
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
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.black : const Color(0xFFB7B7B7),
              ),
            ),
            const SizedBox(height: 9),
            Container(
              height: 2,
              color: selected ? AppColors.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
