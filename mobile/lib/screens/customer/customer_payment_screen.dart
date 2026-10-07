import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class CustomerPaymentScreen extends StatefulWidget {
  const CustomerPaymentScreen({super.key});
  @override
  State<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<CustomerPaymentScreen> {
  String _selectedMethod = 'transfer';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _methods = [
    {'id': 'transfer', 'label': 'Transfer Bank', 'icon': Icons.account_balance_rounded},
    {'id': 'cash', 'label': 'Tunai (Bayar di Tempat)', 'icon': Icons.payments_rounded},
    {'id': 'ewallet', 'label': 'Dompet Digital', 'icon': Icons.phone_android_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final service = args['service'] as Map<String, dynamic>? ?? {};
    final price = (service['price'] as int? ?? 0) + 5000;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pembayaran'), backgroundColor: Colors.white),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryAccent]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total Pembayaran', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 6),
                   Text('Rp ${_fmt(price)}', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                ]),
              ),
              const SizedBox(height: 24),
              Text('Metode Pembayaran', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._methods.map((m) => _buildMethodCard(m)),
            ]),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () async {
                setState(() => _isProcessing = true);
                await Future.delayed(const Duration(seconds: 2));
                if (!mounted) return;
                setState(() => _isProcessing = false);
                // ignore: use_build_context_synchronously
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.customerOrderTracking, (r) => r.settings.name == AppRoutes.customerHome, arguments: args);
              },
              child: _isProcessing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Text('Bayar Sekarang'),
            ),
          ),
        ),
      ]),
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

  Widget _buildMethodCard(Map<String, dynamic> m) {
    final isSelected = _selectedMethod == m['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = m['id'] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder, width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(m['icon'] as IconData, color: isSelected ? AppColors.primary : AppColors.textMuted, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(m['label'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? AppColors.textPrimary : AppColors.textSecondary))),
          if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
        ]),
      ),
    );
  }
}
