import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class CustomerBookingSummaryScreen extends StatelessWidget {
  const CustomerBookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final service = args['service'] as Map<String, dynamic>? ?? {};
    final address = args['address'] as Map<String, dynamic>? ?? {};
    final technician = args['technician'] as Map<String, dynamic>? ?? {};
    final bookingDate = args['bookingDate'] as String? ?? '-';
    final bookingTime = args['bookingTime'] as String? ?? '-';
    final price = service['price'] as int? ?? 0;
    const serviceFee = 5000;
    final total = price + serviceFee;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ringkasan Pesanan'), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSection('Layanan', [
            _buildRow('Nama', service['name'] as String? ?? '-'),
            _buildRow('Durasi', '${service['duration'] as int? ?? 60} menit'),
          ]),
          const SizedBox(height: 14),
          _buildSection('Alamat', [
            _buildRow('Penerima', address['recipientName'] as String? ?? '-'),
            _buildRow('Alamat', '${address['addressLine'] as String? ?? ''}, ${address['city'] as String? ?? ''}'),
          ]),
          const SizedBox(height: 14),
          _buildSection('Jadwal', [
            _buildRow('Tanggal', bookingDate),
            _buildRow('Jam', bookingTime),
          ]),
          const SizedBox(height: 14),
          _buildSection('Teknisi', [
            _buildRow('Nama', technician['name'] as String? ?? '-'),
          ]),
          const SizedBox(height: 14),
          _buildSection('Rincian Biaya', [
            _buildRow('Biaya Layanan', 'Rp ${_fmt(price)}'),
            _buildRow('Biaya Admin', 'Rp 5.000'),
            const Divider(),
            _buildRow('Total', 'Rp ${_fmt(total)}', isBold: true),
          ]),
          const SizedBox(height: 24),
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.customerPayment, arguments: args),
            child: const Text('Lanjutkan ke Pembayaran'),
          ),
        ),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ...children,
      ]),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
        Flexible(child: Text(value, textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, color: isBold ? AppColors.primary : AppColors.textPrimary))),
      ]),
    );
  }
}
