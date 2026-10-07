import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class CustomerServiceDetailScreen extends StatelessWidget {
  const CustomerServiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final name = service['name'] as String? ?? 'Layanan';
    final price = service['price'] as int? ?? 0;
    final duration = service['duration'] as int? ?? 60;
    final description = service['description'] as String? ?? '';
    final icon = service['icon'] as IconData? ?? Icons.handyman_rounded;
    final category = service['category'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Layanan'), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(icon, name, category),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.attach_money_rounded, 'Harga',
                      'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.access_time_rounded, 'Estimasi Waktu', '$duration menit'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.category_rounded, 'Kategori', category),
                  const Divider(height: 32),
                  Text('Deskripsi Layanan', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    description.isNotEmpty
                        ? description
                        : 'Teknisi berpengalaman kami akan datang ke lokasi Anda untuk menangani masalah kompor gas dengan cepat dan profesional.',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Teknisi terverifikasi & berpengalaman',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.customerSelectAddress,
              arguments: service,
            ),
            child: const Text('Pesan Layanan Ini'),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(IconData icon, String name, String category) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryAccent]),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
            Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}