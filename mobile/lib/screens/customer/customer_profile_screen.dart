import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  void _onNavTap(BuildContext context, int index) {
    final route = switch (index) {
      0 => AppRoutes.customerHome,
      1 => AppRoutes.customerOrderHistory,
      2 => AppRoutes.customerChat,
      3 => AppRoutes.customerProfile,
      _ => null,
    };
    if (route != null && index != 3) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil Saya'), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          _buildHeader(user?.name ?? 'Pengguna', user?.email ?? ''),
          const SizedBox(height: 16),

          // ── Section Akun (Edit Profil, Alamat Tersimpan, Ubah Password) ──
          _buildMenuSection('Akun', [
            _buildMenuItem(
              Icons.person_outline_rounded,
              'Edit Profil',
              () => _showEditProfileSheet(context, user?.name ?? '', user?.phone ?? '', user?.address ?? ''),
            ),
            _buildMenuItem(
              Icons.location_on_outlined,
              'Alamat Tersimpan',
              () => Navigator.pushNamed(context, AppRoutes.customerSelectAddress),
            ),
            _buildMenuItem(
              Icons.lock_outline_rounded,
              'Ubah Password',
              () => _showChangePasswordSheet(context),
            ),
          ]),

          const SizedBox(height: 12),
          _buildMenuSection('Pesanan', [
            _buildMenuItem(Icons.receipt_long_rounded, 'Riwayat Pesanan', () => Navigator.pushNamed(context, AppRoutes.customerOrderHistory)),
            _buildMenuItem(Icons.chat_bubble_outline_rounded, 'Pesan', () => Navigator.pushNamed(context, AppRoutes.customerChat)),
          ]),

          const SizedBox(height: 12),
          _buildMenuSection('Lainnya', [
            _buildMenuItem(Icons.help_outline_rounded, 'Pusat Bantuan', () => Navigator.pushNamed(context, AppRoutes.customerHelpCenter)),
            _buildMenuItem(
              Icons.info_outline_rounded,
              'Tentang Aplikasi',
              () => showAboutDialog(
                context: context,
                applicationName: 'KlikKompor',
                applicationVersion: 'v1.0.0',
                applicationIcon: const Icon(Icons.local_fire_department_rounded, size: 40, color: AppColors.primary),
                children: [
                  const Text('KlikKompor adalah platform pemesanan dan manajemen perbaikan kompor gas terpercaya.'),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 16),
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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  // ── Sheet 1: Edit Profil ──────────────────────────────────────────────────
  void _showEditProfileSheet(BuildContext context, String currentName, String currentPhone, String currentAddress) {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);
    final addressCtrl = TextEditingController(text: currentAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Edit Profil Saya', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon (WhatsApp)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Alamat Lengkap',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setStateModal(() => isLoading = true);
                              final auth = ctx.read<AuthProvider>();
                              final ok = await auth.updateProfile(
                                name: nameCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                address: addressCtrl.text.trim(),
                              );
                              setStateModal(() => isLoading = false);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(ok ? 'Profil berhasil diperbarui!' : 'Gagal memperbarui profil.'),
                                    backgroundColor: ok ? Colors.green : AppColors.danger,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Simpan Perubahan', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Sheet 2: Ubah Password ─────────────────────────────────────────────────
  void _showChangePasswordSheet(BuildContext context) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        bool isLoading = false;
        String? errorMsg;

        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ubah Kata Sandi', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  if (errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(8)),
                      child: Text(errorMsg!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.danger)),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextField(
                    controller: currentPassCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Saat Ini',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Baru (min 6 karakter)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Kata Sandi Baru',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (newPassCtrl.text.length < 6) {
                                setStateModal(() => errorMsg = 'Kata sandi baru minimal 6 karakter.');
                                return;
                              }
                              if (newPassCtrl.text != confirmPassCtrl.text) {
                                setStateModal(() => errorMsg = 'Konfirmasi kata sandi tidak cocok.');
                                return;
                              }
                              setStateModal(() { isLoading = true; errorMsg = null; });
                              final auth = ctx.read<AuthProvider>();
                              final ok = await auth.changePassword(
                                currentPassword: currentPassCtrl.text,
                                newPassword: newPassCtrl.text,
                                newPasswordConfirmation: confirmPassCtrl.text,
                              );
                              setStateModal(() => isLoading = false);
                              if (ctx.mounted) {
                                if (ok) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text('Kata sandi berhasil diperbarui!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  setStateModal(() => errorMsg = auth.errorMessage ?? 'Gagal mengubah kata sandi.');
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Simpan Password Baru', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
