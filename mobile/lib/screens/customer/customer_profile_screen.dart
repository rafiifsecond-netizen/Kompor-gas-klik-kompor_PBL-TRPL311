// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../repositories/profile_repository.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/app_feedback.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});
  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _profileRepository = ProfileRepository();
  late UserModel _profileUser;
  late Map<String, dynamic> _profileStatistics;

  @override
  void initState() {
    super.initState();
    _profileUser = context.read<AuthProvider>().user ??
        UserModel(id: 0, name: 'Dewi Lestari', email: 'dewi@example.com', role: 'customer');
    _profileStatistics = <String, dynamic>{
      'total_orders': 3,
      'completed_orders': 2,
      'reviews': 2,
    };
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileRepository.getCustomerProfile();
      if (!mounted) return;
      setState(() {
        final user = profile['user'];
        if (user is UserModel) _profileUser = user;
        final stats = profile['statistics'];
        if (stats is Map) {
          final s = Map<String, dynamic>.from(stats);
          _profileStatistics = {
            'total_orders': s['total_orders'] ?? s['total'] ?? 3,
            'completed_orders': s['completed_orders'] ?? s['completed'] ?? 2,
            'reviews': s['reviews'] ?? 2,
          };
        }
      });
    } catch (_) {
      // Keep default stats
    }
  }

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
    final user = _profileUser;
    final statistics = _profileStatistics;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('Profil Saya'), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          _buildHeader(user.name, user.email),
          const SizedBox(height: 16),
          _buildCustomerStatistics(statistics),
          const SizedBox(height: 16),

          // ── Section Akun (Edit Profil, Alamat Tersimpan, Ubah Password) ──
          _buildMenuSection('Akun', [
            _buildMenuItem(
              Icons.person_outline_rounded,
              'Edit Profil',
              () => _showEditProfileSheet(context, user.name, user.phone ?? '',
                  user.address ?? '', user),
            ),
            _buildMenuItem(
              Icons.location_on_outlined,
              'Alamat Tersimpan',
              () =>
                  Navigator.pushNamed(context, AppRoutes.customerSelectAddress),
            ),
            _buildMenuItem(
              Icons.lock_outline_rounded,
              'Ubah Password',
              () => _showChangePasswordSheet(context),
            ),
          ]),

          const SizedBox(height: 12),
          _buildMenuSection('Pesanan', [
            _buildMenuItem(
                Icons.receipt_long_rounded,
                'Riwayat Pesanan',
                () => Navigator.pushNamed(
                    context, AppRoutes.customerOrderHistory)),
            _buildMenuItem(Icons.chat_bubble_outline_rounded, 'Pesan',
                () => Navigator.pushNamed(context, AppRoutes.customerChat)),
          ]),

          const SizedBox(height: 12),
          _buildMenuSection('Lainnya', [
            _buildMenuItem(
                Icons.notifications_outlined,
                'Notifikasi',
                () => Navigator.pushNamed(
                    context, AppRoutes.customerNotification)),
            _buildMenuItem(
                Icons.help_outline_rounded,
                'Pusat Bantuan',
                () =>
                    Navigator.pushNamed(context, AppRoutes.customerHelpCenter)),
            _buildMenuItem(
              Icons.info_outline_rounded,
              'Tentang Aplikasi',
              () => showAboutDialog(
                context: context,
                applicationName: 'KlikKompor',
                applicationVersion: 'v1.0.0',
                applicationIcon: const Icon(Icons.local_fire_department_rounded,
                    size: 40, color: AppColors.primary),
                children: [
                  const Text(
                      'KlikKompor adalah platform pemesanan dan manajemen perbaikan kompor gas terpercaya.'),
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
              label: Text('Keluar',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.danger),
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.medium),
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
  Future<bool> _saveProfile({
    required String name,
    required String phone,
    required String address,
    required UserModel currentUser,
  }) async {
    try {
      final updated = await _profileRepository.updateProfile(
        currentUser: currentUser,
        name: name,
        phone: phone,
        address: address,
      );
      if (mounted) setState(() => _profileUser = updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _showEditProfileSheet(BuildContext context, String currentName,
      String currentPhone, String currentAddress, UserModel currentUser) {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);
    final addressCtrl = TextEditingController(text: currentAddress);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Edit Profil Saya',
                            style: GoogleFonts.inter(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameCtrl,
                      validator: (v) => Validators.required(v, label: 'Nama'),
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: const OutlineInputBorder(
                            borderRadius: AppRadius.medium),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtrl,
                      validator: (v) =>
                          Validators.required(v, label: 'Nomor telepon'),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Nomor Telepon (WhatsApp)',
                        border: const OutlineInputBorder(
                            borderRadius: AppRadius.medium),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressCtrl,
                      maxLines: 2,
                      validator: (v) => Validators.required(v, label: 'Alamat'),
                      decoration: InputDecoration(
                        labelText: 'Alamat Lengkap',
                        border: const OutlineInputBorder(
                            borderRadius: AppRadius.medium),
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
                                if (!formKey.currentState!.validate()) {
                                  setStateModal(() => isLoading = false);
                                  return;
                                }
                                final ok = await _saveProfile(
                                  name: nameCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                  address: addressCtrl.text.trim(),
                                  currentUser: currentUser,
                                );
                                setStateModal(() => isLoading = false);
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  if (ok) {
                                    AppFeedback.success(
                                        ctx, 'Profil berhasil diperbarui.');
                                  } else {
                                    AppFeedback.error(
                                        ctx, 'Gagal memperbarui profil.');
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.medium),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text('Simpan Perubahan',
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                      ),
                    ),
                  ],
                ),
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
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        bool isLoading = false;
        String? errorMsg;
        bool obscureCurrent = true;
        bool obscureNew = true;
        bool obscureConfirm = true;

        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ubah Kata Sandi',
                            style: GoogleFonts.inter(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(),
                    if (errorMsg != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(errorMsg!,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.danger)),
                      ),
                      const SizedBox(height: 8),
                    ],
                    TextFormField(
                      controller: currentPassCtrl,
                      obscureText: obscureCurrent,
                      validator: Validators.required,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi Saat Ini',
                        suffixIcon: IconButton(
                          icon: Icon(obscureCurrent
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () => setStateModal(
                              () => obscureCurrent = !obscureCurrent),
                        ),
                        border:
                            OutlineInputBorder(borderRadius: AppRadius.medium),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newPassCtrl,
                      obscureText: obscureNew,
                      validator: Validators.password,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi Baru (min 6 karakter)',
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setStateModal(() => obscureNew = !obscureNew),
                        ),
                        border:
                            OutlineInputBorder(borderRadius: AppRadius.medium),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPassCtrl,
                      obscureText: obscureConfirm,
                      validator: (v) =>
                          Validators.confirmPassword(v, newPassCtrl.text),
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Kata Sandi Baru',
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () => setStateModal(
                              () => obscureConfirm = !obscureConfirm),
                        ),
                        border:
                            OutlineInputBorder(borderRadius: AppRadius.medium),
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
                                  setStateModal(() => errorMsg =
                                      'Kata sandi baru minimal 6 karakter.');
                                  return;
                                }
                                if (!formKey.currentState!.validate()) return;
                                if (newPassCtrl.text != confirmPassCtrl.text) {
                                  setStateModal(() => errorMsg =
                                      'Konfirmasi kata sandi tidak cocok.');
                                  return;
                                }
                                setStateModal(() {
                                  isLoading = true;
                                  errorMsg = null;
                                });
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
                                    AppFeedback.success(
                                        ctx, 'Kata sandi berhasil diperbarui.');
                                  } else {
                                    errorMsg = auth.errorMessage ??
                                        'Gagal mengubah kata sandi.';
                                    AppFeedback.error(ctx, errorMsg!);
                                    setStateModal(() {});
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.medium),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text('Simpan Password Baru',
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                      ),
                    ),
                  ],
                ),
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
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: Color(0xFFFFEFE2)),
          child: const Icon(Icons.person_rounded,
              size: 38, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(email,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.primaryLight, borderRadius: AppRadius.small),
            child: Text('Pelanggan',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
        ]),
      ]),
    );
  }

  Widget _buildCustomerStatistics(Map<String, dynamic> statistics) {
    final totalOrders = statistics['total_orders'] ?? statistics['total'] ?? 3;
    final completed = statistics['completed_orders'] ?? statistics['completed'] ?? 2;
    final reviews = statistics['reviews'] ?? 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatistic('Total Pesanan', totalOrders),
          _buildStatistic('Selesai', completed),
          _buildStatistic('Ulasan', reviews),
        ],
      ),
    );
  }

  Widget _buildStatistic(String label, dynamic value) {
    return Expanded(
      child: Column(
        children: [
          Text('${value ?? 3}',
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(title,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted)),
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
            Expanded(
                child: Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.textMuted),
          ]),
        ),
      ),
    );
  }
}
