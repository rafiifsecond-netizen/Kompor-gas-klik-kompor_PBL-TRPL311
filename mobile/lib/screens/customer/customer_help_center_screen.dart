import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class CustomerHelpCenterScreen extends StatefulWidget {
  const CustomerHelpCenterScreen({super.key});
  @override
  State<CustomerHelpCenterScreen> createState() => _CustomerHelpCenterScreenState();
}

class _CustomerHelpCenterScreenState extends State<CustomerHelpCenterScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {'q': 'Bagaimana cara memesan layanan servis kompor?', 'a': 'Pilih Katalog Layanan dari beranda, pilih jenis layanan yang diinginkan, masukkan alamat dan jadwal, pilih teknisi, lalu lakukan pembayaran.'},
    {'q': 'Berapa lama teknisi tiba setelah pemesanan?', 'a': 'Teknisi akan tiba dalam 30-60 menit setelah jam yang dipilih, tergantung jarak dan kondisi lalu lintas.'},
    {'q': 'Apakah ada garansi servis?', 'a': 'Ya, kami memberikan garansi servis selama 7 hari. Jika ada masalah yang sama, teknisi kami akan kembali tanpa biaya tambahan.'},
    {'q': 'Metode pembayaran apa saja yang diterima?', 'a': 'Kami menerima transfer bank, pembayaran tunai di tempat, dan dompet digital.'},
    {'q': 'Bagaimana jika teknisi tidak tersedia?', 'a': 'Anda dapat memilih jadwal berbeda atau menghubungi layanan pelanggan kami untuk mendapat bantuan lebih lanjut.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pusat Bantuan'), backgroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryAccent]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Icon(Icons.support_agent_rounded, color: Colors.white, size: 36),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ada pertanyaan?', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Kami siap membantu 24/7', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          Text('FAQ', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._faqs.asMap().entries.map((e) {
            final i = e.key;
            final faq = e.value;
            final isExpanded = _expandedIndex == i;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isExpanded ? AppColors.primary : AppColors.cardBorder),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => _expandedIndex = isExpanded ? null : i),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(faq['q']!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700))),
                        Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.primary),
                      ]),
                      if (isExpanded) ...[
                        const SizedBox(height: 10),
                        Text(faq['a']!, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                      ],
                    ]),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Text('Hubungi Kami', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _buildContactCard(Icons.email_outlined, 'Email', 'support@klikkompor.id'),
          _buildContactCard(Icons.phone_outlined, 'WhatsApp', '0800-1234-5678'),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }
}
