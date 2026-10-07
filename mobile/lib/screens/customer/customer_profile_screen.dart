import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil Saya'), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(children: [
          _buildHeader(user?.name ?? 'Pengguna', user?.email ?? ''),
          const SizedBox(height: 16),
          _buildMenuSection('Akun', [
            _buildMenuItem(Icons.person_outline_rounded, 'Edit Profil', () {}),
            _buildMenuItem(Icons.location_on_outlined, 'Alamat Tersimpan', () {}),
            _buildMenuItem(Icons.lock_outline_rounded, 'Ubah Password', () {}),
          ]),
          const SizedBox(height: 8),
          _buildMenuSection('Pesanan', [
            _buildMenuItem(Icons.receipt_long_rounded, 'Riwayat Pesanan', () => Navigator.pushNamed(context, AppRoutes.customerOrderHistory)),
            _buildMenuItem(Icons.chat_bubble_outline_rounded, 'Pesan', () => Navigator.pushNamed(context, AppRoutes.customerChat)),
          ]),
          const SizedBox(height: 8),
          _buildMenuSection('Lainnya', [
            _buildMenuItem(Icons.help_outline_rounded, 'Pusat Bantuan', () => Navigator.pushNamed(context, AppRoutes.customerHelpCenter)),
            _buildMenuItem(Icons.info_outline_rounded, 'Tentang Aplikasi', () {}),
          ]),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () async {
                final nav = Navigator.of(context);
                await context.read<AuthProvider>().logout();
                nav.pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              label: Text('Keluar', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.danger)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildHeader(String name, String email) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Container(
          width: 68, height: 68,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFEFE2)),
          child: const Icon(Icons.person_rounded, size: 38, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(email, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: Text('Pelanggan', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ]),
      ]),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ),
        ...items,
      ]),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
          ]),
        ),
      ),
    );
  }
}
